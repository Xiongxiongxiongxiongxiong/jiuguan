/**
  * @file       VertexLitLeaf.shader
  * @brief      带法线&镂空阴影的植被材质（树叶、草）
  * @comment    1. 在 distanceShadowMask的模式下，近处使用实时阴影，远处用顶点色。否则就仅使用顶点色。
                2. 支持烘焙
                3. 支持片元计算的点光源
  */

Shader "XingFei/Scene/VertexLitLeaf" {
    Properties {

        [Header(MainTex and Color)]        
        [Space]

        _MainTex ("DiffuseTex", 2D) = "white" {}
        [Toggle]_PBRShadingGI("使用PBR的全局光照计算方式，更好地支持昼夜变化",Float) = 0.0
        _TintColor ("亮部颜色,a越大，亮部越接近本颜色", Color) = (1,1,1,0.5)

        //[Toggle]_UseVertexLit("使用顶点法线增加明暗",Float) = 0.0
        _IndirectColorAdjust("暗部颜色Tint，a越大，暗部越接近本颜色",Color) = (1.0,1.0,1.0,0.0)

        
    
        //  _AdjustForNotBaked("烘焙间接光权重(先调让亮部对)",Range(0,1)) = 0.0
        //  _BrightRange("亮部区域(再调)",Range(1.0,0.0)) = 1.0
        // _ShadowColor("暗部颜色(后调)", Color) = (0.5,0.5,0.5,1.0)
        // _ShadowColorBrighten("阴影色明度(后调)",Range(0,10)) = 1.0

       
        // [HideInInspector]_LightmapAtten_BlackLevel("光照贴图色阶下限",Range(0,1)) = 0.0
 
        [Header(SSS)]
        [Space]
        _BackSubsurfaceDistortion("BackSubsurfaceDistortion", Range(0,1)) = 0.5
        _SSS_Strength("SSS Strength", Range(0,1)) = 1.0

        // [Header(Vetex Color)]
        // [Space]

        // _vertexColorR_Ratio("顶点色权重",Range(0,1)) = 1.0
        // _vertexColorR_WhiteLevel("顶点色色阶输入上限",Range(0,1)) = 1.0
        // _vertexColorR_BlackLevel("顶点色色阶输入下限",Range(0,1)) = 0.0

        // [Header(Shadow Mode)]
        // [Space]
        // [Toggle(_SHADOW_HEIGHT_MANNUALLY)] _Enable_ShadowHeightMannually("手动设置遮蔽处阴影的高度?", Int) = 0
		// _Shadow_Manually_ShadowFacePointY("遮蔽处阴影的基准高度", Range(-20,100) ) = 1.0
        // _Shadow_Manually_ShadowLum("遮蔽处阴影的明度值", Range(0,1) ) = 0.3

        // [Toggle(_SHADOW_REALTIME)] _Enable_ReatimeShadow("启用实时阴影?", Int) = 0  // 启用这个之后，光照将逐像素计算，不启用，又不烘焙的话，则是逐顶点计算光照

        [Header(Emission)]
        [space]
        [Toggle]_EnableEmissive("启用自发光",Int) = 0
        _EmissionColor("EmissionColor", Color) = (0,0,0)
        _EmissionMap("EmissionMap", 2D) = "white" {}


        [Header(Leaf about)]
        [Space]

        // _Angle ("Angle", Range(-10,10) ) = 0
        _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
        // _MinLightness("MinLightness", Range(0,1)) = 0.2

        // [Space]
        // [Toggle] _BakeShadowToon("ToggleBakeShadowToonEffect", Float) = 1.0 // _BAKESHADOWTOON_ON
        // _BakeShadowToonThre("   BakeShadowToonThre", Range(0.0, 1.0)) = 0.5
        // _BakeShadowToonLow("   BakeShadowToonLow", Range(0.0, 1.0)) = 0.3
        // _BakeShadowToonHigh("   BakeShadowToonHigh", Range(0.0, 1.0)) = 1

        [HideInInspector]_HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HideInInspector][HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)
        [HideInInspector]_TimeStopHawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.35
        [HideInInspector][HDR]_TimeStopHawkEyeColor("HawkEyeColor", Color) = (0.254902,0.3490196,0.7843138,1)

        // [Space]
        // [Toggle] _VanishEffect("ToggleVanishEffect", Float) = 0.0 // _VANISHEFFECT_ON
        // [NoScaleOffset]_VanishTex("   VanishMap", 2D) = "white" {}
        // _VanishParam("   VanishParam", Range(0.0,1.0)) = 1.0
        // _VanishHeight("   VanishHeight", Range(0.0,10.0)) = 2.0
        // _VanishWorldSpaceBaseY("   VanishWorldSpaceBaseY", Float) = 0

        [HideInInspector] _HighlightColor("HighlightColor",Color) = (0,0,0,0)

        //[Header(Distance ShadowMask)]
        //[Toggle]_DistanceShadowMask("近处实时阴影效果",Int) =1 // 如果不去掉的话，会干扰Shader.SetGlobalFloat()

        [Space]
        [Toggle] _WaveEffect("启用摆动效果。(顶点色a通道越白，摆幅越大)", Float) = 0.0 // _WAVEEFFECT_ON
        _WaveSpeed("WaveSpeed", Range(0, 10)) = 1
        _WindStrength("WindStrength", Range(0, 2)) = 1
        _WindDirection("WindDirection", Range(0, 360)) = 0
        _PhaseScale("PhaseScale", Range(0,1)) = 1


    }

    CGINCLUDE
        #include "DataTypes.cginc"
        // #define CHECK_COLOR(value) return HighPrec4(value.rgb,1);
        // #define CHECK_VALUE(value) return HighPrec4(value,value,value,1);
    ENDCG

    SubShader {
        Tags {
			"IgnoreProjector"="True"
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend Off

            // Stencil {
            //     Ref 4
            //     WriteMask 7
            //     Comp Always
            //     Pass Replace
            //     Fail Keep
            //     ZFail Keep // 没通过depth test时不写stencil
            // }

            CGPROGRAM
            #pragma target 3.0
            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu 
            // todo：去除其他不必要的renderer配置、比如directX

            #pragma multi_compile_fwdbase 
            // #pragma multi_compile_fog // TODO : remove per object fog
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            //#pragma multi_compile _ _SHADOW_HEIGHT_MANNUALLY
             
            //_USE_CUSTOM_HEIGHT_FOG _USE_CUSTOM_DISTANCE_HEIGHT_FOG

            #pragma multi_compile _ALWAYS_USE_BAKEATTEN

            // #pragma multi_compile _ _VANISHEFFECT_ON 
            // 消散效果
            // #pragma multi_compile _ _WAVEEFFECT_ON // 摆动效果
            // #pragma multi_compile _BAKESHADOWTOON_ON // bake shadow做二级化处理
            // #pragma multi_compile _USELIGHTMAPINTENSITY_ON

            

            #pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR  DIRECTIONAL_COOKIE POINT_COOKIE LIGHTPROBE_SH   LIGHTMAP_SHADOW_MIXING VERTEXLIGHT_ON
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有： DIRECTIONAL LIGHTMAP_ON   
            #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH 
            
// point light, spot light 都不投射阴影

            #include "AutoLight.cginc"
            #include "PbrHeader.cginc"
            #include "UtilHeader.cginc"
            #include "UnityCG.cginc"
            #include "WavingEffectHeader.cginc"
			#include "HawkEyeHeader.cginc"

            uniform sampler2D _MainTex;
			uniform HighPrec4 _MainTex_ST; // 注意命名潜规则
            uniform MidPrec4 _TintColor;
            // 环境光颜色的调整
            uniform MidPrec4 _IndirectColorAdjust;
            uniform LowPrec _PBRShadingGI;

            // SSS
            uniform MidPrec _BackSubsurfaceDistortion;
            uniform MidPrec _SSS_Strength;

            

            // 顶点色相关 Edit by Will
            uniform MidPrec _vertexColorR_Ratio; // 顶点色明暗权重
            uniform MidPrec _vertexColorR_WhiteLevel;
            uniform MidPrec _vertexColorR_BlackLevel;
            uniform MidPrec4 _ShadowColor;
            uniform MidPrec _ShadowColorBrighten;
            // uniform float _vertexColorR_LambertDarken; // 调整顶点光照计算结果值lambert的暗度值。注意这里用float是因为微软的HLSL编译时对step方法存在bug。https://fogbugz.unity3d.com/default.asp?934464_sjh4cs4ok77ne0cj

            // uniform MidPrec _LightmapAtten_BlackLevel;

            uniform MidPrec _BrightRange;
            uniform MidPrec _AdjustForNotBaked;

            // 阴影相关
            uniform MidPrec _Shadow_Manually_ShadowFacePointY;
            uniform MidPrec _Shadow_Manually_ShadowLum;

            // 自发光
            uniform LowPrec _EnableEmissive;
            uniform MidPrec3 _EmissionColor;
            uniform sampler2D _EmissionMap;

            // 小世界选中高亮自发光用
            uniform MidPrec4 _HighlightColor;


            // uniform MidPrec _Angle;
            uniform MidPrec _Cutoff;
            // uniform MidPrec _MinLightness;

            
            uniform sampler2D _VanishTex;
            uniform MidPrec _VanishParam;
            uniform MidPrec _VanishHeight;
            uniform MidPrec _VanishWorldSpaceBaseY;

// #if _BAKESHADOWTOON_ON
//             uniform MidPrec _BakeShadowToonThre;
//             uniform MidPrec _BakeShadowToonLow;
//             uniform MidPrec _BakeShadowToonHigh;
// #endif

            uniform LowPrec _WaveEffect;
            uniform MidPrec _WindStrength;
            uniform MidPrec _WindDirection;
            uniform MidPrec _WaveSpeed;
            uniform MidPrec _PhaseScale;

            uniform MidPrec4 _PlayerPosition;


            DECLARE_DISTANCE_FOG_TEXTURE(_DistanceFogTexture);
            DECLARE_DISTANCE_FOG_PARAM1(_DistanceFogParam1);
            DECLARE_DISTANCE_FOG_PARAM2(_DistanceFogParam2);
            DECLARE_SUNFOG_PARAM1(_SunFogParam1);
            DECLARE_HEIGHTFOG_PARAM1(_HeightFogParam1);
            DECLARE_HEIGHTFOG_PARAM2(_HeightFogParam2);


            //------------------------------------

            struct VertexInput {
                HighPrec4 vertex : POSITION;
                HighPrec2 uv0 : TEXCOORD0;
                HighPrec2 uv1 : TEXCOORD1;
                MidPrec3 normal : NORMAL;
                MidPrec4 vertexColor: COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID

            };
            struct VertexOutput {

                HighPrec4 pos : SV_POSITION;
                HighPrec2 uv0 : TEXCOORD0;
                HighPrec2 uv1 : TEXCOORD1;
                HighPrec4 worldPos : TEXCOORD2;
                //MidPrec4 vertexColor : COLOR;                
                // MidPrec lightAtten : TEXCOORD3;
                UNITY_LIGHTING_COORDS(4,5)
                MidPrec3 worldNormal:TEXCOORD6;
                MidPrec3 pointLightColor : TEXCOORD7; 

            };
            VertexOutput vert (VertexInput v) {

                UNITY_SETUP_INSTANCE_ID(v);
                VertexOutput o = (VertexOutput)0;

            if(_WaveEffect > PROPERTY_ZERO){
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = WavingWithRegularSin( o.worldPos, _PhaseScale, _WaveSpeed,  _WindStrength * v.vertexColor.a, _WindDirection );
                o.pos = mul(UNITY_MATRIX_VP, o.worldPos);
                
            }else{
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
            }
               
                
                MidPrec3 worldNormal = normalize(mul(v.normal, (MidPrec3x3)unity_WorldToObject)); // worldInverseTranspose
                o.worldNormal = worldNormal;

                o.uv0 = TRANSFORM_TEX(v.uv0.xy, _MainTex);

                //o.lightAtten = 1.0;
                //MidPrec vertexColorWeight = 1.0;
#ifdef LIGHTMAP_ON 

                // 烘焙后，不再使用顶点色的信息，明暗以烘焙光照为唯一标准
                o.uv1 = v.uv1.xy*unity_LightmapST.xy + unity_LightmapST.zw; // 注意需要加上这个xyzw变换，不然无法正确读取lightmap

// #else
            // 不烘焙的时候，允许使用顶点色给树增加明暗效果
            // 为实现通过顶点色给树叶增加阴影的效果，故这里乘以顶点色。美术同学刷的结果是亮处都是白色，暗处是暗色。
            // MidPrec adjustVertexColorR_WhiteLevel = max( max( _vertexColorR_WhiteLevel, _vertexColorR_BlackLevel + 1e-3f ) , 1e-3f);
            // vertexColorWeight = saturate( max(0.0,(v.vertexColor.r - _vertexColorR_BlackLevel)) / ( adjustVertexColorR_WhiteLevel - _vertexColorR_BlackLevel ) );
            // vertexColorWeight = lerp( 1.0, vertexColorWeight, _vertexColorR_Ratio ); // 使用顶点色的权重
            // o.lightAtten = min( vertexColorWeight, o.lightAtten );
#endif
            UNITY_TRANSFER_LIGHTING(o,v.uv1)

            // 是否使用顶点法线来计算NdotL，否则就将法线设置为垂直朝上。现在树叶的法线要求都是根据美术需要处理过的。
            //o.worldNormal = lerp( MidPrec3(0.0,1.0,0.0) , o.worldNormal, _UseVertexLit);
            
            //o.vertexColor = v.vertexColor;
 
			// vertex lights
            // Approximated illumination from non-important point lights
            o.pointLightColor = MidPrec3(0.0h,0.0h,0.0h);
            // #ifdef VERTEXLIGHT_ON // 树叶现在点光源只让它支持烘焙
            //     o.pointLightColor += Shade4PointLights (
            //     unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
            //     unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
            //     unity_4LightAtten0, o.worldPos.xyz, o.worldNormal.xyz);
            // #endif

            // Light Calc
            //------------------------------------------------------------------------
                return o;
            }

     //------------------------------------------------------------------------
     //  fragment Shader

    MidPrec4 frag(VertexOutput i, float facing : VFACE) : SV_Target {


#if _VANISHEFFECT_ON
        MidPrec vanishValue = tex2D(_VanishTex, i.uv0).a;
        clip(_VanishParam - vanishValue * (i.worldPos.y- _VanishWorldSpaceBaseY) / _VanishHeight);
#endif

        LowPrec faceSign = (facing >= 0 ? 1 : -1);
        // UNITY_SETUP_INSTANCE_ID(i);

        MidPrec4 _MainTex_var = tex2D(_MainTex, i.uv0);
        clip(_MainTex_var.a-_Cutoff);

        MidPrec3 albedo = lerp( _MainTex_var.rgb, _TintColor.rgb, _TintColor.a );
        MidPrec3 finalRGB = albedo;

        

      // 如果树叶不参与烘焙，所以它接收到的阴影需要放在这里进行一些处理  
    #ifndef LIGHTMAP_ON
        
        UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos.xyz)
        atten = step(0.999,atten);

        // if( _DistanceShadowMask > PROPERTY_ZERO){
        //     // Distance ShadowMask 方式
        //     atten = step(0.999,atten); // Unity会让采样出来的atten在靠近ShadowMap边缘时逐渐变淡。对于我们跟顶点色衔接，则将这个衰减去掉衔接得更好。
        //     // MidPrec zDist = dot(_WorldSpaceCameraPos - i.worldPos.xyz, UNITY_MATRIX_V[2].xyz);
        //     // MidPrec fadeDist = UnityComputeShadowFadeDistance(i.worldPos.xyz, zDist);
        //     // MidPrec nearPlaceAtten = atten + i.lightAtten * i.lightAtten * 0.5;// 加上顶点色来增加暗部的层次感
        //     // atten = lerp( nearPlaceAtten, i.lightAtten, UnityComputeShadowFade(fadeDist));
        // }else{
        //     // ShadowMask 方式,不像 PBRScene和地表那样考虑距离
        //     atten = min(atten, i.lightAtten); 
        // }
    #else
        MidPrec atten = 1.0;
    #endif

        UnityGI giOutput = UnityGI_Base_RealtimeOrShadowMask( i.uv1.xy, _WorldSpaceLightPos0.xyz, i.worldPos.xyz, atten, i.worldNormal.xyz, _LightColor0.rgb );

        giOutput.indirect.diffuse = lerp(giOutput.indirect.diffuse, _IndirectColorAdjust.rgb, _IndirectColorAdjust.a); //提供这个参数来让暗部颜色更加整体和趋同，减少杂乱的视觉效果

        // back light sss 
        // 参考:https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-1/
        MidPrec3 backLitDir = i.worldNormal * _BackSubsurfaceDistortion + _WorldSpaceLightPos0.xyz;
        MidPrec3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        MidPrec backSSS = saturate(dot(viewDir, -backLitDir));
        backSSS = pow(backSSS, 3) * _SSS_Strength;

        // 计算全局光照的漫反射
        if( _PBRShadingGI > PROPERTY_ZERO){

            // 常规PBR： direct + indirect
            finalRGB =  ( giOutput.light.color * (1.0 + backSSS.xxx) + giOutput.indirect.diffuse + i.pointLightColor ) * albedo; 
        }else
        {
            // 卡通模式： lerp( 亮面色, 暗面色,  ratio )， 该模式能够让暗部有更高饱和度的同时不影响亮部颜色
            MidPrec3 lightenColor = ( _LightColor0.rgb * (1.0 + backSSS.xxx)  + i.pointLightColor ) * albedo;
            finalRGB = lerp( giOutput.indirect.diffuse, lightenColor, saturate( (giOutput.light.color.x + giOutput.light.color.y + giOutput.light.color.z) * 0.33333  ) );
        }

        // 自发光
        if( _EnableEmissive > 0.5 ){
            finalRGB += ( _EmissionColor.rgb * tex2D(_EmissionMap,i.uv0).rgb);
        }

        // 自发光（小世界使用）
        finalRGB += _HighlightColor.rgb;
                
               
                //-----------------------------------------------------------------------------------------


        if(  _EnableHawkEye > PROPERTY_ZERO ){
            finalRGB.rgb = HawkEyeColor(finalRGB.rgb, i.worldPos.xyz);
            return MidPrec4( finalRGB.rgb, 1 );
        }

                // UNITY_APPLY_FOG(i.fogCoord, finalRGB.rgb);
                CALC_DISTANCE_FOG_PARAM(i.worldPos.xyz)
                APPLY_DISTANCE_FOG(finalRGB, 1)

                return MidPrec4(finalRGB,1.0);
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
            // #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing 

            #pragma multi_compile _ _SHADOWS_CLIP

            // allow instanced shadow pass for most of the shaders
            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform HighPrec4 _MainTex_ST; // 注意命名潜规则
            uniform MidPrec _Cutoff;

            struct vertexInput {
                HighPrec4 vertex : POSITION;
                MidPrec3 normal : NORMAL;
                HighPrec4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {
                V2F_SHADOW_CASTER; // 此处定义了pos等属性
                HighPrec2  uv : TEXCOORD1;
            };

            VertexOutput vert( vertexInput v )
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            HighPrec4 frag( VertexOutput i ) : SV_Target
            {
                MidPrec4 texcol = tex2D( _MainTex, i.uv );
#ifndef _SHADOWS_CLIP
                clip( texcol.a - _Cutoff );
#endif
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
        Pass{  // 这个加上去就可以让点光源也进行片元的光源计算。如果这个Pass关掉，那么就将附近的点光源都设置为 Not Important，且不再需要 LIGHTPROBE_SH来判断是否需要开启顶点光照计算，强制让它们都在顶点里计算。当然，顶点里算的光照效果比片元里视觉效果还是差不少。
            Name "forwardadd"
            Tags{"LightMode" = "ForwardAdd"}
            
            
            Blend One One

            CGPROGRAM

            #pragma target 3.0
            #pragma multi_compile_fwdadd
            #pragma multi_compile_instancing 

            #include "UnityCG.cginc"
            #include "UtilHeader.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "WavingEffectHeader.cginc"

            uniform sampler2D _MainTex;
			uniform HighPrec4 _MainTex_ST; // 注意命名潜规则
            uniform MidPrec4 _TintColor;
            uniform MidPrec _Cutoff;

            uniform LowPrec _WaveEffect;
            uniform MidPrec _WindStrength;
            uniform MidPrec _WindDirection;
            uniform MidPrec _WaveSpeed;
            uniform MidPrec _PhaseScale;

            struct VertexInput {
                HighPrec4 vertex : POSITION;
                MidPrec3 normal : NORMAL;
                HighPrec2 uv0 : TEXCOORD0;
                HighPrec2 uv1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct  VertexOutput
            {
                HighPrec4 pos : SV_POSITION;
                HighPrec2 uv0 : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                float4 lmap : TEXCOORD3;
                UNITY_LIGHTING_COORDS(4,5)

            };

            #pragma vertex vert
            #pragma fragment frag

            VertexOutput vert(VertexInput v){
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                
                if(_WaveEffect > PROPERTY_ZERO){
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = WavingWithRegularSin( o.worldPos, _PhaseScale, _WaveSpeed,  _WindStrength, _WindDirection );
                o.pos = mul(UNITY_MATRIX_VP, o.worldPos);
                
                }else{
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    o.pos = UnityObjectToClipPos(v.vertex);
                }

#ifdef LIGHTMAP_ON 
                o.lmap = v.uv1.xy*unity_LightmapST.xy + unity_LightmapST.zw; // 注意需要加上这个xyzw变换，不然无法正确读取lightmap
#endif



                UNITY_TRANSFER_LIGHTING(o,v.uv1.xy)

                o.uv0 = TRANSFORM_TEX(v.uv0.xy, _MainTex);

                return o;
            }

            MidPrec4 frag(VertexOutput IN):SV_TARGET{

                MidPrec4 _MainTex_var = tex2D(_MainTex, IN.uv0);
                MidPrec3 albedo = lerp( _MainTex_var.rgb, _TintColor.rgb, _TintColor.a );
                clip(_MainTex_var.a-_Cutoff);
                  UNITY_LIGHT_ATTENUATION(atten, IN, IN.worldPos.xyz)
                  return MidPrec4(_LightColor0.rgb * atten * albedo , 1);

            }


            ENDCG

        }

        //------------------------------------------------------------------------
        // 用于为光照贴图提供自定义的albedo,emission，mettalic等值。并不在游戏运行时执行。
        Pass {
            Name "META"
            Tags { "LightMode"="Meta" }
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "UtilHeader.cginc"
            #include "UnityMetaPass.cginc"

            uniform MidPrec4 _TintColor;
            uniform sampler2D _MainTex;
            uniform HighPrec4 _MainTex_ST;
            uniform MidPrec _Cutoff;

            struct VertexInput {
                HighPrec4 vertex : POSITION;
                //MidPrec3 normal : NORMAL;
                HighPrec2 uv0 : TEXCOORD0;
                HighPrec2 uv1 : TEXCOORD1;
            };

            struct  VertexOutput
            {
                HighPrec4 pos : SV_POSITION;
                HighPrec2 uv : TEXCOORD0;
            };

            #pragma vertex vert_CustomMeta
            #pragma fragment frag_CustomMeta

            VertexOutput vert_CustomMeta(VertexInput v) {
                VertexOutput output = (VertexOutput)0;
                output.pos = UnityMetaVertexPosition4BakeOnly(v.vertex, v.uv1.xy, unity_LightmapST);
                // output.uv.xy = v.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                output.uv = TRANSFORM_TEX(v.uv0.xy, _MainTex);
                return output;
            }

            HighPrec4 frag_CustomMeta(VertexOutput input) : SV_Target {
                MidPrec4 baseColor = tex2D(_MainTex, input.uv.xy);

                clip( baseColor.a - _Cutoff );

                // baseColor.rgb *= _TintColor.rgb;
                MidPrec3 albedo = lerp( baseColor.rgb, _TintColor.rgb, _TintColor.a );
                baseColor.rgb = albedo;

                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);
                o.Albedo = Luminance(baseColor.rgb).xxx;
                o.Emission = MidPrec3(0,0,0);
                o.SpecularColor = MidPrec3(0,0,0); // TODO：采用pbr，这里区分一下 albedo 和 specular?

                return UnityMetaFragment(o);
            }

            ENDCG
        }
    }
    FallBack Off
}
