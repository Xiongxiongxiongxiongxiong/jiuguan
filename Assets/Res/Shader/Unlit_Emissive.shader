Shader "MT/Unlit_Emissive"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}

        [HDR]_EmissiveColor ("Emissive", Color) = (0, 0, 0, 0)
        _EmissiveTex ("Emissive", 2D) = "white" { }

        [Header(Rim)]
        _RimColor ("Rim Color", Color) = (0.17, 0.36, 0.81, 0.0)
        _RimPower ("Rim Power", Range(0.6, 36.0)) = 8.0
        _RimIntensity ("Rim Intensity", Range(0.0, 100.0)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "IgnoreProjector" = "True" "Queue" = "Transparent" "RenderType" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 nomrmal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 nomrmal:NORMAL;
                float3 viewDir: TEXCOORD2;
            };

            sampler2D _MainTex, _EmissiveTex;
            float4 _MainTex_ST;
            half4 _EmissiveColor, _Color;

            half4 _RimColor;
            half _RimPower;
            half _RimIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.nomrmal = UnityObjectToWorldNormal(v.nomrmal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv) * _Color;
                half4 emissive = tex2D(_EmissiveTex, i.uv) * _EmissiveColor;
                float3 N = normalize(i.nomrmal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float NdL = max(0, dot(N, L));
                NdL = NdL * 0.5 + 0.5;


                //rim
                half rim = (1.0 - saturate(dot(i.viewDir, N))) * _RimIntensity;
                half3 rimcol = pow(rim, _RimPower) * _RimColor;

                half4 finalcol = half4(col.rgb + saturate(rimcol) + emissive.rgb, saturate(rim + col.a));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalcol);
                return finalcol;
            }
            ENDCG
        }
    }
}