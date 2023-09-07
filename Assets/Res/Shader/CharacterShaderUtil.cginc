/**
  * @file       CharacterShaderUtil.cginc
  */

#ifndef CHARACTER_SHADER_UTIL
#define CHARACTER_SHADER_UTIL


  #include "UnityCG.cginc"
  #include "UnityLightingCommon.cginc"
  #include "AutoLight.cginc"
  #include "PbrHeader.cginc"
  #include "HawkEyeHeader.cginc"


    // uniform sampler2D _RampTex;


    uniform LowPrec4 _CharacterMainLight; // 角色专用光
    // uniform MidPrec _CharacterDoToneMapping; // 角色是否参与后效的ToneMapping

    uniform sampler2D _DiffuseTex;
    uniform HighPrec4 _DiffuseTex_ST;

    uniform LowPrec _UseNormalTex;
#if _NORMALMAP
    uniform sampler2D _NormalTex;
    uniform MidPrec _UseObjNormalTex;

    // 限制光照方向相关
    uniform HighPrec3 _FaceForward; // 模型空间中的模型的正方向（比如脸的正方向），用来计算光与脸正面的夹角
    uniform HighPrec _AngleThreshold; // 超过这个角度之后，就锁死光的方向不再向更大的角度偏移
    uniform HighPrec _FaceBackwardThreshold; // 角度达到这样一个阈值后，就强制让整个mesh与光方向的点积设置为0，以实现较好的背光效果（比如脸整个全暗）
#endif

    uniform LowPrec _EmissiveMapOn;
// #if _EMISSIVEMAP
    uniform sampler2D _EmissiveTex;

    uniform LowPrec _PbrToggle;
// #endif // _EMISSIVEMAP
// #if _PBRCONTROLMAP
    uniform sampler2D _PbrControlTex;
// #else
    uniform MidPrec _MetallicControl;
    uniform MidPrec _SmoothnessControl; // 没有指定pbr材质贴图时才使用这两个参数统一调整效果
// #endif
    uniform LowPrec _UseEnvCubeTex;
    uniform MidPrec _EnvCubeLum;
#if _CUBEMAP
    uniform samplerCUBE _EnvCubeTex;
#endif
#if _ALPHATEST_ON
    uniform MidPrec _AlphaCutoff;
#endif // _ALPHATEST_ON
    uniform MidPrec4 _Color;
    uniform MidPrec4 _FaceColor;
    uniform LowPrec _EnableDyeing;
    uniform MidPrec4 _DyeColor;
    uniform MidPrec4 _DyeColor2;
    uniform MidPrec4 _AddedColor;
    uniform MidPrec4 _EmissiveColor;

    uniform LowPrec _ToonEffect;
    uniform MidPrec _ToonThreshold;
    uniform MidPrec _ToonSlopeRange;
    uniform MidPrec _BumpStrength;
    uniform MidPrec4 _ToonDark;
    uniform MidPrec4 _ToonBright;

    uniform MidPrec _EnableCustomLightDir;
    uniform MidPrec3 _CustomLightDir;
    uniform MidPrec _SpecLightYOffset;

// #if _RIMEFFECT_ON
    uniform LowPrec _RimEffect;
    uniform MidPrec _RimStrength;
    uniform MidPrec _RimPow;
    uniform MidPrec _RimRange;
    uniform MidPrec4 _RimLightColor;
// #endif

    // 强化效果
    uniform LowPrec _StrengthenRimLight;
    uniform MidPrec _StrengthenRimStrength;
    uniform MidPrec _StrengthenRimPow;
    uniform MidPrec _StrengthenRimRange;
    uniform MidPrec4 _StrengthenRimLightColor;

    uniform MidPrec _AnisoEffect;
    uniform MidPrec _AnisoSpecColorStrength;
// #if _ANISOEFFECT_ON
    uniform LowPrec _UseShiftTexForAnisoSpec;
    uniform sampler2D _AnisoSpecShiftTex;
    uniform MidPrec4 _AnisoColor; // 第一层高光
    uniform MidPrec4 _AnisoColor2;// 第二层高光
    uniform MidPrec4 _AnisoSpecColor;
    uniform MidPrec _TangentStrength;
    uniform MidPrec _TangentStrength2;
    uniform MidPrec _BinormalStrength;
    // uniform MidPrec _AnisoStrength;
    uniform MidPrec _AnisoSpecPow;
    uniform MidPrec _AnisoBumpStrength;
    uniform MidPrec _AnisoStrength; // 旧的，要删掉

    // 边缘光
    uniform LowPrec _SideRimEffect;
    uniform MidPrec _SideRimStrength;
    uniform MidPrec _SideRimPow;
    uniform MidPrec _SideRimRange;
    uniform MidPrec4 _SideRimLightColor;
    
// #endif
// #if _ALPHAPREMULTIPLY_ON
    uniform MidPrec _GlassReflectionStrength;
// #endif
#if _EYEBALLEFFECT_ON
    uniform MidPrec4 _EyeHighlightColor;
    uniform MidPrec _EyeHighlightPow;
    uniform MidPrec _EyeFakePtCenterCoordU;
    uniform MidPrec _EyeFakePtCenterCoordV;
    uniform MidPrec _EyeFakePtRadius;
#endif
#if _COLORPOSTPROCESS_ON
    uniform MidPrec _GrayRatio;
    uniform MidPrec4 _PostTintColor;
    uniform MidPrec _PostExposure;
#endif

    uniform LowPrec _HiddenEffect;
// #if _HiddenEffect_ON
    uniform MidPrec _WholeBlendRatio;
    uniform MidPrec _WholeGrayRatio;
    uniform MidPrec _SceneDoorHiddenRatio;
// #endif
#if _HIGH2LOWBAKE_ON
    uniform LowPrec _High2LowClipVal;
#endif
#if _DYESWITCH_ON
    uniform sampler2D _DyeMaskTex;
    uniform MidPrec4 _DyeMaskColor1;
    uniform MidPrec4 _DyeMaskColor2;
    uniform MidPrec4 _DyeMaskColor3;
    uniform MidPrec4 _DyeMaskColor4;
#endif
#if _SCREENCLIPSWITCH_ON
    uniform MidPrec _ScreenMinX;
    uniform MidPrec _ScreenMinY;
    uniform MidPrec _ScreenMaxX;
    uniform MidPrec _ScreenMaxY;
#endif

#if _DIRECTED_SCALE
    uniform LowPrec _DirectedScaleOn;
    uniform HighPrec _DirectedScale;
    uniform HighPrec _DirectedRange;
    uniform HighPrec4 _ScaleCenter;
#endif

    uniform LowPrec _FrozenEffect;
    uniform LowPrec _PbrControl;
    uniform MidPrec4 _IceMainColor;

    uniform MidPrec4 _PbrIceColor;
    uniform LowPrec _MetallicRatio;

    uniform MidPrec _IceRimStrength;
    uniform MidPrec _IceRimPow;
    uniform MidPrec _IceRimRange;
    uniform MidPrec4 _IceRimLightColor;

    uniform sampler2D _IceTex;
    uniform MidPrec4 _IceTexST;
    uniform MidPrec4 _IceColor1;
    uniform MidPrec4 _IceColor2;

    uniform MidPrec4 _SpecularColor;
    uniform MidPrec _SpecularPower;

    // 用于自定义环境光（背包界面等不使用场景中光照的情况）
