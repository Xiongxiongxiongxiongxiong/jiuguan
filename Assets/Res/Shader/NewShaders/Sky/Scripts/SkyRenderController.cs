using System;
using UnityEngine;

namespace Renderering.Sky
{
    [ExecuteInEditMode]
    public class SkyRenderController : MonoBehaviour
    {
#if UNITY_EDITOR
        [SerializeField] private bool _referencesHeaderGroup;
        [SerializeField] private bool _scatteringHeaderGroup;
        [SerializeField] private bool _outerSpaceHeaderGroup;
        [SerializeField] private bool _fogScatteringHeaderGroup;
        [SerializeField] private bool _cloudsHeaderGroup;
        [SerializeField] private bool _optionsHeaderGroup;
#endif

        // References
        [Tooltip("The Transform used to simulate the sun position in the sky.")] [SerializeField]
        private Transform _sunTransform = null;

        [Tooltip("The Transform used to simulate the moon position in the sky.")] [SerializeField]
        private Transform _moonTransform = null;

        [Tooltip("The material used to render the sky.")] [SerializeField]
        private Material _skyMaterial = null;

        [Tooltip("The material used to render the fog scattering.")] [SerializeField]
        private Material _fogMaterial = null;

        [Tooltip("The shader used to render the sky only.")] [SerializeField]
        private Shader _emptySkyShader = null;

        [Tooltip("The shader used to render the sky with static clouds.")] [SerializeField]
        private Shader _staticCloudsShader = null;

        [Tooltip("The shader used to render the sky with dynamic clouds.")] [SerializeField]
        private Shader _dynamicCloudsShader = null;

        [Tooltip("The texture used to render the sun disk.")] [SerializeField]
        private Texture2D _sunTexture = null;

        [Tooltip("The texture used to render the moon disk.")] [SerializeField]
        private Texture2D _moonTexture = null;

        [Tooltip("The cubemap texture used to render the stars and Milky Way.")] [SerializeField]
        private Cubemap _starfieldTexture = null;

        [Tooltip("The texture used to render the dynamic clouds.")] [SerializeField]
        private Texture2D _dynamicCloudsTexture = null;

        [Tooltip("The texture used to render the static clouds.")]
        public Texture2D staticCloudTexture = null;

        // Scattering
        [Tooltip("The molecular density of the air.")]
        public float molecularDensity = 2.545f;

        [Tooltip("The red visible wavelength.")] // (380 to 740)
        public float wavelengthR = 680.0f;

        [Tooltip("The green visible wavelength.")]
        public float wavelengthG = 550.0f;

        [Tooltip("The blue visible wavelength.")]
        public float wavelengthB = 450.0f;

        [Tooltip("The rayleigh altitude in kilometers.")]
        public float kr = 8.4f;

        [Tooltip("The mie altitude in kilometers.")]
        public float km = 1.2f;

        [Tooltip("The rayleigh scattering multiplier.")]
        public float rayleigh = 1.5f;

        [Tooltip("The mie scattering multiplier.")]
        public float mie = 1.0f;

        [Tooltip("The mie distance.")] public float mieDistance = 1.0f;
        [Tooltip("The scattering intensity.")] public float scattering = 0.25f;

        [Tooltip("The sky luminance, useful when there is no moon at night sky.")]
        public float luminance = 1.5f;

        [Tooltip("The exposure of the internal sky shader tonemapping.")]
        public float exposure = 2.0f;

        [Tooltip("The rayleigh color multiplier.")]
        public Color rayleighColor = Color.white;

        [Tooltip("The mie color multiplier.")] public Color mieColor = Color.white;

        [Tooltip("The scattering color multiplier.")]
        public Color scatteringColor = Color.white;

        // Outer space
        [Tooltip("The size of the sun texture.")]
        public float sunTextureSize = 1.5f;

        [Tooltip("The intensity of the sun texture.")]
        public float sunTextureIntensity = 1.0f;

        [Tooltip("The sun texture color multiplier.")]
        public Color sunTextureColor = Color.white;

        [Tooltip("The size of the moon texture.")]
        public float moonTextureSize = 1.5f;

        [Tooltip("The intensity of the moon texture.")]
        public float moonTextureIntensity = 1.0f;

        [Tooltip("The moon texture color multiplier.")]
        public Color moonTextureColor = Color.white;

        [Tooltip("The intensity of the regular stars.")]
        public float starsIntensity = 0.5f;

        [Tooltip("The intensity of the Milky Way.")]
        public float milkyWayIntensity = 0.0f;

