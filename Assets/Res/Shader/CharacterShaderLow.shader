// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/**
  * @file       CharacterShaderLow.shader
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/10/11
  */

Shader "XingFei/CharacterShaderLow" {
	Properties {
		_Color("MainColor", Color) = (1,1,1,1)
		_DiffuseTex("DiffuseTex", 2D) = "white" {}
		_PbrControlTex("PbrControlMap", 2D) = "white" {} // R: Metallic, G: Smoothness(=1-Roughness), B: 染色blending, A:是否皮肤(皮肤：黑色 / 非皮肤：白色)

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

		Pass {
			Name "FORWARD_CHARACTER_LOW"
			Tags { "LightMode" = "ForwardBase" }

			Cull [_CullMode]
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vertLowBase
				#pragma fragment fragLowBase
				#pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu
				#pragma multi_compile_fwdbase
				//这个作用是用来实现封印时的方向性缩放效果
				 #pragma multi_compile _ _DIRECTED_SCALE
				#pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE LIGHTMAP_ON LIGHTPROBE_SH LIGHTMAP_ON
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有：DIRECTIONAL  
				#pragma multi_compile _ _ALPHATEST_ON
				#pragma multi_compile _NORMALMAP 
				#pragma multi_compile _CUBEMAP
				
				#include "CharacterShaderUtil.cginc"
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