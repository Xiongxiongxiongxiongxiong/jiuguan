Shader "MT/Builtin/Blur/LowLevel/GaussianBlur"
{
    Properties
    {
//        [Enum(UnityEngine.Rendering.CullMode)]_Cull("CullMode:烘焙不剔除；实时剔除背面，复制一份转180°作为背面",float) = 2
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("CullMode",float) = 2
        _Color("MainColor",Color) = (1,1,1,1)
        [PowerSlider(3)]_BlurScale("BlurScale",range(0,1)) = 0.05
        _Mask("R通道，白色正常扭曲，黑色不扭曲",2D)="white"{}
//        _ShadowColor("ShadowColor",Color) = (0,0,0,1)
//        _ShadowIntensity("ShadowIntersity",range(0,1)) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
//            "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"
        }

        LOD 100

        GrabPass {}

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
                "RenderType"="Transparent"
                "Queue"="Transparent"
                "ForceNoShadowCasting"="True"
            }
            Cull [_Cull]
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma target 3.0
            // #pragma multi_compile_fwdbase
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            // #pragma multi_compile DIRLIGHTMAP_COMBINED
            // #pragma multi_compile DYNAMICLIGHTMAP_ON
            // #pragma multi_compile LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile LIGHTPROBE_SH
            #pragma multi_compile SHADOWS_SCREEN
            // #pragma multi_compile SHADOWS_SHADOWMASK
            // #pragma multi_compile VERTEXLIGHT_ON
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "BlurFunction.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMask : TEXCOORD0;
                #ifdef LIGHTMAP_ON
				half2 uvLM : TEXCOORD1;
                #else
                SHADOW_COORDS(1)
                #endif
                float3 positionWS : TEXCOORD2;
            };

            sampler2D _GrabTexture;
            sampler2D _Mask;
            float4 _Mask_ST;
            half4 _Color;
            half _BlurScale;
            // half _ShadowIntensity;
            // half4 _ShadowColor;
            // float4 _FixTilingOffset;

            v2f vert(appdata v)
            {
                v2f o;
                o.positionWS = mul(unity_ObjectToWorld, v.positionOS);

                o.pos = UnityWorldToClipPos(o.positionWS);
                o.uvMask = TRANSFORM_TEX(v.uv1, _Mask);

                #ifdef LIGHTMAP_ON
				o.uvLM = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
                #else
                TRANSFER_SHADOW(o);
                #endif

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half mask = tex2D(_Mask, i.uvMask).r;
                fixed2 screenUV = i.pos / _ScreenParams.xy;
                fixed4 grabColor = GaussianBlur(screenUV, _GrabTexture, _BlurScale, mask) * _Color;

                #ifdef LIGHTMAP_ON
                fixed3 shadowColor = 0;
                shadowColor = DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM.xy));
                // shadowColor = saturate((1 - shadowColor) * _ShadowColor + shadowColor + 1 - _ShadowIntensity);
                grabColor.rgb *=  shadowColor;
                return grabColor;
                #else
                return grabColor;
                // fixed atten = SHADOW_ATTENUATION(i);
                //
                // return lerp(grabColor,fixed4(grabColor.rgb * atten + (1 - atten) * _ShadowColor, 1), _ShadowIntensity);
                #endif
            }
            ENDCG
        }

    }
//    FallBack "VertexLit"
}