uniform LowPrec _CustomAmbientColorEnable;
    uniform MidPrec4 _CustomAmbientColor;

    // uniform MidPrec _HawkEyeHue;
    // uniform MidPrec _HawkEyeSaturation;
    // uniform MidPrec _HawkEyeIntensity;

    uniform MidPrec _HiddenTransperancy; // 隐身半透程度
    uniform sampler2D _ScreenCopyTex;

    uniform sampler2D _BackgroundTexture; // Grab Pass

    // Render Mode
    uniform LowPrec _CutoutOn;
    uniform LowPrec _TransparentOn;

    DECLARE_DISTANCE_FOG_TEXTURE(_DistanceFogTexture);
    DECLARE_DISTANCE_FOG_PARAM1(_DistanceFogParam1);
    DECLARE_DISTANCE_FOG_PARAM2(_DistanceFogParam2);
    DECLARE_SUNFOG_PARAM1(_SunFogParam1);
    DECLARE_HEIGHTFOG_PARAM1(_HeightFogParam1);
    DECLARE_HEIGHTFOG_PARAM2(_HeightFogParam2);

//-------------------------------------------------------------------------------------
// CharacterShader Low
    struct VertexInputLow {
        HighPrec4 vertex 		: 		POSITION;
        HighPrec2 uv 			: 		TEXCOORD0;
        MidPrec3 normal 		: 		NORMAL;
        MidPrec3 vertexColor 	: 		COLOR;
    };

    struct VertexOutputLow {
        HighPrec4 pos 			: 		SV_POSITION;
        HighPrec2 uv 			: 		TEXCOORD0;
        MidPrec3 worldPos 		: TEXCOORD1;
        LIGHTING_COORDS(2,3)
        MidPrec3 worldNormal 		: TEXCOORD4;
        MidPrec3 vertexColor    : TEXCOORD5;
    };

    struct CharacterLowShadingStruct
    {
        VertexOutputLow input;
    };

    VertexOutputLow vertLowBase(VertexInputLow v) {
        VertexOutputLow o = (VertexOutputLow)0;

#ifdef _DIRECTED_SCALE
        o.pos = mul(UNITY_MATRIX_M, v.vertex);

        HighPrec3 dir = _ScaleCenter - o.pos.xyz;
        HighPrec len = length(dir);

        o.pos.xyz += dir * min(1, (max(0.1, (_DirectedRange - len)) * _DirectedScale));
        o.worldPos = o.pos.xyz;
        o.pos = mul(UNITY_MATRIX_VP, o.pos);
#else
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
#endif
        o.uv = TRANSFORM_TEX( v.uv, _DiffuseTex );
        o.worldNormal = normalize( UnityObjectToWorldNormal(v.normal));
        TRANSFER_VERTEX_TO_FRAGMENT(o);

        o.vertexColor = v.vertexColor;
        return o;
    }

inline MidPrec4 CharacterLowShading(CharacterLowShadingStruct pars){
            
        MidPrec4 albedo = tex2D(_DiffuseTex, pars.input.uv);
        MidPrec4 finalColor = albedo;

        if(_EnableDyeing > PROPERTY_ZERO){
            HighPrec4 pbrControl = tex2D(_PbrControlTex, pars.input.uv);
            MidPrec disableDyingMask = pars.input.vertexColor.g * albedo.a;
            albedo.rgb = dye( albedo.rgb, _DyeColor, _DyeColor2, pbrControl.b, disableDyingMask );
        }else{
            albedo.rgb *= _Color.rgb;
        }

        MidPrec3 skyLightColor = lerp( _LightColor0.rgb, _CharacterMainLight.rgb * 2.0, _CharacterMainLight.a ); // 乘以2是因为没有intensity的，但有时会需要超过1的光颜色
        MidPrec atten = LIGHT_ATTENUATION(pars.input);
        MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light has no position

        // Toon Effect
        MidPrec3 skyLightDiffuse = albedo.rgb * skyLightColor;
        MidPrec3 toonNormal =  pars.input.worldNormal.xyz;
        MidPrec halfLambert = dot(toonNormal, skyLightDir) * 0.5 + 0.5;
        halfLambert *= atten;
        MidPrec toonLambert = smoothstep( _ToonThreshold - _ToonSlopeRange , _ToonThreshold + _ToonSlopeRange, halfLambert - 0.5 );
        MidPrec3 rampValue = lerp( _ToonDark.rgb, _ToonBright.rgb, toonLambert );
        skyLightDiffuse *= rampValue;

        // 计算环境光
        MidPrec3 ambientSkyColor = _CustomAmbientColor.rgb * albedo.rgb;
        finalColor.rgb = skyLightDiffuse + ambientSkyColor;
              
#if _ALPHATEST_ON
        clip( finalColor.a - _AlphaCutoff );   
#endif
        return finalColor;
    }