        [Tooltip("The star field color multiplier.")]
        public Color starfieldColor = Color.white;

        [Tooltip("The rotation of the star field on the X axis.")]
        public float starfieldRotationX = 0.0f;

        [Tooltip("The rotation of the star field on the Y axis.")]
        public float starfieldRotationY = 0.0f;

        [Tooltip("The rotation of the star field on the Z axis.")]
        public float starfieldRotationZ = 0.0f;

        // Fog scattering
        [Tooltip("The scattering scale factor.")]
        public float fogScatteringScale = 1.0f;

        [Tooltip("The distance of the global fog scattering.")]
        public float globalFogDistance = 1000.0f;

        [Tooltip("The smooth step transition from where there is no global fog to where is completely foggy.")]
        public float globalFogSmoothStep = 0.25f;

        [Tooltip("The global fog scattering density.")]
        public float globalFogDensity = 1.0f;

        [Tooltip("The distance of the height fog scattering.")]
        public float heightFogDistance = 100.0f;

        [Tooltip("The smooth step transition from where there is no height fog to where is completely foggy.")]
        public float heightFogSmoothStep = 1.0f;

        [Tooltip("The height fog scattering density.")]
        public float heightFogDensity = 0.0f;

        [Tooltip("The height fog start height.")]
        public float heightFogStart = 0.0f;

        [Tooltip("The height fog end height.")]
        public float heightFogEnd = 100.0f;

        // Clouds
        [Tooltip("The altitude of the dynamic clouds in the sky.")]
        public float dynamicCloudsAltitude = 7.5f;

        [Tooltip("The movement direction of the dynamic clouds.")]
        public float dynamicCloudsDirection = 0.0f;

        [Tooltip("The movement speed of the dynamic clouds.")]
        public float dynamicCloudsSpeed = 0.1f;

        [Tooltip("The coverage of the dynamic clouds.")]
        public float dynamicCloudsDensity = 0.75f;

        [Tooltip("The first color of the dynamic clouds.")]
        public Color dynamicCloudsColor1 = Color.white;

        [Tooltip("The second color of the dynamic clouds.")]
        public Color dynamicCloudsColor2 = Color.white;

        private Vector2 _dynamicCloudsDirection = Vector2.zero;
        public float staticCloudLayer1Speed = 0.0025f;
        public float staticCloudLayer2Speed = 0.0075f;
        private float _staticCloudLayer1Speed = 0f;
        private float _staticCloudLayer2Speed = 0f;
        public float staticCloudScattering = 1.0f;
        public float staticCloudExtinction = 1.5f;
        public float staticCloudSaturation = 2.5f;
        public float staticCloudOpacity = 1.25f;
        public Color staticCloudColor = Color.white;

        // Options
        [SerializeField] [Tooltip("The way the sky settings should be updated. By local material or by global shader properties.")]
        private ShaderUpdateMode _shaderUpdateMode = ShaderUpdateMode.Global;

        [SerializeField] [Tooltip("The way the scattering color should be performed. Automatic by the controller or by your custom colors.")]
        private ScatteringMode _scatteringMode = ScatteringMode.Automatic;

        [SerializeField] [Tooltip("The cloud render system.")]
        private CloudMode _cloudMode = CloudMode.Dynamic;

        private Quaternion _starfieldRotation;
        private Matrix4x4 _starfieldRotationMatrix;

        private static SkyRenderController _instance;

        public static SkyRenderController Instance
        {
            get
            {
                if (_instance == null)
                    _instance = GameObject.FindObjectOfType<SkyRenderController>();

                return _instance;
            }
        }

        public void SetCloudTiling(Vector4 tiling)
        {
            _skyMaterial.SetVector("_DynamicCloudTiling", tiling);
        }
        
        public void SetCloudIntensity(float intensity)
        {
            _skyMaterial.SetFloat("_DynamicCloudIntensity", intensity);
        }

        public void SetAuroraIntensity(float value)
        {
            _skyMaterial.SetFloat("_AuroraIntensity",value);
        }
        
        public void SetAuroraBrightness(float value)
        {
            _skyMaterial.SetFloat("_AuroraBrightness",value);
        }
        
        public void SetAuroraContrast(float value)
        {
            _skyMaterial.SetFloat("_AuroraContrast",value);
        }
        
        public void SetAuroraSpeed(float value)
        {
            _skyMaterial.SetFloat("_AuroraSpeed",value);
        }

