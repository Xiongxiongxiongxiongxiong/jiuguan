/**
  * @file       PBRModel.shader
  * @author     Will

	家园建设中给模型使用的Shader.
	1. 支持逐片元的4盏点光源
	2. 不支持烘焙
	3. 支持法线、PBR、落灰效果


  */

Shader "XingFei/PBR Model" {

	Properties {
		_Color("TintColor", Color) = (1,1,1,1)
		_MainTex("DiffuseMap", 2D) = "white" {}
		[Normal] _BumpMap("NormalMap", 2D) = "bump" {}
		[Toggle]_Emission("是否有自发光信息", Float ) = 0 
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,1)
		_ParamTex("Smoothness(R), Metallic(G), AO(B), Emission(A)", 2D) = "blue" {} // R: Smoothness(=1-Roughness), G: Metallic, B: AO
		_EnvMap("CubeMap", Cube) = "_Skybox" {}
		_EnvScale("Env Strength", Range(0.0,5.0)) = 1.0 // environmeng strength
		_IndirectDiffuseScaler("环境光Diffuse强度",Range(1.0,3.0)) = 1.0 // IndirectLightTint / AmbientColor Scaler值

		_MetallicControl("Metallic Control", Range(0.0,1.0)) = 0.5
		_SmoothnessControl("Smoothness Control", Range(0.0,1.0)) = 0.5 // Smoothness=1-Roughness
		_Cutoff("Alpha Cutoff", Range(0.0,1.0)) = 0.5 // alpha test cutoff value
		// attention：场景材质不做卡通渲染处理

		// 用于背包界面等固定光照环境的情况
        [Toggle] _CustomAmbientColorEnable("使用自定义环境光", Float) = 0.0
        _CustomAmbientColor("自定义环境光", Color) = (0.431,0.615, 0.866,1.0)

		_GlassReflectionStrength("Glass Reflection Strength", Range(0.0,3.0)) = 1.0

		// [HideInInspector]
        [HideInInspector]_HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HideInInspector][HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)
        [HideInInspector]_TimeStopHawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.35
        [HideInInspector][HDR]_TimeStopHawkEyeColor("HawkEyeColor", Color) = (0.254902,0.3490196,0.7843138,1)

		[Toggle] _UnderWater("水面以下", Float) = 0.0 // _UNDERWATER_ON
		_WaterLevel("水面高度", Float) = 0.0
		_WaterParams("WaterParams", Vector) = (0,0,0,0)
		_DeepWaterColor("DeepWaterColor", Color) = (0,0,0,1)

        [Toggle] _WaveEffect("WaveEffect", Float) = 0.0 // _WAVEEFFECT_ON
        _WaveSpeed("WaveSpeed", Range(0, 10)) = 1
        _WindStrength("WindStrength", Range(0, 2)) = 1
        _WindDirection("WindDirection", Range(0, 360)) = 0
        _PhaseScale("PhaseScale", Range(0,1)) = 1

		[Toggle] _FallDust("Fall Dust Tex", Float) = 0.0 // _FALLDUST_ON
		_GSTex("FallDustAlbedoTex", 2D) = "white" {}
		[NoScaleOffset]_GSNormal("FallDustNormalTex", 2D) = "bump" {}
		_GSParams ("GS Params", Vector) = (-0.5, 2, 0.2, 0.2) // x: Range y:Soft z:Smoothness w:Metallic
		[Toggle] _IgnoreBaseNormal("忽略基面的法线贴图",Float) = 0.0 // 包边石忽略顶面法线贴图则能更好地与地表融合

		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 2 // Back
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 5 // SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 10 // OneMinusSrcAlpha
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1 // On
		[Enum(Opaque,0,Cutout,1,Fade,2,Transparent,3)] _RenderMode("RenderMode", Float) = 0 // Opaque

		[HideInInspector] _HighlightColor("HighlightColor",Color) = (0,0,0,0)

		_OutlineWidth("OutlineWidth",Float) = 0.1
		_OutlineColor("OutlineColor",Color) = (1,0,0,1)
	}

    CGINCLUDE
    	#include "UtilHeader.cginc"
    ENDCG

