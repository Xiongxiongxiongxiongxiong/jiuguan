Shader "MT/Builtin/Outline"
{
    Properties
    {
        _OutlineWidth ("Outline", Range(0, 1)) = 0.1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Pass
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 vert(float4 v : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(v);
            }

            float4 frag() : SV_Target
            {
                return float4(1, 1, 1, 1);
            }
            ENDCG
        }

        Pass
        {
            Name "Outline"
            Stencil
            {
                Ref 1
                Comp NotEqual
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _OutlineWidth;
            fixed4 _OutlineColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                // float3 positionOS:TEXCOORD0;
                float3 positionOS_1:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                // o.positionOS = v.vertex.xyz;
                o.positionOS_1.xyz = v.vertex * step(0.000001, _OutlineWidth) + v.normal * _OutlineWidth * 0.1;
                o.pos = UnityObjectToClipPos(o.positionOS_1.xyz);
                // float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
                // float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
                // normal.z = -0.5;
                // pos = pos + float4(normalize(normal), 0) * _OutlineWidth * 0.1;
                // o.pos = mul(UNITY_MATRIX_P, pos);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return float4(_OutlineColor.rgb, 1);
            }
            ENDCG
        }
    }
}