        private void Awake()
        {
            _dynamicCloudsDirection = Vector2.zero;
            InitializeShaderUniforms();
        }

        private void OnEnable()
        {
            if (_skyMaterial)
                RenderSettings.skybox = _skyMaterial;
        }

        private void LateUpdate()
        {
            // In editor only
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                InitializeShaderUniforms();

                if (_skyMaterial)
                    RenderSettings.skybox = _skyMaterial;
            }
#endif

            // Clouds movement
            _dynamicCloudsDirection = ComputeCloudPosition();
            _staticCloudLayer1Speed += staticCloudLayer1Speed * Time.deltaTime;
            _staticCloudLayer2Speed += staticCloudLayer2Speed * Time.deltaTime;
            if (_staticCloudLayer1Speed >= 1.0f)
            {
                _staticCloudLayer1Speed -= 1.0f;
            }

            if (_staticCloudLayer2Speed >= 1.0f)
            {
                _staticCloudLayer2Speed -= 1.0f;
            }

            UpdateShaderUniforms();
        }

        private void InitializeShaderUniforms()
        {
            switch (_shaderUpdateMode)
            {
                case ShaderUpdateMode.Local:
                    _skyMaterial.SetTexture(SkyShaderUniforms.SunTexture, _sunTexture);
                    _skyMaterial.SetTexture(SkyShaderUniforms.MoonTexture, _moonTexture);
                    _skyMaterial.SetTexture(SkyShaderUniforms.StarFieldTexture, _starfieldTexture);
                    _skyMaterial.SetTexture(SkyShaderUniforms.DynamicCloudTexture, _dynamicCloudsTexture);
                    _skyMaterial.SetTexture(SkyShaderUniforms.StaticCloudTexture, staticCloudTexture);
                    break;
                case ShaderUpdateMode.Global:
                    Shader.SetGlobalTexture(SkyShaderUniforms.SunTexture, _sunTexture);
                    Shader.SetGlobalTexture(SkyShaderUniforms.MoonTexture, _moonTexture);
                    Shader.SetGlobalTexture(SkyShaderUniforms.StarFieldTexture, _starfieldTexture);
                    Shader.SetGlobalTexture(SkyShaderUniforms.DynamicCloudTexture, _dynamicCloudsTexture);
                    Shader.SetGlobalTexture(SkyShaderUniforms.StaticCloudTexture, staticCloudTexture);
                    break;
            }
        }

        private void UpdateShaderUniforms()
        {
            _starfieldRotation = Quaternion.Euler(starfieldRotationX, starfieldRotationY, starfieldRotationZ);
            _starfieldRotationMatrix = Matrix4x4.TRS(Vector3.zero, _starfieldRotation, Vector3.one);

            switch (_shaderUpdateMode)
            {
                case ShaderUpdateMode.Local:
                    UpdateLocalShaderUniforms(_skyMaterial);
                    UpdateLocalShaderUniforms(_fogMaterial);
                    break;
                case ShaderUpdateMode.Global:
                    UpdateGlobalShaderUniforms();
                    break;
            }
        }

