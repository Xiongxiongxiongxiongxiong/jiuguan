/**
  * @file       CharacterFrozenEffect.shader 
   角色冰冻状态使用
  */

Shader "XingFei/CharacterFrozenEffect" {
	Properties {
        [HideInInspector]_Color("MainColor", Color) = (1,1,1,1)
		_IceMainColor("IceMainColor", Color) = (0.8, 0.8, 0.8, 1)
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

        [Header(Toon)]
		[Toggle] _ToonEffect("卡通效果", Float) = 1.0
		_ToonThreshold("卡通明暗分界",Range(-0.5,0.5)) = 0
        _ToonSlopeRange("卡通过渡宽度",Range(0,0.5)) = 0.1
        _ToonBright("ToonBright", Color) = (1.0,1.0,1.0,1)
		_ToonDark("ToonDark", Color) = (0.6,0.6,0.6,1)

        [Header(Pbr)]
        [Toggle(_PBRCONTROLMAP)]_PbrControl("PbrControl", Float) = 1.0
        [NoScaleOffset]_PbrControlTex("PbrControlTex", 2D) = "white"{}
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
        [HideInInspector]_FrozenEffectTag("FrozenEffectTag", Float) = 0.0

        // [Header(Normal)]
        // _IceNormal("IceNormal", 2D) = "white"{}
        // _NormalForceX("NormalForceX", range(-1, 1)) = 0
        // _NormalForceY("NormalForceY", range(-1, 1)) = 0

        [Header(Specular)]
        _SpecularColor("SpecularColor", Color) = (1, 1, 1, 1)
        _SpecularPower("SpecPower", Range(1, 20)) = 7.5

        [Space]
		_HawkEyeGrayRatio("HawkEyeGrayRatio", Range(0.0, 1.0)) = 0.0
        _HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)

		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 2 // Back
        // [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 1 // One
        // [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 0 // Zero
		// [Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1 // On

		// [Toggle(_DIRECTED_SCALE)]_DirectedScaleOn("ActivateDirectedScale", Float) = 0.0
		// _DirectedScale("DirectedScale", Float) = 1.0
		// _ScaleCenter("DirectedCenter", Vector) = (0, 0, 0, 0)
	}

	CGINCLUDE
	ENDCG

	SubShader {
		Pass {
			Tags { "LightMode" = "ForwardBase" }

			Cull [_CullMode]
			// Blend [_SrcBlend] [_DstBlend]
			// ZWrite [_ZWrite]

			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				#pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu
				#pragma multi_compile_fwdbase
				//这个作用是用来实现封印时的方向性缩放效果
				//  #pragma multi_compile _ _DIRECTED_SCALE
                #pragma multi_compile _ _PBRCONTROLMAP
				#pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE LIGHTMAP_ON LIGHTPROBE_SH LIGHTMAP_ON
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有：DIRECTIONAL  
				#pragma multi_compile _ _ALPHATEST_ON

				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"
				#include "AutoLight.cginc"
				#include "PbrHeader.cginc"
				#include "UtilHeader.cginc"
                #include "HawkEyeHeader.cginc"

				uniform LowPrec _EnableDyeing;
				uniform MidPrec4 _DyeColor;
    			uniform MidPrec4 _DyeColor2;
				uniform MidPrec4 _IceMainColor;
                uniform MidPrec4 _Color;
				uniform sampler2D _DiffuseTex;
				uniform HighPrec4 _DiffuseTex_ST;
				uniform MidPrec _AlphaCutoff;
				uniform MidPrec _ShadowStrength;
				uniform MidPrec _IndirectLightRatio;

				uniform LowPrec _CustomAmbientColorEnable;
   				uniform MidPrec4 _CustomAmbientColor;

				uniform LowPrec4 _CharacterMainLight; // 角色专用光

				uniform LowPrec _ToonEffect;
				uniform MidPrec _ToonThreshold;
				uniform MidPrec _ToonSlopeRange;
				uniform MidPrec _BumpStrength;
				uniform MidPrec4 _ToonDark;
				uniform MidPrec4 _ToonBright;

                uniform MidPrec _IceRimStrength;
                uniform MidPrec _IceRimPow;
                uniform MidPrec _IceRimRange;
                uniform MidPrec4 _IceRimLightColor;

                uniform sampler2D _IceTex;
                uniform MidPrec4 _IceTexST;
                uniform MidPrec4 _IceColor1;
                uniform MidPrec4 _IceColor2;

                uniform LowPrec _FrozenEffectTag;

                // uniform sampler2D _IceNormal;
                // uniform MidPrec4 _IceNormal_ST;
                // uniform LowPrec _NormalForceX;
                // uniform LowPrec _NormalForceY;

                uniform MidPrec4 _SpecularColor;
                uniform MidPrec _SpecularPower;

#if _PBRCONTROLMAP
                uniform sampler2D _PbrControlTex;
#endif
                uniform MidPrec4 _PbrIceColor;
                uniform LowPrec _MetallicRatio;

				DECLARE_DISTANCE_FOG_TEXTURE(_DistanceFogTexture);
				DECLARE_DISTANCE_FOG_PARAM1(_DistanceFogParam1);
				DECLARE_DISTANCE_FOG_PARAM2(_DistanceFogParam2);
				DECLARE_SUNFOG_PARAM1(_SunFogParam1);
				DECLARE_HEIGHTFOG_PARAM1(_HeightFogParam1);
				DECLARE_HEIGHTFOG_PARAM2(_HeightFogParam2);


				struct VertexInput {
					HighPrec4 vertex 		: POSITION;
					HighPrec2 uv 			: TEXCOORD0;
					MidPrec3 normal 		: NORMAL;
					MidPrec3 vertexColor 	: COLOR;
                    // MidPrec4 tangent        : TANGENT;
				};

				struct VertexOutput {
					HighPrec4 pos 			: SV_POSITION;
					HighPrec4 uv 			: TEXCOORD0;
					MidPrec3 worldPos 		: TEXCOORD1;
					LIGHTING_COORDS(2,3)
					MidPrec3 worldNormal    : TEXCOORD4;
					MidPrec3 vertexColor    : TEXCOORD5;
                    // MidPrec3 worldTangent   : TEXCOORD6;
                    // MidPrec3 worldBinormal  : TEXCOORD7;
                    // HighPrec4 uv1 			: TEXCOORD8;
				};

				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;

#ifdef _DIRECTED_SCALE
					o.pos = mul(UNITY_MATRIX_M, v.vertex);

					HighPrec3 dir = _ScaleCenter - o.pos.xyz;
					HighPrec len = length(dir);

					o.pos.xyz += dir * min(1, (max(0.1, (1 - len)) * _DirectedScale));
					o.worldPos = o.pos.xyz;
					o.pos = mul(UNITY_MATRIX_VP, o.pos);
#else
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
#endif
					o.uv.xy = TRANSFORM_TEX( v.uv, _DiffuseTex );
                    o.uv.zw = v.uv * _IceTexST.xy + _IceTexST.zw;
					o.worldNormal = normalize( UnityObjectToWorldNormal(v.normal));
                    // o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                    // o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
                    // o.uv1.xy = v.uv * _IceNormal_ST.xy + _IceNormal_ST.zw;
					TRANSFER_VERTEX_TO_FRAGMENT(o);

					o.vertexColor = v.vertexColor;
					return o;
				}

				MidPrec4 frag(VertexOutput input) : SV_Target {
					
				MidPrec4 albedo = tex2D(_DiffuseTex, input.uv.xy);
				MidPrec4 finalColor = albedo;

				if(_EnableDyeing > PROPERTY_ZERO){
					// 启用染色时，使用更大自由度的Tint方式。这里乘以2，并不影响 _Color反算得到正确的HSV值给到客户端显示滑条值
					albedo.rgb *= lerp( _DyeColor.rgb * 2.0 ,MidPrec3(1,1,1), lerp(0.0,1.0, input.vertexColor.g) );
				}else{
					albedo.rgb *= _IceMainColor.rgb;
				}

				MidPrec3 skyLightColor = lerp( _LightColor0.rgb, _CharacterMainLight.rgb * 2.0, _CharacterMainLight.a ); // 乘以2是因为没有intensity的，但有时会需要超过1的光颜色
				MidPrec atten = LIGHT_ATTENUATION(input);
                MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light has no position

                //normal
                // MidPrec4 normalColor = tex2D(_IceNormal, input.uv1.xy);
                // MidPrec3 unpackNormal = UnpackNormal(normalColor);
                // MidPrec3 normal = normalize(unpackNormal.z * input.worldNormal + unpackNormal.x * input.worldTangent + unpackNormal.y * input.worldBinormal);

				// Toon Effect
                if(_ToonEffect > PROPERTY_ZERO){

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
                }else{
					// 全局光照
					UnityGI giOutput = UnityGI_Base_RealtimeOrShadowMask( input.uv.xy, skyLightDir.xyz, input.worldPos.xyz, atten, input.worldNormal, skyLightColor );

					MidPrec3 indirectLum = Luminance(giOutput.indirect.diffuse);
					MidPrec3 indirectDiffuse = lerp(indirectLum, giOutput.indirect.diffuse, _IndirectLightRatio);

					MidPrec3 NdotL = saturate(dot(_WorldSpaceLightPos0, input.worldNormal));
					finalColor.rgb =  ( giOutput.light.color * NdotL + indirectDiffuse  ) * albedo.rgb;
				}

                MidPrec3 viewDir = normalize(UnityWorldSpaceViewDir(input.worldPos.xyz));

                // Pbr控制冰霜,金属度越强、平滑度越光滑 冰霜越厚（颜色越白）
                MidPrec metallic = 0.0h;
                MidPrec smoothness = 1.0h;
#if _PBRCONTROLMAP
                HighPrec4 pbrControl = tex2D(_PbrControlTex, input.uv.xy);
                metallic   = pbrControl.r;
                smoothness  = pbrControl.g;
#endif
                finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb + _PbrIceColor.rgb, smoothness * metallic * _MetallicRatio);

                // 冰霜纹理
                MidPrec4 iceCol = tex2D(_IceTex, input.uv.zw);
                finalColor.rgb += iceCol.r * _IceColor1;
                // finalColor.rgb += iceCol.g * _IceColor2;
                finalColor.rgb = lerp(finalColor.rgb + iceCol.g * _IceColor2, finalColor.rgb, iceCol.r);

                // 高光
                MidPrec3 halfDir = normalize(viewDir + skyLightDir);
                // normal.x += _NormalForceX;
                // normal.y += _NormalForceY;
                finalColor.rgb += lerp(0, _SpecularColor * pow(saturate(dot(input.worldNormal, halfDir)), _SpecularPower), iceCol.b) ;
				
                // 边缘光
                MidPrec backLight = abs(dot(input.worldNormal, viewDir));
                backLight = saturate(1 - backLight * _IceRimRange);
                backLight =  SAFE_POW(backLight, _IceRimPow) * _IceRimStrength;
                MidPrec3 rimLight = backLight * _IceRimLightColor.rgb;
                
                finalColor.rgb += rimLight;
                
					
#if _ALPHATEST_ON
					clip( finalColor.a - _AlphaCutoff );
#endif

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