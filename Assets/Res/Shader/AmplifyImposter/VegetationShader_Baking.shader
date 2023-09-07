/**
* @file       VegetationShaderBaking.shader
* @brief      植被材质（树叶、灌木）
* @comment    Amplify Imposter烘焙Shader
*/

Shader "XingFei/Scene/VegetationBakingShader" {
    Properties {
        [Space] _MainTex_Comment0 ("(GPU)开头的注释，表示GPU Intancing属性", Float) = 0
        [Space] _MainTex_Comment1 ("红通道控制透贴，绿通道控制叶片细节", Float) = 0
        [Space] _MainTex_Comment2 ("贴图如果为树叶,则蓝通道为纯黑， ", Float) = 0
        [Space] _MainTex_Comment3 ("如果为灌木-则蓝通道灌木树干部分为白色，其他为黑色", Float) = 0
        
        [Header(MainTex and Color)] 
        [Space]
        [NoScaleOffset]_MainTex ("主纹理。使用方法如上", 2D) = "white" {}
        [HDR]_GradientBackColor("(GPU)基础色1", Color) = (0.6117647,0.2782486,0.07843137,1.0)
        [HDR]_GradientLightColor("(GPU)基础色2", Color) = (0.5960785,0.05701598,0,1.0)
        [Toggle]_CheckGradientDir("查看渐变方向", Float) = 0.0
        _GradientRate("(GPU)渐变平衡点， 若大于0则具备两个基础色渐变的效果", Range(0,1)) = 1
        _GradientLightDir("(GPU)渐变方向", Vector) = (0,-1,0,0)

        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.35
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 2 // Back
        [Space]

        [Header(In Shadow)]
        [Toggle]_InShadow( "(GPU)是否处在阴影区域", Float ) = 0.0

        [Header(Lambert Light)]
        [Space]
        _NdotLStrength("整体明暗区域", Range(0.5,3)) = 1
        _LightenArea("暗部区域亮度", Range(0,50)) = 10
        _LightenAreaStrength("亮部区域亮度", Range(0,50)) = 10
        _AoLightArea("(GPU)AO影响的亮部区域范围", Range(0,1)) = 1
        _LambertSmoothstepMin("(GPU)明暗范围", Range(0,1)) = 0.0
        _LambertSmoothstepMax("(GPU)明暗过渡的软硬度", Range(0,1)) = 0.1

        [Header(AO)]
        [Space]
        _AoColor("(GPU)AoColor", Color) = (0.5,0.0,0.0,1.0)
        _AoLightRatio("(GPU)亮部AO强度", Range(0,1)) = 0.7
        _AoBackRatio("(GPU)暗部AO强度", Range(0,1)) = 0.0
        
        [Header(SSS)]
        [Space]
        _BackSubsurfaceDistortion("BackSubsurfaceDistortion", Range(0,1)) = 1.0
        _SSS_Strength("SSS Strength", Range(0,2)) = 0.0

        [Header(Bark)]
        [Space]
        [Toggle]_WithBark("贴图中存在树枝", Float) = 0.0
        _Bark_AO_Strength("树枝AO强度", Range(0,1)) = 1.0
        [HDR]_Bark_Color("树枝颜色", Color) = (0,0,0,0)

        [HideInInspector]_HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HideInInspector][HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)
        [HideInInspector]_TimeStopHawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.35
        [HideInInspector][HDR]_TimeStopHawkEyeColor("HawkEyeColor", Color) = (0.254902,0.3490196,0.7843138,1)
        [HideInInspector] _HighlightColor("HighlightColor", Color) = (0,0,0,0)

        //[Header(Distance ShadowMask)]
        //[Toggle]_DistanceShadowMask("近处实时阴影效果",Int) =1 // 如果不去掉的话，会干扰Shader.SetGlobalFloat()

        [Space]
        [Toggle] _WaveEffect("启用摆动效果。(顶点色a通道越白，摆幅越大)", Float) = 0.0 // _WAVEEFFECT_ON
        _WaveSpeed("摆动速度", Range(0, 10)) = 1
        _WindStrength("摆动幅度", Range(0, 1)) = 0.5
        _PhaseScale("分簇权重", Range(0,1)) = 0.5
        _PhaseSpeedRate("哪簇需要摆动", Range(0, 1)) = 0.5
        _PhaseSpeed("控制簇的摆动速度", Range(0, 1)) = 0.5

        [Space]
        [Toggle]_BoleBaking("开启树干烘焙", Float) = 0.0
    }

    CGINCLUDE
        #include "../DataTypes.cginc"
        #include "AutoLight.cginc"
        #include "../PbrHeader.cginc"
        #include "../UtilHeader.cginc"
        #include "UnityCG.cginc"
        #include "../WavingEffectHeader.cginc"

        uniform sampler2D _MainTex;
        uniform HighPrec4 _MainTex_ST; // 注意命名潜规则

        // 树枝
        uniform LowPrec _WithBark;
        uniform MidPrec _Bark_AO_Strength;
        uniform MidPrec4 _Bark_Color;

        uniform MidPrec _Cutoff;
        uniform LowPrec _WaveEffect;
        uniform MidPrec _WindStrength;
        uniform MidPrec _PhaseSpeedRate;
        uniform MidPrec _PhaseSpeed;
        uniform MidPrec _WaveSpeed;
        uniform MidPrec _PhaseScale;
    ENDCG

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Geometry"
            "RenderType"="TransparentCutout"
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend Off
            Cull [_CullMode]

            // Stencil {
                //     Ref 4
                //     WriteMask 7
                //     Comp Always
                //     Pass Replace
                //     Fail Keep
                //     ZFail Keep // 没通过depth test时不写stencil
            // }

            CGPROGRAM
            #pragma target 3.0
            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu 
            // todo：去除其他不必要的renderer配置、比如directX

            #pragma multi_compile_fwdbase 
            // #pragma multi_compile_fog // TODO : remove per object fog
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            //#pragma multi_compile _ _SHADOW_HEIGHT_MANNUALLY
            
            //_USE_CUSTOM_HEIGHT_FOG _USE_CUSTOM_DISTANCE_HEIGHT_FOG

            //#pragma multi_compile _ALWAYS_USE_BAKEATTEN

            //#pragma multi_compile _ _GRADIENT_DIR
  

            #pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR  DIRECTIONAL_COOKIE POINT_COOKIE LIGHTPROBE_SH   LIGHTMAP_SHADOW_MIXING LIGHTMAP_ON
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有： DIRECTIONAL VERTEXLIGHT_ON   
            #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH 
            
            // point light, spot light 都不投射阴影

            //GUP Instancing 自定义输入Properties
            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _InShadow)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec4, _GradientBackColor)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec4, _GradientLightColor)
                UNITY_DEFINE_INSTANCED_PROP(HighPrec4, _GradientLightDir)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _GradientRate)
                UNITY_DEFINE_INSTANCED_PROP(HighPrec4, _AoColor)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _AoLightRatio)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _AoBackRatio)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _AoLightArea)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _LambertSmoothstepMin)
                UNITY_DEFINE_INSTANCED_PROP(MidPrec, _LambertSmoothstepMax)
            UNITY_INSTANCING_BUFFER_END(Props)

            uniform MidPrec _NdotLStrength;
            // uniform MidPrec _InShadow;


            //AO
            // uniform MidPrec4 _AoColor;
            // uniform MidPrec _AoLightRatio;
            // uniform MidPrec _AoBackRatio;
            // uniform MidPrec _AoLightArea;
            

            //Gradient
            // uniform HighPrec4 _GradientLightDir;
            // uniform MidPrec _GradientRate;
            // uniform MidPrec4 _GradientLightColor;
            // uniform MidPrec4 _GradientBackColor;
            uniform MidPrec _CheckGradientDir;

            // SSS
            uniform MidPrec _BackSubsurfaceDistortion;
            uniform MidPrec _SSS_Strength;
        
            // 阴影相关
            uniform MidPrec _Shadow_Manually_ShadowFacePointY;
            uniform MidPrec _Shadow_Manually_ShadowLum;

            //Lambert smoothstep
            // uniform MidPrec _LambertSmoothstepMin;
            // uniform MidPrec _LambertSmoothstepMax;
            uniform MidPrec _LightenArea;
            uniform MidPrec _LightenAreaStrength;


            // 小世界选中高亮自发光用
            uniform MidPrec4 _HighlightColor;

            uniform LowPrec _BoleBaking;
            
            uniform MidPrec4 _PlayerPosition;


            DECLARE_DISTANCE_FOG_TEXTURE(_DistanceFogTexture);
            DECLARE_DISTANCE_FOG_PARAM1(_DistanceFogParam1);
            DECLARE_DISTANCE_FOG_PARAM2(_DistanceFogParam2);
            DECLARE_SUNFOG_PARAM1(_SunFogParam1);
            DECLARE_HEIGHTFOG_PARAM1(_HeightFogParam1);
            DECLARE_HEIGHTFOG_PARAM2(_HeightFogParam2);


            //------------------------------------

            struct VertexInput {
                HighPrec4 vertex : POSITION;
                HighPrec2 uv0 : TEXCOORD0;
                HighPrec2 uv1 : TEXCOORD1;
                HighPrec3 normal : NORMAL;
                HighPrec4 vertexColor: COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {

                HighPrec4 pos : SV_POSITION;
                HighPrec4 uv0 : TEXCOORD0;
                HighPrec2 uv1 : TEXCOORD1;
                HighPrec4 worldPos : TEXCOORD2;
                //MidPrec4 vertexColor : COLOR;                
                // MidPrec lightAtten : TEXCOORD3;
                UNITY_LIGHTING_COORDS(4,5)
                HighPrec4 worldNormal:TEXCOORD6;
                MidPrec3 pointLightColor : TEXCOORD7; 
                HighPrec3 vertexColor : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID // 仅当您要访问片元着色器中的实例化属性时才需要
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o); // 仅当您要访问片元着色器中的实例化属性时才需要
                HighPrec gradientRate = UNITY_ACCESS_INSTANCED_PROP(Props, _GradientRate);
                HighPrec4 gradientLightDir = UNITY_ACCESS_INSTANCED_PROP(Props, _GradientLightDir);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
               
                
                o.pos = mul(UNITY_MATRIX_VP, o.worldPos); 

                MidPrec3 worldNormal = normalize(mul(v.normal, (MidPrec3x3)unity_WorldToObject)); // worldInverseTranspose
                o.worldNormal.xyz = worldNormal;

                o.uv0.xy = TRANSFORM_TEX(v.uv0.xy, _MainTex);

                float3 objectToViewPos = UnityObjectToViewPos(v.vertex.xyz);
				float eyeDepth = -objectToViewPos.z;
				o.uv0.z = eyeDepth;

                o.vertexColor = v.vertexColor;

                //o.lightAtten = 1.0;
                //MidPrec vertexColorWeight = 1.0;
                #ifdef LIGHTMAP_ON 

                    // 烘焙后，不再使用顶点色的信息，明暗以烘焙光照为唯一标准
                    o.uv1 = v.uv1.xy*unity_LightmapST.xy + unity_LightmapST.zw; // 注意需要加上这个xyzw变换，不然无法正确读取lightmap

                #endif
                UNITY_TRANSFER_LIGHTING(o,v.uv1)      
                o.pointLightColor = MidPrec3(0.0h,0.0h,0.0h);
                #ifdef VERTEXLIGHT_ON
                    o.pointLightColor += Shade4PointLights (
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0, o.worldPos.xyz, o.worldNormal.xyz);
                 #endif

                // Light Calc
                //------------------------------------------------------------------------

                o.worldNormal.w = saturate(gradientRate * (dot(normalize(gradientLightDir), v.normal) * 0.5 + 0.5)); //模拟光源的渐变色,结果存储在世界法线的w

                return o;
            }

            //------------------------------------------------------------------------
            //  fragment Shader

            void frag(VertexOutput i, out half4 outGBuffer0 : SV_Target0, 
				out half4 outGBuffer1 : SV_Target1, 
				out half4 outGBuffer2 : SV_Target2, 
				out float outDepth : SV_Depth
            )
            {
                //GPU Intancing
                UNITY_SETUP_INSTANCE_ID(i);
                LowPrec inShadow = UNITY_ACCESS_INSTANCED_PROP(Props, _InShadow);
                MidPrec4 gradientBackColor = UNITY_ACCESS_INSTANCED_PROP(Props, _GradientBackColor);
                MidPrec4 gradientLightColor = UNITY_ACCESS_INSTANCED_PROP(Props, _GradientLightColor);
                MidPrec lambertSmoothstepMin = UNITY_ACCESS_INSTANCED_PROP(Props, _LambertSmoothstepMin);               
                MidPrec lambertSmoothstepMax = UNITY_ACCESS_INSTANCED_PROP(Props, _LambertSmoothstepMax);
                MidPrec4 aoColor = UNITY_ACCESS_INSTANCED_PROP(Props, _AoColor);
                MidPrec aoLightArea = UNITY_ACCESS_INSTANCED_PROP(Props, _AoLightArea);
                MidPrec aoLightRatio = UNITY_ACCESS_INSTANCED_PROP(Props, _AoLightRatio);
                MidPrec aoBackRatio = UNITY_ACCESS_INSTANCED_PROP(Props, _AoBackRatio);

                //HighPrec3 lightDir =  HighPrec3(0, 1, 0);
                HighPrec3 lightDir =  normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));

                MidPrec4 _MainTex_var = tex2D(_MainTex, i.uv0.xy);

                clip(_MainTex_var.r - _Cutoff);


                // back light sss 
                // 参考:https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-1/
                // MidPrec3 backLitDir = normalize(i.worldNormal.xyz * _BackSubsurfaceDistortion + lightDir);
                // MidPrec3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // MidPrec backSSS = saturate(saturate(dot(viewDir, -backLitDir)) * normalize(i.worldNormal.y)); //该公式影响树的底部，所以设置向下的法线不受影响
                // backSSS = backSSS * backSSS * backSSS * _SSS_Strength;

                // 控制是否处在阴影区域
                lambertSmoothstepMin = lerp(lambertSmoothstepMin, 1, inShadow);

                // Lambert 光照决定明暗面
                MidPrec NdotL = dot( i.worldNormal.xyz , lightDir);
                MidPrec halfLambert = NdotL * 0.5 + _NdotLStrength; // min:0 => 1, max:2.5 => 3
                halfLambert *= halfLambert;
                
                // 明暗度的亮度调整
                MidPrec lightenFactor = smoothstep(lambertSmoothstepMin, saturate(lambertSmoothstepMin + lambertSmoothstepMax), NdotL - (1 - i.vertexColor.r) * aoLightArea);

                //顶点色 AO
                MidPrec3 _AoColor_Var = lerp(saturate(i.vertexColor.r + aoBackRatio), saturate(i.vertexColor.r + aoLightRatio), lightenFactor);
                _AoColor_Var = lerp(aoColor, MidPrec3(1.0,1.0,1.0), _AoColor_Var);
                lightenFactor = lightenFactor * _LightenAreaStrength + _LightenArea;

                //Edge Color 叶子纹理或者叶片厚度 （采样 Maintex g通道）
                // MidPrec3 DetailColor = _DetailLightenColor.rgb * _MainTex_var.g;//  lerp(fixed3(0,0,0), _DetailLightenColor, _MainTex_var.g);
                // DetailColor *= ( saturate(i.vertexColor.r + 0.3) * halfLambert * _LightEdgeColorRatio);// lerp(fixed3(0,0,0), DetailColor, i.vertexColor.r ); // AO重的地方叶片
   
                // 用实时阴影来区分明暗面
                //MidPrec factor = smoothstep(_LambertSmoothstepMin,_LambertSmoothstepMax,giOutput.light.color)+_BackLuminance.xxx   ;    
                
                // 两个基础色的渐变，共同决定BaseColor
                //模拟光照的颜色渐变,w控制两个baseColor的渐变，渐变方向由美术设置
                MidPrec3 BaseColor = lerp(gradientBackColor, gradientLightColor, i.worldNormal.w) * _MainTex_var.g;
                

                // 最终颜色计算
                MidPrec3 finalRGB = MidPrec3(1, 1, 1);
                if(_WithBark > PROPERTY_ZERO){

                    // 如果贴图中存在树枝，则需要分别计算
                    if(_MainTex_var.b > PROPERTY_ZERO)
                    {
                        // 树干的计算（用于灌木）
                        finalRGB = _Bark_Color * lerp( 1.0, i.vertexColor.r, _Bark_AO_Strength ) * 0.1;
                    }
                    else
                    {
                        // 叶子的计算
                        finalRGB = BaseColor;
                    }   
                }else{
                    // 贴图中不存在树枝
                    finalRGB = BaseColor;
                    //finalRGB = lerp(_DarkColor.rgb, BaseColor.rgb, halfLambert ) * _AoColor_Var.rgb * lightenFactor + DetailColor + _LightColor0.rgb * backSSS * shadowAndAtten;
                }
                 
                finalRGB = min(0.99, finalRGB); // 某些角度导致halfLambert达到很大，导致产生bloom效果，会闪一下。需要限制到1以下

                // 自发光（小世界使用）
                finalRGB += _HighlightColor.rgb;

                // 点光
                finalRGB += i.pointLightColor.rgb;  
                
                float eyeDepth = i.uv0.z;
				float temp_output_4_0_g3 = ( -1.0 / UNITY_MATRIX_P[2].z );
				float temp_output_7_0_g3 = ( ( eyeDepth + temp_output_4_0_g3 ) / temp_output_4_0_g3 );
				float4 appendResult11_g3 = (float4((i.worldNormal.xyz * 0.5 + 0.5) , i.vertexColor.r));
                // UNITY_APPLY_FOG(i.fogCoord, finalRGB.rgb);
                // CALC_DISTANCE_FOG_PARAM(i.worldPos.xyz)
                // APPLY_DISTANCE_FOG(finalRGB, 1)

                // 分开烘焙树干和树叶，再合成两个贴图，会显示有问题，所以在这添加树干的烘焙处理
                if(_BoleBaking > PROPERTY_ZERO){
                    // sky light
                    //MidPrec3 skyLightColor = _LightColor0.rgb;
                    //MidPrec3 skyLightDir = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz)); // 树干光的方向为相机方向
                    //MidPrec NdotL = max(0,dot( skyLightDir.xyz, i.worldNormal.xyz));
                    MidPrec4 mainTex_var = tex2D(_MainTex, i.uv0);
                    finalRGB.rgb = mainTex_var.rgb * 0.03;
                }

                outGBuffer0 = half4(finalRGB.rgb, 1); // abledo,alpha
                outGBuffer1 = appendResult11_g3; // normal,depth
				outGBuffer2 = 1;  //specular,smoothness,ao
                outDepth = i.pos.z;
            }
            ENDCG
        }
    }
    FallBack Off
}