//-------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------
// CharacterShader Very High

    struct VertexInput {
        HighPrec4 vertex   :       POSITION;
        MidPrec3 nor      :       NORMAL;
        MidPrec4 tangent  :       TANGENT;
        HighPrec2 uv       :       TEXCOORD0;
        MidPrec4 vertexColor : COLOR;
    };

    struct VertexOutput {
        HighPrec4 pos          :       SV_POSITION;
        HighPrec2 uv           :       TEXCOORD0;
        HighPrec3 eyeVec       :       TEXCOORD1; // 优化，把eyeVec在vs中计算好
        HighPrec4 worldPos     :       TEXCOORD2;
        MidPrec3 worldNormal  :       TEXCOORD3;
        MidPrec3 worldTangent :       TEXCOORD4;
        MidPrec3 worldBinormal:       TEXCOORD5;
        LIGHTING_COORDS(6,7) // 生成 _LightCoord & _ShadowCoord 变量(占用两个texcoord)，存放shadowmap采样uv
        HighPrec4 grabPos: TEXCOORD8;
        MidPrec4 vertexColor : TEXCOORD9;
        MidPrec4 skyLightDir: TEXCOORD10;
    };
    

    
    // 较原来的公式稍有修改
    // 参见 http://web.engr.oregonstate.edu/~mjb/cs519/Projects/Papers/HairRendering.pdf
    // 以及：最终自己在代码上参考的：https://www.jianshu.com/p/7dc980ea4c51
    inline MidPrec3 ShiftTangent(MidPrec3 T, MidPrec3 N, MidPrec shift)
    {
        MidPrec3 shiftedT = T + shift * N;
        return normalize(shiftedT);
    }

    // 限制光的方向在好看的范围之内
    // 主要用于主角脸部
    inline MidPrec4 ModifyLightDir( float3 _FaceForward, float _AngleThreshold, float _FaceBackwardThreshold, float4 skyLightDir  ){

        float3 faceForward = mul( _FaceForward.xyz , (float3x3)unity_WorldToObject);

        // 限制光源与脸在世界空间都只按水平方向来计算点积
        faceForward = normalize(float3(faceForward.x, 0, faceForward.z));
        // HighPrec4 skyLightDir = HighPrec4( normalize( float3( _WorldSpaceLightPos0.x, 0, _WorldSpaceLightPos0.z )), 1.0); y方向已经在本函数之前设置为0了。
        float FdotL = dot( faceForward, skyLightDir.xyz );
        float3 FcrossL = cross(faceForward, skyLightDir.xyz);
        
        float cosA = cos(_AngleThreshold * 0.01745329); //cos( _AngleThreshold * 3.1415926 * 2.0 / 360 );
        float sinA = sin(_AngleThreshold * 0.01745329); //sin( _AngleThreshold * 3.1415926 * 2.0 / 360 );
        if(FdotL < cosA){

            float3x3 rotMat = 0;
            if(FcrossL.y > 0){
                // 俯视看光源在9-12点钟方向
                rotMat = float3x3( cosA, 0, sinA,
                                0,     1, 0, 
                                -sinA, 0, cosA );
            }else{
                // 俯视看光源在0-3点钟方向
                rotMat = float3x3( cosA, 0, -sinA,
                                0,     1, 0, 
                                sinA, 0, cosA );
            }
            skyLightDir.xyz = mul( rotMat, faceForward); 

        }
        skyLightDir.w = FdotL; // 给片元用，当脸正对光照方向时，要将侧光去掉，否则有瑕疵

        float3 pivotWorldPos = mul(unity_ObjectToWorld, float3(0,0,0));
        float3 eyeVec = UNITY_MATRIX_V[2].xyz;// 用相机forward计算更加符合需求（如果逐顶点位置计算视角方向效果不佳）
        skyLightDir.y = smoothstep( 0.8, 1.0,dot(faceForward,eyeVec)); // 当正脸背对相机时，将侧光去掉

        return skyLightDir;
    }

    // ACES反函数运算，抵消ACES ToneMapping对角色颜色造成的偏色
    inline MidPrec3 antiACES( MidPrec3 albedoTexColor,MidPrec maxColorValue ){

         //y=-(\sqrt{((0.59^{2}-4\cdot2.43\cdot0.14)\cdot x^{2}+(4\cdot2.51\cdot0.14-2\cdot0.03\cdot0.59)\cdot x+0.03^{2})}+0.59\cdot x-0.03)/(2\cdot2.43\cdot x-2\cdot2.51) // will 反函数计算器
        //albedoTexColor.rgb = -(sqrt( (0.59*0.59-4*2.43*0.14)*albedoTexColor.rgb*albedoTexColor.rgb + (4*2.51*0.14-2*0.03*0.59)*albedoTexColor.rgb+0.03*0.03 )+ 0.59*albedoTexColor.rgb- 0.03)/(2*2.43*albedoTexColor.rgb-2*2.51); // 实测：还原原画的程度更高
        //3.4475 * color * color * color - 2.7866 * color * color + 1.2281 * color - 0.0056 // flashyiyi with excel
        //albedoTexColor.rgb = 3.4475 * albedoTexColor.rgb * albedoTexColor.rgb * albedoTexColor.rgb - 2.7866 * albedoTexColor.rgb * albedoTexColor.rgb + 1.2281 * albedoTexColor.rgb - 0.0056; // flashyiyi用excel算的

        // 现用的参数(2.2112f, 0.78f, 2.2448f, 0.4f)的ACES的反函数
        MidPrec3 denominator = 5612*albedoTexColor.rgb-5528;
        denominator = lerp(denominator-PROPERTY_ZERO,denominator + PROPERTY_ZERO , step(0,denominator));
        return max(0,min( maxColorValue, -(25*sqrt((-22048*albedoTexColor.rgb*albedoTexColor.rgb)+20552*albedoTexColor.rgb+1521)+500*albedoTexColor.rgb-975)/denominator)); // 最大值加了限制是因为会导致暗处饱和度过高

    }

    inline MidPrec3 RimLight( MidPrec3 normal, MidPrec3 viewDir, MidPrec rimRange, MidPrec rimPow , MidPrec rimStrength, MidPrec3 rimLightColor ){

        MidPrec backLight = abs(dot(normal, viewDir));
        backLight = saturate(1-backLight*rimRange);
        backLight =  SAFE_POW(backLight, rimPow) * rimStrength;
        MidPrec3 rimLight = backLight * rimLightColor;
        MidPrec strength = max(0, GetGraylevel(rimLight)-RIM_MAX_STRENGTH);
        rimLight *= RIM_MAX_STRENGTH / (RIM_MAX_STRENGTH+strength); // 保证边缘光亮度不超过MAX_RIM_STRENGTH
        // MidPrec rimDistFactor = 1 - saturate(length(pars.input.worldPos.xyz-_WorldSpaceCameraPos)/RIM_MAX_DISTANCE); // 离相机远至一定距离，边缘光强度消失
        // rimLight *= rimDistFactor * rimDistFactor;
        // MidPrec4 skyRim = saturate(normal.y) * rimLight; // 朝天空方向有，朝地面方向没有
        // MidPrec baseSpec = saturate(dot(skyLightDir, reflecDir)); // 法线朝向相机方向的有，法线偏离相机方向的没有
        // rimLight *=  SAFE_POW(baseSpec,5);
        // MidPrec4 specAndRim = max(MidPrec4(iblSpecular,1),rimLight)+skyRim;
        // rimLightTotal += specAndRim.rgb;
        return rimLight;
    } 


// -------------------------------------------------------------------
// 高配 vertex shader
// -------------------------------------------------------------------
    VertexOutput vertHighBase(VertexInput v) {
        VertexOutput o = (VertexOutput)0;

        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        //o.pos = UnityObjectToClipPos(v.vertex);

        // 由于世界位置往往较大，浮点数计算精度不够，z-fighting严重。
        // 于是将模型矩阵和观察矩阵都同时平移主相机世界位置的距离，将相机移到世界空间原点。来避免矩阵中位移项过大的数字。
        HighPrec4x4 modelNew = 0.0f;
        HighPrec4x4 viewNew  = 0.0f;
        AdjustMatrixMVforBigworld( modelNew, viewNew );

        o.pos = mul( UNITY_MATRIX_P, mul( viewNew, mul( modelNew, v.vertex ) ) );

        // o.pos = v.pos; // 避免Unity潜规则中有时要直接使用 VertexOutput.pos 导致的报错

        o.grabPos = ComputeGrabScreenPos(o.pos);

        o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);

        MidPrec3 n = normalize(mul(v.nor, (MidPrec3x3)unity_WorldToObject)); // worldInverseTranspose
        o.worldNormal = n;

        o.eyeVec = normalize(unity_OrthoParams.w * -UNITY_MATRIX_V[2].xyz+(1- unity_OrthoParams.w) * (_WorldSpaceCameraPos-o.worldPos.xyz)); //这个-UNITY_MATRIX_V[2].xyz可以用来表示相机的朝向，即C#代码里的transform.forward

        o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;

        o.vertexColor = v.vertexColor;

#if _ENABLECUSTOMLIGHTDIR_ON
        HighPrec4 lightDir = HighPrec4( normalize(_CustomLightDir), 0.0);
        lightDir =  HighPrec4( UnityObjectToWorldDir(lightDir), 1.0); // w项设置为1，是避免脸使用模型空间法线时在背光情况下强行将脸设置为暗部的情况
#else
        HighPrec4 lightDir = HighPrec4( normalize( HighPrec3( _WorldSpaceLightPos0.x, 0, _WorldSpaceLightPos0.z )), 1.0); // 非自定义光照方向时，就用场景中的主光源方向
#endif

        if(_UseObjNormalTex > PROPERTY_ZERO){
            o.skyLightDir = ModifyLightDir( _FaceForward, _AngleThreshold, _FaceBackwardThreshold, lightDir );
        }else{
            // 非脸，确保y和w的值保证侧光不因为模型朝向原因被关掉。即便是自定义光照方向模式改了y也不会降低效果
            o.skyLightDir = HighPrec4(lightDir.x,1.0,lightDir.z,1.0); // 将y 设置为1，用来强制打开侧光。虽然改了光的水平方向朝向，但没有降低效果
        }

        TRANSFER_VERTEX_TO_FRAGMENT(o);
        return o;
    }


