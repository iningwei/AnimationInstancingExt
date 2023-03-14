Shader "My/ovo/ovo_pbr_opaque_z"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset]_BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", float) = 1.0
        
        
		
		
		[NoScaleOffset]
		_MSTTex				("金属度R,闭塞(环境光遮蔽)G,粗糙度B", 2D) = "gray" {}
		[NoScaleOffset]
		_ETex				("自发光贴图",2D)="white"{} 
		_FaceRatioColor		("轮廓光颜色(A轮廓光范围)",Color) = (0,0,0,0)
    	[HDR]_EmissionCol	("自发光颜色", Color) = (0, 0, 0, 0)
    	
    	_OutLightPow		("自发光泛光范围", range(0.5,2)) = 0.5
    }
    SubShader
    {
	    Tags { "RenderType"="Opaque" }
        LOD 100
		
        Pass // 前向渲染 Base Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				
				float4 worldVertex : TEXCOORD1;
            	half3 worldNormal : TEXCOORD2;
            	half3 worldTangent : TEXCOORD3;
            	half3 worldBiTangent : TEXCOORD4;
				
				
                fixed4 t2w_0 : TEXCOORD5;
                fixed4 t2w_1 : TEXCOORD6;
                fixed4 t2w_2 : TEXCOORD7;
                //使用Unity内置宏 声明一个用于对阴影纹理采样的坐标_ShadowCoord，宏后边的(4) 表示可用的插值寄存器的索引值,即 TEXCOORD4
				
				UNITY_FOG_COORDS(8)
                SHADOW_COORDS(9)  // Unity内部定义为 unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Color;
            uniform	sampler2D	_MSTTex;
			uniform	sampler2D	_ETex;
			uniform	fixed4		_FaceRatioColor;
            uniform fixed3		_EmissionCol;
            uniform half		_OutLightPow;
            

            v2f vert (appdata v)
            {
                v2f o;
                //顶点从模型空间到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算UV变换
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //顶点从模型空间到世界空间
                fixed4 worldVertex = mul(unity_ObjectToWorld, v.vertex);
                //法线从模型空间到世界空间
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //切线从模型空间到切线空间
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                //根据 世界空间法线、世界空间切线、切线方向 计算世界空间副切线 
                fixed3 worldBiTangent = cross(worldNormal,worldTangent) * v.tangent.w;
				
				 

                //将 切线空间到世界空间的转换矩阵写入插值器，为了尽可能的利用插值器，把三个插值器的w分量存储世界空间顶点
                o.t2w_0 = float4(worldTangent.x,worldBiTangent.x,worldNormal.x, worldVertex.x);
                o.t2w_1 = float4(worldTangent.y,worldBiTangent.y,worldNormal.y, worldVertex.y);
                o.t2w_2 = float4(worldTangent.z,worldBiTangent.z,worldNormal.z, worldVertex.z);



				
				o.worldVertex =worldVertex;
				o.worldNormal =worldNormal;
				o.worldTangent = worldTangent;
				o.worldBiTangent = worldBiTangent;
				
				
				 UNITY_TRANSFER_FOG(o,o.pos);

                //使用Unity内置宏，传递阴影坐标到像素着色器
                /*
                 *由于内置宏 TRANSFER_SHADOW 中会使用上下文变量来进行相关计算
                 *此处 顶点着色器（vert）的输入结构体 appdata 必须命名为v，且输入结构体 appdata 内的顶点坐标必须命名为 vertex
                 *输出结构体 v2f 的顶点坐标必须命名为 pos 
                 */
                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //_MainTex 贴图采样，并于颜色参数混合
                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
                //计算环境光和模型颜色的混合
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

                //世界空间顶点
                fixed3 worldVector = fixed3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w);
                //计算世界空间光照方向
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldVector));

                /*-----------------------------------法线计算---------------------------------*/
                //获取  切线空间到世界空间的转换矩阵
                fixed3x3 tangentToWorld = fixed3x3(i.t2w_0.xyz, i.t2w_1.xyz, i.t2w_2.xyz);
                //采样切线空间法线贴图
                fixed4 bump = tex2D(_BumpMap, i.uv);
                //获取切线空间法线
                fixed3 tangentSpeaceNormal = UnpackNormalWithScale(bump,_BumpScale);
                //切线空间法线 转换到 世界空间
                fixed3 worldNormal = normalize(mul(tangentToWorld, tangentSpeaceNormal)); 

                /*-----------------------------------漫反射计算---------------------------------*/
                /*Lambert模型*/
                fixed3 diffuse = albedo.rgb * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));
                
                  

               /*--------------------------------------------------------*/
			   half3 lDirWS = _WorldSpaceLightPos0.xyz;
            	half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.worldVertex.xyz);
            	half3 lrDirWS = normalize(reflect(-lDirWS, worldNormal));
               fixed4 var_MroTex  = tex2D(_MSTTex , i.uv);			//金属度，闭塞，粗糙度	 
                fixed2 var_EmitTex = tex2D(_ETex,i.uv).rg;				//采样自发光
                //准备点积结果
            	half lrdirv = max(0.0,dot(lrDirWS, vDirWS));	//blinn-phong
				lrdirv = pow(lrdirv, (1-var_MroTex.b) * 50 + 1)*var_MroTex.r; //调节高光范围与强度
				half ndotv =  max(0.0, dot(worldNormal, vDirWS));		//Fresnel
				half ndotl = max(0.0,dot(worldNormal, lDirWS));		//lambert

				//菲尼尔 渐变
				fixed UpRatio =pow( saturate( dot(worldNormal, float3(0, 1, 0))+1),2);	//顶底关系
				fixed fresnel = ( 1 -ndotv) * UpRatio;								//菲尼尔
				fixed gradient = saturate(pow(ndotv,5)*4*(1-var_MroTex.b*2) + (var_MroTex.b)*0.4);		//菲尼尔渐变提高立体感

			 
				fixed  diffInt = var_MroTex.b * 1.2 + 0.2;						//漫反射强度
				fixed3 LightCol = _LightColor0.rgb;			//光颜色
            	
            	
            	fixed3 hightLight = saturate(lrdirv * 2)*_LightColor0.rgb*(albedo+0.5);  //高光
            	fixed3 rimLight = pow(fresnel,(1-var_MroTex.b) + 2) * _FaceRatioColor.rgb * (ndotv + _FaceRatioColor.a)*(albedo+0.5); //轮廓光
				fixed3 envSpec = (1 - var_MroTex.b) * albedo * saturate( fresnel + _FaceRatioColor.a); //反射
            	
				//光照模型（自发光） 
            	fixed  outLight = pow(var_EmitTex.g ,   _OutLightPow);
				fixed3 emission = (outLight + var_EmitTex.r) * _EmissionCol;
				
				
				
                
                //计算光照衰减和阴影(包含了阴影衰减，故无需再单独使用 SHADOW_ATTENUATION 内置宏来计算阴影)
                 UNITY_LIGHT_ATTENUATION(atten, i, worldVector);
                //fixed shadow = SHADOW_ATTENUATION(i);
                
				
				fixed3 envDiff = saturate(atten + var_MroTex.g * ambient)  ;   //阴影 AO 环境光  
				
				fixed3 finalRGB=(ambient  + diffuse ) * envDiff + envSpec*0.7 + rimLight + hightLight + emission;
				
				 UNITY_APPLY_FOG(i.fogCoord, finalRGB);			     // apply fog
				  
                fixed4 col = fixed4(finalRGB, 1.0);                
                return col;
            }
            ENDCG
        }
        
		 
        // 此ShadowCaster Pass是用来更新阴影映射纹理, 使其它物体可以接受到他的阴影
        // 即 此Pass将对象渲染为阴影投射器
        Pass
        {
            Tags{ "LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            
            ENDCG
        }
    }
    //FallBack "Specular"
}