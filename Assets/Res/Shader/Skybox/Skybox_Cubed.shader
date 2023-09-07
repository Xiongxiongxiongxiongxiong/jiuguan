// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "XF/Skybox/Cubemap" {
Properties {
    _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
    [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
    _Rotation ("Rotation", Range(0, 360)) = 0
    [NoScaleOffset] _TexDay ("Cubemap Day (HDR)", Cube) = "grey" {}
    [NoScaleOffset] _TexNight ("Cubemap Night (HDR)", Cube) = "grey" {}
    _DayTime ("Day Night Progress", Range(0, 1)) = 0
}

SubShader {
    Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
    Cull Off ZWrite Off

    Pass {

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        samplerCUBE _TexDay;
        half4 _TexDay_HDR;
        samplerCUBE _TexNight;
        half4 _TexNight_HDR;
        
        half4 _Tint;
        half _Exposure;
        float _Rotation;
        float _DayTime;

        float3 RotateAroundYInDegrees (float3 vertex, float degrees)
        {
            float alpha = degrees * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float3(mul(m, vertex.xz), vertex.y).xzy;
        }

        struct appdata_t {
            float4 vertex : POSITION;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float3 texcoord : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert (appdata_t v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
            o.vertex = UnityObjectToClipPos(rotated);
            o.texcoord = v.vertex.xyz;
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            half4 tex = texCUBE (_TexDay, i.texcoord);
            half3 c = DecodeHDR (tex, _TexDay_HDR);
            half4 texNight = texCUBE(_TexNight, i.texcoord);
            half3 cNight = DecodeHDR(texNight, _TexNight_HDR);

            half3 cBlend = lerp(c, cNight, _DayTime);
            cBlend = cBlend * _Tint.rgb * unity_ColorSpaceDouble.rgb;
            cBlend *= _Exposure;
            return half4(cBlend, 1);
        }
        ENDCG
    }
}


Fallback Off

}