//-------------------------------------------------------------------------------------
// PBR，法线，卡通效果等计算

struct CharacterFragShadingStruct{

    VertexOutput input;
};

/// 高配的PBR，法线，卡通效果，边缘光等计算
inline MidPrec4 CharacterHighShading( CharacterFragShadingStruct pars  ){

        MidPrec oneMinusReflectivity;
        MidPrec3 specColor;
        MidPrec4 albedoTexColor = tex2D(_DiffuseTex, pars.input.uv.xy);

#if _ALPHATEST_ON
            clip(albedoTexColor.a - _AlphaCutoff);
#endif
        
        HighPrec3 viewDir = normalize(pars.input.eyeVec);

 // sky light
        // 当作为3d场景中的角色时，需要根据_CharacterMainLight配表来计算受场景光照的影响程度，而作为UI界面中的角色则不考虑场景光照
        MidPrec3 skyLightColor;
        // if( _CustomAmbientColorEnable < PROPERTY_ZERO ){  // 主光源应该只受 _CharacterMainLight 调整
            skyLightColor = lerp( _LightColor0.rgb, _CharacterMainLight.rgb * 2.0, _CharacterMainLight.a ); // 乘以2是因为没有intensity的，但有时会需要超过1的光颜色
        // }else{
        //     skyLightColor = _LightColor0.rgb;
        // }
#if _ENABLECUSTOMLIGHTDIR_ON
        MidPrec3 skyLightDir = normalize(pars.input.skyLightDir.xyz);
        // CHECK_COLOR(skyLightDir.xyz * 0.5 + MidPrec3(0.5,0.5,0.5))
#else
        MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif                                  

        MidPrec3 normal = MidPrec3(0,0,1);
        
        MidPrec attenForFaceBackFromLight = 1.0;
    if(_UseNormalTex > PROPERTY_ZERO){
        MidPrec4 normalLocal = tex2D(_NormalTex, pars.input.uv);
        normalLocal.xyz = UnpackNormal(normalLocal);

        // 如果使用模型空间的法线贴图（比如主角的脸）
        if(_UseObjNormalTex > PROPERTY_ZERO){
            normalLocal.x = -normalLocal.x; // Substance Painter是右手坐标系，并且要注意FBX的脸朝向要是面向电脑屏幕的
            normal = normalize(mul( normalLocal.xyz, (MidPrec3x3)unity_WorldToObject));
            _BumpStrength = 1.0; // 使用模型空间时，会强制让卡通效果采用这个模型空间的法线

            MidPrec3 toonSkyLightDir = SafeNormalize_Mid( MidPrec3(pars.input.skyLightDir.x, 
                                                    0.0, 
                                                    pars.input.skyLightDir.z) ); 
            // MidPrec3 toonSkyLightDir = normalize( MidPrec3(skyLightDir.x, 0.0, skyLightDir.z) );
            MidPrec faceWeight = normalLocal.w;
            normal = lerp( pars.input.worldNormal.xyz, normal.xyz, faceWeight );
            skyLightDir = lerp( skyLightDir, toonSkyLightDir, faceWeight ); 
            // skyLightColor *= lerp( 1.0, 0.7, normalLocal.w * 0.5 + 0.5 ); // cos(40) = 0.766, 因为将主光源的方向由40度倾斜放平了，导致NdotL的结果较之前更亮，故将光强压暗至之前的 cos(40)左右。现在说太暗了就去掉
            // attenForFaceBackFromLight = lerp( 1.0, pars.input.skyLightDir.w, faceWeight );
            attenForFaceBackFromLight = lerp( 1.0, step( 0.0,pars.input.skyLightDir.w - _FaceBackwardThreshold), faceWeight ); // 当光源方向非常接近脸的反方向时将atten设置为0
        }else{
            // 普通使用切线空间的法线贴图
            normal = normalize( normalLocal.z * pars.input.worldNormal +
                            normalLocal.x * pars.input.worldTangent +
                            normalLocal.y * pars.input.worldBinormal  );
        }

        
    }
    else{
        normal = normalize(pars.input.worldNormal);
    }    


// _NORMALMAP
        // normal *= faceSign; // 在 high to low 烘焙时，因为屏幕展开的关系triangle正反面会发生变化，这时存在 VFACE semantic 里面的内容可能是错的


        MidPrec metallic = 0.5h;
        MidPrec smoothness = 0.5h;
        MidPrec roughness = 0.5h;
        MidPrec occlusion = 1.0h;
        
#if _PBRCONTROLMAP
        HighPrec4 pbrControl = tex2D(_PbrControlTex, pars.input.uv);
        metallic   = pbrControl.r;
        smoothness  = pbrControl.g;
        occlusion  = pbrControl.b;

#else
        metallic   = _MetallicControl;
        smoothness  = _SmoothnessControl;
#endif
        metallic = max(0.001h, min(0.999h, metallic));
        smoothness = max(0.02h, min(0.95h, smoothness)); // 将光滑度上限压得较低，因为发现开启hdr后，光滑度很高的时候，会出现输出非常亮的高光的情况。
        // roughness = 1-smoothness;
        roughness = sqrt(1-smoothness); // 处理粗糙度调节感受不是线性变化的问题

        // shadow
        MidPrec atten = LIGHT_ATTENUATION(pars.input);

        // MidPrec lambert = NdotL; 
        MidPrec lambert = saturate( dot(normal, skyLightDir) );
        lambert *= atten;// 阴影的作用直接叠加在 lambert 上

        

        //-----------------------------
        // SkyLight Diffuse Term

        // 计算卡通效果下的lambert值
        MidPrec3 toonNormal = lerp( pars.input.worldNormal.xyz, normal.xyz , _BumpStrength);
        MidPrec halfLambert = dot(toonNormal, skyLightDir) * 0.5 + 0.5;
        // MidPrec backLightFactor = step( 0.7, halfLambert);
        halfLambert *= atten;
        halfLambert *= attenForFaceBackFromLight; 
        // 改成smoothstep，避免了一个除法，但其实不清楚具体开销是变大还是变小，这种过渡会更加平滑(但差距很细微)
        MidPrec toonLambert = smoothstep( _ToonThreshold - _ToonSlopeRange , _ToonThreshold + _ToonSlopeRange, halfLambert - 0.5 );

        // 为避免ACES导致偏色，进行逆计算。逆计算时，要根据向光背光区分处理，因为两者饱和度差别较大
        MidPrec maxColor = lerp(1.2, 5, toonLambert) ;
        MidPrec3 albedo = antiACES(albedoTexColor.rgb, maxColor );
        

        // 染色
        // 放在 aces逆运算之后是因为，如果放在前面，会导致过曝
        if(_EnableDyeing > PROPERTY_ZERO){

            // 启用染色时，使用更大自由度的Tint方式。这里乘以2，并不影响 _Color反算得到正确的HSV值给到客户端显示滑条值
            // 染色支持两种颜色。两种颜色的遮罩是 PbrControlMap的B通道
            MidPrec disableDyingMask = pars.input.vertexColor.g * albedoTexColor.a;
            albedo = dye( albedo, _DyeColor, _DyeColor2, occlusion, disableDyingMask );

            occlusion = 1.0; // 启用了染色之后，AO通道就仅仅作为染色区分两种颜色使用了
        }else{
            albedo.rgb *= _Color.rgb;
        }

        // 根据金属度计算反照率
        albedo = DiffuseAndSpecularFromMetallic (albedo, metallic, /* out */ specColor, /* out */oneMinusReflectivity);

        // 卡通效果：卡通度 ramp
        MidPrec3 rampValue = lerp( _ToonDark.rgb, _ToonBright.rgb, toonLambert );
        MidPrec3 skyLightDiffuse = albedo * skyLightColor * rampValue;


        //-----------------------------
        // SkyLight Specular Term
        
        // sky lighting(sun/moon)
        MidPrec3 skyLightSpecular = MidPrec3(0,0,0);

        MidPrec3 LightDirForSpec = normalize(viewDir + MidPrec3(0.0,_SpecLightYOffset,0.0) ); // 让高光计算的主光源方向始终跟视角方向保持一致,稍微比视角方向高一点，会更真实一点
        MidPrec3 reflecDir = reflect(LightDirForSpec, normal); // reflect()之前normal要归一化
        
        // MidPrec3 halfDir = normalize(viewDir+skyLightDir);
        MidPrec3 halfDir = normalize(viewDir + LightDirForSpec); 
        MidPrec NdotL = saturate(dot(normal, LightDirForSpec));
        MidPrec NdotV = saturate(dot(normal, viewDir));
        MidPrec NdotH = saturate(dot(normal, halfDir));
        MidPrec VdotH = saturate(dot(viewDir, halfDir));

    if( _AnisoEffect > PROPERTY_ZERO ){

        // 根据顶点色绿通道来区分发饰和头发，进行不同的高光计算
        if(pars.input.vertexColor.g > PROPERTY_ZERO )
        {   // 如果是发饰，则进行普通的高光计算
            skyLightSpecular = GetBRDFSpecular(specColor,roughness,NdotH,NdotV,NdotL,VdotH);
        }
        else{

            // 如果是头发部分，则进行各项异性高光计算
            MidPrec3 shiftSpec = MidPrec3(0.5,0.5,0.5);
            MidPrec3 tangent  = 0;// normalize( pars.input.worldTangent );
            MidPrec3 tangent2 = 0;//normalize( pars.input.worldTangent );
            // MidPrec3 originTangent = normalize( pars.input.worldTangent );
            MidPrec3 binormal = normalize( pars.input.worldBinormal);
            MidPrec3 normalAniso = lerp( pars.input.worldNormal, normal, _AnisoBumpStrength);
            // MidPrec3 normalAniso = normalize( pars.input.worldNormal);  

            if(_UseShiftTexForAnisoSpec > PROPERTY_ZERO){
                // shift贴图高光
                shiftSpec = tex2D(_AnisoSpecShiftTex, pars.input.uv).rgb - MidPrec3(0.5,0.0,0.0); // shift tangent for hair
                tangent = ShiftTangent( binormal, normalAniso, shiftSpec.r ); // 由 tangent 改成 binormal，反而效果看上去正确，参考：https://www.jianshu.com/p/7dc980ea4c51 。也许跟Unity生成切线的方式有关？虽然试了一遍，只有这种使用binormal是效果正确的。
                tangent2 = ShiftTangent( binormal, normalAniso, shiftSpec.r * shiftSpec.g ); 
            }
            binormal = normalize( cross(normalAniso,tangent) ); 
            MidPrec roughnessX = roughness * _TangentStrength;
            MidPrec roughnessX2 = roughness * _TangentStrength2;
            MidPrec roughnessY = roughness * _BinormalStrength;

            // 两组高光分别计算然后合并
            MidPrec3 specBRDF = GetBRDFSpecularAniso(specColor,roughness,roughnessX,roughnessY,NdotH,NdotV,NdotL,VdotH,halfDir,tangent,binormal);
            specBRDF *= _AnisoColor.rgb * _AnisoColor.a * 20.0; //_AnisoStrength;
            MidPrec3 specBRDF2 = GetBRDFSpecularAniso(specColor,roughness,roughnessX2,roughnessY,NdotH,NdotV,NdotL,VdotH,halfDir,tangent2,binormal);
            specBRDF2 = specBRDF2 * _AnisoColor2.a * 150.0 * _AnisoColor2.rgb;
            specBRDF = specBRDF + specBRDF2;

            skyLightSpecular = SAFE_POW(specBRDF, _AnisoSpecPow); //来源的公式里并没有这个Pow计算，高于1的pow没什么效果，小于1会让高光整体变亮一点
            skyLightSpecular = clamp(skyLightSpecular,0.0, 2.0); // iPhone上有奇怪的问题，头发有时候会出现不正常的值，判断跟这里面的计算有关，但是现在打包机目前不知为何不能截帧，所以先这样盲改。
            skyLightSpecular = lerp(skyLightSpecular * 0.3 , skyLightSpecular * _AnisoSpecColor.rgb * _AnisoSpecColorStrength, saturate(Luminance(skyLightDiffuse.rgb) * 10)); // 根据亮度，调节高光颜色

            // 发根处接近皮肤颜色的渐变，优化发根和皮肤交界处的效果
            MidPrec hairRootFactor = 1.0 - pars.input.vertexColor.a;
            skyLightDiffuse = lerp(skyLightDiffuse, _FaceColor.rgb, hairRootFactor * hairRootFactor * hairRootFactor);//发根颜色：皮肤颜色和头发颜色渐变  

        }
        
    }else{
        if(_PbrToggle > PROPERTY_ZERO)
        {
            skyLightSpecular = GetBRDFSpecular(specColor,roughness,NdotH,NdotV,NdotL,VdotH);
        }
    }
        //float3 skyLighting = (skyLightDiffuse+skyLightSpecular)*skyLightColor*lambert;
        
        skyLightSpecular *= skyLightColor*NdotL*atten;


        // ambient lighting
        // 处理使用 gradient environment lighting 时，Unity内置的 unity_AmbientSky 变量
        // 不能准确代表 ambient lightign 的问题
        MidPrec3 ambientSkyColor = MidPrec3(0,0,0);
        // if(_CustomAmbientColorEnable < -100 ){  
        //     // 如果是正常环境就使用配表中配的各个氛围的环境光计算的球谐光照
            // ambientSkyColor = ShadeSHPerPixel( normal, ambientSkyColor, pars.input.worldPos );
            // ambientSkyColor = Luminance( UNITY_LIGHTMODEL_AMBIENT.rgb) * 2.0;
            // ambientSkyColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
        // }else{

        ambientSkyColor = _CustomAmbientColor.rgb; // 计算上进行了简化，但是跟编辑器中将环境光设置为这个值时的颜色效果会稍有差别，因为 ShadeSHPerPixel()中有些结合法线的球谐计算。如果美术觉得效果不够，再该成模仿球谐计算的效果。现在角色环境光被定死在一个值上，如果白天变到晚上，只靠主光源来产生明暗变化的感觉。因为美术反映两个光对他们来讲调起来复杂

        MidPrec3 ambientLighting = ambientSkyColor * albedo * occlusion; 

        // point lighting
        // todo：动态点光
        // 思路：算法跟pbr sky light一致(分开计算pbr diffuse & specular)，只需要根据worldPos计算point light direction，以及光照强度衰减等

        //----------------------------------
        // Environment Diffuse And Specular (ibl lighting)

        MidPrec3 iblDiffuse = MidPrec3(0,0,0);
        MidPrec3 iblSpecular = MidPrec3(0,0,0);
        MidPrec nMips = 10; // todo: 512x512 texture, mip num 10
        MidPrec refLevel = max(0.01h, nMips-smoothness*nMips); // reflection mip level; todo
        //float refLevel = max(0.01, SAFE_POW(roughness,0.6) * 7.0);

        if(_PbrToggle > PROPERTY_ZERO)
        {
            if(_UseEnvCubeTex > PROPERTY_ZERO){
                // iblDiffuse = texCUBElod(_EnvCubeTex,MidPrec4(1,0,0,20)).rgb * albedo * occlusion;
                iblDiffuse = (ambientSkyColor.x + ambientSkyColor.y + ambientSkyColor.z) * 0.333 * albedo * occlusion; // iblDiffuse对效果帮助不大，所以就改成用实时环境光来计算了，减少一次对环境球的采样。之所以没有使用环境光的饱和度，是因为配合当前我们使用的环境球是个没有饱和度的球。
                iblSpecular = EnvironmentBRDF(smoothness, NdotV, specColor) * texCUBElod(_EnvCubeTex,MidPrec4(reflecDir,refLevel)).rgb * occlusion;

            }else{
                // 这种用于中配的情况，不再采样一个环境球
                MidPrec3 envColor = MidPrec3(_EnvCubeLum,_EnvCubeLum,_EnvCubeLum);
                iblDiffuse = envColor * albedo * occlusion;
                iblSpecular = EnvironmentBRDF(smoothness, NdotV, specColor) * envColor * occlusion;

            }
        }
        

        //---------------------------------------------
        // 其他效果

        MidPrec3 rimLightTotal = MidPrec3(0,0,0);

        // rim lighting 装备强化后的边缘光
        #if _STRENGTHENRIMLIGHT_ON 
            if(pars.input.vertexColor.g > PROPERTY_ZERO){ // 只有装备，衣服才能强化
                MidPrec backLight = abs(dot(normal, viewDir));
                backLight = saturate(1-backLight*_StrengthenRimRange);
                backLight =  SAFE_POW(backLight, _StrengthenRimPow) * _StrengthenRimStrength;
                MidPrec3 rimLight = backLight * _StrengthenRimLightColor.rgb;
                rimLightTotal = max(rimLight, rimLightTotal);
             }
        #endif

        // 边缘光 (Rim Lighting)
        if(_SideRimEffect > PROPERTY_ZERO){
            rimLightTotal += RimLight( normal, viewDir, _SideRimRange,_SideRimPow, _SideRimStrength, _SideRimLightColor.rgb );
        }

        // rim lighting (silhouette) 常用于选中或者受击等特效
        if(_RimEffect > PROPERTY_ZERO){
            rimLightTotal += RimLight( normal, viewDir, _RimRange, _RimPow , _RimStrength, _RimLightColor.rgb );
        }
        
        // MidPrec3 iblLighting = iblDiffuse + iblSpecular;

        // emissive lighting
        MidPrec3 emissiveLighting = MidPrec3(0,0,0);

        if( _EmissiveMapOn > PROPERTY_ZERO){
            emissiveLighting = tex2D(_EmissiveTex, pars.input.uv).rgb * (1.0 + _EmissiveColor.a * 50.0 ) + _EmissiveColor.rgb; // 不使用标准自发光处理方式中的"自发光贴图*自发光颜色"做法，把这个自发光颜色用来做角色的“闪白”效果
        }


        // final lighting
        MidPrec4 finalLighting = MidPrec4(0,0,0,1);
        MidPrec3 finalLightingDiffuse = MidPrec3(0,0,0);
        MidPrec3 finalLightingSpecular = MidPrec3(0,0,0);

        finalLighting.a = albedoTexColor.a * _Color.a;

        // Diffuse
        // 并没有除以PI,是为了适应我们手绘风格的贴图。角色的原画偏卡通和手绘。如果除以PI，要将光调到很强才能达到贴图的亮度，高光会过曝。而如果不加强光，而将贴图调亮则会丢失许多细节，也增加了绘制贴图的难度。
        finalLightingDiffuse += skyLightDiffuse; 
        finalLightingDiffuse += ambientLighting;
        // finalLightingDiffuse += iblDiffuse; // 环境光的diffuse用 ambientLighting，可控性更高也更省
        
        // Specular
        finalLightingSpecular += skyLightSpecular;
        finalLightingSpecular += iblSpecular;

        // Emission
        finalLightingDiffuse += emissiveLighting;

        // RimLights
        finalLightingDiffuse += rimLightTotal;

#if _ALPHAPREMULTIPLY_ON
        finalLightingDiffuse = finalLightingDiffuse * finalLighting.a;
        finalLightingSpecular = finalLightingSpecular * _GlassReflectionStrength;
#endif
        finalLighting.rgb = finalLightingDiffuse + finalLightingSpecular;
        

        return finalLighting;

}

