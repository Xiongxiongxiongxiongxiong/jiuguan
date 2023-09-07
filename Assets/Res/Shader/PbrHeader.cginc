
#ifndef PBRHEADER_SHADER_HEARDER_INCLUDE
#define PBRHEADER_SHADER_HEARDER_INCLUDE

#include "AutoLight.cginc"
#include "DataTypes.cginc"
#include "UnityPBSLighting.cginc" 
#include "UtilHeader.cginc"
#include "WorkCommon.cginc"
#include "CustomBRDF.cginc"
// BRDF中绝大部分计算都是使用UE4的公式 https://zhuanlan.zhihu.com/p/35878843

#define RIM_MAX_STRENGTH 2
#define RIM_MAX_DISTANCE 50



// ===================================================================
// Utils
// ===================================================================

HighPrec GetGraylevel(HighPrec3 color)
{
    return dot(color, HighPrec3(0.2126f, 0.7152f, 0.0722f));
}

// ===================================================================
// 
// ===================================================================

// GGX distribution 采用跟UE4一样的 GGX / Trowbridge-Reitz模型
MidPrec NormalDistribution(MidPrec Roughness, MidPrec NoH)
{
    MidPrec alpha = Roughness * Roughness;
    MidPrec tmp = alpha / max(1e-8,(NoH*NoH*(alpha*alpha-1.0h)+1.0h));
    return tmp * tmp * UNITY_INV_PI;
}

// UE4中的各向异性GGX 法线分布函数。
// 也是对2012年Disney那篇论文的实现。是将切线方向和副切线方向分别使用不同的粗糙度来实现沿两个不同方向的高光变化的不同。
MidPrec NormalDistributionAniso(MidPrec RoughnessX, MidPrec RoughnessY, MidPrec NoH, MidPrec3 halfVec, MidPrec3 tangent, MidPrec3 binormal)
{
    MidPrec rx = RoughnessX * RoughnessX;
    MidPrec ry = RoughnessY * RoughnessY;
    MidPrec XoH = dot(tangent, halfVec);
    MidPrec YoH = dot(binormal, halfVec);
    MidPrec d = XoH*XoH/(rx*rx) + YoH*YoH/(ry*ry) + NoH*NoH;

    //float cosPhiSqr = XoH*XoH/( max(0.0000001, 1-NoH*NoH) );
    //float headVal = cosPhiSqr/rx + (1-cosPhiSqr)/ry;

    //return UNITY_INV_PI / (rx * ry * d * d);
    return UNITY_INV_PI / (rx * ry * d * d + 1e-2);
}

// Schlick Visibility
MidPrec GeometricVisibility(MidPrec Roughness, MidPrec NoV, MidPrec NoL)
{
    MidPrec k = ( Roughness * Roughness ) * 0.5h;
    MidPrec Vis_SchlickV = NoV * (1 - k) + k;
    MidPrec Vis_SchlickL = NoL * (1 - k) + k;
    return 0.25h / ( Vis_SchlickV * Vis_SchlickL + 1e-2 );
    // return 0.25h / ( Vis_SchlickV * Vis_SchlickL );
}

// Schlick Fresnel
MidPrec3 Fresnel( MidPrec3 SpecularColor, MidPrec VoH )
{
    MidPrec Fc = SAFE_POW(1 - saturate(VoH),5);
    return SpecularColor + (1.0h - SpecularColor) * Fc;
}

MidPrec3 GetBRDFSpecular(MidPrec3 specularColor,MidPrec roughness,MidPrec NoH,MidPrec NoV,MidPrec NoL,MidPrec VoH)
{
    MidPrec3 specular = NormalDistribution(roughness,NoH) * GeometricVisibility(roughness,NoV,NoL) * Fresnel(specularColor,VoH);
    return min(10.0, specular);
}

// anisotropic BRDF
MidPrec3 GetBRDFSpecularAniso(MidPrec3 specularColor,MidPrec roughness, MidPrec RoughnessX, MidPrec RoughnessY,MidPrec NoH,MidPrec NoV,MidPrec NoL,MidPrec VoH, MidPrec3 halfVec, MidPrec3 tangent, MidPrec3 binormal)
{
    return NormalDistributionAniso(RoughnessX,RoughnessY,NoH,halfVec,tangent,binormal) * GeometricVisibility(roughness,NoV,NoL) * Fresnel(specularColor,VoH);
}

