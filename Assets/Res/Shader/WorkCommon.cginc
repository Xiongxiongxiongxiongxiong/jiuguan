#ifndef WORK_COMMON
#define WORK_COMMON

struct WorkSurfaceOutput {
    fixed3 Albedo;
    fixed3 Normal;
    half3 Emission;
    half Specular;
    half Gloss;
    fixed Alpha;
    fixed Atten;
};

struct WorkSurfaceOutputStandard {
    fixed3 Albedo;
    fixed3 Normal;
    fixed3 NormalTangentSpace; // 切线空间的法线（法线贴图采样结果）by Will
    half3 Emission;
    half Metallic;
    half Smoothness;
    half Occlusion;
    fixed Alpha;
    fixed Atten;

};

#endif