// 冰冻状态
//------------------------------------------------------------------------------------
inline MidPrec4 FragFrozenEffect(CharacterLowShadingStruct pars)
{
    MidPrec4 albedo = tex2D(_DiffuseTex, pars.input.uv.xy);
    MidPrec4 finalColor = albedo;

    if(_EnableDyeing > PROPERTY_ZERO){
        // 启用染色时，使用更大自由度的Tint方式。这里乘以2，并不影响 _Color反算得到正确的HSV值给到客户端显示滑条值
        albedo.rgb *= lerp( _DyeColor.rgb * 2.0 ,MidPrec3(1,1,1), lerp(0.0,1.0, pars.input.vertexColor.g) );
    }else{
        albedo.rgb *= _IceMainColor.rgb;
    }

    MidPrec3 skyLightColor = lerp( _LightColor0.rgb, _CharacterMainLight.rgb * 2.0, _CharacterMainLight.a ); // 乘以2是因为没有intensity的，但有时会需要超过1的光颜色
    MidPrec atten = LIGHT_ATTENUATION(pars.input);
    MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light has no position

    //normal
    // MidPrec4 normalColor = tex2D(_IceNormal, pars.input.uv1.xy);
    // MidPrec3 unpackNormal = UnpackNormal(normalColor);
    // MidPrec3 normal = normalize(unpackNormal.z * pars.input.worldNormal + unpackNormal.x * pars.input.worldTangent + unpackNormal.y * pars.input.worldBinormal);


    MidPrec3 skyLightDiffuse = albedo.rgb * skyLightColor;
    MidPrec3 toonNormal =  pars.input.worldNormal.xyz;
    MidPrec halfLambert = dot(toonNormal, skyLightDir) * 0.5 + 0.5;
    halfLambert *= atten;
    MidPrec toonLambert = smoothstep( _ToonThreshold - _ToonSlopeRange , _ToonThreshold + _ToonSlopeRange, halfLambert - 0.5 );
    MidPrec3 rampValue = lerp( _ToonDark.rgb, _ToonBright.rgb, toonLambert );
    skyLightDiffuse *= rampValue;

    // 计算环境光
    MidPrec3 ambientSkyColor = _CustomAmbientColor.rgb * albedo.rgb;
    finalColor.rgb = skyLightDiffuse + ambientSkyColor;

    MidPrec3 viewDir = normalize(UnityWorldSpaceViewDir(pars.input.worldPos.xyz));

    // Pbr控制冰霜,金属度越强、平滑度越光滑 冰霜越厚（颜色越白）
    MidPrec metallic = 0.0h;
    MidPrec smoothness = 1.0h;
    if(_PbrControl > PROPERTY_ZERO)
    {
        HighPrec4 pbrControl = tex2D(_PbrControlTex, pars.input.uv.xy);
        metallic   = pbrControl.r;
        smoothness  = pbrControl.g;
    }
    
    finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb + _PbrIceColor.rgb, smoothness * metallic * _MetallicRatio);

    // 冰霜纹理
    MidPrec4 iceCol = tex2D(_IceTex, pars.input.uv.xy);
    finalColor.rgb += iceCol.r * _IceColor1;
    // finalColor.rgb += iceCol.g * _IceColor2;
    finalColor.rgb = lerp(finalColor.rgb + iceCol.g * _IceColor2, finalColor.rgb, iceCol.r);

    // 高光
    MidPrec3 halfDir = normalize(viewDir + skyLightDir);
    // normal.x += _NormalForceX;
    // normal.y += _NormalForceY;
    finalColor.rgb += lerp(0, _SpecularColor * pow(saturate(dot(pars.input.worldNormal, halfDir)), _SpecularPower), iceCol.b) ;

    // 边缘光
    MidPrec backLight = abs(dot(pars.input.worldNormal, viewDir));
    backLight = saturate(1 - backLight * _IceRimRange);
    backLight =  SAFE_POW(backLight, _IceRimPow) * _IceRimStrength;
    MidPrec3 rimLight = backLight * _IceRimLightColor.rgb;

    finalColor.rgb += rimLight;
                		
