// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

#ifndef SKIN_INPUT_BASE
	#define SKIN_INPUT_BASE

	//#pragma target 3.0
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
	CBUFFER_START(UnityPerMaterial)
	uint _boneTextureBlockWidth;
	uint _boneTextureBlockHeight;
	uint _boneTextureWidth;
	uint _boneTextureHeight;
	float _Cutoff;
	half4 _BaseColor;
	CBUFFER_END

	TEXTURE2D(_boneTexture);            SAMPLER(sampler_boneTexture);
	struct Attributes
	{
		float4 vertex           : POSITION;
		float3 normal           : NORMAL;
		float3 tangent          : TANGENT;
		float4 color            : COLOR;
		float2 uv               : TEXCOORD0;
		float4 bone             : TEXCOORD1;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct Varyings
	{
		float2 uv        : TEXCOORD0;
		float fogCoord   : TEXCOORD1;
		float3 normal    : TEXCOORD2;
		float3 tangent   : TEXCOORD3;
		float4 testColor : TEXCOORD4;
		float4 vertex    : SV_POSITION;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};
	#if (SHADER_TARGET < 30 || SHADER_API_GLES)
		uniform float frameIndex;
		uniform float preFrameIndex;
		uniform float transitionProgress;
	#else
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(float, preFrameIndex)
		#define preFrameIndex_arr Props
		UNITY_DEFINE_INSTANCED_PROP(float, frameIndex)
		#define frameIndex_arr Props
		UNITY_DEFINE_INSTANCED_PROP(float, transitionProgress)
		#define transitionProgress_arr Props
		UNITY_INSTANCING_BUFFER_END(Props)
	#endif

	half4x4 loadMatFromTexture(uint frameIndex, uint boneIndex)
	{
		uint blockCount = _boneTextureWidth / _boneTextureBlockWidth;
		int2 uv;
		uv.y = frameIndex / blockCount * _boneTextureBlockHeight;
		uv.x = _boneTextureBlockWidth * (frameIndex - _boneTextureWidth / _boneTextureBlockWidth * uv.y);

		int matCount = _boneTextureBlockWidth / 4;
		uv.x = uv.x + (boneIndex % matCount) * 4;
		uv.y = uv.y + boneIndex / matCount;

		float2 uvFrame;
		uvFrame.x = uv.x / (float)_boneTextureWidth;
		uvFrame.y = uv.y / (float)_boneTextureHeight;
		
		float offset = 1.0f / (float)_boneTextureWidth;//(textureName, samplerName, coord2, lod)   
		half4 c1 = SAMPLE_TEXTURE2D_LOD(_boneTexture,sampler_boneTexture, uvFrame,0);
		uvFrame.x = uvFrame.x + offset;
		half4 c2 = SAMPLE_TEXTURE2D_LOD(_boneTexture,sampler_boneTexture, uvFrame,0);
		uvFrame.x = uvFrame.x + offset;
		half4 c3 = SAMPLE_TEXTURE2D_LOD(_boneTexture,sampler_boneTexture, uvFrame,0);
		uvFrame.x = uvFrame.x + offset;
		
		half4 c4 = half4(0, 0, 0, 1);
		half4x4 m;
		
		m._11_21_31_41 = c1;
		m._12_22_32_42 = c2;
		m._13_23_33_43 = c3;
		m._14_24_34_44 = c4;
		return m;
	}
	
	
	half4x4 QuaternionToMatrix(float4 quat) // convert quaterinion rotation to mat, zeros out the translation component.
	{

		float xx = quat[0]*quat[0];
		float yy = quat[1]*quat[1];
		float zz = quat[2]*quat[2];
		float xy = quat[0]*quat[1];
		float xz = quat[0]*quat[2];
		float yz = quat[1]*quat[2];
		float wx = quat[3]*quat[0];
		float wy = quat[3]*quat[1];
		float wz = quat[3]*quat[2];
		float4x4 mat;
		mat[0][0]  = 1 - 2 * ( yy + zz );
		mat[1][0]  =     2 * ( xy - wz );
		mat[2][0]  =     2 * ( xz + wy );

		mat[0][1] =     2 * ( xy + wz );
		mat[1][1] = 1 - 2 * ( xx + zz );
		mat[2][1] =     2 * ( yz - wx );

		mat[0][2] =     2 * ( xz - wy );
		mat[1][2] =     2 * ( yz + wx );
		mat[2][2] = 1 - 2 * ( xx + yy );

		mat[3][0] = mat[3][1] = mat[3][2] =  0.0f;
		mat[0][3] = mat[1][3] = mat[2][3] =  0.0f;
		mat[3][3] = 1.0f;
		
		return mat;
	}

	float4 QuatSlerp(float4 Quat1, float4 Quat2, float Slerp)
	{
		const float RawCosom = dot(Quat1, Quat2);
		const float Cosom = abs(RawCosom);
		
		float Scale0, Scale1;
		if (Cosom < 0.9999f)
		{
			const float Omega = acos(Cosom);
			const float InvSin = 1.f / sin(Omega);
			Scale0 = sin((1.f - Slerp) * Omega) * InvSin;
			Scale1 = sin(Slerp * Omega) * InvSin;
		}
		else
		{
			Scale0 = 1.0f - Slerp;
			Scale1 = Slerp;
		}

		// In keeping with our flipped Cosom:
		Scale1 = RawCosom >= 0.0f ? Scale1 : -Scale1;

		return (Scale0 * Quat1) + (Scale1 * Quat2);
	}

	half4x4 TransformToMatrix(float4 trans){
		return half4x4(
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		trans.x,trans.y,trans.z,1
		);
	}

	half4x4 LerpMatrix(in half4x4 pre,in half4x4 next,in half4x4 preAni,float t,float t1){
		float4 transLerp = lerp(pre._12_22_32_42,next._12_22_32_42,t);
		float4 rotSlep = QuatSlerp(pre._11_21_31_41,next._11_21_31_41,t);
		transLerp = lerp(preAni._12_22_32_42,transLerp,t1);
		rotSlep = QuatSlerp(preAni._11_21_31_41,rotSlep,t1);
		return mul(QuaternionToMatrix(rotSlep),TransformToMatrix(transLerp));
	}

	half4x4 GetSkinedLocalPos(Attributes input){
		half4 w = input.color;
		half4 bone = half4(input.bone.x, input.bone.y, input.bone.z, input.bone.w);
		#if (SHADER_TARGET < 30 || SHADER_API_GLES)
			float curFrame = frameIndex;
			float preAniFrame = preFrameIndex;
			float progress = transitionProgress;
		#else
			float curFrame = UNITY_ACCESS_INSTANCED_PROP(frameIndex_arr, frameIndex);
			float preAniFrame = UNITY_ACCESS_INSTANCED_PROP(preFrameIndex_arr, preFrameIndex);
			float progress = UNITY_ACCESS_INSTANCED_PROP(transitionProgress_arr, transitionProgress);
		#endif
		
		int preFrame = curFrame;
		int nextFrame = curFrame + 1.0f;
		
		half4x4 rstPreFrame1 = loadMatFromTexture(preFrame, bone.x) ;
		half4x4 rstPreFrame2 = loadMatFromTexture(preFrame, bone.y) ;
		half4x4 rstPreFrame3 = loadMatFromTexture(preFrame, bone.z) ;
		half4x4 rstPreFrame4 = loadMatFromTexture(preFrame, bone.w) ;

		half4x4 rstNextFrame1 = loadMatFromTexture(nextFrame, bone.x) ;
		half4x4 rstNextFrame2 = loadMatFromTexture(nextFrame, bone.y) ;
		half4x4 rstNextFrame3 = loadMatFromTexture(nextFrame, bone.z) ;
		half4x4 rstNextFrame4 = loadMatFromTexture(nextFrame, bone.w) ;

		half4x4 rstPreAnimFrame1 = loadMatFromTexture(preAniFrame, bone.x);
		half4x4 rstPreAnimFrame2 = loadMatFromTexture(preAniFrame, bone.y);
		half4x4 rstPreAnimFrame3 = loadMatFromTexture(preAniFrame, bone.z);
		half4x4 rstPreAnimFrame4 = loadMatFromTexture(preAniFrame, bone.w);

		half4x4 lerpedCurAnim1 = LerpMatrix(rstPreFrame1,rstNextFrame1,rstPreAnimFrame1,(curFrame-preFrame),progress); 
		half4x4 lerpedCurAnim2 = LerpMatrix(rstPreFrame2,rstNextFrame2,rstPreAnimFrame2,(curFrame-preFrame),progress); 
		half4x4 lerpedCurAnim3 = LerpMatrix(rstPreFrame3,rstNextFrame3,rstPreAnimFrame3,(curFrame-preFrame),progress); 
		half4x4 lerpedCurAnim4 = LerpMatrix(rstPreFrame4,rstNextFrame4,rstPreAnimFrame4,(curFrame-preFrame),progress); 

		half4x4 aniMatrix =  lerpedCurAnim1*w.x+lerpedCurAnim2*w.y+lerpedCurAnim3*w.z+lerpedCurAnim4*w.w;
		return aniMatrix;
	}

	Varyings SkinVertEx(Attributes input)
	{
		Varyings output = (Varyings)0;
		UNITY_SETUP_INSTANCE_ID(input);
		UNITY_TRANSFER_INSTANCE_ID(input, output);
		// w refers weight
		half4x4 aniMatrix = GetSkinedLocalPos(input);
		half4 localPos = mul(input.vertex,aniMatrix);
		output.tangent.xyz = normalize(mul(input.tangent,aniMatrix));
		output.normal = normalize(mul(input.normal,aniMatrix));
		output.normal = TransformObjectToWorldNormal(output.normal);
		output.vertex = TransformObjectToHClip(localPos.xyz);
		output.uv = input.uv;
		return output;
	}

	Varyings SkinShadowVertexPass(Attributes input)
	{
		Varyings output = (Varyings)0;
		UNITY_SETUP_INSTANCE_ID(input);
		UNITY_TRANSFER_INSTANCE_ID(input, output);
		// w refers weight
		half4x4 aniMatrix = GetSkinedLocalPos(input);
		half4 localPos = mul(input.vertex,aniMatrix);
		
		output.tangent.xyz = normalize(mul(input.tangent,aniMatrix));
		output.normal = normalize(mul(input.normal,aniMatrix));
		output.normal = TransformObjectToWorldNormal(output.normal);
		output.uv = input.uv;
		//shadow stuff
		float3 positionWS = mul(UNITY_MATRIX_M,float4(localPos.xyz,1.0)).xyz;
		float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, output.normal, normalize(_MainLightPosition.xyz)));

		#if UNITY_REVERSED_Z
			positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
		#else
			positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
		#endif

		output.vertex = positionCS;
		
		return output;
	}

	half4 SkinShadowPassFragment(Varyings input) : SV_TARGET
	{
		Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
		return 0;
	}

#endif