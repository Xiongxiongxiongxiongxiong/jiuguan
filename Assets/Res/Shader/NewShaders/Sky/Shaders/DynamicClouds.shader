Shader "Hidden/MT/Buintin/DynamicClouds"
{
    Properties
    {
        _SunTexture("_SunTexture",2D) = "black"{}
        _MoonTexture("_MoonTexture",2D) = "black"{}
        _StarFieldTexture("_StarFieldTexture",CUBE) = "black"{}
        _DynamicCloudTexture("_DynamicCloudTexture",2D) = "black"{}
        
        _Aurora_Layer_1("Aurora_Layer_1",2D) = "black"{}        
        _Aurora_Layer_2("Aurora_Layer_2",2D) = "black"{}
        _Aurora_ColorShift("Aurora_Colorshift",2D) = "black"{}

        _AuroraColor("AuroraColor",Color) = (0.1,0.5,0.7,1)
        _AuroraIntensity("AuroraIntensity",range(0,1)) = 1
        _AuroraBrightness("AuroraBrightness",float) = 75
        _AuroraContrast("AuroraContrast",float) = 10
        _AuroraHeight("AuroraHeight",float) = 20000
        _AuroraScale("AuroraScale",float) = 0.01
        _AuroraSpeed("AuroraSpeed",float) = 0.005
        _AuroraSteps("AuroraSteps",float) = 32

        _Aurora_Tiling_Layer1("Aurora_Tiling_Layer1",vector) =(0.1,0.1,0,0.5)
        _Aurora_Tiling_Layer2("Aurora_Tiling_Layer2",vector) = (5,5,0,0.5)
        _Aurora_Tiling_ColorShift("Aurora_Tiling_ColorShift",vector) = (0.05,0.05,0,5)
    }

    SubShader
    {
        Tags
        {
            "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" "IgnoreProjector"="True"
        }
        Cull Back // Render side
        Fog
        {
            Mode Off
        } // Don't use fog
        ZWrite Off // Don't draw to depth buffer

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vertex_program
            #pragma fragment fragment_program
            #pragma target 3.0
            #include "UnityCG.cginc"

            // Constants
            #define PI 3.1415926535
            #define Pi316 0.0596831
            #define Pi14 0.07957747
            #define MieG float3(0.4375f, 1.5625f, 1.5f)

            // Textures
            uniform sampler2D _SunTexture;
            uniform sampler2D _MoonTexture;
            uniform samplerCUBE _StarFieldTexture;
            uniform sampler2D _DynamicCloudTexture;
            uniform float4 _DynamicCloudTiling;

            // Directions
            uniform float3 _SunDirection;
            uniform float3 _MoonDirection;
            uniform float4x4 _SunMatrix;
            uniform float4x4 _MoonMatrix;
            uniform float4x4 _UpDirectionMatrix;
            uniform float4x4 _StarFieldMatrix;
            uniform float4x4 _StarFieldRotationMatrix;

            // Scattering
            uniform float _FogScatteringScale;
            uniform int _ScatteringMode;
            uniform float _Kr;
            uniform float _Km;
            uniform float3 _Rayleigh;
            uniform float3 _Mie;
            uniform float _Scattering;
            uniform float _Luminance;
            uniform float _Exposure;
            uniform float4 _RayleighColor;
            uniform float4 _MieColor;
            uniform float4 _ScatteringColor;

            // Outer Space
            uniform float _SunTextureSize;
            uniform float _SunTextureIntensity;
            uniform float4 _SunTextureColor;
            uniform float _MoonTextureSize;
            uniform float _MoonTextureIntensity;
            uniform float4 _MoonTextureColor;
            uniform float _StarsIntensity;
            uniform float _MilkyWayIntensity;
            uniform float4 _StarFieldColor;

            // Clouds
            uniform float _DynamicCloudAltitude;
            uniform float2 _DynamicCloudDirection;
            uniform float _DynamicCloudDensity;
            uniform float _DynamicCloudIntensity;
            uniform float4 _DynamicCloudColor1;
            uniform float4 _DynamicCloudColor2;
            uniform float _ThunderLightningEffect;

            // Raytracing moon sphere
            bool iSphere(in float3 origin, in float3 direction, in float3 position, in float radius, out float3 normalDirection)
            {
                float3 rc = origin - position;
                float c = dot(rc, rc) - (radius * radius);
                float b = dot(direction, rc);
                float d = b * b - c;
                float t = -b - sqrt(abs(d));
                float st = step(0.0, min(t, d));
                normalDirection = normalize(-position + (origin + direction * t));

                if (st > 0.0) { return true; }
                return false;
            }

            // Mesh data
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            // Vertex to fragment
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 WorldPos : TEXCOORD0;
                float3 SunPos : TEXCOORD1;
                float3 MoonPos : TEXCOORD2;
                float3 StarPos : TEXCOORD3;
                float4 CloudUV : TEXCOORD4;
                float3 positionWS : TEXCOORD5;
            };

            // Vertex shader
            Varyings vertex_program(Attributes v)
            {
                Varyings Output = (Varyings)0;

                Output.positionCS = UnityObjectToClipPos(v.positionOS);
                Output.WorldPos = normalize(mul((float3x3)unity_WorldToObject, v.positionOS.xyz));
                Output.WorldPos = normalize(mul((float3x3)_UpDirectionMatrix, Output.WorldPos));

                // Dynamic cloud position - New
                float3 cloudPos = normalize(float3(Output.WorldPos.x, Output.WorldPos.y * _DynamicCloudAltitude, Output.WorldPos.z));
                Output.CloudUV.xy = cloudPos.xz * _DynamicCloudTiling.xy - 0.005 + _DynamicCloudDirection;
                Output.CloudUV.zw = cloudPos.xz * _DynamicCloudTiling.zw - 0.0065 + _DynamicCloudDirection;
                // Output.CloudUV.xy = cloudPos.xz * 0.25- 0.005 + _DynamicCloudDirection;
                // Output.CloudUV.zw = cloudPos.xz * 0.35- 0.0065 + _DynamicCloudDirection;

                // Outputs
                Output.SunPos = mul((float3x3)_SunMatrix, v.positionOS.xyz) * _SunTextureSize;
                Output.StarPos = mul((float3x3)_StarFieldRotationMatrix, Output.WorldPos);
                Output.StarPos = mul((float3x3)_StarFieldMatrix, Output.StarPos);
                Output.MoonPos = mul((float3x3)_MoonMatrix, v.positionOS.xyz) * 0.75 * _MoonTextureSize;
                Output.MoonPos.x *= -1.0;
                Output.positionWS =  mul( unity_ObjectToWorld, v.positionOS ).xyz;
                return Output;
            }

            sampler2D _Aurora_Layer_1;
            sampler2D _Aurora_Layer_2;
            sampler2D _Aurora_ColorShift;

            float4 _AuroraColor;
            float _AuroraIntensity;
            float _AuroraBrightness;
            float _AuroraContrast;
            float _AuroraHeight;
            float _AuroraScale;
            float _AuroraSpeed;
            float _AuroraSteps;

            float4 _Aurora_Tiling_Layer1;
            float4 _Aurora_Tiling_Layer2;
            float4 _Aurora_Tiling_ColorShift;

            float randomNoise(float3 co)
            {
                return frac(sin(dot(co.xyz, float3(17.2486, 32.76149, 368.71564))) * 32168.47512);
            }

            float4 SampleAurora(float3 uv)
            {
                float2 uv_1 = uv.xy * _Aurora_Tiling_Layer1.xy + (_Aurora_Tiling_Layer1.zw * _AuroraSpeed * _Time.y);

                float4 aurora = tex2Dlod(_Aurora_Layer_1, float4(uv_1.xy, 0, 0));

                float2 uv_2 = uv_1 * _Aurora_Tiling_Layer2.xy + (_Aurora_Tiling_Layer2.zw * _AuroraSpeed * _Time.y);
                float4 aurora2 = tex2Dlod(_Aurora_Layer_2, float4(uv_2.xy, 0, 0));
                aurora += (aurora2 - 0.5) * 0.5;

                aurora.w = aurora.w * 0.8 + 0.05;

                float3 uv_3 = float3(uv.xy * _Aurora_Tiling_ColorShift.xy + (_Aurora_Tiling_ColorShift.zw * _AuroraSpeed * _Time.y), 0.0);
                float4 cloudColor = tex2Dlod(_Aurora_ColorShift, float4(uv_3.xy, 0, 0));

                float contrastMask = 1.0 - saturate(aurora.a);
                contrastMask = pow(contrastMask, _AuroraContrast);
                aurora.rgb *= lerp(float3(0, 0, 0), _AuroraColor.rgb * cloudColor.rgb * _AuroraBrightness * 100, contrastMask);

                float cloudSub = 1.0 - uv.z;
                aurora.a = aurora.a - cloudSub * cloudSub;
                aurora.a = saturate(aurora.a * _AuroraIntensity);
                aurora.rgb *= aurora.a;

                return aurora;
            }

            float4 Aurora(float3 wpos)
            {
                if (_AuroraIntensity < 0.05)
                    return float4(0, 0, 0, 0);

                float3 viewDir = normalize(wpos - _WorldSpaceCameraPos);

                float viewFalloff = 1.0 - saturate(dot(viewDir, float3(0, 1, 0)));

                if (viewDir.y < 0 || viewDir.y > 1)
                    return half4(0, 0, 0, 0);

                float3 traceDir = normalize(viewDir + float3(0, viewFalloff * 0.2, 0));

                float3 worldPos = _WorldSpaceCameraPos + traceDir * ((_AuroraHeight - _WorldSpaceCameraPos.y) / max(traceDir.y, 0.01));
                float3 uv = float3(worldPos.xz * 0.01 * _AuroraScale, 0);

                half3 uvStep = half3(traceDir.xz * -1.0 * (1.0 / traceDir.y), 1.0) * (1.0 / _AuroraSteps);
                uv += uvStep * randomNoise(wpos + _SinTime.w);

                half4 finalColor = half4(0, 0, 0, 0);

                [loop]
                for (int iCount = 0; iCount < _AuroraSteps; iCount++)
                {
                    if (finalColor.a > 1)
                        break;

                    uv += uvStep;
                    finalColor += SampleAurora(uv) * (1.0 - finalColor.a);
                }

                finalColor *= viewDir.y;

                return finalColor;
            }

            float4 fragment_program(Varyings Input) : SV_Target
            {
                float4 aurora = Aurora(Input.positionWS);

                float3 viewDir = normalize(Input.WorldPos);
                float sunCosTheta = dot(viewDir, _SunDirection);
                float moonCosTheta = dot(viewDir, _MoonDirection);
                float r = length(float3(0.0, 50.0, 0.0));
                float sunRise = saturate(dot(float3(0.0, 500.0, 0.0), _SunDirection) / r);
                float moonRise = saturate(dot(float3(0.0, 500.0, 0.0), _MoonDirection) / r);

                float zenith = acos(saturate(dot(float3(0.0, 1.0, 0.0), viewDir))) * _FogScatteringScale;
                float z = (cos(zenith) + 0.15 * pow(93.885 - ((zenith * 180.0f) / PI), -1.253));
                float SR = _Kr / z;
                float SM = _Km / z;

                float3 fex = exp(-(_Rayleigh * SR + _Mie * SM));
                float horizonExtinction = saturate((viewDir.y) * 1000.0) * fex.b;
                float moonExtinction = saturate((viewDir.y) * 2.5);
                float sunset = clamp(dot(float3(0.0, 1.0, 0.0), _SunDirection), 0.0, 0.5);
                float3 Esun = _ScatteringMode == 0 ? lerp(fex, (1.0 - fex), sunset) : _ScatteringColor;

                float rayPhase = 2.0 + 0.5 * pow(sunCosTheta, 2.0);
                float miePhase = MieG.x / pow(MieG.y - MieG.z * sunCosTheta, 1.5);
                float3 BrTheta = Pi316 * _Rayleigh * rayPhase * _RayleighColor;
                float3 BmTheta = Pi14 * _Mie * miePhase * _MieColor * sunRise;
                float3 BrmTheta = (BrTheta + BmTheta) / (_Rayleigh + _Mie);
                float3 inScatter = BrmTheta * Esun * _Scattering * (1.0 - fex);
                inScatter *= sunRise;

                rayPhase = 2.0 + 0.5 * pow(moonCosTheta, 2.0);
                miePhase = MieG.x / pow(MieG.y - MieG.z * moonCosTheta, 1.5);
                BrTheta = Pi316 * _Rayleigh * rayPhase * _RayleighColor;
                BmTheta = Pi14 * _Mie * miePhase * _MieColor * moonRise;
                BrmTheta = (BrTheta + BmTheta) / (_Rayleigh + _Mie);
                Esun = _ScatteringMode == 0 ? (1.0 - fex) : _ScatteringColor;
                float3 moonInScatter = BrmTheta * Esun * _Scattering * 0.1 * (1.0 - fex);

                moonInScatter *= 1.0 - sunRise;

                BrmTheta = BrTheta / (_Rayleigh + _Mie);
                float3 skyLuminance = BrmTheta * _ScatteringColor * _Luminance * (1.0 - fex);

                float4 tex1 = tex2D(_DynamicCloudTexture, Input.CloudUV.xy);
                float4 tex2 = tex2D(_DynamicCloudTexture, Input.CloudUV.zw);
                float3 cloud = float3(0.0, 0.0, 0.0);
                float cloudAlpha = 1.0;
                float noise1 = 1.0;
                float noise2 = 1.0;
                float mixCloud = 0.0;
                if (_DynamicCloudDensity < 25)
                {
                    noise1 = pow(tex1.g + tex2.g, 0.1);
                    noise2 = pow(tex2.b * tex1.r, 0.25);

                    cloudAlpha = saturate(pow(noise1 * noise2, _DynamicCloudDensity));
                    float3 cloud1 = lerp(_DynamicCloudColor1.rgb, float3(0.0, 0.0, 0.0), noise1);
                    float3 cloud2 = lerp(_DynamicCloudColor1.rgb, _DynamicCloudColor2.rgb, noise2) * 2.5;
                    cloud = lerp(cloud1, cloud2, noise1 * noise2);

                    float3 cloudLightning = lerp(float3(0.0, 0.0, 0.0), float3(1.0, 1.0, 1.0), saturate(pow(cloud, lerp(4.5, 2.25, 0.25)) * 500.0f));

                    cloud += cloudLightning * _ThunderLightningEffect;
                    cloudAlpha = 1.0 - cloudAlpha;
                    mixCloud = saturate((viewDir.y - 0.1) * pow(noise1 * noise2, _DynamicCloudDensity));
                }

                float3 sunTexture = tex2D(_SunTexture, Input.SunPos + 0.5).rgb * _SunTextureColor * _SunTextureIntensity;
                sunTexture = pow(sunTexture, 2.0);
                sunTexture *= fex.b * saturate(sunCosTheta);

                float3 rayOrigin = float3(0.0, 0.0, 0.0); //_WorldSpaceCameraPos;
                float3 rayDirection = viewDir;
                float3 moonPosition = _MoonDirection * 38400.0 * _MoonTextureSize;
                float3 normalDirection = float3(0.0, 0.0, 0.0);
                float3 moonColor = float3(0.0, 0.0, 0.0);
                float4 moonTexture = saturate(tex2D(_MoonTexture, Input.MoonPos.xy + 0.5) * moonCosTheta);
                float moonMask = 1.0 - moonTexture.a * _MoonTextureIntensity;
                if (iSphere(rayOrigin, rayDirection, moonPosition, 17370.0, normalDirection))
                {
                    float moonSphere = max(dot(normalDirection, _SunDirection), 0.0) * moonTexture.a * 2.0;
                    moonColor = moonTexture.rgb * moonSphere * _MoonTextureColor * _MoonTextureIntensity * moonExtinction;
                }

                float4 starTex = texCUBE(_StarFieldTexture, Input.StarPos);
                float3 stars = starTex.rgb * pow(starTex.a, 2.0) * _StarsIntensity;
                float3 milkyWay = pow(starTex.rgb, 1.5) * _MilkyWayIntensity;
                float3 starfield = (stars + milkyWay) * _StarFieldColor * horizonExtinction * moonMask;

                float3 OutputColor = inScatter + moonInScatter + skyLuminance + (sunTexture + moonColor + starfield) * cloudAlpha;

                OutputColor = saturate(1.0 - exp(-_Exposure * OutputColor));

                OutputColor = pow(OutputColor, 2.2);

                OutputColor = lerp(OutputColor, cloud, mixCloud * _DynamicCloudIntensity);

                return float4(OutputColor + aurora, 1.0);
            }
            ENDHLSL
        }
    }
}