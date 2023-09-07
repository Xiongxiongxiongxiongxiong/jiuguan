Shader "Check/Check_Hair_AB"
{
    Properties
    {   
        [Header(Main Texture)]
        [KeywordEnum(custom,tex)]COL("Custom Color",Float) = 0
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_Contrast("Contrast", Range(0, 5)) = 1
        
        [Header(Mix Texture)]
        _MixTex("MixMap(R,G,B,A = Aomap,VgradientMap,--,--)", 2D) = "white" {}
        _MaskTex("SmoothnessMask", 2D) = "white" {}

        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _VgradientInt("VgradientInt",Range(0,1)) = 0
        [HideInInspector][Gamma]_Metallic ("Metallic", Range(0,1)) = 0.0
        _Occulusion("Occulusion", Range(0,1)) = 1

        [Header(Normal Texture)]
        [NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0,2)) = 1.0
        
        [Header(Specular)]
        _SpecularShift("Hair Shifted Texture", 2D) = "white" {}
        _SpecularInt ("Specular Int",Range(0,10)) = 1

        [HideInInspector]_PrimaryColor("Specular1Color", Color) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector]_PrimaryShift("PrimaryShift", Range(-4, 4)) = 0.0
        [HideInInspector]_SecondaryColor("Specular2Color", Color) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector]_SecondaryShift("SecondaryShift", Range(-4, 4)) = 0.5

        [HideInInspector]_specPower("SpecularPower", Range(0, 80)) = 20
        [HideInInspector]_SpecularWidth("SpecularWidth", Range(0, 1)) = 0.5
        [HideInInspector]_SpecularScale("SpecularScale", Range(0, 1)) = 0.3
    }
    CGINCLUDE

    #define BINORMAL_PER_FRAGMENT

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {   
            Tags {
                "LightMode" = "ForwardBase"
            }
            Cull Off
            CGPROGRAM
            #pragma target 3.0

            #pragma multi_compile COL_CUSTOM COL_TEX
            #pragma multi_compile _ SHADOWS_SCREEN
            #pragma multi_compile _ VERTEXLIGHT_ON

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #define FORWARD_BASE_PASS

            #include "MyHairLightingM1.cginc"

            ENDCG
        }

        Pass {
            Tags {
                "LightMode" = "ForwardAdd"
            }
            Blend One One
            ZWrite Off
            
            CGPROGRAM

            #pragma target 3.0

            #pragma multi_compile COL_CUSTOM COL_TEX
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #pragma multi_compile_fwdadd_fullshadows

            #include "MyHairLightingM1.cginc"

            ENDCG
        }

        Pass
        {   
            Tags {
                "LightMode" = "ForwardBase"
            }
            Cull front
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma target 3.0

            #pragma multi_compile COL_CUSTOM COL_TEX
            #pragma multi_compile _ SHADOWS_SCREEN
            #pragma multi_compile _ VERTEXLIGHT_ON

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #define FORWARD_BASE_PASS

            #include "MyHairLightingM2.cginc"

            ENDCG
        }

        Pass {
            Tags {
                "LightMode" = "ForwardAdd"
            }
            Cull front
            Blend SrcAlpha One
            ZWrite Off
            
            CGPROGRAM

            #pragma target 3.0
            
            #pragma multi_compile COL_CUSTOM COL_TEX
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #pragma multi_compile_fwdadd_fullshadows

            #include "MyHairLightingM2.cginc"

            ENDCG
        }

        Pass
        {   
            Tags {
                "LightMode" = "ForwardBase"
            }
            Cull back
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma target 3.0

            #pragma multi_compile COL_CUSTOM COL_TEX
            #pragma multi_compile _ SHADOWS_SCREEN
            #pragma multi_compile _ VERTEXLIGHT_ON

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #define FORWARD_BASE_PASS

            #include "MyHairLightingM2.cginc"

            ENDCG
        }

        Pass {
            Tags {
                "LightMode" = "ForwardAdd"
            }
            Cull back
            Blend SrcAlpha One
            ZWrite Off
            
            CGPROGRAM

            #pragma target 3.0

            #pragma multi_compile COL_CUSTOM COL_TEX
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #pragma multi_compile_fwdadd_fullshadows

            #include "MyHairLightingM2.cginc"

            ENDCG
        }

        Pass {
            Tags {
                "LightMode" = "ShadowCaster"
            }

            CGPROGRAM

            #pragma target 3.0

            #pragma multi_compile_shadowcaster

            #pragma vertex MyShadowVertexProgram
            #pragma fragment MyShadowFragmentProgram

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaCutoff;

            struct VertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                #if defined(SHADOWS_CUBE)
                    float3 lightVec : TEXCOORD1;
                #endif
            };

            float GetAlpha (Interpolators i) {
                float alpha = tex2D(_MainTex, i.uv.xy).a;;
                return alpha;
            }

            Interpolators MyShadowVertexProgram (VertexData v) {
                Interpolators i;
                #if defined(SHADOWS_CUBE)
                    i.position = UnityObjectToClipPos(v.position);
                    i.lightVec =
                        mul(unity_ObjectToWorld, v.position).xyz - _LightPositionRange.xyz;
                #else
                    i.position = UnityClipSpaceShadowCasterPos(v.position.xyz, v.normal);
                    i.position = UnityApplyLinearShadowBias(i.position);
                #endif
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return i;
            }

            float4 MyShadowFragmentProgram (Interpolators i) : SV_TARGET {
                float alpha = GetAlpha(i);
                clip(alpha - _AlphaCutoff);
                #if defined(SHADOWS_CUBE)
                    float depth = length(i.lightVec) + unity_LightShadowBias.x;
                    depth *= _LightPositionRange.w;
                    return UnityEncodeCubeShadowDepth(depth);
                #else
                    return 0;
                #endif
            }

            ENDCG
        }
    }
}