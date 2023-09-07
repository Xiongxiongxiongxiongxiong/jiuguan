// Amplify Impostors
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>

#ifndef AMPLIFYIMPOSTORS_INCLUDED
#define AMPLIFYIMPOSTORS_INCLUDED

#include "AmplifyImpostorsConfig.cginc"

#if (defined(AI_HD_RENDERPIPELINE) || defined(AI_LW_RENDERPIPELINE)) && !defined(AI_RENDERPIPELINE)
	#define AI_RENDERPIPELINE
#endif

float2 VectortoOctahedron( float3 N )
{
	N /= dot( 1.0, abs(N) );
	if( N.z <= 0 )
	{
		N.xy = ( 1 - abs(N.yx) ) * ( N.xy >= 0 ? 1.0 : -1.0 );
	}
	return N.xy;
}

float2 VectortoHemiOctahedron( float3 N )
{
	N.xy /= dot( 1.0, abs(N) );
	return float2( N.x + N.y, N.x - N.y );
}

float3 OctahedronToVector( float2 Oct )
{
	float3 N = float3( Oct, 1.0 - dot( 1.0, abs(Oct) ) );
	if( N.z < 0 )
	{
		N.xy = ( 1 - abs(N.yx) ) * ( N.xy >= 0 ? 1.0 : -1.0 );
	}
	return normalize(N);
}

float3 HemiOctahedronToVector( float2 Oct )
{
	Oct = float2( Oct.x + Oct.y, Oct.x - Oct.y ) *0.5;
	float3 N = float3( Oct, 1 - dot( 1.0, abs(Oct) ) );
	return normalize(N);
}

sampler2D _Albedo;
sampler2D _Normals;
sampler2D _Emission;

#ifdef AI_RENDERPIPELINE
	TEXTURE2D(_Specular);
	SAMPLER(sampler_Specular);
	SAMPLER(SamplerState_Point_Repeat);
#else
	sampler2D _Specular;
#endif

#if defined(AI_HD_RENDERPIPELINE) && ( AI_HDRP_VERSION >= 50702 )
	TEXTURE2D(_Features);
#endif

#if defined(AI_RENDERPIPELINE) && ( AI_HDRP_VERSION >= 50702 || AI_LWRP_VERSION >= 50702 ) 
CBUFFER_START(UnityPerMaterial)
#endif
float _FramesX;
float _FramesY;
float _Frames;
float _ImpostorSize;
float _Parallax;
float _TextureBias;
float _ClipMask;
float _DepthSize;
float _AI_ShadowBias;
float _AI_ShadowView;
float4 _Offset;
float4 _AI_SizeOffset;
float _EnergyConservingSpecularColor;

#ifdef EFFECT_HUE_VARIATION
	half4 _HueVariation;
#endif
#if defined(AI_RENDERPIPELINE) && ( AI_HDRP_VERSION >= 50702 || AI_LWRP_VERSION >= 50702 ) 
CBUFFER_END
#endif


#ifdef AI_RENDERPIPELINE
	#define AI_SAMPLEBIAS(textureName, samplerName, coord2, bias) SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)
	#define ai_ObjectToWorld GetObjectToWorldMatrix()
	#define ai_WorldToObject GetWorldToObjectMatrix()

	#define AI_INV_TWO_PI  INV_TWO_PI
	#define AI_PI          PI
	#define AI_INV_PI      INV_PI
#else
	#define AI_SAMPLEBIAS(textureName, samplerName, coord2, bias) tex2Dbias( textureName, float4( coord2, 0, bias) )
	#define ai_ObjectToWorld unity_ObjectToWorld
	#define ai_WorldToObject unity_WorldToObject

	#define AI_INV_TWO_PI  UNITY_INV_TWO_PI
	#define AI_PI          UNITY_PI
	#define AI_INV_PI      UNITY_INV_PI
#endif