// ===================================================================
// env lighting
// ===================================================================

// brdf specular - [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
// http://www.klayge.org/2014/07/20/%e6%b8%b8%e6%88%8f%e4%b8%ad%e5%9f%ba%e4%ba%8e%e7%89%a9%e7%90%86%e7%9a%84%e7%8e%af%e5%a2%83%e5%85%89%e6%b8%b2%e6%9f%93%ef%bc%88%e4%b8%89%ef%bc%89%ef%bc%9alut%e7%9a%84%e6%9b%b2%e9%9d%a2%e6%8b%9f/
// UE4 IBL的分析：http://www.sztemple.cc/articles/pbr%E7%90%86%E8%AE%BA%E4%BD%93%E7%B3%BB%E6%95%B4%E7%90%86%EF%BC%88%E4%B8%89%EF%BC%89%EF%BC%9Aibl
MidPrec3 EnvironmentBRDF(MidPrec g, MidPrec NoV, MidPrec3 specColor)
{
    // MidPrec4 t = MidPrec4( 1/0.96h, 0.475h, (0.0275h - 0.25h * 0.04h) /0.96h, 0.25h );
    MidPrec4 t = MidPrec4( 1.0417h, 0.4750h, 0.0182h, 0.2500h );
    t *= MidPrec4(g, g, g, g);
    // t += MidPrec4( 0, 0, (0.015h - 0.75h * 0.04h) /0.96h, 0.75h );
    t += MidPrec4( 0, 0, -0.0156h,0.7500h );
    MidPrec a0 = t.x * min( t.y, exp2( -9.28h * NoV ) ) + t.z;
    MidPrec a1 = t.w;
    return saturate( a0 + specColor * ( a1 - a0 ) );
}

// ===================================================================
// point lighting
// ===================================================================

#define MAX_POINTLIGHT_NUM 4

struct PointLightData {
    HighPrec3 pos;
    MidPrec3 color;
    HighPrec atten;
};

PointLightData GetNonImportantPointLight1() {
    PointLightData output;
    output.pos = HighPrec3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
    output.color = unity_LightColor[0].rgb;
    output.atten = unity_4LightAtten0.x;
    return output;
}

PointLightData GetNonImportantPointLight2() {
    PointLightData output;
    output.pos = HighPrec3(unity_4LightPosX0.y, unity_4LightPosY0.y, unity_4LightPosZ0.y);
    output.color = unity_LightColor[1].rgb;
    output.atten = unity_4LightAtten0.y;
    return output;
}

PointLightData GetNonImportantPointLight3() {
    PointLightData output;
    output.pos = HighPrec3(unity_4LightPosX0.z, unity_4LightPosY0.z, unity_4LightPosZ0.z);
    output.color = unity_LightColor[2].rgb;
    output.atten = unity_4LightAtten0.z;
    return output;
}

PointLightData GetNonImportantPointLight4() {
    PointLightData output;
    output.pos = HighPrec3(unity_4LightPosX0.w, unity_4LightPosY0.w, unity_4LightPosZ0.w);
    output.color = unity_LightColor[3].rgb;
    output.atten = unity_4LightAtten0.w;
    return output;
}

// 用于不能使用法线信息的单面模型（树叶等）
HighPrec3 AmbientPointLight(HighPrec3 worldPos, MidPrec3 diffuseColor, PointLightData ptLight) {
    MidPrec3 pointLightDir = ptLight.pos - worldPos;
    MidPrec3 normPtLightDir = normalize(pointLightDir);
    MidPrec lengthSq = dot(pointLightDir, pointLightDir);
    HighPrec atten = 1.0 / (1.0 + lengthSq * ptLight.atten);
    return atten * ptLight.color * diffuseColor;
}