        private void UpdateLocalShaderUniforms(Material mat)
        {
            mat.SetVector(SkyShaderUniforms.SunDirection, transform.InverseTransformDirection(-_sunTransform.forward));
            mat.SetVector(SkyShaderUniforms.MoonDirection, transform.InverseTransformDirection(-_moonTransform.forward));
            mat.SetMatrix(SkyShaderUniforms.SunMatrix, _sunTransform.worldToLocalMatrix);
            mat.SetMatrix(SkyShaderUniforms.MoonMatrix, _moonTransform.worldToLocalMatrix);
            mat.SetMatrix(SkyShaderUniforms.UpDirectionMatrix, transform.worldToLocalMatrix);
            mat.SetInt(SkyShaderUniforms.ScatteringMode, (int)_scatteringMode);
            mat.SetFloat(SkyShaderUniforms.Kr, kr * 1000f);
            mat.SetFloat(SkyShaderUniforms.Km, km * 1000f);
            mat.SetVector(SkyShaderUniforms.Rayleigh, ComputeRayleigh() * rayleigh);
            mat.SetVector(SkyShaderUniforms.Mie, ComputeMie() * mie);
            mat.SetFloat(SkyShaderUniforms.MieDistance, mieDistance);
            mat.SetFloat(SkyShaderUniforms.Scattering, scattering * 60f);
            mat.SetFloat(SkyShaderUniforms.Luminance, luminance);
            mat.SetFloat(SkyShaderUniforms.Exposure, exposure);
            mat.SetColor(SkyShaderUniforms.RayleighColor, rayleighColor);
            mat.SetColor(SkyShaderUniforms.MieColor, mieColor);
            mat.SetColor(SkyShaderUniforms.ScatteringColor, scatteringColor);
            mat.SetFloat(SkyShaderUniforms.SunTextureSize, sunTextureSize);
            mat.SetFloat(SkyShaderUniforms.SunTextureIntensity, sunTextureIntensity);
            mat.SetColor(SkyShaderUniforms.SunTextureColor, sunTextureColor);
            mat.SetFloat(SkyShaderUniforms.MoonTextureSize, moonTextureSize);
            mat.SetFloat(SkyShaderUniforms.MoonTextureIntensity, moonTextureIntensity);
            mat.SetColor(SkyShaderUniforms.MoonTextureColor, moonTextureColor);
            mat.SetFloat(SkyShaderUniforms.StarsIntensity, starsIntensity);
            mat.SetFloat(SkyShaderUniforms.MilkyWayIntensity, milkyWayIntensity);
            mat.SetColor(SkyShaderUniforms.StarFieldColor, starfieldColor);
            mat.SetMatrix(SkyShaderUniforms.StarFieldRotation, _starfieldRotationMatrix);
            mat.SetFloat(SkyShaderUniforms.FogScatteringScale, fogScatteringScale);
            mat.SetFloat(SkyShaderUniforms.GlobalFogDistance, globalFogDistance);
            mat.SetFloat(SkyShaderUniforms.GlobalFogSmoothStep, globalFogSmoothStep);
            mat.SetFloat(SkyShaderUniforms.GlobalFogDensity, globalFogDensity);
            mat.SetFloat(SkyShaderUniforms.HeightFogDistance, heightFogDistance);
            mat.SetFloat(SkyShaderUniforms.HeightFogSmoothStep, heightFogSmoothStep);
            mat.SetFloat(SkyShaderUniforms.HeightFogDensity, heightFogDensity);
            mat.SetFloat(SkyShaderUniforms.HeightFogStart, heightFogStart);
            mat.SetFloat(SkyShaderUniforms.HeightFogEnd, heightFogEnd);
            mat.SetFloat(SkyShaderUniforms.DynamicCloudAltitude, dynamicCloudsAltitude);
            mat.SetVector(SkyShaderUniforms.DynamicCloudDirection, _dynamicCloudsDirection);
            mat.SetFloat(SkyShaderUniforms.DynamicCloudDensity, Mathf.Lerp(25.0f, 0.0f, dynamicCloudsDensity));
            mat.SetVector(SkyShaderUniforms.DynamicCloudColor1, dynamicCloudsColor1);
            mat.SetVector(SkyShaderUniforms.DynamicCloudColor2, dynamicCloudsColor2);
            //mat.SetFloat(ShaderUniforms.StaticCloudInterpolator, staticCloudInterpolator);
            mat.SetFloat(SkyShaderUniforms.StaticCloudLayer1Speed, _staticCloudLayer1Speed);
            mat.SetFloat(SkyShaderUniforms.StaticCloudLayer2Speed, _staticCloudLayer2Speed);
            mat.SetFloat(SkyShaderUniforms.StaticCloudScattering, staticCloudScattering);
            mat.SetFloat(SkyShaderUniforms.StaticCloudExtinction, staticCloudExtinction);
            mat.SetFloat(SkyShaderUniforms.StaticCloudSaturation, staticCloudSaturation);
            mat.SetFloat(SkyShaderUniforms.StaticCloudOpacity, staticCloudOpacity);
            mat.SetVector(SkyShaderUniforms.StaticCloudColor, staticCloudColor);
        }

