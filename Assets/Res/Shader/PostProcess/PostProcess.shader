/**
  * @file       PostProcess.shader
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/04/26
  */

Shader "XingFei/PostProcess/CombinedEffect" {
	Properties {
		_MainTex("MainTex", 2D) = "white" {}
		_BaseTex("BaseTex", 2D) = "white" {}

		// bloom parameters
		[HideInInspector]_SampleScale("SampleScale", Float) = 0.5
		[HideInInspector]_Threshold("Threshold", Range(0,5)) = 1 // 只保留高于这个阈值的亮度
		[HideInInspector]_BloomIntensity("BloomIntensity", Float) = 1
		[HideInInspector]_CurveX("CurveX", Float) = 0
		[HideInInspector]_CurveY("CurveY", Float) = 0
		[HideInInspector]_CurveZ("CurveZ", Float) = 0

		// [HideInInspector]_ThresholdChar("ThresholdChar", Range(0,5)) = 1 // 只保留高于这个阈值的亮度
		// [HideInInspector]_BloomIntensityChar("BloomIntensityChar", Float) = 1
		// [HideInInspector]_CurveXChar("CurveXChar", Float) = 0
		// [HideInInspector]_CurveYChar("CurveYChar", Float) = 0
		// [HideInInspector]_CurveZChar("CurveZChar", Float) = 0

		// tone mapping parameters
		[HideInInspector]_ToneMapExposure("ToneMapExposure", Float) = 1
		[HideInInspector]_ToneSplitParam("ToneSplitParam", Vector) = (0,0,0,0)
		[HideInInspector]_ToneToeScaleOffset("ToneToeScaleOffset", Vector) = (0,1,0,1) // offset x, offset y, scale x, scale y
		[HideInInspector]_ToneToelnA("ToneToelnA", Float) = 0
		[HideInInspector]_ToneToeB("ToneToeB", Float) = 0
		[HideInInspector]_ToneLinearScaleOffset("ToneLinearScaleOffset", Vector) = (0,1,0,1)
		[HideInInspector]_ToneLinearlnA("ToneLinearlnA", Float) = 0
		[HideInInspector]_ToneLinearB("ToneLinearB", Float) = 0
		[HideInInspector]_ToneShoulderScaleOffset("ToneShoulderScaleOffset", Vector) = (0,1,0,1)
		[HideInInspector]_ToneShoulderlnA("ToneShoulderlnA", Float) = 0
		[HideInInspector]_ToneShoulderB("ToneShoulderB", Float) = 0

		// color grading
		[HideInInspector]_ColorGradeRgbTex("ColorGradeRgbTex", 2D) = "white" {}
		// [HideInInspector]_ColorGradeHue("ColorGradeHue", Float) = 1
		[HideInInspector]_ColorGradeSaturation("ColorGradeSaturation", Float) = 1
		// [HideInInspector]_ColorGradeIntensity("ColorGradeIntensity", Float) = 1

		// fog
		[HideInInspector]_FogColor("FogColor", Color) = (0.5,0.6,0.7,1)
		[HideInInspector]_FogDensity("FogDensity", Range(0.0,1)) = 0.3
		[HideInInspector]_FogAttenuation("FogAttenuation", Range(0.00001,1)) = 1
		[HideInInspector]_FogExcludeSkybox("FogExcludeSkybox", Float) = 1

		// stencil
        [Header(Stencil Properties)]
        _StencilRef("StencilRef", Int) = 1
        _StencilReadMask("StencilReadMask", Int) = 7
        _StencilWriteMask("StencilWriteMask", Int) = 7
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("StencilComp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _PassOp("PassOp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _FailOp("FailOp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _ZFailOp("ZFailOp", Int) = 0

        _BkgGroundColor("BkgGroundColor", Color) = (1,1,1,1)
        _ForeGroundColor("ForeGroundColor", Color) = (1,1,1,1)
        _EyeDepthMin("EyeDepthMin", Float) = 0.3
        _EyeDepthMax("EyeDepthMax", Float) = 100
	}

	CGINCLUDE
        // #define CHECK_COLOR(value) return float4(value.rgb,1);
    	// #define CHECK_VALUE(value) return float4(value,value,value,1);

		#pragma target 3.0
		#include "PostProcessCommon.cginc"
		#include "../UtilHeader.cginc"

		// 这个Shader目前已弃用，但在内存中仍能见到，故先将关键字都删掉
		// #pragma multi_compile _ _BLOOM
		// #pragma multi_compile _ _TONEMAPPING
		// #pragma multi_compile _ _FOG
		// // #pragma multi_compile _ _POSTPROCESSSPLIT
		// #pragma multi_compile _ _COLORGRADE
		// #pragma multi_compile _ _POSTPROCESS_STENCIL

		#pragma skip_variants FOG_EXP FOG_EXP2 VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_TexelSize; // set by unity: Vector4(1/width, 1/height, width, height)

		uniform sampler2D _BaseTex;
		uniform float4 _BaseTex_TexelSize;

		// uniform sampler2D _CharBkgTexture; // 场景、角色后处理效果分开
		// uniform sampler2D _SceneBkgTexture;

		uniform sampler2D _PostStencilTexture;

		uniform float _Threshold;
		uniform float _CurveX;
		uniform float _CurveY;
		uniform float _CurveZ;
		uniform float _SampleScale;
		uniform float _BloomIntensity;

// #if _POSTPROCESSSPLIT
// 		uniform float _ThresholdChar;
// 		uniform float _CurveXChar;
// 		uniform float _CurveYChar;
// 		uniform float _CurveZChar;
// 		uniform float _BloomIntensityChar;
// #endif

#if _TONEMAPPING
		uniform float _ToneMapExposure;
		uniform float4 _ToneSplitParam; // x0, x1, invW
		uniform float4 _ToneToeScaleOffset;
		uniform float4 _ToneLinearScaleOffset;
		uniform float4 _ToneShoulderScaleOffset;
		uniform float _ToneToelnA;
		uniform float _ToneLinearlnA;
		uniform float _ToneShoulderlnA;
		uniform float _ToneToeB;
		uniform float _ToneLinearB;
		uniform float _ToneShoulderB;
#endif

#if _COLORGRADE
		uniform sampler2D _ColorGradeRgbTex;
		// uniform float _ColorGradeHue;
		uniform float _ColorGradeSaturation;
		// uniform float _ColorGradeIntensity;
#endif

#if _FOG
		uniform float4 _FogColor;
		uniform float _FogDensity;
		uniform float _FogAttenuation;
		uniform float _FogHeight;
		uniform float _FogExcludeSkybox;
		// uniform float4x4 _FrustumCornersWS; // frustum corners (far clipping plane, world space)
		uniform float4 _CameraPositionWS; // camera position (world space)
#endif

		uniform float4 _BkgGroundColor;
		uniform float4 _ForeGroundColor;
		uniform float _EyeDepthMin;
		uniform float _EyeDepthMax;

		UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture); // todo: selector

		float ToneMapEval(float src)
		{
#if _TONEMAPPING
			float normVal = src * _ToneSplitParam.z;
			float offsetX, offsetY, scaleX, scaleY, lnA, B;
			if(normVal < _ToneSplitParam.x) { // todo：去掉if else
				offsetX = _ToneToeScaleOffset.x;
				offsetY = _ToneToeScaleOffset.y;
				scaleX = _ToneToeScaleOffset.z;
				scaleY = _ToneToeScaleOffset.w;
				lnA = _ToneToelnA;
				B = _ToneToeB;
			} else if(normVal < _ToneSplitParam.y) {
				offsetX = _ToneLinearScaleOffset.x;
				offsetY = _ToneLinearScaleOffset.y;
				scaleX = _ToneLinearScaleOffset.z;
				scaleY = _ToneLinearScaleOffset.w;
				lnA = _ToneLinearlnA;
				B = _ToneLinearB;
			} else {
				offsetX = _ToneShoulderScaleOffset.x;
				offsetY = _ToneShoulderScaleOffset.y;
				scaleX = _ToneShoulderScaleOffset.z;
				scaleY = _ToneShoulderScaleOffset.w;
				lnA = _ToneShoulderlnA;
				B = _ToneShoulderB;
			}

			normVal = (normVal - offsetX) * scaleX;
			float res = 0;
			if( normVal>0 ) {
				res = exp(lnA + B * log(normVal));
			}
			return res * scaleY + offsetY;
#else
			return src;
#endif
		}

		float GetGraylevel(float3 color)
		{
		    return dot(color, float3(0.2126f, 0.7152f, 0.0722f));
		}

		// bilinear downsample
		half3 DownSampleFilter(sampler2D tex, float2 uv, float2 texelSize)
		{
			float4 d = texelSize.xyxy * float4(-1.0, -1.0, 1.0, 1.0);

			half3 s;
			s = DecodeHDR( tex2D(tex, uv + d.xy) ); // mobile平台上，rendertexture是ldr的，因此hdr bloom的做法是：在rendertexture上存rgbm压缩图像，从texture上读出来时decode一下、转到hdr空间，然后在hdr空间完成计算，然后encode一下，转到ldr空间保存到中间结果rendertexture中
			s += DecodeHDR( tex2D(tex, uv + d.zy) );
			s += DecodeHDR( tex2D(tex, uv + d.xw) );
			s += DecodeHDR( tex2D(tex, uv + d.zw) );

			return s * 0.25;
		}

		// bilinear upsample
		half3 UpSampleFilter(sampler2D tex, float2 uv, float2 texelSize, float sampleScale)
		{
			float4 d = texelSize.xyxy * float4(-1.0, -1.0, 1.0, 1.0) * sampleScale;

			half3 s;
			s = DecodeHDR( tex2D(tex, uv + d.xy) );
			s += DecodeHDR( tex2D(tex, uv + d.zy) );
			s += DecodeHDR( tex2D(tex, uv + d.xw) );
			s += DecodeHDR( tex2D(tex, uv + d.zw) );

			return s * 0.25;
		}

		//
		float4 FragPreFilter(vertOutput input) : SV_Target {
			float2 uv = input.uv;
			half4 s0 = SafeHDR(tex2D(_MainTex, uv)); // todo: auto eye-adaption exposure
			half br = Brightness(s0.rgb); // pixel brightness

// #if _POSTPROCESSSPLIT
// 			float4 sceneMask = tex2D(_SceneBkgTexture, uv);
// 			float4 charMask = tex2D(_CharBkgTexture, uv);

// 			half brScene = br * sceneMask.r * _BloomIntensity;
// 			half brChar = br * charMask.r * _BloomIntensityChar;

// 			half rqScene = clamp(brScene - _CurveX, 0.0, _CurveY);
// 			rqScene = _CurveZ * rqScene * rqScene;

// 			half rqChar = clamp(brChar - _CurveXChar, 0.0, _CurveYChar);
// 			rqChar = _CurveZChar * rqChar * rqChar;

// 			float paramScene = sceneMask.r * max(rqScene, brScene - _Threshold) / max(brScene, 1e-5);
// 			float paramChar = charMask.r * max(rqChar, brChar - _ThresholdChar) / max(brChar, 1e-5);
// 			float param = max(paramScene, paramChar);

// 			s0.rgb *= param;
// #else
			br *= _BloomIntensity;
			half rq = clamp(br - _CurveX, 0.0, _CurveY);
			rq = _CurveZ * rq * rq;
			s0.rgb *= max(rq, br - _Threshold) / max(br, 1e-5);
// #endif

			return EncodeHDR(s0.rgb);
		}

		//
		float4 FragDownSample(vertOutput input) : SV_Target {
			half3 downsampleRes = DownSampleFilter(_MainTex, input.uv, _MainTex_TexelSize.xy);
			return EncodeHDR(downsampleRes);
		}

		//
		float4 FragUpSample(vertOutput input) : SV_Target {
			half3 base = DecodeHDR( tex2D(_BaseTex, input.uv) ); // 之前的处理结果
			half3 blur = UpSampleFilter(_MainTex, input.uv, _MainTex_TexelSize.xy, _SampleScale); // 这一层的upsample结果
			return EncodeHDR(base + blur);
		}

		//
		float4 FragFinalCombine(vertOutput input) : SV_Target {
			half3 color = tex2D(_MainTex, input.uv); // 直接读取source rendertexture，不用DecodeHDR

#if _BLOOM
			half3 bloom = UpSampleFilter(_BaseTex, input.uv, _BaseTex_TexelSize.xy, _SampleScale); //* _BloomIntensity;
			color += bloom;
#endif

#if _TONEMAPPING
			//color.r = ToneMapEval(color.r); // todo：改成只对luminance做一次tone mapping
			//color.g = ToneMapEval(color.g);
			//color.b = ToneMapEval(color.b);
			color.rgb *= _ToneMapExposure;
			float grayLevel = GetGraylevel(color.rgb);
			float newGrayLevel = ToneMapEval(grayLevel);
			color.rgb = color.rgb * newGrayLevel / grayLevel;
#endif


#if _COLORGRADE
			// float3 hsi = RgbToHsi(color.rgb);
			// float3 hsi = RgbToHsv(color.rgb);
			// hsi.r *= _ColorGradeHue;
			// hsi.g *= _ColorGradeSaturation;
			// hsi.b *= _ColorGradeIntensity;
			// color.rgb = HsiToRgb(hsi.rgb);
			// color.rgb = HsvToRgb(hsi.rgb);

			float mappedR = tex2D(_ColorGradeRgbTex, float2(color.r, 0.5/4.0)).r;
			float mappedG = tex2D(_ColorGradeRgbTex, float2(color.g, 1.5/4.0)).r;
			float mappedB = tex2D(_ColorGradeRgbTex, float2(color.b, 2.5/4.0)).r;
			color.rgb = float3(mappedR, mappedG, mappedB);

			// CHECK_VALUE(mappedR)

			float lum = Luminance(color.rgb);
			color.rgb = lerp( float3(lum,lum,lum), color.rgb, _ColorGradeSaturation );
#endif

#if _FOG
			float depth = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, input.uv );
			depth = Linear01Depth(depth);

			fixed isSkybox = depth<0.9999; // todo：后面还是要改成用stencil；或者直接把render target在初始阶段clear depth buffer到1000；现在这个做法，可能会出现某些情况下，非常远处的东西反而不受雾的影响
			isSkybox = lerp( isSkybox, 1, _FogExcludeSkybox);

			// CHECK_VALUE(depth);
			// CHECK_VALUE(isSkybox);

			float4 camDir = depth * input.interpolatedRayWS; // 这个向量的长度 = camera to pixel distance(world space，具体可以分析view frustum的相似三角形)
			// interpolatedRayWS 向量模 = camera to pixel的每个方向，直到far clipping plane的距离(用向量插值，不能直接用距离插值)
			float distanceWS = length(camDir);
			float3 normCamDir = normalize(input.interpolatedRayWS.xyz);

			float Y = _CameraPositionWS.y;
			float vy = normCamDir.y;
			float fogInt = _FogDensity * exp(-_FogAttenuation*(Y+_FogHeight))
				* (1-exp(-_FogAttenuation*vy*distanceWS)) / (_FogAttenuation * vy);
			//CHECK_VALUE(fogInt);
			fogInt = saturate(fogInt);
			color = lerp(color, _FogColor, fogInt*isSkybox);
#endif

			// CHECK_VALUE(mainTexColor.a);

#if _POSTPROCESS_STENCIL
			float4 stencilColor = tex2D(_PostStencilTexture, input.uv);
			float charMask = stencilColor.r;
			float bkgMask = 1 - charMask;

			float depthVal = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, input.uv );
			float eyeDepth = LinearEyeDepth(depthVal);
			// depthVal = Linear01Depth(depthVal);
			// depthVal = 1 - depthVal;
			float grayColor = GetGraylevel(color); // 灰化（包含前景&背景）

			_EyeDepthMin = max( _ProjectionParams.y, _EyeDepthMin );
			_EyeDepthMax = min( max( _EyeDepthMin, _EyeDepthMax ), _ProjectionParams.z );
			float eyeDepthVal = saturate( (eyeDepth - _EyeDepthMin) / (_EyeDepthMax - _EyeDepthMin) );

			// color = grayColor.rrr * bkgMask * _BkgGroundColor.rgb
			// 	+ grayColor.rrr * charMask; // 前景、背景都用 bkg 灰化颜色

			// color = depthVal.r * bkgMask * _BkgGroundColor.rgb
			// 	+ grayColor.rrr * charMask * _ForeGroundColor.rgb; // 背景用z、前景用 bkg 灰化颜色

			// color = depthVal.r * bkgMask * _BkgGroundColor.rgb
			// 	+ depthVal.r * charMask * _ForeGroundColor.rgb; // 前景、背景用 z 值

			color = eyeDepthVal.r * bkgMask * _BkgGroundColor.rgb
				+ eyeDepthVal.r * charMask * _ForeGroundColor.rgb; // 前景、背景用处理过的 z 值
#endif

			return float4(color,1); // todo：现在的输出是HDR，需要用tone mapping转到ldr
		}



	ENDCG

	SubShader {
		ZTest Always
		Cull Off
		ZWrite Off

		Pass { // pass 0, prefilter
			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragPreFilter
			ENDCG
		}

		Pass { // pass 1, downsample
			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragDownSample
			ENDCG
		}

		Pass { // pass 2, upsample
			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragUpSample
			ENDCG
		}

		Pass { // pass 3, final result
			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragFinalCombine
			ENDCG
		}

		Pass { // pass 4, clear render target to (0,0,0,0)
			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragClearToZero
				float4 FragClearToZero(vertOutput input) : SV_Target {
					return float4(0,0,0,0);
				}
			ENDCG
		}

		Pass { // pass 5, stencil mask
            Stencil {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_PassOp]
                Fail [_FailOp]
                ZFail [_ZFailOp]
            }

			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragPostStencil
				float4 FragPostStencil(vertOutput input) : SV_Target {
					return float4(1,0,0,0);
				}
			ENDCG
		}

		Pass{ // pass 6,  Test

			CGPROGRAM

				#pragma vertex VertDefault
				#pragma fragment FragTest
				float4 FragTest(vertOutput input) : SV_Target {
					float4 color = tex2D(_MainTex, input.uv);
					float maxColor = max( color.r , max(color.g, color.b) ) - 1.0;
					return float4(maxColor,maxColor,maxColor,1.0);
				}

			ENDCG

		}

		// Pass { // pass 5, character stencil mask
		// 	Stencil {
		// 		Ref 2
		// 		ReadMask 6
		// 		Comp Equal
		// 		Pass Keep
		// 		Fail Keep
		// 		ZFail Keep
		// 	}
		// 	CGPROGRAM
		// 		#pragma vertex VertDefault
		// 		#pragma fragment FragStencilCharacter
		// 		float4 FragStencilCharacter(vertOutput input) : SV_Target {
		// 			float4 mainC = tex2D(_MainTex, input.uv);
		// 			mainC = step(0, mainC); // 转成 1 or 0 的mask
		// 			return mainC;
		// 		}
		// 	ENDCG
		// }

		// Pass { // pass 6, scene stencil mask
		// 	Stencil {
		// 		Ref 4
		// 		ReadMask 6
		// 		Comp Equal

		// 		// Ref 2
		// 		// ReadMask 6
		// 		// Comp NotEqual // todo：因为大世界地表和地表草的材质没有写stencil的原因，暂时把stencil区分改成 角色\非角色

		// 		Pass Keep
		// 		Fail Keep
		// 		ZFail Keep
		// 	}
		// 	CGPROGRAM
		// 		#pragma vertex VertDefault
		// 		#pragma fragment FragStencilScene
		// 		float4 FragStencilScene(vertOutput input) : SV_Target {
		// 			float4 mainC = tex2D(_MainTex, input.uv);
		// 			mainC = step(0, mainC); // 转成 1 or 0 的mask
		// 			return mainC;
		// 		}
		// 	ENDCG
		// }

		// Pass { // pass 7, stencil test output
		// 	CGPROGRAM
		// 		#pragma vertex VertDefault
		// 		#pragma fragment FragStencilTestOutput
		// 		float4 FragStencilTestOutput(vertOutput input) : SV_Target {
		// 			float4 charC = tex2D(_CharBkgTexture, input.uv);
		// 			float4 sceneC = tex2D(_SceneBkgTexture, input.uv);
		// 			// return charC;
		// 			// return sceneC;
		// 			return charC * float4(1,0,0,1) + sceneC;
		// 		}
		// 	ENDCG
		// }
	}
}