inline void SphereImpostorVertex( inout float4 vertex, inout float3 normal, inout float4 frameUVs, inout float4 viewPos )
{
	// INPUTS
	float2 uvOffset = _AI_SizeOffset.zw; // (20.8,20.59,0.000775,0.000775)
	float sizeX = _FramesX; // 3
	float sizeY = _FramesY - 1; // adjusted 2
	float UVscale = _ImpostorSize; // 20.87
	float4 fractions = 1 / float4( sizeX, _FramesY, sizeY, UVscale ); // 1/3 1/3 1/2 1/20.87
	float2 sizeFraction = fractions.xy; // 1/3 1/3
	float axisSizeFraction = fractions.z;// 1/2
	float fractionsUVscale = fractions.w;// 1/20.87

	// Basic data
	float3 worldOrigin = 0;
	float4 perspective = float4( 0, 0, 0, 1 );
	// if there is no perspective we offset world origin with a 5000 view dir vector, otherwise we use the original world position
	if( UNITY_MATRIX_P[ 3 ][ 3 ] == 1 )
	{
		perspective = float4( 0, 0, 5000, 0 );
		worldOrigin = ai_ObjectToWorld._m03_m13_m23;
	}
	float3 worldCameraPos = worldOrigin + mul( UNITY_MATRIX_I_V, perspective ).xyz;

	float3 objectCameraPosition = mul( ai_WorldToObject, float4( worldCameraPos, 1 ) ).xyz - _Offset.xyz; //ray origin
	objectCameraPosition.y = 0.0; // 固定Y方向
	float3 objectCameraDirection = normalize( objectCameraPosition ); // 相机方向 == 法线方向

	// Create orthogonal vectors to define the billboard
	float3 upVector = float3( 0,1,0 ); // 向上方向
	float3 objectHorizontalVector = normalize( cross( objectCameraDirection, upVector ) );// 向右方向
	float3 objectVerticalVector = cross( objectHorizontalVector, objectCameraDirection );// 准确的向上方向

	// Create vertical radial angle
	// 通过反正切求相机水平面夹角弧度值[0, 2PI] => (0, 1) => (0.5, sizeX + 0.5)
	float verticalAngle = frac( atan2( -objectCameraDirection.z, -objectCameraDirection.x ) * AI_INV_TWO_PI ) * sizeX * sizeX + 0.5;

	// Create horizontal radial angle
	float verticalDot = dot( objectCameraDirection, upVector );// 相机向量在Y方向的投影[0, 1]
	float upAngle = ( acos( -verticalDot ) * AI_INV_PI ) + axisSizeFraction * 0.5f; // 竖直平面上的夹角[0, PI] => [0, 1] => [0.25, 1.25]
	float yRot = sizeFraction.x * AI_PI * verticalDot * ( 2 * frac( verticalAngle ) - 1 );

	// Billboard rotation
	float2 uvExpansion = vertex.xy;
	// float cosY = cos( yRot );
	// float sinY = sin( yRot );
	// float2 uvRotator = mul( uvExpansion, float2x2( cosY, -sinY, sinY, cosY ) );

	// Billboard
	float3 billboard = objectHorizontalVector * uvExpansion.x + objectVerticalVector * uvExpansion.y + _Offset.xyz;

	// Frame coords
	// imposter贴图为从下往上排列
	float intVerticalAngle = floor( verticalAngle );
	float2 relativeCoords = float2( floor(intVerticalAngle / sizeX),  intVerticalAngle); // 采样贴图位置，例如(0, 0)为贴图左下角第一张
	float2 frameUV = ( ( uvExpansion * fractionsUVscale + 0.5 ) + relativeCoords ) * sizeFraction;

	frameUVs.xy = frameUV - uvOffset;
	
	frameUVs.zw = 0;

	viewPos.w = 0;
	viewPos.xyz = UnityObjectToViewPos( billboard );

	vertex.xyz = billboard;
	normal.xyz = objectCameraDirection;
}

