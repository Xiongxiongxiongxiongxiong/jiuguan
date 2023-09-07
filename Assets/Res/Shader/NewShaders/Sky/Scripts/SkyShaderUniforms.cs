using UnityEngine;

namespace Renderering.Sky
{
    internal static class SkyShaderUniforms
    {
        // Textures
        internal static readonly int SunTexture = Shader.PropertyToID("_SunTexture");
        internal static readonly int MoonTexture = Shader.PropertyToID("_MoonTexture");
        internal static readonly int StarFieldTexture = Shader.PropertyToID("_StarFieldTexture");
        internal static readonly int DynamicCloudTexture = Shader.PropertyToID("_DynamicCloudTexture");
        internal static readonly int StaticCloudTexture = Shader.PropertyToID("_StaticCloudTexture");
        
        // Directions
        internal static readonly int SunDirection = Shader.PropertyToID("_SunDirection");
        internal static readonly int MoonDirection = Shader.PropertyToID("_MoonDirection");
        internal static readonly int SunMatrix = Shader.PropertyToID("_SunMatrix");
        internal static readonly int MoonMatrix = Shader.PropertyToID("_MoonMatrix");
        internal static readonly int UpDirectionMatrix = Shader.PropertyToID("_UpDirectionMatrix");
        internal static readonly int StarFieldMatrix = Shader.PropertyToID("_StarFieldMatrix");
        
        // Scattering
        internal static readonly int ScatteringMode = Shader.PropertyToID("_ScatteringMode");
        internal static readonly int Kr = Shader.PropertyToID("_Kr");
        internal static readonly int Km = Shader.PropertyToID("_Km");
        internal static readonly int Rayleigh = Shader.PropertyToID("_Rayleigh");
        internal static readonly int Mie = Shader.PropertyToID("_Mie");
        internal static readonly int MieDistance = Shader.PropertyToID("_MieDepth");
        internal static readonly int Scattering = Shader.PropertyToID("_Scattering");
        internal static readonly int Luminance = Shader.PropertyToID("_Luminance");
        internal static readonly int Exposure = Shader.PropertyToID("_Exposure");
        internal static readonly int RayleighColor = Shader.PropertyToID("_RayleighColor");
        internal static readonly int MieColor = Shader.PropertyToID("_MieColor");
        internal static readonly int ScatteringColor = Shader.PropertyToID("_ScatteringColor");
        
        // Outer space
        internal static readonly int SunTextureSize = Shader.PropertyToID("_SunTextureSize");
        internal static readonly int SunTextureIntensity = Shader.PropertyToID("_SunTextureIntensity");
        internal static readonly int SunTextureColor = Shader.PropertyToID("_SunTextureColor");
        internal static readonly int MoonTextureSize = Shader.PropertyToID("_MoonTextureSize");
        internal static readonly int MoonTextureIntensity = Shader.PropertyToID("_MoonTextureIntensity");
        internal static readonly int MoonTextureColor = Shader.PropertyToID("_MoonTextureColor");
        internal static readonly int StarsIntensity = Shader.PropertyToID("_StarsIntensity");
        internal static readonly int MilkyWayIntensity = Shader.PropertyToID("_MilkyWayIntensity");
        internal static readonly int StarFieldColor = Shader.PropertyToID("_StarFieldColor");
        internal static readonly int StarFieldRotation = Shader.PropertyToID("_StarFieldRotationMatrix");
        
        // Fog scattering
        internal static readonly int FogScatteringScale = Shader.PropertyToID("_FogScatteringScale");
        internal static readonly int GlobalFogDistance = Shader.PropertyToID("_GlobalFogDistance");
        internal static readonly int GlobalFogSmoothStep = Shader.PropertyToID("_GlobalFogSmooth");
        internal static readonly int GlobalFogDensity = Shader.PropertyToID("_GlobalFogDensity");
        internal static readonly int HeightFogDistance = Shader.PropertyToID("_HeightFogDistance");
        internal static readonly int HeightFogSmoothStep = Shader.PropertyToID("_HeightFogSmooth");
        internal static readonly int HeightFogDensity = Shader.PropertyToID("_HeightFogDensity");
        internal static readonly int HeightFogStart = Shader.PropertyToID("_HeightFogStart");
        internal static readonly int HeightFogEnd = Shader.PropertyToID("_HeightFogEnd");

        // Clouds
        internal static readonly int DynamicCloudAltitude = Shader.PropertyToID("_DynamicCloudAltitude");
        internal static readonly int DynamicCloudDirection = Shader.PropertyToID("_DynamicCloudDirection");
        internal static readonly int DynamicCloudDensity = Shader.PropertyToID("_DynamicCloudDensity");
        internal static readonly int DynamicCloudColor1 = Shader.PropertyToID("_DynamicCloudColor1");
        internal static readonly int DynamicCloudColor2 = Shader.PropertyToID("_DynamicCloudColor2");
        internal static readonly int ThunderLightningEffect = Shader.PropertyToID("_ThunderLightningEffect");
        internal static readonly int StaticCloudInterpolator = Shader.PropertyToID("_StaticCloudInterpolator");
        internal static readonly int StaticCloudLayer1Speed = Shader.PropertyToID("_StaticCloudLayer1Speed");
        internal static readonly int StaticCloudLayer2Speed = Shader.PropertyToID("_StaticCloudLayer2Speed");
        internal static readonly int StaticCloudColor = Shader.PropertyToID("_StaticCloudColor");
        internal static readonly int StaticCloudScattering = Shader.PropertyToID("_StaticCloudScattering");
        internal static readonly int StaticCloudExtinction = Shader.PropertyToID("_StaticCloudExtinction");
        internal static readonly int StaticCloudSaturation = Shader.PropertyToID("_StaticCloudSaturation");
        internal static readonly int StaticCloudOpacity = Shader.PropertyToID("_StaticCloudOpacity");
        
        // Aurora
        internal static readonly int AuroraLayer1Texture = Shader.PropertyToID("_Aurora_Layer_1");
        internal static readonly int AuroraLayer2Texture = Shader.PropertyToID("_Aurora_Layer_2");
        internal static readonly int AuroraColorShiftTexture = Shader.PropertyToID("_Aurora_ColorShift");
        internal static readonly int AuroraTilingLayer1 = Shader.PropertyToID("_Aurora_Tiling_Layer1");
        internal static readonly int AuroraTilingLayer2 = Shader.PropertyToID("_Aurora_Tiling_Layer2");
        internal static readonly int AuroraTilingColorShift = Shader.PropertyToID("_Aurora_Tiling_ColorShift");
        internal static readonly int AuroraColor = Shader.PropertyToID("_AuroraColor");
        internal static readonly int AuroraIntensity = Shader.PropertyToID("_AuroraIntensity");
        internal static readonly int AuroraBrightness = Shader.PropertyToID("_AuroraBrightness");
        internal static readonly int AuroraContrast = Shader.PropertyToID("_AuroraContrast");
        internal static readonly int AuroraHeight = Shader.PropertyToID("_AuroraHeight");
        internal static readonly int AuroraScale = Shader.PropertyToID("_AuroraScale");
        internal static readonly int AuroraSpeed = Shader.PropertyToID("_AuroraSpeed");
        internal static readonly int AuroraSteps = Shader.PropertyToID("_AuroraSteps");
    }
}