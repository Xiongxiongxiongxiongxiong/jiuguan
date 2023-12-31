﻿Shader "XingFei/PostProcess/ReadPostProcessResult"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle]_TogglePostRT("TogglePostRT", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _POST_PROCESS_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _PostRT;
            sampler2D _PostRT1;
            fixed _TogglePostRT;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
#if _POST_PROCESS_ON
                fixed4 col = 0.0;
                if(_TogglePostRT > 0.001)
                    col = tex2D(_PostRT1, i.uv);
                else
                    col = tex2D(_PostRT, i.uv);
#else
                fixed4 col = tex2D(_MainTex, i.uv);
#endif
                return col;
            }
            ENDCG
        }
    }
}
