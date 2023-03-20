// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE/UVloop_bloom_Alpha"
{
	Properties
	{
		[HDR]_Tex1_Color("Tex1_Color", Color) = (1,1,1,1)
		_Texture1("Texture1", 2D) = "white" {}
		_Texture2("Texture2", 2D) = "white" {}
		[HDR]_Tex2_Color("Tex2_Color", Color) = (0.990566,0.990566,0.990566,1)
		_tex1_UV("tex1_UV", Vector) = (1,0.3,0,0)
		_tex2_UV("tex2_UV", Vector) = (0.1,1,0,0)
		[Toggle(_USERORA_ON)] _useRorA("use R orA", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _USERORA_ON
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform sampler2D _Texture1;
		uniform float2 _tex1_UV;
		uniform float4 _Tex1_Color;
		uniform sampler2D _Texture2;
		uniform float2 _tex2_UV;
		uniform float4 _Tex2_Color;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 tex2DNode1 = tex2D( _Texture1, ( i.uv_texcoord + ( _Time.y * _tex1_UV ) ) );
			o.Emission = ( ( i.vertexColor * tex2DNode1 * _Tex1_Color ) * ( tex2D( _Texture2, ( i.uv_texcoord + ( _Time.y * _tex2_UV ) ) ) * _Tex2_Color * i.vertexColor ) ).rgb;
			#ifdef _USERORA_ON
				float staticSwitch41 = tex2DNode1.a;
			#else
				float staticSwitch41 = tex2DNode1.r;
			#endif
			o.Alpha = ( i.vertexColor.a * _Tex1_Color.a * staticSwitch41 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
115;399;2008;980;1454.713;45.43652;1.223795;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;28;-1398.245,213.4202;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;27;-1350.952,369.5297;Inherit;False;Property;_tex2_UV;tex2_UV;6;0;Create;True;0;0;0;False;0;False;0.1,1;-5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;5;-1473.24,-226.8811;Inherit;False;Property;_tex1_UV;tex1_UV;5;0;Create;True;0;0;0;False;0;False;1,0.3;-2,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;22;-1434.434,-392.2848;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-1329.38,47.75455;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1116.469,311.985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-1326.961,-566.0581;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1197.013,-278.3865;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-919.4341,197.1216;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-997.8976,-491.8857;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-641.7855,-437.8466;Inherit;True;Property;_Texture1;Texture1;2;0;Create;True;0;0;0;False;0;False;-1;None;d0c09f24ef9477c47a4fafe7afddc70f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-603.9772,265.5891;Inherit;False;Property;_Tex2_Color;Tex2_Color;4;1;[HDR];Create;True;0;0;0;False;0;False;0.990566,0.990566,0.990566,1;3.924528,0.6849413,0.8810959,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;33;-625.2728,533.644;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;42;-245.6645,-117.8346;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-667.3209,45.70686;Inherit;True;Property;_Texture2;Texture2;3;0;Create;True;0;0;0;False;0;False;-1;None;50ebe5dde950cbb4d81f8f4eab98bbfd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;35;-611.3689,-213.177;Inherit;False;Property;_Tex1_Color;Tex1_Color;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;6.422235,6.422235,6.422235,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-262.2668,366.2142;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;41;-42.27285,-445.5875;Inherit;False;Property;_useRorA;use R orA;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-13.48731,-289.1227;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;32.96118,-45.86367;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;193.3801,155.3344;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;39;362,-68;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ASE/UVloop_bloom_Alpha;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;29;0;28;0
WireConnection;29;1;27;0
WireConnection;6;0;22;0
WireConnection;6;1;5;0
WireConnection;30;0;31;0
WireConnection;30;1;29;0
WireConnection;19;0;20;0
WireConnection;19;1;6;0
WireConnection;1;1;19;0
WireConnection;2;1;30;0
WireConnection;24;0;2;0
WireConnection;24;1;23;0
WireConnection;24;2;33;0
WireConnection;41;1;1;1
WireConnection;41;0;1;4
WireConnection;34;0;42;0
WireConnection;34;1;1;0
WireConnection;34;2;35;0
WireConnection;38;0;34;0
WireConnection;38;1;24;0
WireConnection;40;0;42;4
WireConnection;40;1;35;4
WireConnection;40;2;41;0
WireConnection;39;2;38;0
WireConnection;39;9;40;0
ASEEND*/
//CHKSM=0108D0C84DDF40B89592495E1AEBD5FD6CF33339