inline void SphereImpostorFragment( inout SurfaceOutputStandardSpecular o, out float4 clipPos, out float3 worldPos, float4 frameUV, float4 viewPos )
{
	#if _USE_PARALLAX_ON
		float4 parallaxSample = tex2Dbias( _Normals, float4( frameUV.xy, 0, -1 ) );
		frameUV.xy = ( ( 0.5 - parallaxSample.a ) * frameUV.zw ) + frameUV.xy;
	#endif

	// albedo alpha
	float4 albedoSample = tex2Dbias( _Albedo, float4( frameUV.xy, 0, _TextureBias) );

	// early clip
	o.Alpha = ( albedoSample.a - _ClipMask );
	clip( o.Alpha );

	#ifdef EFFECT_HUE_VARIATION
		half3 shiftedColor = lerp(albedoSample.rgb, _HueVariation.rgb, viewPos.w);
		half maxBase = max(albedoSample.r, max(albedoSample.g, albedoSample.b));
		half newMaxBase = max(shiftedColor.r, max(shiftedColor.g, shiftedColor.b));
		maxBase /= newMaxBase;
		maxBase = maxBase * 0.5f + 0.5f;
		shiftedColor.rgb *= maxBase;
		albedoSample.rgb = saturate(shiftedColor);
	#endif
	o.Albedo = albedoSample.rgb;
	
	// Specular Smoothness
	float4 specularSample = AI_SAMPLEBIAS( _Specular, sampler_Specular, frameUV.xy, _TextureBias );
	o.Specular = specularSample.rgb;
	o.Smoothness = specularSample.a;

	// Emission Occlusion
	float4 emissionSample = tex2Dbias( _Emission, float4( frameUV.xy, 0, _TextureBias) );
	o.Emission = emissionSample.rgb;
	o.Occlusion = emissionSample.a;

	// Diffusion Features
	#if defined(AI_HD_RENDERPIPELINE) && ( AI_HDRP_VERSION >= 50702 )
	float4 feat1 = _Features.SampleLevel( SamplerState_Point_Repeat, frameUV.xy, 0);
	o.Diffusion = feat1.rgb;
	o.Features = feat1.a;
	float4 test1 = _Specular.SampleLevel( SamplerState_Point_Repeat, frameUV.xy, 0);
	o.MetalTangent = test1.b;
	#endif

	// Normal
	float4 normalSample = tex2Dbias( _Normals, float4( frameUV.xy, 0, _TextureBias) );
	float4 remapNormal = normalSample * 2 - 1; // object normal is remapNormal.rgb
	float3 worldNormal = normalize( mul( (float3x3)ai_ObjectToWorld, remapNormal.xyz ) );
	o.Normal = worldNormal;

	// Depth
	float depth = remapNormal.a * _DepthSize * 0.5 * length( ai_ObjectToWorld[ 2 ].xyz );

	#if !defined(AI_RENDERPIPELINE) // no SRP
		#if defined(SHADOWS_DEPTH)
			if( unity_LightShadowBias.y == 1.0 ) // get only the shadowcaster, this is a hack
			{
				viewPos.z += depth * _AI_ShadowView;
				viewPos.z += -_AI_ShadowBias;
			}
			else // else add offset normally
			{
				viewPos.z += depth;
			}
		#else // else add offset normally
			viewPos.z += depth;
		#endif
	#elif defined(AI_RENDERPIPELINE) // SRP
		#if ( defined(SHADERPASS) && (SHADERPASS == SHADERPASS_SHADOWS) ) || defined(UNITY_PASS_SHADOWCASTER)
			viewPos.z += depth * _AI_ShadowView;
			viewPos.z += -_AI_ShadowBias;
		#else // else add offset normally
			viewPos.z += depth;
		#endif
	#endif

	worldPos = mul( UNITY_MATRIX_I_V, float4( viewPos.xyz, 1 ) ).xyz;
	clipPos = mul( UNITY_MATRIX_P, float4( viewPos.xyz, 1 ) );
	
	#if !defined(AI_RENDERPIPELINE) // no SRP
		#if defined(SHADOWS_DEPTH)
			clipPos = UnityApplyLinearShadowBias( clipPos );
		#endif
	#elif defined(AI_RENDERPIPELINE) // SRP
		#if defined(UNITY_PASS_SHADOWCASTER) && !defined(SHADERPASS)
			#if UNITY_REVERSED_Z
				clipPos.z = min( clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE );
			#else
				clipPos.z = max( clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE );
			#endif
		#endif
	#endif
	
	clipPos.xyz /= clipPos.w;
	
	if( UNITY_NEAR_CLIP_VALUE < 0 )
		clipPos = clipPos * 0.5 + 0.5;
}
#endif //AMPLIFYIMPOSTORS_INCLUDED
