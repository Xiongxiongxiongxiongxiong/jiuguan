Shader "MT/MT_Character"
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

        _MaskTex ("MaskTex", 2D) = "white" { }
        _BRDF_LutTex ("BRDF LutTex", 2D) = "black" { }

        [Header(Lighting)]
        _MainLightCol("MainLight Color",Color) = (.55,.55,.55,1)
        _MainLightStrength ("MainLight Strength", float) = 1
        _EyeSpecularColor ("Eye Specular Color", Color) = (1, 1, 1, 1)
        _EyeSpecularStrength ("Eye Specular Strength", float) = 1
        
        [Space][Space]
        [Toggle]_UseLightA ("LightA ON/OFF", int) = 0        
        [HDR]_LightColor_A("Light A Color",Color) = (1,1,1,1)
        _LightStrength_A ("LightStrength_A", float) = 1
        _LightDir_A("Light A Directional",Vector) = (0.5,0.5,0.5)

        [Toggle]_UseLightB ("LightB ON/OFF", int) = 0       
        [HDR]_LightColor_B("Light B Color",Color) = (1,1,1,1)
        _LightStrength_B ("LightStrength_B", float) = 1
        _LightDir_B("Light B Directional",Vector) = (0.5,0.5,0.5)

        [HDR]_AmbientColor("Ambient Color",Color) = (0.5,0.5,0.5,0.5)
        [HDR]_Envlight_Color("Envlight Color",Color) = (0.6,0.5,0.47,0.5)
        _EnvLight_Lerp ("EnvLight Lerp", Range(0, 1)) = 1
        _IBL_Strength ("IBL Strength", Range(0, 1)) = 0.5

        [Header(Rim)]
        [Toggle]_UseRim ("Rim ON/OFF", int) = 0
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPow("RimPow",float) = 5
        _RimStrength("RimStrength",float) = 1

        [Header(SSS)]
        [Toggle]_SSSON ("SSS ON/OFF", int) = 0
        _Thickness ("SSS Thickness", 2D) = "white" { }
        [HDR]_InternalColor ("Internal Color", Color) = (1, 1, 1, 1)
        [HDR]_InternalColor_eye ("eye Internal Color", Color) = (1, 1, 1, 1)
        _SSS ("SSS Intensity", float) = .5
        _fLTDistortion ("SSS Distortion", float) = -.1
        _iLTPower ("SSS Power", float) = 3.5
        _fLTScale ("SSS Scale", float) = 1.5
        _fLTAmbient ("SSS Ambient", float) = 1.2


        [Space]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
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
            Cull [_CullMode]
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
            sampler2D _BRDF_LutTex;
            sampler2D _MaskTex;
            half4 _MainColor,_EyeSpecularColor;
            half3 _MainLightCol;
            float _Roughness;
            float _Metallic;
            float _AO;
            float4 _MainTex_ST;
            half3 _InternalColor,_InternalColor_eye;
            half4 _AmbientColor,_Envlight_Color;
            float _NormalScale;
            float3 _LightDir_A,_LightDir_B;
            float3 _LightColor_A,_LightColor_B;
            float _EyeSpecularStrength,_MainLightStrength,_LightStrength_A,_LightStrength_B,_EnvLight_Lerp,_IBL_Strength;

            #include "MT_Character_Util.cginc"

            half3 CalculateLight(v2f i, float3 lightDir, float3 lightCol, float3 albedo, float3 N, float3 V, float roughness,float _MTex, float3 F0){
                //Vector
                float3 R = reflect(-V, N);
                float3 L = normalize(lightDir).xyz;
                float3 H = normalize(V + L);

                float NdotV = max(0, dot(N, V));
                float NdotH = max(0, dot(N, H));
                float NdotL = max(0, dot(N, L));
                float LdotH = max(0, dot(L, H));

                //PBR
                float diffuseTerm = DisneyDiffuse2(NdotV, NdotL, LdotH, roughness);
                
                //BRDF
                float NDF = D_GGX_NDF(NdotH, roughness);
                float G = GeometrySmith(NdotL, NdotV, roughness);
                float3 F = FresnelSchlick(NdotV, F0);

                //NDF = saturate(NDF);
                half3 nom = NDF * F * G;
                half3 denom = 4 * NdotV * NdotL + 0.002;
                half3 speculerCol = nom / denom;
                speculerCol = pow(speculerCol,2 - roughness);

                //Light
                half3 LightAtten = NdotL; //*atten ;
                half3 LightColor = _MainLightCol;

                //Diffuse
                //float3 diffuseColor = kD * Diffuse_Fresnel_Burley(NdotV,NdotL,VdotH,roughness) * albedo * NdotL * light.color;
                float BRDFNdotL =dot(N, L) * 0.5 + 0.5;
                BRDFNdotL = min(0.85,BRDFNdotL);
                //BRDFNdotL = smoothstep(0,1,BRDFNdotL);
                half3 BRDFinf = tex2D(_BRDF_LutTex,float2(BRDFNdotL,1));

                //Color
                half3 PBRColor = albedo * BRDFinf * diffuseTerm + speculerCol * NdotL * saturate(dot(V, L) * 2);
                half3 col = PBRColor * LightColor;
                return col;
            }

            half3 CalculateLight_eye(v2f i, float3 lightDir, float3 lightCol, float3 albedo, float3 N, float3 V, float roughness,float _MTex, float3 F0){
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
                float diffuseTerm = DisneyDiffuse2(NdotV, NdotL, LdotH, roughness);
                                //BRDF
                float NDF = D_GGX_NDF(NdotH, roughness + 0.1);
                float G = GeometrySmith(NdotL, NdotV, roughness);
                float3 F = FresnelSchlick(NdotV, F0);

                //NDF = saturate(NDF);
                half3 nom = NDF * F * G;
                half3 denom = 4 * NdotV * NdotL + 0.002;
                half3 speculerCol = nom / denom * _EyeSpecularColor;
                //speculerCol = pow(speculerCol,2 - _RTex);
                
                //BRDF
                speculerCol = smoothstep(0.3,.6,speculerCol) * _EyeSpecularStrength;

                //Light
                half3 LightAtten = NdotL; //*atten ;
                half3 LightColor = _MainLightCol;

                //Diffuse
                float BRDFNdotL =dot(N, L) * 0.5 + 0.5;
                half3 BRDFinf = tex2D(_BRDF_LutTex,float2(BRDFNdotL,1));

                //Color
                half3 PBRColor = albedo * BRDFinf * diffuseTerm + speculerCol * NdotL;
                half3 col = PBRColor * LightColor;
                return col;
            }

            half3 CalculateLight_cloth(v2f i, float3 lightDir, float3 lightCol, float3 albedo, float3 N, float3 V, float roughness,float _MTex, float3 F0){
                //Vector
                float3 R = reflect(-V, N);
                float3 L = normalize(lightDir).xyz;
                float3 H = normalize(V + L);

                float NdotV = max(0, dot(N, V));
                float NdotH = max(0, dot(N, H));
                float NdotL = max(0, dot(N, L));
                float LdotH = max(0, dot(L, H));

                //PBR
                float diffuseTerm = DisneyDiffuse2(NdotV, NdotL, LdotH, roughness);
                
                //BRDF
                float NDF = D_GGX_NDF(NdotH, roughness);
                float G = GeometrySmith(NdotL, NdotV, roughness);
                float3 F = FresnelSchlick(NdotV, F0);

                //NDF = saturate(NDF);
                half3 nom = NDF * F * G;
                half3 denom = 4 * NdotV * NdotL + 0.002;
                half3 speculerCol = nom / denom;
                speculerCol = pow(speculerCol,2 - roughness);

                //Light
                half3 LightAtten = NdotL; //*atten ;
                half3 LightColor = _MainLightCol;

                //Diffuse
                //float3 diffuseColor = kD * Diffuse_Fresnel_Burley(NdotV,NdotL,VdotH,roughness) * albedo * NdotL * light.color;
                float BRDFNdotL =dot(N, L) * 0.5 + 0.5;
                BRDFNdotL = min(0.85,BRDFNdotL);
                //BRDFNdotL = smoothstep(0,1,BRDFNdotL);
                half3 BRDFinf = tex2D(_BRDF_LutTex,float2(BRDFNdotL,1));

                //Color
                half3 PBRColor = albedo * BRDFinf * diffuseTerm + speculerCol * NdotL * saturate(dot(V, L) * 2);
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
                float3 mask = tex2D(_MaskTex, i.uv).rgb;

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
                float3 normal = InitializeFragmentNormal(i);
                float3 N = normal;
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = max(0,dot(N,V));

                //Light
                UnityLight mainLight = CreateLight(i);
                UnityIndirect envlight = CreateIndirectLight(i,V,_RTex,AO);
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                half3 col = 0;
                if(mask.r == 1){
                    col = CalculateLight(i,mainLight.dir,mainLight.color * attenuation,albedo,N,V,_RTex,_MTex,F0)* attenuation * _MainLightStrength;
                    #ifdef _USELIGHTA_ON
                    float3 lightDirA = UnityObjectToWorldDir(_LightDir_A);
                    col += CalculateLight(i,lightDirA,_LightColor_A,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_A;
                    #endif
                    #ifdef _USELIGHTB_ON
                    float3 lightDirB = UnityObjectToWorldDir(_LightDir_B);
                    col += CalculateLight(i,lightDirB,_LightColor_B,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_B;
                    #endif
                }
                else if(mask.g == 1){
                    col = CalculateLight_eye(i,mainLight.dir,mainLight.color * attenuation,albedo,N,V,_RTex,_MTex,F0)* attenuation * _MainLightStrength;
                    #ifdef _USELIGHTA_ON
                    float3 lightDirA = UnityObjectToWorldDir(_LightDir_A);
                    col += CalculateLight_eye(i,lightDirA,_LightColor_A,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_A;
                    #endif
                    #ifdef _USELIGHTB_ON
                    float3 lightDirB = UnityObjectToWorldDir(_LightDir_B);
                    col += CalculateLight_eye(i,lightDirB,_LightColor_B,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_B;
                    #endif
                }else{
                    col = CalculateLight_cloth(i,mainLight.dir,mainLight.color * attenuation,albedo,N,V,_RTex,_MTex,F0)* attenuation * _MainLightStrength;
                    #ifdef _USELIGHTA_ON
                    float3 lightDirA = UnityWorldToObjectDir(_LightDir_A);
                    col += CalculateLight_cloth(i,lightDirA,_LightColor_A,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_A;
                    #endif
                    #ifdef _USELIGHTB_ON
                    float3 lightDirB = UnityObjectToWorldDir(_LightDir_B);
                    col += CalculateLight_cloth(i,lightDirB,_LightColor_B,albedo,N,V,_RTex,_MTex,F0) * _LightStrength_B;
                    #endif
                }

                //envlight
                float NdotL =  max(0, dot(N,mainLight.dir)); //*atten ;
                half F90 = saturate(sqrt(1 - _RTex) + (1 - _MTex));
                float3 FL = FresnelLerpU(F0, F90, NdotV) * _IBL_Strength;
            
                col += lerp(envlight.diffuse,_Envlight_Color,_EnvLight_Lerp) * diffuseColor * (1 - FL)
                    + envlight.specular * FL;
                col *= ambient;
                //SSS
                #ifdef _SSSON_ON
                    half3 sssCol = lerp(_InternalColor,_InternalColor_eye,mask.g); 
                    half3 sss_mask = tex2D(_Thickness, i.uv);
                    half3 SSSColor = CalculateSSSColor(mainLight.dir, N, V, sss_mask.r,sssCol) * mainLight.color * diffuseColor;
                    col += SSSColor;
                #endif

                //Rim
                #ifdef _USERIM_ON
                col += CalculateRimColor(NdotV,F0);
                #endif

                //col = CalculateLight(i,mainLight.dir,mainLight.color * attenuation,albedo,N,V,_RTex,_MTex,F0)* attenuation * _MainLightStrength;

                half4 finalCol = half4(col, 1);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }
            
            ENDCG
        }
    }
    Fallback "Diffuse"
}