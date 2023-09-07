#ifndef MYHAIRBRDF_INCLUDED
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
#define MYHAIRBRDF_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

// Marchsner Model
#define PI 3.1415926
#define SQRT2PI 2.50663

inline float square(float x) {
	return x * x;
}

inline float Hair_G(float B, float Theta)
{
	return exp(-0.5 * square(Theta) / (B*B)) / (SQRT2PI * B);
}

inline float Hair_F(float CosTheta)
{
	float n = 1.55;
	float F0 = square((1 - n) / (1 + n));
	return F0 + (1 - F0) * pow(1 - CosTheta, 5);
} 

float acosFast(float inX)
{
	float x = abs(inX);
	float res = -0.156583f * x + (0.5 * PI);
	res *= sqrt(1.0f - x);
	return (inX >= 0) ? res : PI - res;
}
 

float3 HairSpecularMarschner( float roughness, float3 albedo, float3 L, float3 V, half3 N, float Shadow, float Backlit, float Area)
{   
    float3 S = 0;

    const float VoL = dot(V, L);
    const float SinThetaL = dot(N, L);
    const float SinThetaV = dot(N, V);
    float cosThetaL = sqrt(max(0, 1 - SinThetaL * SinThetaL));
    float cosThetaV = sqrt(max(0, 1 - SinThetaV * SinThetaV));
    float CosThetaD = sqrt((1 + cosThetaL * cosThetaV + SinThetaV * SinThetaL) / 2.0);

    const float3 Lp = L - SinThetaL * N;
    const float3 Vp = V - SinThetaV * N;
    const float CosPhi = dot(Lp, Vp) * rsqrt(dot(Lp, Lp) * dot(Vp, Vp) + 1e-4);
    const float CosHalfPhi = sqrt(saturate(0.5 + 0.5 * CosPhi));

    float n_prime = 1.19 / CosThetaD + 0.36 * CosThetaD;

    float Shift = 0.0499f;
    float Alpha[] =
    {
        -0.0998,//-Shift * 2,
        0.0499f,// Shift,
        0.1996  // Shift * 4
    };
    float B[] =
    {
        Area + square(roughness),
        Area + square(roughness) / 2,
        Area + square(roughness) * 2
    };

    float3 Tp;
    float Mp, Np, Fp, a, h, f;
    float ThetaH = SinThetaL + SinThetaV;
    // R
    Mp = Hair_G(B[0], ThetaH - Alpha[0]);
    Np = 0.25 * CosHalfPhi;
    Fp = Hair_F(sqrt(saturate(0.5 + 0.5 * VoL)));
    S += (Mp * Np) * (Fp * lerp(1, Backlit, saturate(-VoL))) * _SpecularInt;

    // TT
    Mp = Hair_G(B[1], ThetaH - Alpha[1]);
    a =  rcp(n_prime);
    h = CosHalfPhi * (1 + a * (0.6 - 0.8 * CosPhi));
    f = Hair_F(CosThetaD * sqrt(saturate(1 - h * h)));
    Fp = square(1 - f);
    Tp = pow(albedo, 0.5 * sqrt(1 - square((h * a))) / CosThetaD);
    Np = exp(-3.65 * CosPhi - 3.98);
    S += pow((Mp * Np) * (Fp * Tp) * Backlit * 0.5, 1.5);
    // TRT
    Mp = Hair_G(B[2], ThetaH - Alpha[2]);
    f = Hair_F( CosThetaD * 0.5f);
    Fp = square(1 - f) * f;
    Tp = pow(albedo, 0.8 / CosThetaD);
    Np = exp(17 * CosPhi - 16.78);

    S += (Mp * Np) * (Fp * Tp) * _SpecularInt;

    return S;
}


half remap(half x, half t1, half t2, half s1, half s2)
{
    return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
}


half hairStrandSpecular(fixed3 T, fixed3 V, fixed3 L, fixed specPower)
{
    fixed3 H = normalize(V + L);

    fixed HdotT = dot(T, H);
    fixed sinTH = sqrt(1 - HdotT * HdotT);
    fixed dirAtten = smoothstep(-_SpecularWidth, 0, HdotT);
    
    return dirAtten * saturate(pow(sinTH, specPower));
}

