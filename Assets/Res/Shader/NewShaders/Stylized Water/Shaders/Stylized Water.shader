Shader "MT/Builtin/StylizedWater"
{
    Properties
    {
        [Header(Densities)]
        [PowerSlider(3)]_DepthDensity ("水体深度", Range(0.0, 1.0)) = 0.05
        [PowerSlider(3)]_DistanceDensity ("距离遮罩", Range(0.0, 1.0)) = 0.1
        _Alpha("水体整体透明度",range(0,1)) = 1

        [Header(Distort)]
        [PowerSlider(3)]_DistortDensity("折射扰动强度",range(0,1)) = 0.1
        _DistortIntensity("折射强度",range(0,10)) = 5
        _DistortXOffset("折射X向偏移",range(-0.1,0.1)) = 0
        _DistortYOffset("折射Y向偏移",range(-0.1,0.1)) = 0

        [Header(Waves)]
        [NoScaleOffset] _WaveNormalMap ("水面法线", 2D) = "bump"{}
        [PowerSlider(3)]_WaveNormalIntensity("法线强度",range(0,10)) = 0.1
        _WaveNormalScale ("法线缩放", float) = 5.0
        _WaveNormalSpeed ("法线移动速度", float) = 0.1

        [Header(Base Color)]
        [HDR] _ShallowColor ("浅水颜色", Color) = (0.15, 0.35, 0.45, 1.0)
        [HDR] _DeepColor ("深水颜色", Color) = (0.15, 0.25, 0.6, 1.0)
        [HDR] _FarColor ("远处颜色", Color) = (0.1, 0.3, 0.2, 1.0)

        [Header(Subsurface Scattering)]
        [HDR] _SSSColor ("次表面散射颜色", Color) = (0.1, 0.2, 0.3, 1)
        [PowerSlider(3)]_SSSRange("次表面散射范围",range(1,10)) = 1

        [Header(Caustic)]
        [PowerSlider(3)]_CausticContribution ("焦散强度", Range(0.0, 5.0)) = 1.0
        [NoScaleOffset] _CausticTexture ("焦散纹理", 2D) = "black"{}
        _CausticScale ("焦散纹理缩放", float) = 5.0
        _CausticSpeed ("焦散移动速度", float) = 0.1
        [PowerSlider(3)]_CausticNoiseScale ("焦散扭曲程度", Range(0.0, 1.0)) = 0.2
        
//        [Header(CausticUnderWater)]
//        [NoScaleOffset]_CausticMap("水下焦散图",2D)="Black"{}

        [Header(Sun Specular)]
        [HDR]_SunSpecularColor ("高光颜色", Color) = (1, 1, 1, 1)
        _SunSpecularExponent ("高光收敛度", float) = 50

        [Header(Foam)]
        [NoScaleOffset] _FoamMap ("泡沫纹理", 2D) = "black"{}
        _FoamScale ("纹理缩放", float) = 10
        _FoamSpeed ("纹理移动速度", float) = 0.1
        [HDR]_FoamColor ("泡沫颜色,a通道可改变泡沫透明度", Color) = (1, 1, 1, 1)
        [PowerSlider(3)]_FoamRange("泡沫范围",range(0,1)) = 0
        _FoamExponent ("泡沫收敛度", float) = 5

        [Header(Edge Foam)]
        [HDR] _EdgeFoamTex("边缘泡沫纹理",2D) = "black"{}
        _EdgeFoamColor ("边缘泡沫颜色", Color) = (1, 1, 1, 1)
        _EdgeFoamDepth ("边缘泡沫范围", range(0,1)) = 0.05
        _EdgeFoamSpeed("边缘泡沫移动速度",float) = 0.01
        _EdgeFoamExponent("边缘泡沫收敛度",float) = 2
        _EdgeFoamIntensity("边缘泡沫强度",float) = 20

        [Header(Reflection)]
        [NoScaleOffset]_Cubemap ("Cubemap", Cube) = "Black" {}
        _CubeMapIntensity("Cubemap强度",range(0,5)) = 0.5
        _ReflectionContribution ("反射球强度", Range(0.0, 5.0)) = 1.0

        [Header(Shadow Mapping)]
        [Toggle(SHADOWS)]
        _FancyShadows("开启", int) = 0
        _MaxShadowDistance("阴影范围，该值同ProjectSetting->Quality->Shadow Distance", float) = 50.0
        _ShadowColor ("阴影颜色,a通道可改变阴影强度", Color) = (0, 0, 0, .5)
        
        [Header(Emission)]
        _EmissionTex("EmissionTex",2D) = "white"{}
        [HDR]_EmissionColor("EmissionColor",Color)=(0,0,0,0)
    }
    SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        GrabPass
        {
            "_GrabTexture"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "Always"
            }

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma shader_feature SHADOWS

            #include "UnityCG.cginc"
            float4x4 unity_MatrixInvVP;

            float _DepthDensity;
            float _DistanceDensity;
            float _Alpha;

            sampler2D _WaveNormalMap;
            float _WaveNormalScale;
            float _WaveNormalSpeed, _WaveNormalIntensity;

            float _DistortDensity, _DistortIntensity,_DistortXOffset,_DistortYOffset;
            sampler2D _CausticMap;

            float3 _ShallowColor;
            float3 _DeepColor;
            float3 _FarColor;

            float _ReflectionContribution;
            samplerCUBE _Cubemap;
            float _CubeMapIntensity;

            float4 _SSSColor;
            float _SSSRange;

            sampler2D _CausticTexture;
            float _CausticScale;
            float _CausticNoiseScale;
            float _CausticSpeed;
            float _CausticContribution;

            float3 _SunSpecularColor;
            float _SunSpecularExponent;

            sampler2D _FoamMap;
            float _FoamScale;
            float _FoamSpeed;
            float _FoamExponent;
            float4 _FoamColor;
            float _FoamRange;

            float3 _EdgeFoamColor;
            float _EdgeFoamDepth;
            sampler2D _EdgeFoamTex;
            float4 _EdgeFoamTex_ST;
            float _EdgeFoamSpeed, _EdgeFoamIntensity,_EdgeFoamExponent;

            sampler2D _MainDirectionalShadowMap;
            uint _FancyShadows;
            float _MaxShadowDistance;
            float4 _ShadowColor;

            sampler2D _GrabTexture;
            sampler2D _CameraDepthTexture;
            sampler2D _EmissionTex;
            float4 _EmissionTex_ST;
            float4 _EmissionColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv_EdgeFoamUV : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                float4 grabPosition : TEXCOORD2;
                float2 uv : TEXCOORD3;

                UNITY_FOG_COORDS(3)
            };

            #define PI (3.1415926536)


            // 从输入波参数返回一个简单波形(用作高度偏移)
            float SimpleWave(float2 position, float2 direction, float wavelength, float amplitude, float speed)
            {
                float x = PI * dot(position, direction) / wavelength;
                float phase = speed * _Time.y;
                return amplitude * sin(x + phase);
                return amplitude * (1 - abs(sin(x + phase)));
            }


            // 以给定的方向和速度，平移输入uv
            float2 Panner(float2 uv, float2 direction, float speed)
            {
                return uv + normalize(direction) * speed * _Time.y;
            }


            // 以波状方式呈现纹理
            // 无序地向四个方向运动
            float3 MotionFourWayChaos(sampler2D tex, float2 uv, float speed, float scale, bool unpackNormal)
            {
                float2 uv1 = Panner(uv + float2(0.000, 0.000), float2(0.1, 0.1), speed);
                float2 uv2 = Panner(uv + float2(0.418, 0.355), float2(-0.1, -0.1), speed);
                float2 uv3 = Panner(uv + float2(0.865, 0.148), float2(-0.1, 0.1), speed);
                float2 uv4 = Panner(uv + float2(0.651, 0.752), float2(0.1, -0.1), speed);

                float3 sample1;
                float3 sample2;
                float3 sample3;
                float3 sample4;

                if (unpackNormal)
                {
                    sample1 = UnpackNormalWithScale(tex2D(tex, uv1), scale).rgb;
                    sample2 = UnpackNormalWithScale(tex2D(tex, uv2), scale).rgb;
                    sample3 = UnpackNormalWithScale(tex2D(tex, uv3), scale).rgb;
                    sample4 = UnpackNormalWithScale(tex2D(tex, uv4), scale).rgb;

                    return normalize(sample1 + sample2 + sample3 + sample4);
                }
                else
                {
                    sample1 = tex2D(tex, uv1).rgb;
                    sample2 = tex2D(tex, uv2).rgb;
                    sample3 = tex2D(tex, uv3).rgb;
                    sample4 = tex2D(tex, uv4).rgb;

                    return (sample1 + sample2 + sample3 + sample4) / 4.0;
                }
            }


            float3 MotionFourWaySparkle(sampler2D tex, float2 uv, float4 coordinateScale, float speed)
            {
                float2 uv1 = Panner(uv * coordinateScale.x, float2(0.1, 0.1), speed);
                float2 uv2 = Panner(uv * coordinateScale.y, float2(-0.1, -0.1), speed);
                float2 uv3 = Panner(uv * coordinateScale.z, float2(-0.1, 0.1), speed);
                float2 uv4 = Panner(uv * coordinateScale.w, float2(0.1, -0.1), speed);

                float3 sample1 = UnpackNormal(tex2D(tex, uv1)).rgb;
                float3 sample2 = UnpackNormal(tex2D(tex, uv2)).rgb;
                float3 sample3 = UnpackNormal(tex2D(tex, uv3)).rgb;
                float3 sample4 = UnpackNormal(tex2D(tex, uv4)).rgb;

                float3 normalA = float3(sample1.x, sample2.y, 1);
                float3 normalB = float3(sample3.x, sample4.y, 1);

                return normalize(float3((normalA + normalB).xy, (normalA * normalB).z));
            }

            // 计算波形
            float GetWaveHeight(float2 worldPosition)
            {
                float2 dir1 = float2(1, 0);
                float2 dir2 = float2(1, 0);
                float wave1 = SimpleWave(worldPosition, dir1, 2, 0, 0);
                float wave2 = SimpleWave(worldPosition, dir2, 7.5, 0, 0);
                return wave1 + wave2;
            }

            // 计算波的TBN空间
            float3x3 GetWaveTBN(float2 worldPosition, float d)
            {
                float waveHeight = GetWaveHeight(worldPosition);
                float waveHeightDX = GetWaveHeight(worldPosition - float2(d, 0));
                float waveHeightDZ = GetWaveHeight(worldPosition - float2(0, d));

                // 计算Z和X方向上的偏导数，分别是正切向量和二法向量
                float3 tangent = normalize(float3(0, waveHeight - waveHeightDZ, d));
                float3 binormal = normalize(float3(d, waveHeight - waveHeightDX, 0));

                // 交叉结果得到法向量，并返回TBN矩阵。
                // 注意，TBN矩阵是正交的，即TBN^-1 = TBN^T。
                float3 normal = normalize(cross(binormal, tangent));
                return transpose(float3x3(tangent, binormal, normal));
            }

            // 返回给定世界空间位置的阴影空间坐标
            float4 GetShadowCoordinate(float3 positionWS, float4 weights)
            {
                // 计算每个级联的阴影坐标
                float4 sc0 = mul(unity_WorldToShadow[0], float4(positionWS, 1));
                float4 sc1 = mul(unity_WorldToShadow[1], float4(positionWS, 1));
                float4 sc2 = mul(unity_WorldToShadow[2], float4(positionWS, 1));
                float4 sc3 = mul(unity_WorldToShadow[3], float4(positionWS, 1));

                // 通过乘以权重得到最终的阴影坐标
                return sc0 * weights.x + sc1 * weights.y + sc2 * weights.z + sc3 * weights.w;
            }

            float GetLightVisibility(sampler2D shadowMap, float3 positionWS, float maxDistance, float2 distort, float distortIntensity)
            {
                // 计算每个阴影级联的权重
                float distFromCam = length(positionWS - _WorldSpaceCameraPos.xyz);

                // 如果我们超出阴影贴图的边缘，返回1.0(没有阴影)
                if (distFromCam > maxDistance)
                {
                    return 1.0;
                }
                float4 near = float4(distFromCam >= _LightSplitsNear);
                float4 far = float4(distFromCam <= _LightSplitsFar);
                float4 cascadeWeights = near * far;

                float4 shadowCoord = GetShadowCoordinate(positionWS, cascadeWeights);
                return tex2Dproj(shadowMap, shadowCoord - float4(distort * distortIntensity, 0, 0)) < shadowCoord.z / shadowCoord.w;
            }

            // float4 ComputeClipSpacePosition(float2 positionNDC, float deviceDepth)
            // {
            //     float4 positionCS = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);
            //
            // #if UNITY_UV_STARTS_AT_TOP
            //     // Our world space, view space, screen space and NDC space are Y-up.
            //     // Our clip space is flipped upside-down due to poor legacy Unity design.
            //     // The flip is baked into the projection matrix, so we only have to flip
            //     // manually when going from CS to NDC and back.
            //     positionCS.y = -positionCS.y;
            // #endif
            //
            //     return positionCS;
            // }
            //
            // float3 ComputeWorldSpacePosition(float2 positionNDC, float deviceDepth, float4x4 invViewProjMatrix)
            // {
            //     float4 positionCS  = ComputeClipSpacePosition(positionNDC, deviceDepth);
            //     float4 hpositionWS = mul(invViewProjMatrix, positionCS);
            //     return hpositionWS.xyz / hpositionWS.w;
            // }

            v2f vert(appdata v)
            {
                v2f o;

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 计算波形
                // o.worldPosition.y += GetWaveHeight(o.worldPosition.xz);
                o.vertex = mul(UNITY_MATRIX_VP, float4(o.worldPosition, 1));

                // o.grabPosition = ComputeGrabScreenPos(mul(UNITY_MATRIX_VP, float4(mul(unity_ObjectToWorld, v.vertex).xyz, 1)));
                o.grabPosition = ComputeGrabScreenPos(o.vertex);

                o.uv_EdgeFoamUV.xy = v.uv;
                o.uv_EdgeFoamUV.zw = TRANSFORM_TEX(v.uv, _EdgeFoamTex);
                o.uv = TRANSFORM_TEX(v.uv,_EmissionTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            
            float4 frag(v2f i) : SV_Target
            {
                // 摄像机位置指向顶点的方向
                float3 viewDirWS = normalize(i.worldPosition - _WorldSpaceCameraPos);

                // 计算世界法线
                float3x3 tangentToWorld = GetWaveTBN(i.worldPosition.xz, 0.01);
                float3 normalTS = MotionFourWayChaos(_WaveNormalMap, i.worldPosition.xz / _WaveNormalScale, _WaveNormalSpeed, _WaveNormalIntensity, true);
                float3 normalWS = mul(tangentToWorld, normalTS);

                // 计算屏幕uv
                float2 screenUV = i.grabPosition.xy / i.grabPosition.w;

                // 计算水面焦散
                float2 causticUV = i.worldPosition.xz / _CausticScale + _CausticNoiseScale * normalTS.xz;
                float3 causticColor = MotionFourWayChaos(_CausticTexture, causticUV, _CausticSpeed, 0, false) * 2;                
                
                // 计算折射
                float3 grabColor = tex2D(_GrabTexture, screenUV.xy + causticColor.xy * _DistortDensity+half2(_DistortXOffset,_DistortYOffset)).rgb * _DistortIntensity;

                // 计算深度
                float depth = tex2D(_CameraDepthTexture, screenUV.xy).x;
                float waterDepth = abs(LinearEyeDepth(depth) - LinearEyeDepth(i.vertex.z));
                depth = exp(-_DepthDensity * waterDepth);

                //距离遮罩
                float distanceMask = exp(-_DistanceDensity / 10 * length(i.worldPosition - _WorldSpaceCameraPos));

                // 阴影
                float shadowMask = 1.0;
                #ifdef SHADOWS
                shadowMask = GetLightVisibility(_MainDirectionalShadowMap, i.worldPosition, _MaxShadowDistance, causticColor.xy * _DistortDensity, 0.05);
                #endif

                // return shadowMask;

                // 计算基础色，并混合阴影
                float3 baseColor = grabColor * _ShallowColor;
                baseColor = lerp(_DeepColor, baseColor, depth);
                baseColor = lerp(_FarColor, baseColor, distanceMask);
                baseColor = lerp(_ShadowColor.rgb * _ShadowColor.a + baseColor * (1 - _ShadowColor.a), baseColor, shadowMask);

                // 菲涅尔
                float fresnelMask = 0.0 + 1.0 * pow(1.0 + dot(normalWS, -viewDirWS), 5.0);

                // 计算反射球
                float3 reflectedColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect(viewDirWS, normalWS));
                reflectedColor = reflectedColor * fresnelMask * distanceMask;
                reflectedColor = reflectedColor * _ReflectionContribution;
                reflectedColor = lerp(_ShadowColor.rgb * _ShadowColor.a + reflectedColor * (1 - _ShadowColor.a), reflectedColor, shadowMask);

                // SSS
                float3 sssColor = pow(saturate(dot(viewDirWS, _WorldSpaceLightPos0.xyz)),_SSSRange) * _SSSColor;
                // sssColor = lerp(_ShadowColor.rgb * _ShadowColor.a + sssColor * (1 - _ShadowColor.a), sssColor, shadowMask);
                
                // 焦散混合距离与阴影
                causticColor = causticColor * distanceMask;
                causticColor = causticColor * _CausticContribution;
                
                // float3 depthWS = ComputeWorldSpacePosition(screenUV, depth, unity_MatrixITMV);
                //  float CausticMask = exp(-waterDepth / 10);
                // half3 causticUpColor = MotionFourWayChaos(_CausticMap, depthWS.xz * _CausticScale, 0, 1, false) * CausticMask;
                // return float4(causticUpColor,1);
                // causticColor = lerp(_ShadowColor.rgb * _ShadowColor.a + causticColor * (1 - _ShadowColor.a), causticColor, shadowMask);

                // 高光
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 reflectDir = reflect(-lightDir,normalWS);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                // float sunSpecularMask = saturate(dot(viewDir, reflectDir));
                // sunSpecularMask = saturate(pow(sunSpecularMask, _SunSpecularExponent) * shadowMask);
                float sunSpecularMask = pow(max(0,dot(viewDir,reflectDir)),_SunSpecularExponent)* shadowMask ;
                float3 sunSpecularColor = lerp(0, _SunSpecularColor, sunSpecularMask) * distanceMask;

                // 计算边缘泡沫
                float edgeFoamMask = (exp(-waterDepth / _EdgeFoamDepth));
                float3 edgeFoam = saturate(pow(MotionFourWayChaos(_EdgeFoamTex, i.uv_EdgeFoamUV.zw, _EdgeFoamSpeed, 0, false),_EdgeFoamExponent) * edgeFoamMask * _EdgeFoamColor) * _EdgeFoamIntensity;
                // edgeFoam = lerp(_ShadowColor.rgb * _ShadowColor.a + edgeFoam * (1 - _ShadowColor.a), edgeFoam, shadowMask);

                // 计算水面泡沫
                float3 foam1 = MotionFourWayChaos(_FoamMap, i.worldPosition.xz / _FoamScale, _FoamSpeed, 0, false);
                float3 foam2 = MotionFourWayChaos(_FoamMap, i.worldPosition.xz / _FoamScale, _FoamSpeed, 0, false);
                float foamMask = saturate(dot(foam1, foam2) * saturate(3.0 * sqrt(saturate(dot(foam1.x, foam2.x))))-1+_FoamRange);
                foamMask = saturate(pow(foamMask, _FoamExponent)) * distanceMask;
                float3 foamColor = lerp(0, _FoamColor * _FoamColor.a, foamMask)*(1-edgeFoamMask);
                // foamColor = lerp(_ShadowColor.rgb * _ShadowColor.a + foamColor * (1 - _ShadowColor.a), foamColor, shadowMask);

                //CubeMap
                float3 viewR = reflect(viewDirWS, normalWS);
                float3 cubeMap = texCUBE(_Cubemap, viewR).rgb * _CubeMapIntensity ;
                cubeMap = lerp(_ShadowColor.rgb * _ShadowColor.a + cubeMap * (1 - _ShadowColor.a), cubeMap, shadowMask);

                //EmissionTex
                float3 emi = tex2D(_EmissionTex,i.uv).rgb * _EmissionColor.rgb;

                float3 color = baseColor + reflectedColor + sssColor + causticColor + sunSpecularColor + foamColor + edgeFoam + cubeMap + emi;
// return float4(emi,1);
                UNITY_APPLY_FOG(i.fogCoord, color);
                return float4(color, _Alpha);
            }
            ENDCG
        }
    }
}