// 计算一个pt light的 lambert光照模型
HighPrec3 LambertPointLight(HighPrec3 worldPos, MidPrec3 normal, MidPrec3 diffuseColor, PointLightData ptLight) {
    MidPrec3 pointLightDir = ptLight.pos - worldPos;
    MidPrec3 normPtLightDir = normalize(pointLightDir);
    MidPrec lengthSq = dot(pointLightDir, pointLightDir);
    MidPrec ptLightNdotL = saturate( dot(normal, normPtLightDir) );
    HighPrec atten = 1.0 / (1.0 + lengthSq * ptLight.atten);
    return ptLightNdotL * atten * ptLight.color * diffuseColor;
}

// 计算一个pt light
HighPrec3 PbrPointLight(HighPrec3 worldPos, MidPrec3 normal, MidPrec3 viewDir, MidPrec3 diffuseColor, MidPrec3 specColor,
    MidPrec roughness, PointLightData ptLight) {
    MidPrec3 lightDir = ptLight.pos - worldPos;
    MidPrec lengthSq = dot(lightDir, lightDir);
    HighPrec atten = 1.0 / (1.0 + lengthSq * ptLight.atten);

    lightDir = normalize( lightDir );
    MidPrec3 halfDir = normalize( viewDir + lightDir );
    MidPrec NoL = saturate(dot(normal, lightDir));
    MidPrec NoH = saturate(dot(normal, halfDir));
    MidPrec NoV = saturate(dot(normal, viewDir));
    MidPrec VoH = saturate(dot(viewDir, halfDir));

    //float3 ptLightDiffuse = diffuseColor;
    MidPrec3 ptLightSpecular = GetBRDFSpecular(specColor, roughness, NoH, NoV, NoL, VoH);
    //float3 ptLighting = (ptLightDiffuse + ptLightSpecular) * atten * ptLight.color;
    MidPrec3 ptLighting = (ptLightSpecular) * atten * ptLight.color;
    return ptLighting * NoL;
}

// 同时计算4个pt light（场景中实际的pt light数量可能少于4）
MidPrec3 PbrPointLights(HighPrec3 worldPos, MidPrec3 normal, MidPrec3 viewDir, MidPrec3 diffuseColor, MidPrec3 specColor, MidPrec roughness) {
    HighPrec4 lightX = unity_4LightPosX0 - worldPos.x;
    HighPrec4 lightY = unity_4LightPosY0 - worldPos.y;
    HighPrec4 lightZ = unity_4LightPosZ0 - worldPos.z;

    HighPrec4 lengthSq = lightX*lightX + lightY*lightY + lightZ*lightZ;
    lengthSq = max(lengthSq, 0.000001);
    HighPrec4 corr = rsqrt(lengthSq); // reciprocal of squared root
    HighPrec4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0);

    lightX *= corr;
    lightY *= corr;
    lightZ *= corr;

    MidPrec4 halfX = lightX + viewDir.x;
    MidPrec4 halfY = lightY + viewDir.y;
    MidPrec4 halfZ = lightZ + viewDir.z;
    MidPrec4 halfLenSq = halfX*halfX + halfY*halfY + halfZ*halfZ;
    halfLenSq = max(halfLenSq, 0.000001);
    MidPrec4 halfCorr = rsqrt(halfLenSq);
    halfX *= halfCorr;
    halfY *= halfCorr;
    halfZ *= halfCorr;

    MidPrec4 NdotL = max( MidPrec4(0,0,0,0), lightX*normal.x + lightY*normal.y + lightZ*normal.z );
    MidPrec NoV = saturate(dot(normal, viewDir));
    MidPrec4 NdotH = max( MidPrec4(0,0,0,0), halfX*normal.x + halfY*normal.y + halfZ*normal.z );
    MidPrec4 VdotH = max( MidPrec4(0,0,0,0), halfX*viewDir.x + halfY*viewDir.y + halfZ*viewDir.z );

    MidPrec3 ptLightDiffuse = diffuseColor; // todo: albedo只用算一次，如果已经在directional light中算过，这里甚至一次都不用算
    MidPrec3 ptLightSpecular1 = GetBRDFSpecular(specColor, roughness, NdotH.x, NoV, NdotL.x, VdotH.x);
    MidPrec3 ptLightSpecular2 = GetBRDFSpecular(specColor, roughness, NdotH.y, NoV, NdotL.y, VdotH.y);
    MidPrec3 ptLightSpecular3 = GetBRDFSpecular(specColor, roughness, NdotH.z, NoV, NdotL.z, VdotH.z);
    MidPrec3 ptLightSpecular4 = GetBRDFSpecular(specColor, roughness, NdotH.w, NoV, NdotL.w, VdotH.w);
    // todo：参考builtin-shader的Shade4PointLights()，把上述4个计算合并
    ptLightSpecular1 *= atten.x * unity_LightColor[0].rgb * NdotL.x;
    ptLightSpecular2 *= atten.y * unity_LightColor[1].rgb * NdotL.y;
    ptLightSpecular3 *= atten.z * unity_LightColor[2].rgb * NdotL.z;
    ptLightSpecular4 *= atten.w * unity_LightColor[3].rgb * NdotL.w;

    //return ptLightDiffuse + ptLightSpecular1 + ptLightSpecular2 + ptLightSpecular3 + ptLightSpecular4;
    return ptLightSpecular1 + ptLightSpecular2 + ptLightSpecular3 + ptLightSpecular4;
}



