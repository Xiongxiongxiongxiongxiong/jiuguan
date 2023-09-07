Shader "MT/MT_Standard_Matcap"
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

        [Header(Matcap)]
        [HDR]_MatCapColor("MatCap Color", Color) = (0, 0, 0, 0)
        _MatCap("MatCap", 2D) = "white" {}


        [Header(Rim)]
        _RimColor ("Rim Color", Color) = (0.17, 0.36, 0.81, 0.0)
        _RimPower ("Rim Power", Range(0.6, 36.0)) = 8.0
        _RimIntensity ("Rim Intensity", Range(0.0, 100.0)) = 1.0


        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        LOD 200
        Cull [_CullMode]
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert

        #pragma target 3.0

        sampler2D _MainTex, _MRA, _Normal, _EmissiveTex, _MatCap;

        struct Input
        {
            float2 uv_MainTex;
            float2 matcapuv : TEXCOORD2;
            float3 viewDir;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            o.matcapuv.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(v.normal));
            o.matcapuv.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(v.normal));
            //o.matcapuv = UnityObjectToWorldNormal(v.normal).xy;
            o.matcapuv = o.matcapuv * 0.5 + 0.5;
        }


        half _Roughness, _Metallic, _NormalScale, _AO;

        half4 _Color, _EmissiveColor, _MatCapColor;

        half4 _RimColor;
        half _RimPower;
        half _RimIntensity;


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
            //Matcap
            half3 matcap = tex2D(_MatCap, IN.matcapuv) * _MatCapColor;

            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
            half3 rimcol = pow(rim, _RimPower) * _RimIntensity*_RimColor;
            o.Emission = emissive + lerp(matcap, rimcol, rim);
            o.Normal = normal;
            o.Alpha = c.a;
        }
        ENDCG

    }
    FallBack "Diffuse"
}