        private void UpdateGlobalShaderUniforms()
        {
            Shader.SetGlobalVector(SkyShaderUniforms.SunDirection, transform.InverseTransformDirection(-_sunTransform.forward));
            Shader.SetGlobalVector(SkyShaderUniforms.MoonDirection, transform.InverseTransformDirection(-_moonTransform.forward));
            Shader.SetGlobalMatrix(SkyShaderUniforms.SunMatrix, _sunTransform.worldToLocalMatrix);
            Shader.SetGlobalMatrix(SkyShaderUniforms.MoonMatrix, _moonTransform.worldToLocalMatrix);
            Shader.SetGlobalMatrix(SkyShaderUniforms.UpDirectionMatrix, transform.worldToLocalMatrix);
            Shader.SetGlobalInt(SkyShaderUniforms.ScatteringMode, (int)_scatteringMode);
            Shader.SetGlobalFloat(SkyShaderUniforms.Kr, kr * 1000f);
            Shader.SetGlobalFloat(SkyShaderUniforms.Km, km * 1000f);
            Shader.SetGlobalVector(SkyShaderUniforms.Rayleigh, ComputeRayleigh() * rayleigh);
            Shader.SetGlobalVector(SkyShaderUniforms.Mie, ComputeMie() * mie);
            Shader.SetGlobalFloat(SkyShaderUniforms.MieDistance, mieDistance);
            Shader.SetGlobalFloat(SkyShaderUniforms.Scattering, scattering * 60f);
            Shader.SetGlobalFloat(SkyShaderUniforms.Luminance, luminance);
            Shader.SetGlobalFloat(SkyShaderUniforms.Exposure, exposure);
            Shader.SetGlobalColor(SkyShaderUniforms.RayleighColor, rayleighColor);
            Shader.SetGlobalColor(SkyShaderUniforms.MieColor, mieColor);
            Shader.SetGlobalColor(SkyShaderUniforms.ScatteringColor, scatteringColor);
            Shader.SetGlobalFloat(SkyShaderUniforms.SunTextureSize, sunTextureSize);
            Shader.SetGlobalFloat(SkyShaderUniforms.SunTextureIntensity, sunTextureIntensity);
            Shader.SetGlobalColor(SkyShaderUniforms.SunTextureColor, sunTextureColor);
            Shader.SetGlobalFloat(SkyShaderUniforms.MoonTextureSize, moonTextureSize);
            Shader.SetGlobalFloat(SkyShaderUniforms.MoonTextureIntensity, moonTextureIntensity);
            Shader.SetGlobalColor(SkyShaderUniforms.MoonTextureColor, moonTextureColor);
            Shader.SetGlobalFloat(SkyShaderUniforms.StarsIntensity, starsIntensity);
            Shader.SetGlobalFloat(SkyShaderUniforms.MilkyWayIntensity, milkyWayIntensity);
            Shader.SetGlobalColor(SkyShaderUniforms.StarFieldColor, starfieldColor);
            Shader.SetGlobalMatrix(SkyShaderUniforms.StarFieldRotation, _starfieldRotationMatrix);
            Shader.SetGlobalFloat(SkyShaderUniforms.FogScatteringScale, fogScatteringScale);
            Shader.SetGlobalFloat(SkyShaderUniforms.GlobalFogDistance, globalFogDistance);
            Shader.SetGlobalFloat(SkyShaderUniforms.GlobalFogSmoothStep, globalFogSmoothStep);
            Shader.SetGlobalFloat(SkyShaderUniforms.GlobalFogDensity, globalFogDensity);
            Shader.SetGlobalFloat(SkyShaderUniforms.HeightFogDistance, heightFogDistance);
            Shader.SetGlobalFloat(SkyShaderUniforms.HeightFogSmoothStep, heightFogSmoothStep);
            Shader.SetGlobalFloat(SkyShaderUniforms.HeightFogDensity, heightFogDensity);
            Shader.SetGlobalFloat(SkyShaderUniforms.HeightFogStart, heightFogStart);
            Shader.SetGlobalFloat(SkyShaderUniforms.HeightFogEnd, heightFogEnd);
            Shader.SetGlobalFloat(SkyShaderUniforms.DynamicCloudAltitude, dynamicCloudsAltitude);
            Shader.SetGlobalVector(SkyShaderUniforms.DynamicCloudDirection, _dynamicCloudsDirection);
            Shader.SetGlobalFloat(SkyShaderUniforms.DynamicCloudDensity, Mathf.Lerp(25.0f, 0.0f, dynamicCloudsDensity));
            Shader.SetGlobalVector(SkyShaderUniforms.DynamicCloudColor1, dynamicCloudsColor1);
            Shader.SetGlobalVector(SkyShaderUniforms.DynamicCloudColor2, dynamicCloudsColor2);
            //Shader.SetGlobalFloat(ShaderUniforms.StaticCloudInterpolator, staticCloudInterpolator);
            Shader.SetGlobalFloat(SkyShaderUniforms.StaticCloudLayer1Speed, _staticCloudLayer1Speed);
            Shader.SetGlobalFloat(SkyShaderUniforms.StaticCloudLayer2Speed, _staticCloudLayer2Speed);
            Shader.SetGlobalFloat(SkyShaderUniforms.StaticCloudScattering, staticCloudScattering);
            Shader.SetGlobalFloat(SkyShaderUniforms.StaticCloudExtinction, staticCloudExtinction);
            Shader.SetGlobalFloat(SkyShaderUniforms.StaticCloudSaturation, staticCloudSaturation);
            Shader.SetGlobalFloat(SkyShaderUniforms.StaticCloudOpacity, staticCloudOpacity);
            Shader.SetGlobalVector(SkyShaderUniforms.StaticCloudColor, staticCloudColor);
        }