//------------------------------------------------------------------------
// 全局光照相关函数或者宏定义


// For grass which use lightmap intensity but not baked

#if _USELIGHTMAPINTENSITY_ON
    
    sampler2D _ShadowMask;
    sampler2D _LightMap;

#endif

// For grass which use lightmap intensity but not baked
fixed UnitySampleBakedOcclusion_UseLightmapIntensity( fixed bakedShadowMask, float2 lightmapUV, float3 worldPos){
        // #if defined (SHADOWS_SHADOWMASK)
            // #if defined(LIGHTMAP_ON)
        #if _USELIGHTMAPINTENSITY_ON
                fixed4 rawOcclusionMask = bakedShadowMask; //tex2D(_LightMap, lightmapUV.xy);
            // #else
            //     fixed4 rawOcclusionMask = fixed4(1.0, 1.0, 1.0, 1.0);
            //     #if UNITY_LIGHT_PROBE_PROXY_VOLUME
            //         if (unity_ProbeVolumeParams.x == 1.0)
            //             rawOcclusionMask = LPPV_SampleProbeOcclusion(worldPos);
            //         else
            //             rawOcclusionMask = UNITY_SAMPLE_TEX2D(_ShadowMask, lightmapUV.xy);
            //     #else
            //         rawOcclusionMask = UNITY_SAMPLE_TEX2D(_ShadowMask, lightmapUV.xy);
            //     #endif
            // #endif
            //return saturate(dot(rawOcclusionMask, unity_OcclusionMaskSelector)); 只考虑一盏光
        #endif

        return 1.0; 

}

//
// 之所以要使用自定义的 DecodeLightmap，是发现移动平台线性空间下 unity_Lightmap_HDR.x 竟然不等于4.59。即便是GPU Bakery 烘焙出的.hdr文件通过getPixels()得到的值，看上去也是dLDR编码过的。虽然感觉乘以4.59比实时的亮一点，但是Unity官方文档上说要这么干。
MidPrec3 DecodeLightmap_Custom( MidPrec4 lightmapTex ){
    #if defined(UNITY_COLORSPACE_GAMMA)
            return lightmapTex.rgb * 2.0;
    #else
            return lightmapTex.rgb * 4.59;
    #endif
}


// 烘焙出的lightmap会乘以这个tint
MidPrec4 _IndirectLightTint = MidPrec4(1,1,1,0.25); 
// 是否使用 Distance ShadowMask 模式，1.0为使用，0.0为不使用
LowPrec _DistanceShadowMask;

// 烘焙后的lightmap乘以的Tint
inline MidPrec3 BakedColorTint(){
    return _IndirectLightTint.rgb * _IndirectLightTint.a * 4.0;
}