#if _ALPHATEST_ON
	clip( finalColor.a - _AlphaCutoff );
#endif

    if(  _EnableHawkEye > PROPERTY_ZERO ){
        finalColor.rgb = HawkEyeCharacter(finalColor.rgb, pars.input.worldPos.xyz);
        return finalColor;
    }

    CALC_DISTANCE_FOG_PARAM(pars.input.worldPos.xyz)
    APPLY_DISTANCE_FOG(finalColor, 1)

    return finalColor;
}

inline MidPrec4 FragFrozenEffect(CharacterFragShadingStruct pars)
{
    
    MidPrec4 albedo = tex2D(_DiffuseTex, pars.input.uv.xy);
    MidPrec4 finalColor = albedo;

    if(_EnableDyeing > PROPERTY_ZERO){
        // 启用染色时，使用更大自由度的Tint方式。这里乘以2，并不影响 _Color反算得到正确的HSV值给到客户端显示滑条值
        albedo.rgb *= lerp( _DyeColor.rgb * 2.0 ,MidPrec3(1,1,1), lerp(0.0,1.0, pars.input.vertexColor.g) );
    }else{
        albedo.rgb *= _IceMainColor.rgb;
    }

    MidPrec3 skyLightColor = lerp( _LightColor0.rgb, _CharacterMainLight.rgb * 2.0, _CharacterMainLight.a ); // 乘以2是因为没有intensity的，但有时会需要超过1的光颜色
    MidPrec atten = LIGHT_ATTENUATION(pars.input);
    MidPrec3 skyLightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light has no position

    //normal
    // MidPrec4 normalColor = tex2D(_IceNormal, pars.input.uv1.xy);
    // MidPrec3 unpackNormal = UnpackNormal(normalColor);
    // MidPrec3 normal = normalize(unpackNormal.z * pars.input.worldNormal + unpackNormal.x * pars.input.worldTangent + unpackNormal.y * pars.input.worldBinormal);


    MidPrec3 skyLightDiffuse = albedo.rgb * skyLightColor;
    MidPrec3 toonNormal =  pars.input.worldNormal.xyz;
    MidPrec halfLambert = dot(toonNormal, skyLightDir) * 0.5 + 0.5;
    halfLambert *= atten;
    MidPrec toonLambert = smoothstep( _ToonThreshold - _ToonSlopeRange , _ToonThreshold + _ToonSlopeRange, halfLambert - 0.5 );
    MidPrec3 rampValue = lerp( _ToonDark.rgb, _ToonBright.rgb, toonLambert );
    skyLightDiffuse *= rampValue;

    // 计算环境光
    MidPrec3 ambientSkyColor = _CustomAmbientColor.rgb * albedo.rgb;
    finalColor.rgb = skyLightDiffuse + ambientSkyColor;

    MidPrec3 viewDir = normalize(UnityWorldSpaceViewDir(pars.input.worldPos.xyz));

    // Pbr控制冰霜,金属度越强、平滑度越光滑 冰霜越厚（颜色越白）
    MidPrec metallic = 0.0h;
    MidPrec smoothness = 1.0h;
 #if _PBRCONTROLMAP
    HighPrec4 pbrControl = tex2D(_PbrControlTex, pars.input.uv.xy);
    metallic   = pbrControl.r;
    smoothness  = pbrControl.g;
#endif
    finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb + _PbrIceColor.rgb, smoothness * metallic * _MetallicRatio);

    // 冰霜纹理
    MidPrec4 iceCol = tex2D(_IceTex, pars.input.uv.xy);
    finalColor.rgb += iceCol.r * _IceColor1;
    // finalColor.rgb += iceCol.g * _IceColor2;
    finalColor.rgb = lerp(finalColor.rgb + iceCol.g * _IceColor2, finalColor.rgb, iceCol.r);

    // 高光
    MidPrec3 halfDir = normalize(viewDir + skyLightDir);
    // normal.x += _NormalForceX;
    // normal.y += _NormalForceY;
    finalColor.rgb += lerp(0, _SpecularColor * pow(saturate(dot(pars.input.worldNormal, halfDir)), _SpecularPower), iceCol.b) ;

    // 边缘光
    MidPrec backLight = abs(dot(pars.input.worldNormal, viewDir));
    backLight = saturate(1 - backLight * _IceRimRange);
    backLight =  SAFE_POW(backLight, _IceRimPow) * _IceRimStrength;
    MidPrec3 rimLight = backLight * _IceRimLightColor.rgb;

    finalColor.rgb += rimLight;
                		
