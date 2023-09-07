// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/**
  * @file       CharacterTransparentLow.shader
  * @author     Liuj
  * @date       2021/05/25
  */

Shader "XingFei/CharacterTransparentLow" {
	Properties {
		_Color("MainColor", Color) = (1,1,1,1)
		_DiffuseTex("DiffuseTex", 2D) = "white" {}

		[Toggle]_EnableDyeing("启用染色",Float) = 0.0
        _DyeColor("DyeColor",Color) = (1,1,1,1)
        _DyeColor2("DyeColor2",Color) = (1,1,1,1)

		_ShadowStrength("ShadowStrength", Range(0,1)) = 0.3

		_IndirectLightRatio("环境光的权重",Range(0,1)) = 1.0

		 [Toggle] _CustomAmbientColorEnable("使用自定义环境光", Float) = 0.0
        _CustomAmbientColor("自定义环境光", Color) = (0.6705883,0.6705883, 0.6705883,1.0)

		[Toggle] _AlphaTest("AlphaTest", Float) = 0.0 // _ALPHATEST_ON
		_AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5 // alpha test cutoff value

		[Toggle] _ToonEffect("卡通效果", Float) = 1.0
		_ToonThreshold("卡通明暗分界",Range(-0.5,0.5)) = 0
        _ToonSlopeRange("卡通过渡宽度",Range(0,0.5)) = 0.1
        _ToonBright("ToonBright", Color) = (1.0,1.0,1.0,1)
		_ToonDark("ToonDark", Color) = (0.6,0.6,0.6,1)

		_EmissiveColor("EmissiveColor", Color) = (0,0,0,1)
        [Toggle]_EmissiveMapOn("EmissiveMap On", Float) = 0.0
        _EmissiveTex("EmissiveMap", 2D) = "white" {}

		[Toggle] _StrengthenRimLight("强化效果",Float) = 0.0
        _StrengthenRimStrength("RimStrength", Range(0,60)) = 1
        _StrengthenRimPow("RimPow", Range(0,6)) = 2
        _StrengthenRimRange("RimRange", Range(0,2)) = 2
        _StrengthenRimLightColor("RimColor", Color) = (1,1,0,1)

        [Toggle] _RimEffect("边缘光", Float) = 0.0 // Unity潜规则：对应的selector宏名字是_RIMEFFECT_ON
        _RimStrength("RimStrength", Range(0,60)) = 1
        _RimPow("RimPow", Range(0,6)) = 2
        _RimRange("RimRange", Range(0,2)) = 2
        _RimLightColor("RimColor", Color) = (1,0,0,1)

		_HawkEyeGrayRatio("HawkEyeGrayRatio", Range(0.0, 1.0)) = 0.0
        _HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)

		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 2 // Back
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 1 // One
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 0 // Zero
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1 // On

		[Toggle(_DIRECTED_SCALE)] 
		_DirectedScaleOn("ActivateDirectedScale", Float) = 0.0
		_DirectedScale("DirectedScale", Float) = 1.0
        _DirectedRange("DirectedRange", Float) = 1.0
		_ScaleCenter("DirectedCenter", Vector) = (0, 0, 0, 0)

		// ====================== CharacterFrozenEffect ======================
        [HideInInspector][Toggle]_FrozenEffect("FrozenEffect", Float) = 0.0
        [HideInInspector][Toggle]_PbrControl("PbrControl", Float) = 1.0
		_IceMainColor("IceMainColor", Color) = (0.8, 0.8, 0.8, 1)

        _PbrIceColor("PbrIceColor", Color) = (1, 1, 1, 1)
        _MetallicRatio("MetallicRatio", Range(0, 1)) = 1.0

        [Header(Rim)]
        _IceRimStrength("RimStrength", Range(0,60)) = 2.2
        _IceRimPow("RimPow", Range(0,6)) = 2.47
        _IceRimRange("RimRange", Range(0,2)) = 2
        _IceRimLightColor("RimColor", Color) = (0.6, 0.792, 0.86, 1)

        [Header(Ice)]
        [NoScaleOffset]_IceTex("IceTexture", 2D) = "white"{}
        _IceTexST("IceTexST", Vector) = (3, 3, 0, 0)
        _IceColor1("IceColor1", Color) = (0.66, 0.86, 1, 1)
        _IceColor2("IceColor2", Color) = (1, 1, 1, 1)

        [Header(Specular)]
        _SpecularColor("SpecularColor", Color) = (1, 1, 1, 1)
        _SpecularPower("SpecPower", Range(1, 20)) = 7.5

        // ====================== CharacterFrozenEffect ======================	
	}

	CGINCLUDE
	ENDCG

	SubShader {
		LOD 100

		Tags {  "Queue" = "AlphaTest+47"  } // 设置RenderQueue到这里是为了能够在开启景深效果时写入深度图

		Pass{
            Name "WRITE_DEPTHPASS"
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Offset 2,2 // avoid z fighting

            CGPROGRAM

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "PbrHeader.cginc"
			#include "UtilHeader.cginc"
			
            #pragma vertex vert
            #pragma fragment frag
			
            
            //#pragma only_renderers d3d9 d3d11 glcore gles
            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu
            #pragma target 3.0

            uniform sampler2D _DiffuseTex;
            uniform HighPrec4 _DiffuseTex_ST;

            uniform MidPrec _AlphaCutoff;

            struct VertexInput {
                HighPrec4 vertex : POSITION;
                // HighPrec2 uv : TEXCOORD0;
            };

            struct VertexOutput {
                HighPrec4 pos : SV_POSITION;
                // HighPrec2 uv : TEXCOORD0;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;

                // o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
                // 这个Fresnel效果经常叠在其他材质上使用，所以不特殊处理这两个矩阵的话，会与物体原本材质产生z-fighting.
                // HighPrec4x4 modelNew = 0.0f;
                // HighPrec4x4 viewNew  = 0.0f;
                // AdjustMatrixMVforBigworld( modelNew, viewNew );
                // o.pos = mul(UNITY_MATRIX_P, mul( viewNew, mul( modelNew, v.vertex ) ));
				o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            MidPrec4 frag(VertexOutput i, LowPrec facing : VFACE) : SV_Target {
                // MidPrec4 albedoTexColor = tex2D(_DiffuseTex, i.uv.xy);
                // clip(albedoTexColor.a - _AlphaCutoff); // alpha test的片元需要丢弃，否则该片元遮挡了自身片元,写入depthBuffer（如果有自身遮挡，会导致上一个colorbuffer为背景,blend显示错误）
                return LowPrec4(0,0,0,0); 
            }

            ENDCG
        }


		Pass {
			Name "FORWARD_CHARACTER_LOW"
			Tags { "LightMode" = "ForwardBase" }

			Cull [_CullMode]
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vertLowBase
				#pragma fragment frag
				#pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu
				#pragma multi_compile_fwdbase
				//这个作用是用来实现封印时的方向性缩放效果
				#pragma multi_compile _ _DIRECTED_SCALE

				// 强化效果
            	#pragma multi_compile _ _STRENGTHENRIMLIGHT_ON

				#pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE LIGHTMAP_ON LIGHTPROBE_SH LIGHTMAP_ON
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有：DIRECTIONAL  
				#pragma multi_compile _ _ALPHATEST_ON

				#pragma multi_compile _NORMALMAP 
				#pragma multi_compile _CUBEMAP

				#include "CharacterShaderUtil.cginc"

				MidPrec4 frag(VertexOutputLow input) : SV_Target {

					CharacterLowShadingStruct charParams;
					charParams.input = input;
					if(_FrozenEffect > PROPERTY_ZERO)
					{
						return FragFrozenEffect( charParams );
					}
					
					MidPrec4 albedo = tex2D(_DiffuseTex, input.uv);
					MidPrec4 finalColor = albedo;

					if(_EnableDyeing > PROPERTY_ZERO){
						// 启用染色时，使用更大自由度的Tint方式。这里乘以2，并不影响 _Color反算得到正确的HSV值给到客户端显示滑条值
						albedo.rgb *= lerp( _DyeColor.rgb * 2.0 ,MidPrec3(1,1,1), lerp(0.0,1.0, input.vertexColor.g) );
					}else{
						albedo.rgb *= _Color.rgb;
					}

					MidPrec3 skyLightColor = lerp( _LightColor0.rgb, _CharacterMainLight.rgb * 2.0, _CharacterMainLight.a ); // 乘以2是因为没有intensity的，但有时会需要超过1的光颜色
					MidPrec atten = LIGHT_ATTENUATION(input);
					MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light has no position

					// Toon Effect
					
					MidPrec3 skyLightDiffuse = albedo.rgb * skyLightColor;
					MidPrec3 toonNormal =  input.worldNormal.xyz;
					MidPrec halfLambert = dot(toonNormal, skyLightDir) * 0.5 + 0.5;
					halfLambert *= atten;
					MidPrec toonLambert = smoothstep( _ToonThreshold - _ToonSlopeRange , _ToonThreshold + _ToonSlopeRange, halfLambert - 0.5 );
					MidPrec3 rampValue = lerp( _ToonDark.rgb, _ToonBright.rgb, toonLambert );
					skyLightDiffuse *= rampValue;

					// 计算环境光
					MidPrec3 ambientSkyColor = _CustomAmbientColor.rgb * albedo.rgb;
					finalColor.rgb = skyLightDiffuse + ambientSkyColor;

					MidPrec3 rimLightTotal = MidPrec3(0,0,0);
					MidPrec3 viewDir = normalize(_WorldSpaceCameraPos - input.worldPos).xyz;
					MidPrec3 normal = input.worldNormal;
					MidPrec3 reflecDir = reflect(viewDir, normal); // reflect()之前normal要归一化

					// rim lighting 装备强化后的边缘光
					#if _STRENGTHENRIMLIGHT_ON 
						if(input.vertexColor.g > PROPERTY_ZERO){ // 只有装备，衣服才能强化
							MidPrec backLight = abs(dot(normal, viewDir));
							backLight = saturate(1-backLight*_StrengthenRimRange);
							backLight =  SAFE_POW(backLight, _StrengthenRimPow) * _StrengthenRimStrength;
							MidPrec3 rimLight = backLight * _StrengthenRimLightColor.rgb;
							rimLightTotal = max(rimLight, rimLightTotal);
						}
					#endif

					// rim lighting (silhouette) 常用于选中或者受击等特效
					if(_RimEffect > PROPERTY_ZERO){

						MidPrec backLight = abs(dot(normal, viewDir));
						backLight = saturate(1-backLight*_RimRange);
						backLight =  SAFE_POW(backLight, _RimPow) * _RimStrength;
						MidPrec4 rimLight = backLight * _RimLightColor;
						MidPrec strength = max(0, GetGraylevel(rimLight)-RIM_MAX_STRENGTH);
						rimLight *= RIM_MAX_STRENGTH / (RIM_MAX_STRENGTH+strength); // 保证边缘光亮度不超过MAX_RIM_STRENGTH
						MidPrec rimDistFactor = 1 - saturate(length(input.worldPos.xyz-_WorldSpaceCameraPos)/RIM_MAX_DISTANCE); // 离相机远至一定距离，边缘光强度消失
						rimLight *= rimDistFactor * rimDistFactor;
						MidPrec4 skyRim = saturate(normal.y) * rimLight; // 朝天空方向有，朝地面方向没有
						MidPrec baseSpec = saturate(dot(skyLightDir, reflecDir)); // 法线朝向相机方向的有，法线偏离相机方向的没有
						rimLight *=  SAFE_POW(baseSpec,5);
						MidPrec4 specAndRim = rimLight+skyRim;

						rimLightTotal += specAndRim.rgb;
						// iblSpecular = specAndRim.rgb;
						// rimLightTotal = max(specAndRim.rgb, rimLightTotal.rgb);
					}
					
					// emissive lighting
					MidPrec3 emissiveLighting = MidPrec3(0,0,0);

					if( _EmissiveMapOn > PROPERTY_ZERO){
						emissiveLighting = tex2D(_EmissiveTex, input.uv).rgb + _EmissiveColor.rgb; // 不使用标准自发光处理方式中的"自发光贴图*自发光颜色"做法，把这个自发光颜色用来做角色的“闪白”效果

					}else{
						emissiveLighting = _EmissiveColor.rgb;
					}

					finalColor.rgb += emissiveLighting;	

					finalColor.rgb += rimLightTotal;
						
#if _ALPHATEST_ON
					clip( finalColor.a - _AlphaCutoff );
#endif
					
					finalColor.a = albedo.a * _Color.a;
					
					if(  _EnableHawkEye > PROPERTY_ZERO ){
						finalColor.rgb = HawkEyeCharacter(finalColor.rgb, input.worldPos.xyz);
						return finalColor;
					}

					CALC_DISTANCE_FOG_PARAM(input.worldPos.xyz)
        			APPLY_DISTANCE_FOG(finalColor, 1)

					return finalColor;
				}
			ENDCG
		}

		Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_shadowcaster 
			// 测试发现不写这个，也能烘出正确的阴影来（未烘焙时的实时阴影也是正确的）
            // #pragma multi_compile_instancing
            // #pragma multi_compile _ _ALPHATEST_ON


            #include "UnityCG.cginc"
			#include "UtilHeader.cginc"

            // #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH SHADOWS_SCREEN

            uniform sampler2D _MainTex;
            // uniform HighPrec4 _MainTex_ST;

#if _ALPHATEST_ON
            uniform MidPrec _Cutoff;
#endif

            struct vertexInput {
                HighPrec4 vertex : POSITION;
                MidPrec3 normal : NORMAL;
                HighPrec4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct vertexOutput {
                V2F_SHADOW_CASTER; // 定义了pos等
                // HighPrec2 uv : TEXCOORD1;
            };

            vertexOutput vert( vertexInput v ) {
                vertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o) // 这个宏里面直接使用了变量v
                // o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            HighPrec4 frag( vertexOutput i ) : SV_Target {
//                 MidPrec4 texcol = tex2D(_MainTex, i.uv); // 可以乘上_Color.a，但是没必要
// #if _ALPHATEST_ON
// 				 clip( texcol.a - _Cutoff );
// #endif
               
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }
	}
	FallBack Off
	//Fallback "BuildIn/VertexLit"
}