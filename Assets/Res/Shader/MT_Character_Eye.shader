Shader "MT/MT_Character_Eye"
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

        [Header(Lighting)]
        _SepcularStrength ("Sepcular Strength", float) = 1
        _MainLightStrength ("MainLight Strength", float) = 1
        [Toggle]_UseLightA ("LightA ON/OFF", int) = 0
        _LightDir_A("Light A Directional",Vector) = (0.5,0.5,0.5,1)
        [HDR]_LightColor_A("Light A Color",Color) = (1,1,1,1)
        _LightStrength_A ("LightStrength_A", float) = 1

        [Toggle]_UseLightB ("LightB ON/OFF", int) = 0
        _LightDir_B("Light B Directional",Vector) = (0.5,0.5,0.5,1)
        [HDR]_LightColor_B("Light B Color",Color) = (1,1,1,1)
        _LightStrength_B ("LightStrength_A", float) = 1
        [HDR]_AmbientColor("Ambient Color",Color) = (0.5,0.5,0.5,0.5)


        [Header(Rim)]
        [Toggle]_UseRim ("Rim ON/OFF", int) = 0
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPow("RimPow",float) = 5
        _RimStrength("RimStrength",float) = 1
        _BRDF_LutTex ("BRDF LutTex", 2D) = "Black" { }

        [Space]
        [Toggle]_SSSON ("SSS", int) = 0
        _Thickness ("SSS Mask(R-Thickness,G-Mask)", 2D) = "white" { }
        _InternalColor ("Internal Color", Color) = (1, 1, 1, 1)
        _SSS ("SSS Intensity", float) = .5
        _fLTDistortion ("fLTDistortion", float) = -.1
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
            Tags {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members normal,worldPos)
            //	#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #define FORWARD_BASE_PASS

            #pragma shader_feature _SSSON_ON 
            #pragma shader_feature _USELIGHTA_ON 
            #pragma shader_feature _USELIGHTB_ON 
            #pragma shader_feature _USERIM_ON
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
                SHADOW_COORDS(6)
                float3 normal: NORMAL;
                float3 worldPos: TEXCOORD2;
                float4 tangent: TEXCOORD3;

                float3 modelpos: TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _Normal;
            sampler2D _MRA;
            sampler2D _EmissionTex;
            sampler2D _BRDF_LutTex;
            half4 _MainColor;
            half3 _Emission;
            float _Roughness;
            float _Metallic;
            float _AO;
            float4 _MainTex_ST;
            half4 _AmbientColor;
            float _NormalScale;
            float3 _LightDir_A,_LightDir_B;
            float3 _LightColor_A,_LightColor_B;
            float _SepcularStrength,_MainLightStrength,_LightStrength_A,_LightStrength_B;

            #include "MT_Character_Util.cginc"

            half3 CalculateLight(v2f i, float3 lightDir, float3 lightCol, float3 albedo, float3 N, float3 V, float _RTex,float _MTex, float3 F0){
                //Vector
                float3 R = reflect(-V, N);
                float3 L = normalize(lightDir).xyz;
                float3 H = normalize(V + L);
                //H = normalize(H - 0.5 * dot(H,i.tangent.xyz) * i.tangent.xyz);

                float NdotV = max(0, dot(N, V));
                float NdotH = max(0, dot(N, H));
                float NdotL = max(0, dot(N, L));
                float LdotH = max(0, dot(L, H));

                //PBR
                float diffuseTerm = DisneyDiffuse2(NdotV, NdotL, LdotH, _RTex);
                                //BRDF
                float NDF = D_GGX_NDF(NdotH, _RTex + 0.1);
                float G = GeometrySmith(NdotL, NdotV, _RTex);
                float3 F = FresnelSchlick(NdotV, F0);

                //NDF = saturate(NDF);
                half3 nom = NDF * F * G;
                half3 denom = 4 * NdotV * NdotL + 0.002;
                half3 speculerCol = nom / denom;
                //speculerCol = pow(speculerCol,2 - _RTex);
                
                //BRDF
                speculerCol = smoothstep(0.3,.6,speculerCol) * _SepcularStrength;

                //Light
                half3 LightAtten = NdotL; //*atten ;
                half3 LightColor = lightCol;

                //Diffuse
                float curve = length(fwidth(N))/length(fwidth(i.pos));
                float BRDFNdotL =dot(N, L) * 0.5 + 0.5;
                half3 BRDFinf = tex2D(_BRDF_LutTex,float2(BRDFNdotL,1));

                //Color
                half3 PBRColor = albedo * BRDFinf * diffuseTerm + speculerCol * NdotL;
                half3 col = PBRColor * LightColor;
                return col;
            }


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.modelpos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_SHADOW(o)

                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.noraml));
                o.normal = worldNormal;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = worldPos;
                o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                _Roughness = _Roughness * _Roughness;
                // sample the texture
                fixed4 albedo = tex2D(_MainTex, i.uv) * _MainColor;
                half3 mra = tex2D(_MRA, i.uv);
                fixed3 Emission = tex2D(_EmissionTex, i.uv) * _Emission;

                half atten = SHADOW_ATTENUATION(i);

                half _RTex = pow(mra.g, 2) * _Roughness;
                _RTex = max(0.002, _RTex);
                half _MTex = mra.r * _Metallic;
                fixed AO = lerp(mra.b, 1, _AO);
                half3 ambient = lerp(_AmbientColor,1,AO);

                #ifdef UNITY_COLORSPACE_GAMMA
					half3 F0 = lerp(half3(0.220916301, 0.220916301, 0.220916301), albedo.rgb, _MTex);
                #else
                    half3 F0 = lerp(half3(0.04, 0.04, 0.04), albedo.rgb, _MTex);
                #endif

                half3 diffuseColor = albedo.rgb * (1 - _MTex);

                //TBN
                float3 N = InitializeFragmentNormal(i);
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = max(0,dot(N,V));

                UnityLight mainLight = CreateLight(i);
                UnityIndirect envlight = CreateIndirectLight(i,V,_RTex,AO);
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

                half3 col = CalculateLight(i,mainLight.dir,mainLight.color * attenuation,albedo,N,V,_RTex,_MTex,F0)* attenuation * _MainLightStrength;
                col =0;
                #ifdef _USELIGHTA_ON
                float3 lightDirA = UnityWorldToObjectDir(_LightDir_A);
                col += CalculateLight(i,lightDirA,_LightColor_A,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_A;
                #endif
                #ifdef _USELIGHTB_ON
                float3 lightDirB = UnityWorldToObjectDir(_LightDir_B);
                col += CalculateLight(i,lightDirB,_LightColor_B,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_B;
                #endif
                col *= ambient;

                //envlight
                float NdotL =  max(0, dot(N,mainLight.dir)); //*atten ;
                half F90 = saturate(sqrt(1 - _RTex) + (1 - _MTex));
                float3 FL = FresnelLerpU(F0, F90, NdotV);
            
                col += envlight.diffuse * diffuseColor
                    + envlight.specular * NdotL * FL * ambient;

                //SSS
                #ifdef _SSSON_ON
                    half3 sss_mask = tex2D(_Thickness, i.uv);
                    half3 SSSColor = CalculateSSSColor(mainLight.dir, N, V, sss_mask.r) * mainLight.color * diffuseColor;
                    col += SSSColor;
                #endif

                #ifdef _USERIM_ON
                col += CalculateRimColor(NdotV,F0);
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