#if _ALPHATEST_ON
	clip( finalColor.a - _AlphaCutoff );
#endif

    if(  _EnableHawkEye > PROPERTY_ZERO ){
        finalColor.rgb = HawkEyeCharacter(finalColor.rgb, pars.input.worldPos.xyz);
        return finalColor;
    }

    CALC_DISTANCE_FOG_PARAM(pars.input.worldPos.xyz)
    APPLY_DISTANCE_FOG(finalColor, 1)

    return finalColor;
}

//------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
// 低配的Character Fragment

MidPrec4 fragLowBase(VertexOutputLow input) : SV_Target 
{
    CharacterLowShadingStruct charParams;
    charParams.input = input;
if(_FrozenEffect > PROPERTY_ZERO)
{
    return FragFrozenEffect( charParams );
}

    MidPrec4 finalLighting = CharacterLowShading( charParams );

if(  _EnableHawkEye > PROPERTY_ZERO ){
        finalLighting.rgb = HawkEyeCharacter(finalLighting.rgb, input.worldPos.xyz);
        return finalLighting;
}

        CALC_DISTANCE_FOG_PARAM(input.worldPos.xyz)
        APPLY_DISTANCE_FOG(finalLighting, 1)

        return finalLighting;
}

//------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
// 高配的Character Fragment

MidPrec4 fragVeryHighBase(VertexOutput input) : SV_Target 
{

    CharacterFragShadingStruct charParams;
    charParams.input = input;
if(_FrozenEffect > PROPERTY_ZERO)
{
    return FragFrozenEffect( charParams );
}

    MidPrec4 finalLighting = CharacterHighShading( charParams );
    finalLighting.rgb += _AddedColor.rgb;

if(  _EnableHawkEye > PROPERTY_ZERO ){
        finalLighting.rgb = HawkEyeCharacter(finalLighting.rgb, input.worldPos.xyz);
        return finalLighting;
}

        CALC_DISTANCE_FOG_PARAM(input.worldPos.xyz)
        APPLY_DISTANCE_FOG(finalLighting, 1)

        return finalLighting;
        // return MidPrec4( finalLighting.rgb, finalLighting.a * _CharacterDoToneMapping ); // 带宽开销太大，去掉了
}

