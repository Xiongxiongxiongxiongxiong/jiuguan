#ifndef MT_CHARACTER_UTIL
#define MT_CHARACTER_UTIL
    
float POW5(float a)
{
    return a * a * a * a * a;
}

float DisneyDiffuse2(float NdotV, float NdotL, float LdotH, float Roughness)
{
    float fd90 = 0.5 + 2 * LdotH * LdotH * Roughness;
    // Two schlick fresnel term
    float lightScatter = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    float viewScatter = (1 + (fd90 - 1) * Pow5(1 - NdotV));

    return lightScatter * viewScatter;
}

//D
float D_GGX_NDF(float NdotH, float Roughness)
{
    float r2 = Roughness * Roughness;
    float NdH2 = pow(NdotH, 2);
    float denom = pow(NdH2 * (r2 - 1) + 1, 2);

    return r2 / denom;
}

float3 ScaleNormal(float3 N, float Scale)
{
    N.xy *= Scale;
    N.z = sqrt(1 - saturate(dot(N.xy, N.xy)));
    return N;
}

//F
float3 FresnelSchlick(float NdotV, float3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - NdotV, 5);
}

float3 FresnelSchlickUnreal(float3 V, float3 H, float3 F0)
{
    float VDotH = max(0, dot(V, H));
    float P = exp2(-5.55473 * VDotH - 6.98316 * VDotH);

    return F0 + (1 - F0) * P;
}

half3 FresnelLerpU(half3 F0, half3 F90, half NDotV)
{
    half t = Pow5(1 - NDotV); // ala Schlick interpoliation
    return lerp(F0, F90, t);
}


//G
float GeomrtrySchlickGGX(float NdotV, float Roughness)
{
    float r = Roughness + 1.0;
    float k = (r * r) / 8.0;
    float denom = NdotV * (1.0 - k) + k;

    return NdotV / denom;
}

float GeometrySmith(float NdotV, float NdotL, float Roughness)
{
    float ggx2 = GeomrtrySchlickGGX(NdotV, Roughness);
    float ggx1 = GeomrtrySchlickGGX(NdotL, Roughness);

    return ggx1 * ggx2;
}

//TBN
float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
    return cross(normal, tangent.xyz) *
        (binormalSign * unity_WorldTransformParams.w);
}

float3 InitializeFragmentNormal(v2f i) {
    float3 tangentSpaceNormal = UnpackNormalWithScale(tex2D(_Normal, i.uv.xy), _NormalScale);
    float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
    float3 normal = normalize(
        tangentSpaceNormal.x * i.tangent +
        tangentSpaceNormal.y * binormal +
        tangentSpaceNormal.z * i.normal
    );
    return normal;
}

//Light
UnityLight CreateLight (v2f i) {
    UnityLight light;

    #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
        light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif
    light.color = _LightColor0.rgb;
    return light;
}

float3 BoxProjection (
    float3 direction, float3 position,
    float4 cubemapPosition, float3 boxMin, float3 boxMax) {
    #if UNITY_SPECCUBE_BOX_PROJECTION
        UNITY_BRANCH
        if (cubemapPosition.w > 0) {
            float3 factors =
                ((direction > 0 ? boxMax : boxMin) - position) / direction;
            float scalar = min(min(factors.x, factors.y), factors.z);
            direction = direction * scalar + (position - cubemapPosition);
        }
    #endif
    return direction;
}

UnityIndirect CreateIndirectLight (v2f i, float3 viewDir, float roughness,float AO) {
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;
    #if defined(FORWARD_BASE_PASS)
        indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
        float3 reflectionDir = reflect(-viewDir, i.normal);
        Unity_GlossyEnvironmentData envData;
        envData.roughness = roughness;
        envData.reflUVW = BoxProjection(
            reflectionDir, i.worldPos,
            unity_SpecCube0_ProbePosition,
            unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
        );
        float3 probe0 = Unity_GlossyEnvironment(
            UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData
        );
        envData.reflUVW = BoxProjection(
            reflectionDir, i.worldPos,
            unity_SpecCube1_ProbePosition,
            unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax
        );
        #if UNITY_SPECCUBE_BLENDING
            float interpolator = unity_SpecCube0_BoxMin.w;
            UNITY_BRANCH
            if (interpolator < 0.99999) {
                float3 probe1 = Unity_GlossyEnvironment(
                    UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0),
                    unity_SpecCube0_HDR, envData
                );
                indirectLight.specular = lerp(probe1, probe0, interpolator);
            }
            else {
                indirectLight.specular = probe0;
            }
        #else
            indirectLight.specular = probe0;
        #endif

        float occlusion = AO;
        indirectLight.diffuse *= occlusion;
        indirectLight.specular *= occlusion;
    #endif

    return indirectLight;
}

//SSS
#ifdef _SSSON_ON
    sampler2D _Thickness;
    float _SSS, _fLTAmbient, _fLTDistortion, _fLTScale, _iLTPower, _flt;
    inline float3 CalculateSSSColor(float3 L, float3 N, float3 V, float thickness, float3 SSScolor)
    {
        float3 H = normalize(L + N * _fLTDistortion);
        float VdotH = pow(saturate(dot(V, -H)), _iLTPower) * _fLTScale + _fLTAmbient;
        float3 I = SSScolor * VdotH * (1 - thickness) * _SSS;
        return I;
    }
#endif

//Rim
#ifdef _USERIM_ON
    half4 _RimColor;
    float _RimStrength,_RimPow;
    float3 CalculateRimColor(float cosTheta, float3 F0)
    {
        float3 fresnelColor = 0 + (1.0 - F0) * pow(1.0 - cosTheta,_RimPow);
        fresnelColor *= _RimColor * _RimStrength;
        return fresnelColor;
    }
#endif

#endif