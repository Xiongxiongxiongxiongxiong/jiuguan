#ifndef MYHAIRLIGHTING_M2_INCLUDED
#define MYHAIRLIGHTING_M2_INCLUDED

sampler2D _MainTex,_MixTex, _MaskTex;
float4 _MainTex_ST;
float _AlphaCutoff;
float _Contrast,_VgradientInt,_SpecularInt,_SpecularPow;
float4 _Color;

float _Smoothness;
float _Metallic;
float _Occulusion;

sampler2D _BumpMap;
float _BumpScale;

sampler2D _SpecularShift;
float4 _SpecularShift_ST;

float4 _DiffuseColor;
float4 _PrimaryColor;
float _PrimaryShift;
float4 _SecondaryColor;
float _SecondaryShift;

float _specPower;
float _SpecularWidth;
float _SpecularScale;

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "MyHairBRDF.cginc"

struct VertexData {
    float4 vertex  : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;

};

struct Interpolators {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    #if defined(BINORMAL_PER_FRAGMENT)
        float4 tangent : TEXCOORD2;
    #else
        float3 tangent : TEXCOORD2;
        float3 binormal : TEXCOORD3;
    #endif

    float3 worldPos : TEXCOORD4;

    SHADOW_COORDS(5)

    #if defined(VERTEXLIGHT_ON)
        float3 vertexLightColor : TEXCOORD6;
    #endif

    float2 uv1 : TEXCOORD7;

};

float GetAlpha (Interpolators i) {
    return tex2D(_MainTex, i.uv).a;
}

float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
    return cross(normal, tangent.xyz) *
        (binormalSign * unity_WorldTransformParams.w);
}

void ComputeVertexLightColor (inout Interpolators i) {
    #if defined(VERTEXLIGHT_ON)
        i.vertexLightColor = Shade4PointLights(
            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
            unity_LightColor[0].rgb, unity_LightColor[1].rgb,
            unity_LightColor[2].rgb, unity_LightColor[3].rgb,
            unity_4LightAtten0, i.worldPos, i.normal
        );
    #endif
}

float3 GetTangentSpaceNormal (Interpolators i) {
    float3 normal = float3(0, 0, 1);
    normal = UnpackScaleNormal(tex2D(_BumpMap, i.uv.xy), _BumpScale);
    return normal;
}

void InitializeFragmentNormal(inout Interpolators i) {
    float3 mainNormal =
        UnpackScaleNormal(tex2D(_BumpMap, i.uv.xy), _BumpScale);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal = i.binormal;
	#endif
	
	i.normal = normalize(
		mainNormal.x * i.tangent +
		mainNormal.y * binormal +
		mainNormal.z * i.normal
	);
}

Interpolators MyVertexProgram (VertexData v) {
    Interpolators i;
    i.pos  = UnityObjectToClipPos(v.vertex);
    i.worldPos = mul(unity_ObjectToWorld, v.vertex);
    i.normal = UnityObjectToWorldNormal(v.normal);

    #if defined(BINORMAL_PER_FRAGMENT)
        i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
    #else
        i.tangent = UnityObjectToWorldDir(v.tangent.xyz);
        i.binormal = CreateBinormal(i.normal, i.tangent, v.tangent.w);
    #endif

    i.uv  = TRANSFORM_TEX(v.uv, _MainTex);
    i.uv1 = TRANSFORM_TEX(v.uv, _SpecularShift);

    TRANSFER_SHADOW(i);

    ComputeVertexLightColor(i);
    return i;
}

UnityLight CreateLight (Interpolators i) {
    UnityLight light;
    #if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE)
        light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif
    
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}

UnityIndirect CreateIndirectLight (Interpolators i, float3 viewDir) {
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

    #if defined(VERTEXLIGHT_ON)
        indirectLight.diffuse = i.vertexLightColor;
    #endif

    #if defined(FORWARD_BASE_PASS)
        indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
        float3 reflectionDir = reflect(-viewDir, i.normal);
        float roughness = 1 - _Smoothness;
        float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(
            unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS
        );
        indirectLight.specular = DecodeHDR(envSample, unity_SpecCube0_HDR);
    #endif

    float occlusion = lerp(1, saturate(tex2D(_MixTex, i.uv).r), _Occulusion);
    indirectLight.diffuse *= occlusion;

    return indirectLight;
}

half3 HairColor(half4 albedo, half3 color){
    albedo *= 80;
    half3 finalColor = albedo.rgb * color;

    return finalColor;
}

half4 MyFragmentProgram (Interpolators i): SV_TARGET {

    float alpha = GetAlpha(i);
    clip(_AlphaCutoff - alpha);

    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

    InitializeFragmentNormal(i);

    float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);

    half4 property = tex2D(_MainTex, i.uv);
    half debug = tex2D(_MainTex,i.uv).b;

    float3 albedo = HairColor(property , _Color);

    float3 specularTint;
    float oneMinusReflectivity;

    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );
    float smoothness = tex2D(_SpecularShift, i.uv) * _Smoothness * tex2D(_MaskTex, i.uv).r ;
    
    half3 avgColor = half3(0.5, 0.5, 0.5);
    albedo = lerp(avgColor, albedo, _Contrast) * saturate(tex2D(_MixTex, i.uv).g + _VgradientInt); 
    half4 color = MY_HAIR_SHADING_M(
        albedo, specularTint,
        oneMinusReflectivity, smoothness,
        i.normal, viewDir, i.tangent, binormal, i.uv1,
        CreateLight(i), CreateIndirectLight(i, viewDir)
    );
    color.a = alpha;
    return color;
}

#endif  