half3 shiftTangent(fixed3 T, fixed3 N, fixed shift)
{
    return normalize(T + shift * N);
}

half3 getSpecular( half3 lightColor0, 
                   half4 primaryColor, half primaryShift,
                   half4 secondaryColor, half secondaryShift,
                   half3 N, half3 T, half3 V, half3 L, half specPower, half2 uv)
{
    float shiftTex = tex2D(_SpecularShift, uv) - 0.5;

    fixed3 t1 = shiftTangent(T, N, primaryShift + shiftTex);
    fixed3 t2 = shiftTangent(T, N, secondaryShift + shiftTex);

    fixed3 specular = fixed3(0.0, 0.0, 0.0);
    specular += lightColor0 * primaryColor * hairStrandSpecular(t1, V, L, specPower) * _SpecularScale * _SpecularScale;
    specular += lightColor0 * secondaryColor * hairStrandSpecular(t2, V, L, specPower) * _SpecularScale * _SpecularScale;

    return specular;
}

half4 MY_HAIR_SHADING (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir, float3 tangent, float3 binormal, float2 uv,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    // NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
    // In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
    // but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
    // Following define allow to control this. Set it to 0 if ALU is critical on your platform.
    // This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
    // Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
    #define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

    #if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
    // The amount we shift the normal toward the view vector is defined by the dot product.
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    // A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
    //normal = normalize(normal);

    float nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
    #else
    half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
    #endif

    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // MyDiffuse term
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;
    // MySpecular term
    #ifdef UV_HORIZONTAL
        half3 specular_0 = getSpecular(
            light.color,_PrimaryColor, _PrimaryShift,_SecondaryColor,_SecondaryShift, 
            normal, tangent, viewDir, light.dir, _specPower, uv
        );
    #else
        half3 specular_0 = getSpecular(
            light.color,_PrimaryColor, _PrimaryShift,_SecondaryColor,_SecondaryShift, 
            normal, binormal, viewDir, light.dir, _specPower, uv
        );
    #endif

    float shiftTex = tex2D(_SpecularShift, uv)-0.5;
    // Specular term
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    #if UNITY_BRDF_GGX
    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    roughness = max(roughness, 0.002);
    float V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);
    #else
    // Legacy
    half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
    half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
    #endif

    float specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

    #ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
    #endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
    #endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
    #ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    #else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
    #endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    half3 kajiyacolor =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                        + specular_0
                        + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    // return half4(shiftTex,shiftTex,shiftTex,1);
    return half4(kajiyacolor, 1);
}

half4 MY_HAIR_SHADING_M (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir, float3 tangent, float3 binormal, float2 uv,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    #define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

    #if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
    // The amount we shift the normal toward the view vector is defined by the dot product.
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    // A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
    //normal = normalize(normal);

    float nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
    #else
    half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
    #endif

    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    // MyDiffuse term
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;
    // MySpecular term
    half3 specular_0 = getSpecular(
        light.color,_PrimaryColor, _PrimaryShift,_SecondaryColor,_SecondaryShift, 
        normal, binormal, viewDir, light.dir, _specPower, uv
    );

    float shiftTex = tex2D(_SpecularShift, uv) - 0.5;
    half3 shiftBinormal = shiftTangent(binormal, normal, shiftTex);
    half3 specular_m = HairSpecularMarschner(roughness,diffColor,light.dir, viewDir, shiftBinormal, 1.0f,1.0f,0.0f);


    // Specular term
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    
    #if UNITY_BRDF_GGX
    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    roughness = max(roughness, 0.002);
    float V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);
    #else
    // Legacy
    half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
    half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
    #endif

    float specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

    #ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
    #endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
    #endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
    #ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    #else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
    #endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    half3 kajiyacolor =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                        + specular_0
                        + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    half3 marschnercolor = diffColor * (gi.diffuse + light.color * diffuseTerm)
                        + specular_m * light.color
                        + surfaceReduction * 0.25 * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    return half4( marschnercolor , 1);
}

#endif  