// 对于使用吸Lightmap颜色的吸色草等材质，需要使用这个来计算实时阴影。
// 其实就是加了一个step()来规避采样ShadowMap时在靠近ShadowDistance边缘处的渐隐效果。不烘焙的物体采样shadowMap都会这样，这样的弊端是近处实时阴影与远处LightMap过渡时，atten会比较亮。正常烘焙的物体没这问题。（对着buildin代码查了很多关键字，都没有找到做这个fade的地方，而UnitySampleShadow() 又没法自己直接调用，故目前只能加个Step() ）
// #define LIGHT_ATTENUATION_USE_LIGHTMAP_INTENSITY(destName, input, worldPos) \
//         UNITY_LIGHT_ATTENUATION(destName, input, worldPos); \
//         destName = step(0.99999,destName); // 奇怪，0.99999h可以，0.99999x就不行

// 上面的 0.99999 在低精度手机比如iPhone7上会导致整个ShadowDistance之内都被判定为阴影区域的错误。现在没有在使用近处实时阴影的方案，故将上面的代码注释掉，改成正常的采样实时阴影 
#define LIGHT_ATTENUATION_USE_LIGHTMAP_INTENSITY(destName, input, worldPos) \
        UNITY_LIGHT_ATTENUATION(destName, input, worldPos); 


// Shadowmap

MidPrec _ShadowDistance = 10.0;

// 分析详见：https://www.cnblogs.com/hyapp/p/12608758.html 
inline MidPrec Custom_UnityComputeShadowFadeDistance(float3 wpos)
{
    return distance(wpos, unity_ShadowFadeCenterAndType.xyz);
    // return lerp(z, sphereDist, 1);
    // return lerp(z, sphereDist, unity_ShadowFadeCenterAndType.w); // 对于Direct Light 的w分量值为1。输出距离fade圆心的距离
}

// 自定义实时阴影衰减曲线的衰减函数
// 另外，有个帖子分析Unity原本的计算，详见：https://www.cnblogs.com/hyapp/p/12608758.html
inline MidPrec Custom_UnityComputeShadowFade(MidPrec fadeDist)
{

#if defined(SHADER_API_D3D11) || defined(SHADER_API_D3D12) || defined(SHADER_API_D3D11_9X) || defined(SHADER_API_XBOXONE)
        
    // Unity 2018.1原本的计算
    // 专给PC平台使用，是因为PC平台在ShadowDistance之外的范围atten值都为0，这跟移动端不同。所以会在shadowDistance附近及之外产生黑色区域，只能通过与移动端分开处理来解决
    return saturate( fadeDist * _LightShadowData.z  + _LightShadowData.w );

#else

    // 自定义的一次函数做Fade
    MidPrec fadeRatio = fadeDist / (_ShadowDistance + PROPERTY_ZERO);
    // return saturate( fadeRatio * 9.091  - 7.27273 ); // 0.8-0.99 用这个阴影更暗的，因为骑上载具后头顶会很淡
    return saturate( fadeRatio * 4.0  - 2.8 ); // 0.7-0.95 
    // 下面是一次函数的公式
    // MidPrec leftRatio = 0.7; //0.8
    // MidPrec rightRatio = 0.95; //0.99
    // return saturate(( fadeRatio - leftRatio ) / ( rightRatio - leftRatio ));

#endif
        // // 根据这个帖子猜测出的Fade计算：https://www.cnblogs.com/hyapp/p/12608758.html
        // // 这个计算的结果跟下面Unity原本计算的效果不同，有可能是Unity2018的Fade计算跟上述帖子中不同
        // half s  =  1.0 / 3.75;
        // half k = 5.0;
        // half shadowDistance = _ShadowDistance;
        // half w = (1.0 - s) * k - 1.0;
        // half fade = fadeDist * (1.0 - s) * k / shadowDistance - w;
        // fade = saturate(fade);
        // return fade;
   
    
}


//------------------------------------------------------------------------
// 使用 UnityGI_Base() 的方式计算全局光照 realtime / shadowMask