//------------------------------------------------------------------------------------
// 隐身状态

/// 隐身状态 frag ---- VeryHigh
// 采样RT
MidPrec4 fragHiddenVeryHigh(VertexOutput input) : SV_Target 
{

    CharacterFragShadingStruct charParams;
    charParams.input = input;
if(_FrozenEffect > PROPERTY_ZERO)
{
    return FragFrozenEffect( charParams );
}

    MidPrec4 finalLighting = CharacterHighShading( charParams );
    finalLighting.rgb += _AddedColor.rgb;

    // 隐身状态， 读取RT 
    // 普通半透，颜色对比度降一点
    finalLighting.a = _WholeBlendRatio;
    MidPrec wholeGrayColor = GetGraylevel(finalLighting.rgb);
    finalLighting.rgb = lerp( finalLighting.rgb, wholeGrayColor.rrr, _WholeGrayRatio );
    // 使用不透明物体渲染后的RT来制作伪半透效果。现在改用GrabPass了，避免每帧去截屏
    // MidPrec3 bgColor = tex2Dproj(_ScreenCopyTex, input.grabPos).rgb;
    MidPrec3 bgColor = tex2Dproj(_BackgroundTexture,input.grabPos).rgb;
    finalLighting.rgb = finalLighting.rgb * finalLighting.a + bgColor * ( 1.0 - finalLighting.a );
    finalLighting.a = 1.0;

if(  _EnableHawkEye > PROPERTY_ZERO ){
        finalLighting.rgb = HawkEyeCharacter(finalLighting.rgb, input.worldPos.xyz);
        return finalLighting;
}

        CALC_DISTANCE_FOG_PARAM(input.worldPos.xyz)
        APPLY_DISTANCE_FOG(finalLighting, 1)

        return finalLighting;
}

/// 隐身状态 frag ---- High
// Scene Door 点阵式clip
MidPrec4 fragHiddenHigh(VertexOutput input) : SV_Target 
{
    CharacterFragShadingStruct charParams;
    charParams.input = input;
if(_FrozenEffect > PROPERTY_ZERO)
{
    return FragFrozenEffect( charParams );
}

    HighPrec2 pos = input.grabPos.xy / input.grabPos.w; //IN.screenPos.xy / IN.screenPos.w;
    pos *= _ScreenParams.xy; // (0-1728, 0-828) (e.g.) pos in screen width , screen height

    // 这种隔一个像素变化一次，会导致类似z-fighting的视觉症状，故还是用四维矩阵来做。
    // MidPrec thresholdVector[4] = { 0.252, 0.752, 0.52, 0.12 }; 
    // clip(_SceneDoorHiddenRatio - ( thresholdVector[floor(fmod(pos.x,2) + floor( 2.0 * fmod(pos.y,2) ))] ));

    // Screen-door transparency: Discard pixel if below threshold.
    // float4x4 thresholdMatrix = // 改成将除法先算好。这个会导致低分辨率下不好看的网点形状
    // {  1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
    //   13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
    //    4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
    //   16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    // }; 
    static HighPrec4x4 thresholdMatrix = 
    {  0.058823,  0.5294117,  0.17647, 0.6471,
      0.7647,  0.294117, 0.8823529,  0.4117647,
       0.235294117, 0.7058823529,  0.117647, 0.588235294,
      0.94117647,  0.470588235, 0.82352941,  0.352941176
    };
        // MidPrec4x4 thresholdMatrix =
    // {  1.0 / 17.0,  15.0 / 17.0,  1.0 / 17.0, 15.0 / 17.0,
    //    8.0 / 17.0,  4.0 / 17.0,  8.0 / 17.0, 4.0 / 17.0,
    //    1.0 / 17.0, 15.0 / 17.0,  1.0 / 17.0,  15.0 / 17.0,
    //    8.0 / 17.0, 4.0 / 17.0,  8.0 / 17.0,  4.0 / 17.0
    // }; 
    // 上面两种矩阵在分辨率降到0.6左右就出现很明显的菱形或正方形，不够好看。这个每四像素相当于一格，虽然在高分辨率上不如上面两个，但效果比较稳定。  
    // MidPrec4x4 thresholdMatrix =
    // {  1.0 / 17.0,  1.0 / 17.0,  15.0 / 17.0, 15.0 / 17.0,
    //    1.0 / 17.0,  1.0 / 17.0,  15.0 / 17.0, 15.0 / 17.0,
    //    8.0 / 17.0, 8.0 / 17.0,  4.0 / 17.0,  4.0 / 17.0,
    //    8.0 / 17.0, 8.0 / 17.0,  4.0 / 17.0,  4.0 / 17.0
    // }; 
    // HighPrec4x4 thresholdMatrix = 
    // {  0.058823,  0.058823,  0.8823529, 0.8823529,
    //    0.058823,  0.058823,  0.8823529, 0.8823529,
    //    0.470588235, 0.470588235,  0.235294117, 0.235294117,
    //   0.470588235,  0.470588235, 0.235294117,  0.235294117
    // };

    // MidPrec4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
    // 这个步骤关键是采样 thresholdMatrix中间的一个item，以下三种写法均能得到正确结果，暂不明白为什么前两种能work
    // clip(_HiddenTransperancy - thresholdMatrix[fmod(pos.x, 4)] * _RowAccess[fmod(pos.y, 4)]);
    // clip(_HiddenTransperancy - dot(thresholdMatrix[fmod(pos.x, 4)] ,_RowAccess[fmod(pos.y, 4)]));
    clip(_SceneDoorHiddenRatio - (thresholdMatrix[floor(fmod(pos.x, 4))][floor(fmod(pos.y, 4))]));

    MidPrec4 finalLighting = CharacterHighShading( charParams );
    finalLighting.rgb += _AddedColor.rgb;

    // 隐身状态， 读取RT 
    // 普通半透，颜色对比度降一点
    // finalLighting.a = _WholeBlendRatio;
    // MidPrec wholeGrayColor = GetGraylevel(finalLighting.rgb);
    // finalLighting.rgb = lerp( finalLighting.rgb, wholeGrayColor.rrr, _WholeGrayRatio );
    // // 使用不透明物体渲染后的RT来制作伪半透效果
    // MidPrec3 bgColor = tex2Dproj(_ScreenCopyTex, input.grabPos).rgb;
    // finalLighting.rgb = finalLighting.rgb * finalLighting.a + bgColor * ( 1.0 - finalLighting.a );
    // finalLighting.a = 1.0;

if(  _EnableHawkEye > PROPERTY_ZERO ){
        finalLighting.rgb = HawkEyeCharacter(finalLighting.rgb, input.worldPos.xyz);
        return finalLighting;
}
        CALC_DISTANCE_FOG_PARAM(input.worldPos.xyz)
        APPLY_DISTANCE_FOG(finalLighting, 1)

        // return MidPrec4(finalLighting.rgb, finalLighting.a * _CharacterDoToneMapping); 带宽增加20M，不用了
        return finalLighting;
        
}

// 隐身状态
//------------------------------------------------------------------------------------

#endif // CHARACTER_SHADER_UTIL