        /// <summary>
        /// Total rayleigh computation.
        /// </summary>
        private Vector3 ComputeRayleigh()
        {
            Vector3 rayleigh = Vector3.one;
            Vector3 lambda = new Vector3(wavelengthR, wavelengthG, wavelengthB) * 1e-9f;
            float n = 1.0003f; // Refractive index of air
            float pn = 0.035f; // Depolarization factor for standard air.
            float n2 = n * n;
            //float N = 2.545E25f;
            float N = molecularDensity * 1E25f;
            float temp = (8.0f * Mathf.PI * Mathf.PI * Mathf.PI * ((n2 - 1.0f) * (n2 - 1.0f))) / (3.0f * N) * ((6.0f + 3.0f * pn) / (6.0f - 7.0f * pn));

            rayleigh.x = temp / Mathf.Pow(lambda.x, 4.0f);
            rayleigh.y = temp / Mathf.Pow(lambda.y, 4.0f);
            rayleigh.z = temp / Mathf.Pow(lambda.z, 4.0f);

            return rayleigh;
        }

        /// <summary>
        /// Total mie computation.
        /// </summary>
        private Vector3 ComputeMie()
        {
            Vector3 mie;

            //float c = (0.6544f * Turbidity - 0.6510f) * 1e-16f;
            float c = (0.6544f * 5.0f - 0.6510f) * 10f * 1e-9f;
            Vector3 k = new Vector3(686.0f, 678.0f, 682.0f);

            mie.x = (434.0f * c * Mathf.PI * Mathf.Pow((4.0f * Mathf.PI) / wavelengthR, 2.0f) * k.x);
            mie.y = (434.0f * c * Mathf.PI * Mathf.Pow((4.0f * Mathf.PI) / wavelengthG, 2.0f) * k.y);
            mie.z = (434.0f * c * Mathf.PI * Mathf.Pow((4.0f * Mathf.PI) / wavelengthB, 2.0f) * k.z);

            //float c = (6544f * 5.0f - 6510f) * 10.0f * 1.0e-9f;
            //mie.x = (0.434f * c * Mathf.PI * Mathf.Pow((2.0f * Mathf.PI) / wavelengthR, 2.0f) * k.x) / 3.0f;
            //mie.y = (0.434f * c * Mathf.PI * Mathf.Pow((2.0f * Mathf.PI) / wavelengthG, 2.0f) * k.y) / 3.0f;
            //mie.z = (0.434f * c * Mathf.PI * Mathf.Pow((2.0f * Mathf.PI) / wavelengthB, 2.0f) * k.z) / 3.0f;

            return mie;
        }

        /// <summary>
        /// Returns the cloud uv position based on the direction and speed.
        /// </summary>
        private Vector2 ComputeCloudPosition()
        {
            float x = _dynamicCloudsDirection.x;
            float z = _dynamicCloudsDirection.y;
            float dir = Mathf.Lerp(0f, 360f, dynamicCloudsDirection);
            float windSpeed = dynamicCloudsSpeed * 0.05f * Time.deltaTime;

            x += windSpeed * Mathf.Sin(0.01745329f * dir);
            z += windSpeed * Mathf.Cos(0.01745329f * dir);

            if (x >= 1.0f) x -= 1.0f;
            if (z >= 1.0f) z -= 1.0f;

            return new Vector2(x, z);
        }

        /// <summary>
        /// Updates the material settings if there is a change from Inspector.
        /// </summary>
        public void UpdateSkySettings()
        {
            switch (_cloudMode)
            {
                case CloudMode.Off:
                    _skyMaterial.shader = _emptySkyShader;
                    break;
                case CloudMode.Static:
                    _skyMaterial.shader = _staticCloudsShader;
                    break;
                case CloudMode.Dynamic:
                    _skyMaterial.shader = _dynamicCloudsShader;
                    break;
            }
        }
    }
}