/**
  * @file       CharacterTransparent.shader
  半透材质使用，因为有PreZ Pass，所以有正确的渲染排序和自遮挡，但是DrawCall增加了。

高配LOD: 600 , 500
PBR + 描边

低配LOD：300
使用 CharacterShaderLow.Shader

  */


Shader "XingFei/CharacterTransparent" {
    Properties {

        _Color("Color", Color) = (1,1,1,1)
        [Toggle]_EnableDyeing("启用染色",Float) = 0.0
        _FaceColor("脸颜色",Color) = (1,0.93,0.91,1)
        _DyeColor("DyeColor",Color) = (1,1,1,1)
        _DyeColor2("DyeColor2",Color) = (1,1,1,1)
        _AddedColor("_AddedColor", Color) = (0,0,0,0)
        _DiffuseTex("DiffuseMap", 2D) = "white" {}
        
        _NormalTex("NormalMap", 2D) = "bump" {}
        _UseNormalTex("启用法线贴图",Float) = 1.0
        [Toggle]_UseObjNormalTex("法线贴图是模型空间的",Float) = 0.0
        _FaceForward("模型在模型空间的正方向",Vector) = (0,-1,0,0)
        _AngleThreshold("光照角度上限",Range(0,180)) = 80
        _FaceBackwardThreshold("背光时整体全暗的阈值",Range(-0.99,-0.6)) = -0.7

        [Toggle]_EnableCustomLightDir("启用自定义主光方向",Float) = 0.0
        _CustomLightDir("自定义主光方向",Vector) = (0,1,-0.7,0)

        [HDR]_EmissiveColor("EmissiveColor", Color) = (0,0,0,1)
        [Toggle]_EmissiveMapOn("EmissiveMap On", Float) = 0.0
        _EmissiveTex("EmissiveMap", 2D) = "white" {}
        [Toggle]_PbrToggle("是否开启Pbr", Float) = 1.0
        _PbrControlTex("PbrControlMap", 2D) = "white" {} // R: Metallic, G: Smoothness(=1-Roughness), B: AO, A:是否皮肤(皮肤：黑色 / 非皮肤：白色)
        _UseEnvCubeTex("使用CubeMap",Float) = 1.0
        _EnvCubeTex("CubeMap", Cube) = "_Skybox" {}
        _EnvCubeLum("替代环境球的亮度",Range(0,1)) = 1.0
        _MetallicControl("Metallic Control", Range(0.0,1.0)) = 0.5
        _SmoothnessControl("Smoothness Control", Range(0.0,1.0)) = 0.5 // Smoothness=1-Roughness
        _AlphaCutoff("Alpha Cutoff", Range(0.0,1.0)) = 0.5 // alpha test cutoff value

        _GlassReflectionStrength("Glass Reflection Strength", Range(0.0,3.0)) = 1.0

        _HawkEyeGrayRatio("HawkEyeGrayRatio", Range(0.0, 1.0)) = 0.0
        _HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)
        // _HawkEyeHue("HawkEyeHue", Range(0, 1)) = 1
        // _HawkEyeSaturation("HawkEyeSaturation", Range(0, 6)) = 1
        // _HawkEyeIntensity("HawkEyeIntensity", Range(0, 20)) = 1

        [Toggle] _ToonEffect("卡通效果", Float) = 0.0 // Unity潜规则：对应的selector宏名字是_TOONEFFECT_ON

        _ToonThreshold("卡通明暗分界",Range(-0.5,0.5)) = -0.063
        _ToonSlopeRange("卡通过渡宽度",Range(0,0.5)) = 0.1
        _ToonDark("ToonDark", Color) = (0.6,0.6,0.6,1)
        _ToonBright("ToonBright", Color) = (1.0,1.0,1.0,1)


        [Toggle] _OutlineEffect("描边效果", Float) = 0.0 // _OUTLINEEFFECT_ON
        [Toggle]_OutlineUseVertexColor("Outline Use VertexColor",Float) = 0.0
        _OutlineLight("OutlineLight", Range(0.0, 1.0)) = 0.5
        _OutlineThreshold("OutlineThreshold", Range(0.0,1.0)) = 0.3
        _OutlineMinThickness("OutlineThickMin", Range(0.0,0.05)) = 0.005
        _OutlineMaxThickness("OutlineThickMax", Range(0.0,0.05)) = 0.009
        _OutlineThickness("OutlineThickness", Range(0.0, 0.02)) = 0.005
        [Toggle]_OutlineExpandWithDistance("随着距离变化描边宽度", Float) = 0
        _OutlineColor("OutlineColor", Color) = (0,0,0,1)
        _BumpStrength("BumpStrength", Range(0,1)) = 1

        // 用于背包界面等固定光照环境的情况
        [Toggle] _CustomAmbientColorEnable("使用自定义环境光", Float) = 0.0
        _CustomAmbientColor("自定义环境光", Color) = (0.431,0.615, 0.866,1.0)

        _SpecLightYOffset("高光光照方向y偏移（0表示就是相机方向，最大值是当前大世界太阳光y偏移值）", Range(-0.5,0.84)) = 0

        // 边缘光
        [Toggle] _SideRimEffect("边缘光", Float) = 0.0
        _SideRimStrength("RimStrength", Range(0,60)) = 1
        _SideRimPow("RimPow", Range(0,6)) = 2
        _SideRimRange("RimRange", Range(0,2)) = 2
        _SideRimLightColor("RimColor", Color) = (1,0,0,1)

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

        [Toggle] _AnisoEffect("各向异性高光", Float) = 0.0 // Unity潜规则：对应的selector宏名字是_ANISOEFFECT_ON
        _UseShiftTexForAnisoSpec("使用Shift噪声贴图扰动各项异性高光",Float) = 0.0
        _AnisoSpecShiftTex("高光偏移噪声",2D) = "black"{}
        _AnisoColor("AnisoColor", Color) = (1,1,1,1)
        _AnisoColor2("第二层高光颜色及强度", Color) = (1,1,1,1)
        _TangentStrength("TangentStrength", Range(0.01,2)) = 1
        _TangentStrength2("TangentStrength2", Range(0.01,2)) = 1
        _BinormalStrength("BinormalStrength", Range(0.01,2)) = 1
        _AnisoSpecPow("AnisoSpecPow", Range(0.01,5)) = 1
        _AnisoBumpStrength("AnisoBumpStrength",Range(0,1)) = 1
        _AnisoSpecColorStrength("AnisoColorStrength", Range(1.0, 10.0)) = 5.0
        _AnisoStrength("_AnisoStrength",Float) = 5.0 // 旧的，要删掉
        _AnisoSpecColor("AnisoSpecColor", Color) = (1,1,1,1)

        [Toggle] _EyeballEffect("眼球高光", Float) = 0.0 // _EYEBALLEFFECT_ON

        _EyeHighlightColor("EyeHighlightColor", Color) = (1,1,1,1)
        _EyeHighlightPow("EyeHighlightPow", Range(0.1,300)) = 1
        _EyeFakePtCenterCoordU("EyeFakePtCenterCoordU", Range(0,1)) = 0
        _EyeFakePtCenterCoordV("EyeFakePtCenterCoordV", Range(0,1)) = 0
        _EyeFakePtRadius("EyeFakePtRadius", Range(0,0.01)) = 0.1

        [Toggle] _HiddenEffect("隐身效果", Float) = 0.0 // _HiddenEffect 用来做隐身效果
        _WholeBlendRatio("WholeBlendRatio", Range(0,1)) = 0.5
        _WholeGrayRatio("WholeGrayRatio", Range(0,1)) = 0.5

        [Toggle] _ColorPostProcess("ColorPostProcess", Float) = 0.0 // _COLORPOSTPROCESS_ON
        _GrayRatio("GrayRatio", Range(0,1)) = 1
        _PostTintColor("PostTintColor", Color) = (1,0,0,1)
        _PostExposure("PostExposure", Range(0,4)) = 1

        [Toggle] _UseEarlyZPass("UseEarlyZPass", Float) = 0.0 // _USEEARLYZPASS_ON

        [Toggle] _High2LowBake("High2LowBake", Float) = 0.0 // _HIGH2LOWBAKE_ON
        _High2LowClipVal("High2LowClipVal", Float) = 1.0

        [Toggle] _DyeSwitch("DyeSwitch", Float) = 0.0 // _DYESWITCH_ON
        [NoScaleOffset]_DyeMaskTex("DyeMaskTex", 2D) = "white" {}
        [HDR]_DyeMaskColor1("DyeMaskColor1", Color) = (1,0,0,1)
        [HDR]_DyeMaskColor2("DyeMaskColor2", Color) = (0,1,0,1)
        [HDR]_DyeMaskColor3("DyeMaskColor3", Color) = (0,0,1,1)
        [HDR]_DyeMaskColor4("DyeMaskColor4", Color) = (1,1,0,1)

        [Toggle] _ScreenClipSwitch("ScreenClipSwitch", Float) = 0.0 // _SCREENCLIPSWITCH_ON
        _ScreenMinX("ScreenMinX", Float) = 0
        _ScreenMinY("ScreenMinY", Float) = 0
        _ScreenMaxX("ScreenMaxX", Float) = 0
        _ScreenMaxY("ScreenMaxY", Float) = 0

        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 2 // Back
        [Enum(UnityEngine.Rendering.CullMode)] _ShadowCullMode ("ShadowCullMode", Float) = 2 // Back
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 5 // SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 10 // OneMinusSrcAlpha
        [Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1 // On
        [Enum(Opaque,0,Cutout,1,Fade,2,Transparent,3)] _RenderMode("RenderMode", Float) = 0 // Opaque
        [Toggle] _CutoutOn("Cutout On", Float) = 0
        [Toggle] _TransparentOn("Transparent On", Float) = 0

        [Header(Offset)]
        _OutlineOffsetFactor("Outline Offset factor",Float) = 10
        _OutlineOffsetUnits("Outline Offset units,",Float) = 10

        [Header(Stencil Properties)]
        _StencilRef("StencilRef", Int) = 1
        _StencilReadMask("StencilReadMask", Int) = 7
        _StencilWriteMask("StencilWriteMask", Int) = 7
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("StencilComp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _PassOp("PassOp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _FailOp("FailOp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _ZFailOp("ZFailOp", Int) = 0

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
        #include "UtilHeader.cginc"
        #include "OutlineHeader.cginc"
        //
        // Hue, Saturation, Value
        // Ranges:
        //  Hue [0.0, 1.0]
        //  Sat [0.0, 1.0]
        //  Lum [0.0, HALF_MAX]
        //
        MidPrec3 RgbToHsv(MidPrec3 c)
        {
            MidPrec4 K = MidPrec4(0.0h, -1.0h / 3.0h, 2.0h / 3.0h, -1.0h);
            MidPrec4 p = lerp(MidPrec4(c.bg, K.wz), MidPrec4(c.gb, K.xy), step(c.b, c.g));
            MidPrec4 q = lerp(MidPrec4(p.xyw, c.r), MidPrec4(c.r, p.yzx), step(p.x, c.r));
            MidPrec d = q.x - min(q.w, q.y);
            MidPrec e = 1.0e-4h;
            return MidPrec3(abs(q.z + (q.w - q.y) / (6.0h * d + e)), d / (q.x + e), q.x);
        }

        MidPrec3 HsvToRgb(MidPrec3 c)
        {
            MidPrec4 K = MidPrec4(1.0h, 2.0h / 3.0h, 1.0h / 3.0h, 3.0h);
            MidPrec3 p = abs(frac(c.xxx + K.xyz) * 6.0h - K.www);
            return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
        }
    ENDCG


//-------------------------------------------------------------------------------------
// CharacterShader Very High

    SubShader {

        Tags {  "Queue" = "AlphaTest+47"  } // 设置RenderQueue到这里是为了能够在开启景深效果时写入深度图

        // SHADER_LOD_VERY_HIGH / SHADER_LOD_HIGH
        LOD 500

        // Guoyi: early z pass (使用跟"ForwardBase"不一样的light mode "Always"，便于在运行时根据需要开关；因为Unity只能通过ight mode来开关shader pass，坑~)
        // 这个pass能够让自身产生遮挡（比如两条腿），但是我们角色实用单mesh多维子材质，然后这个Pass没有办法全部排在角色身体所有颜色Pass之前。于是仍然存在先渲染的身体部分比如内裤会渲染出来，后面再渲染裙子，但内裤颜色很白就很显眼。如果能够拆成多个mesh，通过修改RenderQueue可以让这个写depth的Pass全部先渲染。现在是间隔着渲染，渲染完身体一个部分，再渲染身体另一部分。

        Pass{
            Name "WRITE_DEPTHPASS"
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Offset 2,2 // avoid z fighting

            CGPROGRAM
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
                HighPrec4x4 modelNew = 0.0f;
                HighPrec4x4 viewNew  = 0.0f;
                AdjustMatrixMVforBigworld( modelNew, viewNew );
                o.pos = mul(UNITY_MATRIX_P, mul( viewNew, mul( modelNew, v.vertex ) ));
                return o;
            }

            MidPrec4 frag(VertexOutput i, LowPrec facing : VFACE) : SV_Target {
                // MidPrec4 albedoTexColor = tex2D(_DiffuseTex, i.uv.xy);
                // clip(albedoTexColor.a - _AlphaCutoff); // 小米6, mix2 在预创角的场景下一定情况下会闪退 
                return LowPrec4(0,0,0,0); 
            }

            ENDCG
        }

        Pass {
            Name "FORWARD_CHARACTER_VERY_HIGH"
            Tags { "LightMode" = "ForwardBase" } // // renderqueue & rendertype在shader编辑器中设置

            Cull [_CullMode]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            ZTest LEqual

            // Stencil { // 黑边不用参与bloom，因此上面那个outline pass不用写stencil
            //     Ref 2
            //     WriteMask 7
            //     Comp Always
            //     Pass Replace
            //     Fail Keep
            //     ZFail Keep
            // }

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

            #pragma target 3.0
            #pragma vertex vertHighBase
            #pragma fragment fragVeryHighBase

            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu 
            // todo：去除其他不必要的renderer配置、比如directX

            #pragma multi_compile_fwdbase

            // 强化效果
            #pragma multi_compile _ _STRENGTHENRIMLIGHT_ON

            //_ALPHAPREMULTIPLY_ON 跟角色建模同学确认过这个模式暂时没有使用，为减少关键字先去掉
            // rendermode
            #pragma multi_compile _NORMALMAP 
            // selector: 是否有 normal map
            // By Will： 这里认为也都是设置了Normalmap的，看了下，大部分角色都是有Normalmap的，而目前内存是瓶颈，故为了减少内存，仅编译带Normalmap的变体
            //#pragma multi_compile _ _EMISSIVEMAP 
            // selector: 是否有 emissive map
            #pragma multi_compile _PBRCONTROLMAP 
            // selector: 是否有 pbr control map
            // By Will： 这里认为也都是设置了PBRmap的，看了下，大部分角色都是有PBRlmap的，而目前内存是瓶颈，故为了减少内存，仅编译带PBRlmap的变体

            #pragma multi_compile _CUBEMAP 
            // selector: 是否有 cube map（没有手动设置cubemap时默认使用skybox或者reflection probe, if any） 
            // By Will 注意这里只有认为必定存在_CUBEMAP的情况。因为如果不设置Cubemap，金属性质的东西会很黑，具体计算暂时没有去检查。为减少关键字，先把不设置Cubemap的情况去掉
            
            //_USE_CUSTOM_HEIGHT_FOG _USE_CUSTOM_DISTANCE_HEIGHT_FOG

            // #pragma multi_compile _ _HiddenEffect_ON
            // 隐身效果

            // #pragma multi_compile _ _COLORPOSTPROCESS_ON 
            // 整体颜色变换（用于灰显或者整体变红之类的提示效果）
            
            // #pragma multi_compile _ _DYESWITCH_ON // 角色模型染色 ( 如果染色不需要实时修改，提前在Editor做好就够用，可以改成 shader_feature，省一个 shader variant )
            // #pragma multi_compile _ _SCREENCLIPSWITCH_ON
            // TODO：因为 shader keyword 超了，临时关闭 染色 和 屏幕剔除 这两个 shader keyword，之后考虑把这两个合并一下
            

            #pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE LIGHTMAP_ON LIGHTPROBE_SH
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有：DIRECTIONAL 
            // 角色材质不烘焙，所以可以把 LIGHTMAP_ON 这个宏也去掉
            #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH 
            
// point light, spot light 都不投射阴影

            #include "CharacterShaderUtil.cginc"


            ENDCG
        }

        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            Cull [_ShadowCullMode]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            // #pragma multi_compile_shadowcaster
            // #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            uniform sampler2D _DiffuseTex;
            uniform HighPrec4 _DiffuseTex_ST;
            uniform HighPrec _OutlineEffect; // 是否开启描边，现在即便是高端机，有些角色也可能会关闭描边以提升性能
            uniform HighPrec _OutlineThickness;
            uniform HighPrec _OutlineUseVertexColor;
            uniform LowPrec _CutoutOn;

            
            HighPrec4 Custom_UnityClipSpaceShadowCasterPos(HighPrec4 vertex, HighPrec3 normal, HighPrec4 vertexColor, HighPrec outlineUseVertexColor, HighPrec outlineThickness)
            {

                HighPrec4x4 modelNew = 0.0f;
                HighPrec4x4 viewNew  = 0.0f;
                AdjustMatrixMVforBigworld( modelNew, viewNew );
                return OutlineCalcInViewSpace(modelNew, viewNew, vertex, normal, vertexColor, outlineUseVertexColor, outlineThickness);

            }

            struct vertexInput {
                HighPrec4 vertex : POSITION;
                HighPrec3 normal : NORMAL;
                HighPrec4 color:COLOR;
                HighPrec4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct vertexOutput {
                V2F_SHADOW_CASTER; // 定义了pos等
                HighPrec2 uv : TEXCOORD1;
            };

            vertexOutput vert( vertexInput v ) {
                vertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o) // 这个宏里面直接使用了变量v

                o.uv = TRANSFORM_TEX(v.texcoord, _DiffuseTex);
                return o;
            }

            HighPrec4 frag( vertexOutput i ) : SV_Target {
                MidPrec4 texcol = tex2D(_DiffuseTex, i.uv); // 可以乘上_Color.a，但是没必要

                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }

    } 

// CharacterShader Very High
//-------------------------------------------------------------------------------------


//     // SHADER_LOD_LOW
    SubShader
    {
        LOD 300
        UsePass "XingFei/CharacterTransparentLow/WRITE_DEPTHPASS"
        UsePass "XingFei/CharacterTransparentLow/FORWARD_CHARACTER_LOW"
    }

    //FallBack "BuildIn/VertexLit"
    FallBack Off
    CustomEditor "CharacterShaderEditor" // toggle custom editor
}