UnityGI UnityGI_Base_RealtimeOrShadowMask( HighPrec2 lmapUV, MidPrec3 skyLightDir, MidPrec3 worldPos, MidPrec atten, MidPrec3 worldNormalForSubtractiveModeAndRealtimeGI, MidPrec3 realtimeLightColor  )
{

	// Input for UnityGI_Base()
	UnityGI gi;
	UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
	gi.indirect.diffuse = 0;
	gi.indirect.specular = 0;
	gi.light.color = realtimeLightColor.rgb;
	gi.light.dir = skyLightDir;
	UnityGIInput data;
	UNITY_INITIALIZE_OUTPUT(UnityGIInput, data);
	data.light = gi.light;
	data.lightmapUV.xy = lmapUV;
	data.worldPos = worldPos.xyz;
	// data.worldViewDir = input.vertexOutput.;
	data.atten = atten; // atten 在很近的范围就变成0了。导致近处有黑边

    UnityGI o_gi;
    ResetUnityGI(o_gi); // 将直接光、间接光的颜色值都设置为0
    o_gi.light = data.light; // 光源的方向要正确设置，不能简单重置
    

// 第一个是用于烘焙后。第二个是用于吸色草等，不参与烘焙，但直接使用地表和物件烘焙的lightmap
#if defined(LIGHTMAP_ON) || defined(_USELIGHTMAPINTENSITY_ON)
//#ifdef LIGHTMAP_ON // 烘焙完以后使用lightmap

    #if defined(LIGHTMAP_ON) && !defined(_USELIGHTMAPINTENSITY_ON)
	    MidPrec4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lmapUV);
    #else
        MidPrec4 bakedColorTex = tex2D(_LightMap, lmapUV);
    #endif

	MidPrec3 bakedColor = DecodeLightmap_Custom(bakedColorTex);

    // 混合实时阴影和烘焙的ShadowMask阴影
    half bakedAtten = bakedColorTex.a; //UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
    MidPrec realtimeShadowAttenuation = 1.0;
    
// #if LIGHTMAP_ON // 草也接受实时阴影
    
    #if defined( _ALWAYS_USE_BAKEATTEN )

        // 烘焙后，就始终使用烘焙阴影而不使用实时阴影的物体。如树叶
        data.atten = bakedAtten;

    #else

        // // 普通的烘焙后的物体，会根据是否开启近处实时阴影模式来判断阴影的采样方式
        // float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz); // 求片元点到相机的距离的向量，在View空间相机Forward方向的投影长度。
        MidPrec fadeDist = Custom_UnityComputeShadowFadeDistance(data.worldPos);
        // if( _DistanceShadowMask > PROPERTY_ZERO){
        //     // Distance ShadowMask 方式
        //     data.atten = lerp(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
        // } 
        // else{
        //     // ShadowMask 方式
            realtimeShadowAttenuation = saturate(data.atten + Custom_UnityComputeShadowFade(fadeDist)); //UnityComputeShadowFade()
            data.atten = min(realtimeShadowAttenuation, bakedAtten); 
        //}

    #endif
	 
// #else
//         // _USELIGHTMAPINTENSITY_ON 是草等低矮植被用的
//         data.atten *= bakedAtten; 
// #endif
    o_gi.light.ndotl = data.atten; //暂时使用ndotl存储阴影
    o_gi.light.color *= data.atten; // 直接光
	//o_gi.indirect.diffuse += ( lerp( bakedColor.rgb, _IndirectLightTint.rgb,_IndirectLightTint.a ) ) ; // 间接光 
    //o_gi.indirect.diffuse += ( bakedColor.rgb * BakedColorTint()) ; // 间接光
    // 这里用正片叠底的方式来实现tint，a通道 x 4 是用来实现缩放，及增亮正片叠底后的结果的。但同时会尽量保存光照贴图中彩色信息
    // indirectLight 省去了 UnityGI_Base()中 UnityGI_IndirectSpecular()中根据粗糙度采样环境球得到spec和diffuse的计算。虽然少了些明显的金属质感效果，但我们场景(不包括角色)并不需要非常写实的效果，所以足够了
    MidPrec3 indirectLight = lerp( bakedColor.rgb * BakedColorTint(), bakedColor.rgb, SaturateFromRGB_MidPrec(bakedColor.rgb) );
    o_gi.indirect.diffuse += indirectLight;

    // 根据实时阴影压暗 环境光Diffuse项
    // 说明： 环境光diffuse部分如果在烘焙的阴影区域之内，如果同时处在动态实时阴影区域中，理论上这种区域附近应该有相应的AO。但我们不使用SSAO，故无法直接给站在烘焙阴影区域的角色脚下或身边增加AO效果。于是这里取实时阴影区域作为mask，让烘焙阴影区域的环境光diffuse也降暗一点，来达到类似AO的目的。虽然与AO相差甚远，看上去就是在阴影区域处也有实时阴影而已，但至少角色不飘了。
    o_gi.indirect.diffuse *= lerp( lerp( 0.7, 1.0, realtimeShadowAttenuation ), 1.0, data.atten);

    // return o_gi;

	// 
	//------------------------------------------------------------------------


