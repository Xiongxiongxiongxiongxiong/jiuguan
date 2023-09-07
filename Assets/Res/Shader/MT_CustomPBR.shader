Shader "MT/MT_CustomPBR"
{
    Properties
    {
        [Header(Albedo)]
        _MainColor ("MainColor", COLOR) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" { }

        [Header(PBR)]
        _MRA ("MRA", 2D) = "white" { }
        _Roughness ("Roughtness", Range(0, 1)) = 1
        _Metallic ("Metallic", Range(0, 1)) = 1
        _AO ("AO", Range(0, 1)) = 1

        [Header(Normal)]
        [NoScaleOffset]_Normal ("Noraml", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Range(0, 5)) = 1

        [Header(Emission)]
        [NoScaleOffset]_EmissionTex ("EmissionTex", 2D) = "black" { }
        [HDR]_Emission ("Emission", COLOR) = (0, 0, 0, 0)

        [Header(Aniso)]
        [Toggle]_UseAniso ("UesAniso", int) = 0
        _AnisoNormalTex ("AnisoNoramlTex (RG-Normal,G-Weight)", 2D) = "bump" { }
        _AnisoOffset ("AnisoOffset", float) = 1

        [Header(Lighting)]
        _LightDir("Light Directional",Vector) = (0.5,0.5,0.5,1)
        [HDR]_LightColor("Light Color",Color) = (1,1,1,1)
        _EnvCube("Env Cube",Cube) = "skybox"{}
        [HDR]_AmbientColor("Ambient Color",Color) = (0.5,0.5,0.5,0.5)
        _IBL ("IBL", float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2

        [Space]
        [Toggle]_SSSON ("SSS", int) = 0
        _Thickness ("SSS Mask(R-Thickness,G-Mask)", 2D) = "white" { }
        _InternalColor ("Internal Color", Color) = (1, 1, 1, 1)
        _SSS ("SSS Intensity", float) = 1
        _fLTDistortion ("fLTDistortion", float) = 1
        _iLTPower ("iLTPower", float) = 3.5
        _fLTScale ("fLTScale", float) = 1.5
        _fLTAmbient ("fLTAmbient", float) = 1.2
        _flt ("flt", float) = 0.4

    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members normal,worldPos)
            //	#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase

            #pragma shader_feature _USEANISO_ON _SSSON_ON
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 noraml: NORMAL;
                float4 tangent: TANGENT;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos: SV_POSITION;
                SHADOW_COORDS(7)
                float3 normal: NORMAL;
                float3 worldPos: TEXCOORD2;

                float4 tSpace0: TEXCOORD3;
                float4 tSpace1: TEXCOORD4;
                float4 tSpace2: TEXCOORD5;
            };

            sampler2D _MainTex;
            sampler2D _Normal;
            sampler2D _MRA;
            sampler2D _EmissionTex;
            sampler2D _AnisoNormalTex;
            //samplerCUBE _EnvCube;
            UNITY_DECLARE_TEXCUBE(_EnvCube);
            half4 _MainColor;
            half3 _Emission;
            float _Roughness;
            float _Metallic;
            float _AO;
            float _AnisoOffset;
            float _IBL;
            float4 _MainTex_ST;
            half4 _AmbientColor;
            float _NormalScale;
            float3 _LightDir;
            float3 _LightColor;

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

            //SSS
            #ifdef _SSSON_ON
                sampler2D _Thickness;
                float3 _InternalColor;
                float _SSS, _fLTAmbient, _fLTDistortion, _fLTScale, _iLTPower, _flt;

                inline float3 SubsurfaceShadingSimple(float3 diffColor, float3 normal, float3 viewDir, float3 thickness,
                                                      float3 lightDir, float3 lightColor)
                {
                    half3 vLTLight = lightDir + normal * _fLTDistortion;
                    half fLTDot = pow(saturate(dot(viewDir, -vLTLight)), _iLTPower) * _fLTScale;
                    half3 fLT = 1 * (fLTDot + _fLTAmbient) * (thickness);
                    return diffColor * ((lightColor * fLT) * _flt);
                }
            #endif


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_SHADOW(o)

                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.noraml));
                o.normal = worldNormal;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = worldPos;

                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
                o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                _Roughness = _Roughness * _Roughness;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                half3 mra = tex2D(_MRA, i.uv);
                fixed3 Emission = tex2D(_EmissionTex, i.uv) * _Emission;

                half atten = SHADOW_ATTENUATION(i);

                half _RTex = pow(mra.g, 2) * _Roughness;
                _RTex = max(0.002, _RTex);
                half _MTex = mra.r * _Metallic;
                fixed AO = lerp(mra.b, 1, _AO);

                #ifdef UNITY_COLORSPACE_GAMMA
					half3 F0 = lerp(half3(0.220916301, 0.220916301, 0.220916301), col.rgb, _MTex);
                #else
                half3 F0 = lerp(half3(0.04, 0.04, 0.04), col.rgb, _MTex);
                #endif

                half3 diffuseColor = col.rgb * (1 - _MTex);

                //TBN
                float3 worldN;
                float3 normal = UnpackNormalWithScale(tex2D(_Normal, i.uv), _NormalScale);
                worldN.x = dot(i.tSpace0.xyz, normal.xyz);
                worldN.y = dot(i.tSpace1.xyz, normal.xyz);
                worldN.z = dot(i.tSpace2.xyz, normal.xyz);
                worldN = normalize(worldN);

                //Vector
                float3 N = normalize(worldN);
                float3 L = normalize(UnityObjectToWorldDir(_LightDir)).xyz;
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 H = normalize(V + L);
                float3 R = reflect(-V, N);

                float NdotL = max(0, dot(N, L));
                float NdotV = max(0, dot(N, V));
                float LdotH = max(0, dot(L, H));
                float NdotH = max(0, dot(N, H));

                //Aniso
                #ifdef _USEANISO_ON
                float3 anisoNormalTex = UnpackNormal(tex2D(_AnisoNormalTex, i.uv));
                float anisoNormalWeight = anisoNormalTex.z * 0.5 + 0.5;
                anisoNormalTex = float3(anisoNormalTex.xy, 1);
                anisoNormalTex = ScaleNormal(anisoNormalTex, 1);

                float3 worldAnisoN;
                worldAnisoN.x = dot(i.tSpace0.xyz, anisoNormalTex);
                worldAnisoN.y = dot(i.tSpace1.xyz, anisoNormalTex);
                worldAnisoN.z = dot(i.tSpace2.xyz, anisoNormalTex);
                float3 nAniso = normalize(worldAnisoN);

                float nhAniso = max(0, dot(nAniso, H));
                float aniso = max(sin(radians(nhAniso + _AnisoOffset) * 180), 0);

                NdotH = lerp(NdotH, aniso, anisoNormalWeight);
                #endif

                //PBR
                float diffuseTerm = DisneyDiffuse2(NdotV, NdotL, LdotH, _RTex);
                //BRDF
                float NDF = D_GGX_NDF(NdotH, _RTex);
                float G = GeometrySmith(NdotL, NdotV, _RTex);
                float3 F = FresnelSchlick(NdotV, F0);


                half F90 = saturate(sqrt(1 - _RTex) + (1 - _MTex));
                float3 FL = FresnelLerpU(F0, F90, NdotV);

                half3 nom = NDF * F * G;
                half3 denom = 4 * NdotV * NdotL + 0.002;
                half3 brdf = nom / denom;

                //SKYBOX
                half4 evnSample = UNITY_SAMPLE_TEXCUBE_LOD(_EnvCube, R, _RTex * 16);
                half3 skyDate = DecodeHDR(evnSample, unity_SpecCube0_HDR);

                //Light
                half3 LightAtten = NdotL; //*atten ;
                half3 LightColor = _LightColor.rgb * LightAtten;

                //Color
                half3 PBRColor = diffuseColor * diffuseTerm + brdf;

                half3 ambient = _AmbientColor * AO;
                col.rgb = PBRColor * LightColor * AO
                    + ambient * diffuseColor
                    + _IBL * LightAtten * FL * ambient;
                //SSS
                #ifdef _SSSON_ON
                    half3 sss_mask = tex2D(_Thickness, i.uv);
                    half3 SSSColor = SubsurfaceShadingSimple(_InternalColor, N, V, sss_mask.g * _SSS, L, LightColor);
                    col.rgb += SSSColor*sss_mask.r;
                #endif

                half4 finalCol = half4(col.rgb, 1);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }
            ENDCG

        }
    }
    Fallback "Diffuse"
}