// -------------------------------------------------------------------
	SubShader {

		Pass {
			Name "FORWARD_SCENE_MULTI_LIGHTS"
			Tags { "LightMode" = "ForwardBase" } // renderqueue & rendertype在shader编辑器中设置

			Cull [_CullMode]
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]


			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu 
			// todo：去除其他不必要的renderer配置、比如directX

			#pragma multi_compile_fwdbase 
			#pragma multi_compile _ _ALPHATEST_ON 
			#pragma multi_compile _ _ONLY_DIRECTIONAL_LIGHT

			
			// _USE_CUSTOM_HEIGHT_FOG _USE_CUSTOM_DISTANCE_HEIGHT_FOG

			#pragma multi_compile _SHADOW_SOFT_2X2

			#pragma multi_compile _ _PROP_CUBEMAP_ON 


			#pragma skip_variants  DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2    DIRECTIONAL_COOKIE POINT_COOKIE FOG_LINEAR SHADOWS_SHADOWMASK LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH LIGHTMAP_ON 
			// 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有：DIRECTIONAL  VERTEXLIGHT_ON   


			// 因为场景里始终有直射光，所以这个pass( fwdbase )里将点光源和聚光灯的阴影计算skip掉
			#pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH 

			
// point light, spot light 都不投射阴影
			// #pragma skip_variants SHADOWS_SCREEN // 写了这个，就没有directional light realtime shadow了
			// todo: #pragma skip_variants SHADOWS_SOFT

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "UnityGlobalIllumination.cginc"
			#include "PbrHeader.cginc" 

			// Will
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			#include "Lighting.cginc"
			#include "WorkCommon.cginc"
        	#include "WorkPBSLighting.cginc"
			#include "PBRSceneFallDust.cginc"
			#include "UnityStandardUtils.cginc"
			#include "SampleShadowmapHeader.cginc"
			#include "HawkEyeHeader.cginc"



// #if _DIFFUSEMAP
			uniform sampler2D _MainTex;
			uniform HighPrec4 _MainTex_ST;
// #endif // _DIFFUSEMAP
// #if _BUMPMAP
			uniform sampler2D _BumpMap;
			uniform HighPrec4 _BumpMap_ST;
// #endif // _BUMPMAP
// #if _EMISSIVEMAP
// 			uniform sampler2D _EmissionMap;
// #endif // _EMISSIVEMAP
// #if _PARAMTEX
			uniform sampler2D _ParamTex;
// #else
			uniform MidPrec _MetallicControl;
			uniform MidPrec _SmoothnessControl; // 没有指定pbr材质贴图时才使用这两个参数统一调整效果
// #endif // _PARAMTEX
// #if _PROP_CUBEMAP_ON
// 			uniform samplerCUBE _EnvMap;
// #endif // _PROP_CUBEMAP_ON
			uniform MidPrec4 _Color;
			uniform MidPrec4 _EmissionColor;

			uniform LowPrec _Emission; // 是否开启了自发光

			uniform MidPrec _IndirectDiffuseScaler;

			uniform MidPrec4 _HighlightColor; // 用于家园建设的高亮

			// 用于自定义环境光（背包界面等不使用场景中光照的情况）
			uniform LowPrec _CustomAmbientColorEnable;
            uniform MidPrec4 _CustomAmbientColor;

#if _ALPHATEST_ON
			uniform MidPrec _Cutoff; // todo: 支持透贴
#endif 
			// uniform MidPrec _EnvScale; // environment strength

			uniform LowPrec _FallDust;

#if _ALPHAPREMULTIPLY_ON
			uniform MidPrec _GlassReflectionStrength;
#endif // _ALPHAPREMULTIPLY_ON

#if _UNDERWATER_ON
			uniform MidPrec _WaterLevel;
			uniform MidPrec4 _WaterParams;
			uniform MidPrec4 _DeepWaterColor;
#endif

			uniform MidPrec4 _PlayerPosition;


			DECLARE_DISTANCE_FOG_TEXTURE(_DistanceFogTexture);
			DECLARE_DISTANCE_FOG_PARAM1(_DistanceFogParam1);
			DECLARE_DISTANCE_FOG_PARAM2(_DistanceFogParam2);
			DECLARE_SUNFOG_PARAM1(_SunFogParam1);
			DECLARE_HEIGHTFOG_PARAM1(_HeightFogParam1);
			DECLARE_HEIGHTFOG_PARAM2(_HeightFogParam2);

			struct VertexInput {
				HighPrec4 vertex   :       POSITION;
				MidPrec3 nor      :       NORMAL;
				MidPrec4 tangent  :       TANGENT;
				HighPrec4 uv0      :       TEXCOORD0;
				
			};

			struct VertexOutput {
				HighPrec4 pos          :       SV_POSITION;
				HighPrec4 uv0          :       TEXCOORD0;
				HighPrec4 worldPos     :       TEXCOORD1;
				MidPrec3 worldNormal  :       TEXCOORD2;
				MidPrec3 worldTangent :       TEXCOORD3;
				MidPrec3 worldBinormal:       TEXCOORD4;
                UNITY_SHADOW_COORDS(5)
				// UNITY_LIGHTING_COORDS(7,8)
  				// MidPrec3 pointLightColor : TEXCOORD9;
				MidPrec2 uv_GSTex : TEXCOORD6;

#ifndef _ONLY_DIRECTIONAL_LIGHT
				// point lights
				HighPrec4 lightPosX :TEXCOORD7;
				HighPrec4 lightPosY :TEXCOORD8;
				HighPrec4 lightPosZ :TEXCOORD9;
				HighPrec4 lightColor0:TEXCOORD10; // w分量用来给Frag判断是否需要进行点光源计算
				HighPrec3 lightColor1:TEXCOORD11;
				HighPrec3 lightColor2:TEXCOORD12;
				HighPrec3 lightColor3:TEXCOORD13;
				HighPrec4 lightAttenSq:TEXCOORD14;
#endif
			};


// -------------------------------------------------------------------
// 高配 vertex shader
// -------------------------------------------------------------------
			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				// 由于世界位置往往较大，浮点数计算精度不够，z-fighting严重。
                // 于是将模型矩阵和观察矩阵都同时平移主相机世界位置的距离，将相机移到世界空间原点。来避免矩阵中位移项过大的数字。
				HighPrec4x4 modelNew = 0.0f;
                HighPrec4x4 viewNew  = 0.0f;
                AdjustMatrixMVforBigworld( modelNew, viewNew );
                o.pos = mul( UNITY_MATRIX_P, mul( viewNew, mul(modelNew, v.vertex) )); //UnityObjectToClipPos(v.vertex);


				// MidPrec3 n = normalize(mul(v.nor, (MidPrec3x3)unity_WorldToObject)); // worldInverseTranspose
				MidPrec3 n = UnityObjectToWorldNormal(v.nor);

				// transfer UV
				o.uv0.xy = TRANSFORM_TEX(v.uv0.xy, _MainTex); // For MainTex and _EmissionMap, PBRControlmap
				o.uv0.zw = TRANSFORM_TEX(v.uv0.xy, _BumpMap);
				o.worldNormal = n;
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;

#ifndef _ONLY_DIRECTIONAL_LIGHT

			// point lights 参数传到Fragment中计算
            // Approximated illumination from non-important point lights
			// 关键字 VERTEXLIGHT_ON 在不烘焙的物体及附近有Not Important的点光源时才会定义
			o.lightColor0.a = 0.0; // 默认认为没有点光源

            #ifdef VERTEXLIGHT_ON

				o.lightPosX = unity_4LightPosX0;
				o.lightPosY = unity_4LightPosY0;
				o.lightPosZ = unity_4LightPosZ0;
				o.lightColor0.rgb = unity_LightColor[0].rgb;
				o.lightColor1 = unity_LightColor[1].rgb;
				o.lightColor2 =unity_LightColor[2].rgb;
				o.lightColor3 = unity_LightColor[3].rgb;
				o.lightAttenSq = unity_4LightAtten0;

				o.lightColor0.a = 1.0; // 给frag判断是否需要进行点光计算
            #endif
#endif
			TRANSFER_SHADOW(o)

			if(_FallDust > PROPERTY_ZERO){
				TRANSFER_FALL_DUST(v,o)
			}

				return o;
			}

