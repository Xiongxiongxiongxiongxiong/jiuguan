/**
* @file       VegetationImposter.shader
* @brief      植被Amplify Imposter运行时shader
* @comment  
*/

Shader "XingFei/Scene/VegetationImposter" {
    Properties {
        [NoScaleOffset]_Albedo ("主纹理", 2D) = "white" {}
		[NoScaleOffset]_Normals("法线贴图", 2D) = "white" {}

        [Header(Custom Properties)]
        [Space]
        [Header(In Shadow)]
        [Toggle]_InShadow( "(GPU)是否处在阴影区域", Float ) = 0.0

        [Header(Lambert Light)]
        [Space]
        _NdotLStrength("整体明暗区域", Range(0.5,3)) = 1
        _LightenArea("暗部区域亮度", Range(0,50)) = 10
        _LightenAreaStrength("亮部区域亮度", Range(0,50)) = 10
        _AoLightArea("(GPU)AO影响的亮部区域范围", Range(0,1)) = 1
        _LambertSmoothstepMin("(GPU)明暗范围", Range(0,1)) = 0.0
        _LambertSmoothstepMax("(GPU)明暗过渡的软硬度", Range(0,1)) = 0.1

        [Header(AO)]
        [Space]
        _AoColor("(GPU)AoColor", Color) = (0.5,0.0,0.0,1.0)
        _AoLightRatio("(GPU)亮部AO强度", Range(0,1)) = 0.7
        _AoBackRatio("(GPU)暗部AO强度", Range(0,1)) = 0.0
        
        [Header(PreSet)]
        [Space]
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        _TextureBias("Texture Bias", Float) = -1
        _AdjustColor("颜色调节", Color) = (1.0,1.0,1.0,1.0)

        [HideInInspector]_HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HideInInspector][HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)
        [HideInInspector]_TimeStopHawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.35
        [HideInInspector][HDR]_TimeStopHawkEyeColor("HawkEyeColor", Color) = (0.254902,0.3490196,0.7843138,1)

        // 烘焙时，会赋值，删除会导致显示错误
        _FramesX("Frames X", Float) = 16
		_FramesY("Frames Y", Float) = 16
		_DepthSize("DepthSize", Float) = 1
		_ImpostorSize("Impostor Size", Float) = 1
		_Offset("Offset", Vector) = (0,0,0,0)
		_AI_SizeOffset( "Size & Offset", Vector ) = ( 0,0,0,0 )
    }

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Geometry"
            "RenderType"="TransparentCutout"
        }

        Pass {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend Off
            Cull Back

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
            

            #pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR  DIRECTIONAL_COOKIE POINT_COOKIE LIGHTPROBE_SH   LIGHTMAP_SHADOW_MIXING LIGHTMAP_ON
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有： DIRECTIONAL VERTEXLIGHT_ON   
            #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH 
            
            #include "../DataTypes.cginc"
            #include "AutoLight.cginc"
            #include "../PbrHeader.cginc"
            #include "../UtilHeader.cginc"
            #include "../HawkEyeHeader.cginc"
            #include "UnityCG.cginc"
			#include "AmplifyImpostors.cginc"

            uniform MidPrec4 _AdjustColor;
            uniform MidPrec _Cutoff;

            uniform MidPrec _InShadow;

            uniform MidPrec _NdotLStrength;
            uniform MidPrec _LambertSmoothstepMin;
            uniform MidPrec _LambertSmoothstepMax;
            uniform MidPrec _LightenArea;
            uniform MidPrec _LightenAreaStrength;

             //AO
            uniform MidPrec4 _AoColor;
            uniform MidPrec _AoLightRatio;
            uniform MidPrec _AoBackRatio;
            uniform MidPrec _AoLightArea;

            // 小世界选中高亮自发光用
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
                MidPrec3 normal : NORMAL;
                HighPrec4 uv0 : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {
                HighPrec4 pos : SV_POSITION;
                HighPrec4 worldPos : TEXCOORD0;
                HighPrec4 uv0 : TEXCOORD1;
                HighPrec4 modelMatrix0 : TEXCOORD2;
                HighPrec4 modelMatrix1 : TEXCOORD3;
                HighPrec4 modelMatrix2 : TEXCOORD4;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);

                HighPrec4 viewPos;

				SphereImpostorVertex( v.vertex, v.normal, o.uv0, viewPos);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                // 将顶点的M矩阵传递到片元进行计算
                // 不能在片元直接使用M矩阵原因：Gpuinstancing绘制时会调换矩阵顺序，unity内部机制导致取得M矩阵在自身和其他obj矩阵间进行切换
                o.modelMatrix0 = unity_ObjectToWorld._m00_m01_m02_m03;
                o.modelMatrix1 = unity_ObjectToWorld._m10_m11_m12_m13;
                o.modelMatrix2 = unity_ObjectToWorld._m20_m21_m22_m23;

                return o;
            }

            //------------------------------------------------------------------------
            //  fragment Shader

            MidPrec4 frag(VertexOutput i) : SV_Target {
                // albedo alpha
                MidPrec4 albedoSample = tex2Dbias( _Albedo, HighPrec4( i.uv0.xy, 0, _TextureBias) );
                MidPrec4 normalSample = tex2Dbias( _Normals, HighPrec4( i.uv0.xy, 0, _TextureBias));
                normalSample.xyz = normalSample.xyz * 2.0 - 1.0;
                // normaslSample.xyz = mul((float3x3)unity_ObjectToWorld, normalSample.xyz);
                MidPrec3 temp = normalSample.xyz;
                normalSample.x = dot(i.modelMatrix0.xyz, temp);
                normalSample.y = dot(i.modelMatrix1.xyz, temp);
                normalSample.z = dot(i.modelMatrix2.xyz, temp);
                normalSample.xyz = normalize(normalSample.xyz);

                //return MidPrec4(unity_ObjectToWorld._m00,unity_ObjectToWorld._m01,unity_ObjectToWorld._m02,1);

                // 控制是否处在阴影区域
                _LambertSmoothstepMin = lerp(_LambertSmoothstepMin, 1, _InShadow);

                 // Lambert 光照决定明暗面
                HighPrec3 lightDir =  Unity_SafeNormalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
                MidPrec NdotL = dot( normalSample.xyz , lightDir);
                MidPrec halfLambert = NdotL * 0.5 + _NdotLStrength; // min:0 => 1, max:2.5 => 3
                halfLambert *= halfLambert;

                // 明暗度的亮度调整
                MidPrec lightenFactor = smoothstep(_LambertSmoothstepMin, saturate(_LambertSmoothstepMin + _LambertSmoothstepMax), NdotL - (1 - normalSample.w) * _AoLightArea);

                //顶点色 AO
                MidPrec3 _AoColor_Var = lerp(saturate(normalSample.w + _AoBackRatio), saturate(normalSample.w + _AoLightRatio), lightenFactor);
                _AoColor_Var = lerp(_AoColor, MidPrec3(1.0,1.0,1.0), _AoColor_Var);
                lightenFactor = lightenFactor * _LightenAreaStrength + _LightenArea;

                // early clip
                clip( albedoSample.a - _Cutoff );

                // return normalSample;

                MidPrec3 finalRGB = albedoSample.rgb * _AoColor_Var.rgb * halfLambert * lightenFactor + albedoSample.rgb;

                MidPrec lum = Luminance(_IndirectLightTint.rgb);
                lum += lerp(0, 8, lum);
				finalRGB.rgb = lerp(finalRGB.rgb * _IndirectLightTint.rgb, finalRGB.rgb, saturate(lum * lum));

                finalRGB = min(MAX_COLOR, finalRGB); // 某些角度导致halfLambert达到很大，导致产生bloom效果，会闪一下。需要限制到1以下

                if(  _EnableHawkEye > PROPERTY_ZERO ){
                    finalRGB = HawkEyeColor(finalRGB, i.worldPos.xyz);
                    return MidPrec4( finalRGB.rgb, 1 );
                }

                // UNITY_APPLY_FOG(i.fogCoord, finalRGB.rgb);
                CALC_DISTANCE_FOG_PARAM(i.worldPos.xyz)
                APPLY_DISTANCE_FOG(finalRGB, 1)

                return MidPrec4(finalRGB,1.0);
            }
            ENDCG
        }
        
    }
    FallBack Off
}