#else // 未烘焙时使用lambert diffuse

	// 在烘焙之前，用于考虑实时的环境光。ShadeSHPerPixel会计算Lighting-Environment Lighting
    // MidPrec3 ambientSkyColor = MidPrec3(0,0,0);
    //ambientSkyColor = ShadeSHPerPixel( worldNormalForSubtractiveModeAndRealtimeGI, ambientSkyColor, worldPos ); 
	//另补充球谐光照原理：例如在光照条件固定的情况下，我们可以对每个空间点附近的一个球面区域去真实的用公式计算一些采样点的值，然后按照前面章节用光照公式的采样曲线同选定的几组球谐函数正交基底积分算出每个正交基底的参数，最后利用这些正交基底，即可以求出空间点球面上任意一个位置的光照，这就是光照探头的基本思想，即在光照固定的情况下先用真实光照方程采样，降低维度，用一组少量参数去计算任意位置的光照。
    // 我们是各氛围配环境光，配的环境光只是纯色，所以使用 ShadeSHPerPixel()没有意义。而因为是卡通风，所以这个纯色已经满足需求了

    // 不加Fade的话，编辑器上会在ShadowDistance外显示atten=0的效果
    MidPrec fadeDist = Custom_UnityComputeShadowFadeDistance(data.worldPos);
    atten = saturate(data.atten + Custom_UnityComputeShadowFade(fadeDist)); //UnityComputeShadowFade()

    o_gi.light.color = realtimeLightColor * atten; // 直接光
    o_gi.indirect.diffuse = unity_AmbientSky.rgb;  //间接光

    

#endif

// 模拟烘焙了最强环境光方向贴图的效果，目的是为了让背光面和阴影区能够有法线凹凸效果
    // MidPrec3 envLightDir = MidPrec3(0,1,0);
    // MidPrec3 envLightDir =  MidPrec3(-0.4,1,0.1); 
    // MidPrec3 envLightDir = MidPrec3(-0.4,1,-0.1); // 西南方向朝下的光
    MidPrec3 envLightDir = MidPrec3(-0.3698,0.9245,-0.09245); // 这是(-0.4,1,-0.1)单位化的结果
    // MidPrec3 envLightDir = MidPrec3(normalize( UNITY_MATRIX_V[0].xyz + UNITY_MATRIX_V[2].xyz + MidPrec3(0,0.8,0) ));
    MidPrec indirectHalfLambert = dot( envLightDir, worldNormalForSubtractiveModeAndRealtimeGI ) * 0.5 + 0.5;
    o_gi.indirect.diffuse *= lerp(indirectHalfLambert, 1.0, 0.4 ); // TODO: 确定这个值（这个0.4还可以再调整）
    o_gi.indirect.diffuse = max(0.0, o_gi.indirect.diffuse);

    return o_gi;

}

//------------------------------------------------------------------------
// Lighting Standard For Mobile

inline half4 LightingStandardForMobile (SurfaceOutputStandard s, float3 viewDir, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = BRDF2_Unity_PBS_Custom (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
    c.a = outputAlpha;

    return c;
}

inline void LightingStandardForMobile_GI (
    SurfaceOutputStandard s,
    UnityGIInput data,
    inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif
}

inline half4 CalcLightMobileWorkSurface (WorkSurfaceOutputStandard s, float3 viewDir, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = BRDF2_Will_PBS(s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
    c.a = outputAlpha;

    c = min(10,c); // 过亮的值会导致bloom过于严重

    // 自发光
    c.rgb += s.Emission.rgb;

    return c;
}


#endif // PBRHEADER_SHADER_HEARDER_INCLUDE
