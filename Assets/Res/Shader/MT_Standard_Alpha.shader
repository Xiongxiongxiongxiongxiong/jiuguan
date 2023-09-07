Shader "MT/MT_Standard_Alpha"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _MRA ("MRA", 2D) = "white" { }
        _Roughness ("Roughness", Range(0, 1)) = 1
        _Metallic ("Metallic", Range(0, 1)) = 1
        _AO ("AO", Range(0, 1)) = 0

        [HDR]_EmissiveColor ("Emissive", Color) = (0, 0, 0, 0)
        _EmissiveTex ("Emissive", 2D) = "white" { }
        _Normal ("Normal", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Range(0, 5)) = 1
        _OP ("OP", Range(0, 1)) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"
        }
        LOD 200
        Cull [_CullMode]
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:fade

        #pragma target 3.0

        sampler2D _MainTex, _MRA, _Normal, _EmissiveTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Roughness, _Metallic, _NormalScale, _AO, _OP;

        half4 _Color, _EmissiveColor;


        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            half3 mra = tex2D(_MRA, IN.uv_MainTex);
            half3 normal = UnpackNormalWithScale(tex2D(_Normal, IN.uv_MainTex), _NormalScale);
            half3 emissive = tex2D(_EmissiveTex, IN.uv_MainTex).rgb * _EmissiveColor.rgb;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = mra.r * _Metallic;
            o.Smoothness = pow(saturate(1 - mra.g * _Roughness), 2);
            o.Occlusion = lerp(mra.b, 1, _AO);
            o.Emission = emissive;
            o.Normal = normal;
            o.Alpha = c.a * (1 - _OP);
        }
        ENDCG

    }
    FallBack "Diffuse"
}