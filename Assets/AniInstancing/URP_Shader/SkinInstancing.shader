// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/SkinInstancing" {
	Properties {
		[MainTexture] _BaseMap("Texture", 2D) = "white" {}
		[MainColor]   _BaseColor("Color", Color) = (1, 1, 1, 1)
		[HideInInspector]_boneTextureBlockWidth("_boneTextureBlockWidth", float) = 0
		[HideInInspector]_boneTextureBlockHeight("_boneTextureBlockHeight", float) = 0
		[HideInInspector]_boneTextureWidth("_boneTextureWidth", float) = 0
		[HideInInspector]_boneTextureHeight("_boneTextureHeight", float) = 0
	 
	}
	SubShader {
		Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" }
		LOD 300
		Pass
		{
			// Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
			// no LightMode tag are also rendered by Universal Render Pipeline
			Name "ForwardLit"
			Tags{"LightMode" = "UniversalForward"}

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest Less
			Cull Back

			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 2.0

			// -------------------------------------
			// Universal Pipeline keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
			#pragma shader_feature_local_fragment _EMISSION
			#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature_local_fragment _OCCLUSIONMAP
			#pragma shader_feature_local _PARALLAXMAP
			#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF

			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile_fog
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			
			#pragma vertex SkinVertEx
			#pragma fragment SkinFragment
			
			#include "SkinInput.hlsl"
			
			float4 SkinFragment (Varyings input):SV_Target {
				UNITY_SETUP_INSTANCE_ID(input);
				half4 albedo = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv);
				
				float nl = clamp(dot(input.normal,normalize(_MainLightPosition.xyz)),0.2,1.0); 
				return float4(albedo.xyz*nl,albedo.w);//albedo*nl;
			}
			
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Cull Back

			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex SkinShadowVertexPass
			#pragma fragment SkinShadowPassFragment

			#include "SkinInput.hlsl"
			 
			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0
			Cull Back

			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON

			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
			ENDHLSL
		}
		
	}

	//Fallback "Legacy Shaders/VertexLit"
}