// -------------------------------------------------------------------
// 高配 pixel shader
// -------------------------------------------------------------------
HighPrec4 frag(VertexOutput input, LowPrec facing : VFACE) : SV_Target{


		MidPrec4 baseColor = MidPrec4(0,0,0,1);
		baseColor.rgba = tex2D(_MainTex, input.uv0.xy).rgba * MidPrec4(_Color.rgb,1.0);

#if _ALPHATEST_ON // todo: alpha test
		clip(baseColor.a - _Cutoff);
#endif
		

		// sky light
		MidPrec3 skyLightColor = _LightColor0.rgb;
		MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light has no position
		MidPrec3 viewDir = normalize(_WorldSpaceCameraPos.xyz-input.worldPos.xyz); //normalize(input.eyeVec);

		MidPrec metallic = 0.5;
		MidPrec smoothness = 0.5;
		MidPrec roughness = 0.5;
		MidPrec occlusion = 1.0;
		MidPrec emission = 0.0;
// #if _PARAMTEX
		MidPrec4 pbrControl = tex2D(_ParamTex, input.uv0.xy);
		metallic = pbrControl.g;
		smoothness = pbrControl.r;
		occlusion = pbrControl.b;
// #if _EMISSION_ON
		emission = pbrControl.a * _Emission;
// #endif
// #else
// 				metallic = _MetallicControl;
// 				smoothness = _SmoothnessControl;
// #endif
		// linear space calc  by Will
		// metallic =  SAFE_POW(metallic, 2.2);
		// smoothness =  SAFE_POW(smoothness, 2.2);

		metallic = max(0.001h, min(0.999h, metallic));
		smoothness = max(0.04h, min(0.96h, smoothness)); // 参考x9角色材质
		// roughness = sqrt(1-smoothness); // 处理粗糙度调节感受不是线性变化的问题
		roughness = 1-smoothness;
		roughness *= roughness;
		// smoothness 的取值范围从 [0.02, 0.98] 改到 [0.04, 0.96]，怀疑在 iphoneX 等手机上，smoothness调到最大时，会出现闪白的情况，是
		// 以为超出了 half precision float 的取值范围( roughness = 0.02*0.02，接近 half precision fraction 最小能表示的数量级 ) 导致的

		// 处理接收到的实时阴影
		#if defined(_SHADOW_SOFT_2X2) || defined(_SHADOW_SOFT_POSSION)
			MidPrec atten = Custom_UnitySampleShadowmap(input._ShadowCoord, input.worldPos);
		#else
			UNITY_LIGHT_ATTENUATION(atten, input, input.worldPos)
		#endif

	//------------------------------------------------------------------------
	// new pbr 这个计算是直接使用 WorkPBSLighting.cginc的公式。 它的特点是比旧的公式金属的高光区域更大。但暗部会更暗。

		// some variables for calc
		
		MidPrec3 normalLocal = UnpackNormal(tex2D(_BumpMap, input.uv0.zw)); // convert from (0,1) to (-1,1)

		fixed3 lightDir = normalize(UnityWorldSpaceLightDir(input.worldPos.xyz)); // todo：将点光源加进来
		float3 worldViewDir = normalize(UnityWorldSpaceViewDir(input.worldPos.xyz));
		WorkSurfaceOutputStandard surfOutput = (WorkSurfaceOutputStandard)0;
		surfOutput.Albedo = baseColor.rgb;
// #if _EMISSION_ON 
		surfOutput.Emission = emission * _EmissionColor.rgb;

// #endif
		surfOutput.Alpha = baseColor.a;
		surfOutput.Occlusion = occlusion;
		surfOutput.Normal = normalize(	normalLocal.z * input.worldNormal +
							normalLocal.x * input.worldTangent +
							normalLocal.y * input.worldBinormal );
		surfOutput.NormalTangentSpace = normalLocal;
		surfOutput.Smoothness = smoothness;
		surfOutput.Metallic = metallic;

		// 落灰苔藓落雪效果
		if(_FallDust > PROPERTY_ZERO){
			APPLY_FALL_DUST_EFFECT( input, surfOutput)
		}

		// Setup lighting environment ，以下代码参考surface shader 生成的代码
		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
		gi.light.color = _LightColor0.rgb;
		gi.light.dir = lightDir;
		// Call GI (lightmaps/SH/reflections) lighting function
		UnityGIInput giInput;
		UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
		giInput.light = gi.light;
		giInput.worldPos = input.worldPos.xyz;
		giInput.worldViewDir = worldViewDir;
		giInput.atten = atten;
		giInput.lightmapUV = 0.0;
		giInput.ambient = 0.0;

		giInput.probeHDR[0] = unity_SpecCube0_HDR;
		giInput.probeHDR[1] = unity_SpecCube1_HDR;
		#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
			giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
		#endif
		#ifdef UNITY_SPECCUBE_BOX_PROJECTION
			giInput.boxMax[0] = unity_SpecCube0_BoxMax;
			giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
			giInput.boxMax[1] = unity_SpecCube1_BoxMax;
			giInput.boxMin[1] = unity_SpecCube1_BoxMin;
			giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
		#endif
		//LightingPBRScene_GI( surfOutput, giInput, gi);
		LightingWorkPBS_GI( surfOutput, giInput, gi);
		 
		 // 如果是背包等不使用场景光照的情况，就使用自定义的环境光
		if(_CustomAmbientColorEnable > PROPERTY_ZERO){
			gi.indirect.diffuse = _CustomAmbientColor.rgb;
		}

		// realtime lighting: call lighting function

		// BRDF计算。BRDF2的计算量跟LightingPBRScene的计算量相差不大，但镜面高光会非常亮，需要修改输出时的上限值，没有采取调高bloom阈值的方式来避免过曝，因为bloom阈值调高的话，现在植被等也能泛光的梦幻效果就没了，且角色材质上的bloom也会被减弱不少。
		// 确定为采取BRDF2。这样能够适应更多的材质需求。
		// LightingPBRScene中Spec项只考虑了D项，高光比Unity的BRDF2稍暗。瓷砖效果做不出来。
		// MidPrec4 finalLighting =  LightingPBRScene(surfOutput, worldViewDir, gi); 
		MidPrec4 finalLighting = CalcLightMobileWorkSurface(surfOutput, worldViewDir, gi); 
		

#ifndef _ONLY_DIRECTIONAL_LIGHT
		// point lights 
		// finalLighting.rgb += input.pointLightColor * baseColor.rgb;
		if(input.lightColor0.a > PROPERTY_ZERO ){
			finalLighting.rgb += Shade4PointLights (
                input.lightPosX, input.lightPosY, input.lightPosZ,
                input.lightColor0.rgb, input.lightColor1, input.lightColor2, input.lightColor3,
                input.lightAttenSq, input.worldPos.xyz, surfOutput.Normal.xyz) * baseColor.rgb;
		}
#endif

	// new pbr
	//------------------------------------------------------------------------


// emissive lighting 自发光的计算已经挪到 LightingPBRScene 中了
// 		MidPrec3 emissiveLighting = MidPrec3(0.0,0.0,0.0);
// #if _EMISSIVEMAP 
// 		emissiveLighting = tex2D(_EmissionMap, input.uv0).rgb * _EmissionColor.rgb;
// #else
// 		emissiveLighting = _EmissionColor.rgb;
// #endif
// 		finalLighting.rgb += emissiveLighting;

		// High light 仅用关于幻冥山家园建造  
		// todo: 将这个高亮改成shader_feature,在幻冥山才启用高亮变体，其他不启用该变体。以减少这个加法
		finalLighting.rgb += _HighlightColor.rgb;


if(  _EnableHawkEye > PROPERTY_ZERO ){ // 把 clip 都提前，以优化性能；把 阴阳眼 效果放在所有clip结束之后立马执行
        finalLighting.rgb = HawkEyeColor(finalLighting.rgb, input.worldPos.xyz);
        return MidPrec4( finalLighting.rgb, 1 );
}


				// Fog
                CALC_DISTANCE_FOG_PARAM(input.worldPos.xyz)
                APPLY_DISTANCE_FOG(finalLighting, 1)
				
				return finalLighting;
			}

		ENDCG
		}


		// todo：根据alpha test宏自定义 shadow caster pass

        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_shadowcaster 
			// 测试发现不写这个，也能烘出正确的阴影来（未烘焙时的实时阴影也是正确的）
            #pragma multi_compile _ _ALPHATEST_ON


            #include "UnityCG.cginc"

            // #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH SHADOWS_SCREEN
			#pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH

            uniform sampler2D _MainTex;
            uniform HighPrec4 _MainTex_ST;

#if _ALPHATEST_ON
            uniform MidPrec _Cutoff;
#endif

            struct vertexInput {
                HighPrec4 vertex : POSITION;
                MidPrec3 normal : NORMAL;
                HighPrec4 texcoord : TEXCOORD0;
            };

            struct vertexOutput {
                V2F_SHADOW_CASTER; // 定义了pos等
                HighPrec2 uv : TEXCOORD1;
            };

            vertexOutput vert( vertexInput v ) {
                vertexOutput o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o) // 这个宏里面直接使用了变量v
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            HighPrec4 frag( vertexOutput i ) : SV_Target {
                MidPrec4 texcol = tex2D(_MainTex, i.uv); // 可以乘上_Color.a，但是没必要
#if _ALPHATEST_ON
				 clip( texcol.a - _Cutoff );
#endif
               
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }


	}



	FallBack Off
	CustomEditor "PBRSceneShaderEditor" // custom editor toggle
	
}