/**
  * @file       UtilHeader.cginc
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/05/14
  */

#ifndef UTIL_HEADER_SHADER_INCLUDED
#define UTIL_HEADER_SHADER_INCLUDED

#include "DataTypes.cginc"

//
#define CHECK_COLOR(value) return HighPrec4(value.rgb,1);
#define CHECK_VALUE(value) return HighPrec4(value,value,value,1);

// Shader LOD 注:写ShaderLod的地方不能使用 define，只能写数字
//#define SHADER_LOD_VERY_HIGH 600 // 极致
//#define SHADER_LOD_HIGH 500  // 精致
//#define SHADER_LOD_MEDIUM 400 // 流畅
//#define SHADER_LOD_LOW 300 // 省电


// 通用宏定义
#define PROPERTY_ZERO 0.01 // property判断是否大于0时的变量，一般用于trigger的属性判断，因为property是一个浮点数，所以用0判断不靠谱。
#define MAX_COLOR 20.0 // 颜色计算结果的上限：树
#define MAX_COLOR_GRASS 5.0 // 颜色计算结果的上限：草


// 避免计算出现非正常结果的宏定义

#define SAFE_POW( a, x ) pow( a + 1e-2, x )


// 采样Mipmap的 Bias, 解决贴图看上去糊的问题
HighPrec _SampleBias = -2.0;

// 避免分母为0，导致rsqrt后值为inf（无穷）,产生了ip7特效黑色问题
inline MidPrec3 SafeNormalize_Mid(MidPrec3 inVec)
{
    MidPrec dp3 = max(0.001h, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

inline HighPrec3 SafeNormalize_High(HighPrec3 inVec)
{
    HighPrec dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}


//
inline HighPrec3 UnityObjectToViewDir( in HighPrec3 pos )
{
    return mul(UNITY_MATRIX_V, mul(unity_ObjectToWorld, HighPrec4(pos, 0.0))).xyz; // 注意pos.w用0.0，因为是vector，用pos.w=1算出来的结果是错误的
}
inline HighPrec3 UnityObjectToViewDir(HighPrec4 pos) // overload for float4; avoids "implicit truncation" warning for existing shaders
{
    return UnityObjectToViewDir(pos.xyz);
}

inline HighPrec3 UnityWorldToViewDir( in HighPrec3 dir ) {
	return mul(UNITY_MATRIX_V, HighPrec4(dir, 0.0)).xyz;
}
inline HighPrec3 UnityWorldToViewDir(HighPrec4 dir) {
	return UnityWorldToViewDir(dir.xyz);
}

inline HighPrec3 UnityViewToWorldDir( in HighPrec3 dir ) {
	return mul(UNITY_MATRIX_I_V, HighPrec4(dir, 0.0)).xyz;
}

inline HighPrec3 UnityViewToWorldDir(HighPrec4 dir) {
	return UnityViewToWorldDir(dir.xyz);
}

inline MidPrec3 CustomUnpackNormal(MidPrec4 packedNormal) {
  return packedNormal.xyz * 2 - 1;
}

//--------------------------------
// 颜色相关函数
inline MidPrec SaturateFromRGB_MidPrec( MidPrec3 rgb ){
  MidPrec maxValue = max( rgb.r, max(rgb.g, rgb.b));
  MidPrec minValue = min( rgb.r, min(rgb.g, rgb.b));
  MidPrec diff = maxValue - minValue;
  return diff / ( maxValue + 0.01h );
}

inline LowPrec SaturateFromRGB_LowPrec( LowPrec3 rgb ){
  LowPrec maxValue = max( rgb.r, max(rgb.g, rgb.b));
  LowPrec minValue = min( rgb.r, min(rgb.g, rgb.b));
  LowPrec diff = maxValue - minValue;
  return diff / ( maxValue + 0.01 );
}

// RGB和HSV互转
inline MidPrec3 Rgb2Hsv(MidPrec3 rgb){
  MidPrec maxValue = max(rgb.r, max(rgb.g, rgb.b));
  MidPrec minValue = min(rgb.r, min(rgb.g, rgb.b));
  MidPrec delta = maxValue - minValue;

  MidPrec3 hsv;
  if(delta == 0){
    hsv.r = 0;
  }else if(maxValue == rgb.r){
    hsv.r = 60 * ((rgb.g - rgb.b) / delta % 6);
  }else if(maxValue == rgb.g){
    hsv.r = 60 * ((rgb.b - rgb.r) / delta + 2);
  }else if(maxValue == rgb.b){
    hsv.r = 60 * ((rgb.r - rgb.g) / delta + 4);
  }

  hsv.g = maxValue == 0 ? 0 : delta / maxValue;

  hsv.b = maxValue;

  return hsv;
}

inline MidPrec3 Hsv2Rgb(MidPrec3 hsv){
  MidPrec c = hsv.b * hsv.g;
  MidPrec x = c * (1 - abs(hsv.r / 60 % 2 - 1));
  MidPrec m = hsv.b - c;

  MidPrec3 rgb;
  if(hsv.r < 60){
    rgb = MidPrec3(c, x, 0);
  }else if(hsv.r < 120){
    rgb = MidPrec3(x, c, 0);
  }else if(hsv.r < 180){
    rgb = MidPrec3(0, c, x);
  }else if(hsv.r < 240){
    rgb = MidPrec3(0, x, c);
  }else if(hsv.r < 300){
    rgb = MidPrec3(x, 0, c);
  }else if(hsv.r < 360){
    rgb = MidPrec3(c, 0, x);
  }

  return rgb + m;
}

inline MidPrec3 ChangeColorByHsv(MidPrec3 src, MidPrec3 hsvOffset){
  MidPrec3 result = src;
  #if _CUSTOM_COLOR
    MidPrec3 hsv = Rgb2Hsv(src);
    hsv.r = clamp(hsv.r + hsvOffset.r, 0, 360);
    hsv.g = saturate(hsv.g + hsvOffset.g);
    hsv.b = hsv.b + hsvOffset.b; // 明度不需限制到0 - 1
    result = Hsv2Rgb(hsv);
  #endif
  return result;
}


//----------------------------------------------
// interact with player
// 与角色互动
inline HighPrec3 InteractWithPlayer( HighPrec3 worldPos, HighPrec4 playerPos, HighPrec interactDistance, HighPrec offsetFactor, HighPrec offsetMulply  ){

  HighPrec3 deltaPos = worldPos.xyz - playerPos.xyz;
  HighPrec playerDistance = dot( deltaPos.xz, deltaPos.xz );
  if(playerDistance < interactDistance){
      HighPrec forceMulply = interactDistance - playerDistance;

      HighPrec2 force = deltaPos.xz * forceMulply * offsetFactor * offsetMulply ;
      // HighPrec2 force = deltaPos.xz * forceMulply * saturate( playerPos.w  * 15) * offsetFactor * offsetMulply ; // playerPos.w 需要乘以一个值，因为它是每帧角色的位置差，太小了。forceMulply乘以两次，是为了让草推开的范围有个弧度变化，稍好看一点。之前会根据角色停下来而停下变形，但是那样会导致植物迅速恢复到正常姿势，像有弹性一样，效果不佳。故现在不在考虑角色是否停下来。
      worldPos.xz += force;
  }
  return worldPos;
}     

  float4 _PlayerPos; // 角色的位置。雾效里用到是为了避免高山远处雾效非常重时，显示为纯色效果不佳。也用于互动
  //float4 _Player2CameraPos; //相对于摄像机的角色位置


//----------------------------------------------
// 大世界场景中浮点精度问题导致的 z-fighting 解决方案
// 将模型矩阵和观察矩阵同时位移至世界空间原点附近

inline void AdjustMatrixMVforBigworld( out float4x4 modelMatrix, out float4x4 viewMatrix ){

    // 由于世界位置往往较大，浮点数计算精度不够，z-fighting严重。
    // 于是将模型矩阵和观察矩阵都同时平移主相机世界位置的距离，将相机移到世界空间原点。来避免矩阵中位移项过大的数字。
    modelMatrix = HighPrec4x4(
        UNITY_MATRIX_M._11, UNITY_MATRIX_M._12, UNITY_MATRIX_M._13, UNITY_MATRIX_M._14 - _WorldSpaceCameraPos.x,
        UNITY_MATRIX_M._21, UNITY_MATRIX_M._22, UNITY_MATRIX_M._23, UNITY_MATRIX_M._24 - _WorldSpaceCameraPos.y,
        UNITY_MATRIX_M._31, UNITY_MATRIX_M._32, UNITY_MATRIX_M._33, UNITY_MATRIX_M._34 - _WorldSpaceCameraPos.z,
        0.0f, 0.0f, 0.0f, 1.0f
    );
    viewMatrix = HighPrec4x4(
        UNITY_MATRIX_V._11, UNITY_MATRIX_V._12, UNITY_MATRIX_V._13, 0.0f,
        UNITY_MATRIX_V._21, UNITY_MATRIX_V._22, UNITY_MATRIX_V._23, 0.0f,
        UNITY_MATRIX_V._31, UNITY_MATRIX_V._32, UNITY_MATRIX_V._33, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    );
}

// -------------------------------------------------------------------
// utils for baking
//

half ModifyBakeAtten(half bakeAtten) {
  return saturate(bakeAtten + 0.1h); // TODO： 开放烘焙阴影浓度调节
}

// 优化Unity built-in的 UnityMetaVertexPosition 函数，去掉 unity_MetaVertexControl 参数的分支（项目中只使用bake GI, 不用 dynamic GI）
float4 UnityMetaVertexPosition4BakeOnly(float4 vertex, float2 uv1,float4 lightmapST)
{
    vertex.xy = uv1 * lightmapST.xy + lightmapST.zw;
    // OpenGL right now needs to actually use incoming vertex position,
    // so use it in a very dummy way
    vertex.z = vertex.z > 0 ? 1.0e-4f : 0.0f;
    return mul(UNITY_MATRIX_VP, float4(vertex.xyz, 1.0));
}

// -------------------------------------------------------------------
// utils for Dying 染色
// 染色。支持两种颜色
// disableDyingMask = pars.input.vertexColor.g * albedoTexColor.a

inline MidPrec3 dye( MidPrec3 albedo, MidPrec4 dyeColor, MidPrec4 dyeColor2, MidPrec blend, MidPrec disableDyingMask  ){
    // 启用染色时，使用更大自由度的Tint方式。这里乘以2，并不影响 _Color反算得到正确的HSV值给到客户端显示滑条值
    // 染色支持两种颜色。两种颜色的遮罩是 PbrControlMap的B通道
    MidPrec3 dyeColor1and2 = lerp( dyeColor2.rgb, dyeColor.rgb, blend);
    MidPrec3 dyeColorWithAlpha = lerp( MidPrec3(1,1,1), dyeColor1and2.rgb * 2.0, dyeColor.a);
    albedo *= lerp( dyeColorWithAlpha ,MidPrec3(1,1,1), disableDyingMask ); 
    return albedo;
}

// -------------------------------------------------------------------

// 是否使用shader中每个model单独计算的fog
#define USE_BUILTIN_FOG

#if defined(USE_BUILTIN_FOG)
#define BUILTIN_FOG_COORDS(idx)         UNITY_FOG_COORDS(idx)
#define BUILTIN_FOG_TRANSFER(o,outpos)  UNITY_TRANSFER_FOG(o,outpos)
#define BUILTIN_FOG_APPLY(coord,col)    UNITY_APPLY_FOG(coord,col)
#else
#define BUILTIN_FOG_COORDS(idx)
#define BUILTIN_FOG_TRANSFER(o,outpos)
#define BUILTIN_FOG_APPLY(coord,col)
#endif

// 距离雾/Distance Fog ------------------------------------------------

// _DistanceFogTexture
#define DECLARE_DISTANCE_FOG_TEXTURE(tex) uniform sampler2D tex

/*
  _DistanceFogParam1
  param1.x : distance fog near
  param1.y : distance fog far
 */
#define DECLARE_DISTANCE_FOG_PARAM1(param1) uniform MidPrec4 param1
 /*
   _DistanceFogParam2
   param2.x : distance fog pow
   param2.y : distance fog thin
   param2.z : distance fog dense
  */
#define DECLARE_DISTANCE_FOG_PARAM2(param2) uniform MidPrec4 param2

  /*
	_SunFogParam1
	param1.xyz : sun fog color
	param1.w   : sun fog pow
   */
#define DECLARE_SUNFOG_PARAM1(param1) uniform MidPrec4 param1

   /*
	 _HeightFogParam1
	 param1.x : height fog density
	 param1.y : height fog exp
	 param1.z : height fog offset (in world space y direction)
	 param1.w : height fog 类 tone mapping 的 拉伸曲线 exp 参数：在算出最后的 fogDensity 以后，不直接拿来用
			   （因为fog density很可能会大于1），也不直接 saturate( fogDensity ) （因为这样输出的结果是一条折线，
				 显示在屏幕上时，雾效会有一条非常明显的折痕），而是使用 1 - exp(-param * fogDensity)，作为最后
				 实际使用的 雾浓度
	 => 迭代 改成
	 param1.x ： 起始高度
	 param1.y ： 终止高度
	 param1.z ： 起始浓度
	 param1.w ： 终止浓度
	*/
#define DECLARE_HEIGHTFOG_PARAM1(param1) uniform MidPrec4 param1

	/*
	  _HeightFogParam2
	  param2.xyz : height fog color
	  param2.w  ： pow
	 */
#define DECLARE_HEIGHTFOG_PARAM2(param2) uniform MidPrec4 param2

	 /* 
   
   by Will:
   地表已经被我修改为 Blend SrcAlpha OneMinusSrcAlpha。 以下公式解释简述为：
   Opaque和普通混合时：
   finalC = f*d + (1-d)c0
   当 Blend One One 时，
   fincalC = f*d + (1-d)(c0 + c1) = fd + (1-d)c0 + (1-d)c1 = finalC0 + (1-d)c0
   所以GuoYi 提供了 addpassModifier 用于区分 Blend One One 和其他情况

   by GuoYi:
	   addpassModifier 变量，在 first-pass 中值为1，在 add-pass 中值为0
	   原理是：   假设有 一个 base pass 和一个 add pass，已经计算出距离雾的融合权重为 fogRatio
				 则最后的融合公式为 (baseColor+addColor) * (1-fogRatio) + fogColor * fogRatio       (A)
				 (因为默认的Unity terrain中、base pass和add pass的叠加方式，就是`decal add`、或者`blend one one`)
				 但是因为 base pass 和 add pass 需要分成两个 material 先后计算，因此最后的计算规则是
				 先计算 base pass，同时把雾也算进去，得
							 baseColor * (1-fogRatio) + fogColor * fogRatio                        (B)
				 然后计算 add pass，这次不计算雾，得
							 addColor * (1-fogRatio) + fogColor * 0                                (C)
				 显然 (A) = (B) + (C)
	 如果是 heightmap based terrain，因为在计算每个 add pass 时都会使用 grab pass 获取的前面的各层地表的叠加效果，因此
	 这个公式可能需要做一些修改
				 <=4层地表时，输出为 baseColor * (1-fogRatio) + fogColor * fogRatio
				 >4,<=8层地表时，正确输出应该为 (baseColor * blend1 + addColor * blend2) * (1-fogRatio) + fogColor * fogRatio
						 但是只能通过 grab pass 获得 grabColor = baseColor * (1-fogRatio) + fogColor * fogRatio
						 所以实际计算为： (grabColor-fogColor*fogRatio)*blend1 + addColor * blend2 * (1-fogRatio) + fogColor * fogRatio
				 >8,<=4层地表时，计算方式以此类推
	  */

// #if _USE_CUSTOM_DISTANCE_HEIGHT_FOG
// 	  // ！！！注意需要考虑两个 addpass 如何正确受雾(distance fog + sun fog)：一个是 terrain 的 addpass；一个是 forward add "LightMode" 处理 point light 的 add pass（在这类addpass中，无法计算太阳雾，因为_WorldSpaceLightPos0.xyz不再是主光源方向，而是点光源位置）
// #define CALC_DISTANCE_FOG_PARAM(worldPosXYZ) \
// 		half3 fogColorPart = _HeightFogParam2.rgb;\
//         half cameraDis = saturate( (worldPosXYZ.y - _HeightFogParam1.x)/(_HeightFogParam1.y - _HeightFogParam1.x) ); \
//         cameraDis = saturate(1 - cameraDis); \
// 		if (cameraDis > 0)\
// 		{\
// 			cameraDis =  SAFE_POW(cameraDis, _HeightFogParam2.w); \
// 			cameraDis = _HeightFogParam1.z + cameraDis * (_HeightFogParam1.w - _HeightFogParam1.z); \
// 			fogColorPart = _HeightFogParam2.rgb * cameraDis; \
// 		}\
// 		else\
// 		{\
// 			cameraDis = distance(_WorldSpaceCameraPos, worldPosXYZ); \
// 			half3 fogCameraVec = normalize(worldPosXYZ - _WorldSpaceCameraPos.xyz); \
// 			half3 fogLightVec = normalize(_WorldSpaceLightPos0.xyz); \
// 			cameraDis = saturate((cameraDis - _DistanceFogParam1.x) / (_DistanceFogParam1.y - _DistanceFogParam1.x)); \
// 			cameraDis = saturate(cameraDis * (_DistanceFogParam2.z - _DistanceFogParam2.y) + _DistanceFogParam2.y); \
// 			cameraDis =  SAFE_POW(cameraDis, _DistanceFogParam2.x); \
// 			half4 fogTexColor = tex2D(_DistanceFogTexture, float2(cameraDis, 0.5f)); \
// 			half sunFogRatio =  SAFE_POW(saturate(dot(fogCameraVec, fogLightVec)), _SunFogParam1.w); \
// 			sunFogRatio = lerp(sunFogRatio, 0, _WorldSpaceLightPos0.w); \
// 			fogTexColor.rgb = lerp(fogTexColor.rgb, _SunFogParam1.rgb, sunFogRatio); \
// 			cameraDis *= fogTexColor.a; \
// 			fogColorPart = fogTexColor.rgb * cameraDis; \
// 		}\
// 		fogColorPart = fogColorPart * saturate(1 - _WorldSpaceLightPos0.w);


// 	 // !!! 这个目前主要在特效材质中使用，用来处理在 blend one one 等混合模式下，做了雾效渲染以后，
// 	 // 原来完全透明的面片部分反而显示出来的效果问题
// 	#define MODIFY_FOGCOLOR_BY_ALPHA(mainColorAlpha, refVal) \
// 		fogColorPart = fogColorPart * step(refVal, mainColorAlpha); //还不确定这段代码有没有用

// 	 // !!! 注意这里不要修改 color.a ，否则会影响地表不同层的融合效果
// 	#define APPLY_DISTANCE_FOG(color, addpassModifier) \
// 		color.rgb = fogColorPart * addpassModifier + (1 - cameraDis) * color.rgb;\

// 	#define DISTANCE_FOG_ADDPASS_COMBINE(color, gt, pblend) \
// 		color.rgb = (1 - cameraDis) * color.rgb * pblend[0] + (gt.rgb - fogColorPart) * pblend[1] + fogColorPart;

//       #if _DST_BLEND_ONE 
//         #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 0)      
//       #else
//         #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 1)
//       #endif

//------------------------------------------------------------------------
// 这是我们正在使用的雾效: 面板中 DistanceFogAndSunFog

// 这里是以下部分代码的注释： by Will
      // cameraDis = saturate( (cameraDis - _DistanceFogParam1.x) / (_DistanceFogParam1.y - _DistanceFogParam1.x) ); \ // ( dis - 最淡距离(起雾距离) ) / ( 最浓起点距离 - 最淡距离 )
      //   cameraDis = saturate( cameraDis * (_DistanceFogParam2.z - _DistanceFogParam2.y) + _DistanceFogParam2.y ); \ // dis *( 最大浓度 - 最小浓度) + 最小浓度
      //   cameraDis =  SAFE_POW( cameraDis, _DistanceFogParam2.x ); \ // 使变化有曲线效果
//       half4 fogTexColor = tex2D(_DistanceFogTexture, float2(cameraDis, 0.5f)); \ // 这张图是用CS脚本借助Gradient类生成的
// half sunFogRatio =  SAFE_POW( saturate(dot(fogCameraVec, fogLightVec)), _SunFogParam1.w ); \ // 这里是将非直射光的ratio设置为0
// sunFogRatio = lerp( sunFogRatio , 0 ,_WorldSpaceLightPos0.w); \
// fogTexColor.rgb = lerp( fogTexColor.rgb, _SunFogParam1.rgb, sunFogRatio ); \ // 距离雾和太阳雾颜色比重
// cameraDis *= fogTexColor.a; \ // 考虑雾alpha，当alpha很低，相当于CameraDis较小。
// half3 fogColorPart = fogTexColor.rgb * cameraDis; \ // 距离越小，该fogColorPart越暗
// fogColorPart = fogColorPart * saturate(1-_WorldSpaceLightPos0.w); 只有在直射光的pass中才计算雾效


#ifndef _NO_CUSTOM_FOG
      // ！！！注意需要考虑两个 addpass 如何正确受雾(distance fog + sun fog)：一个是 terrain 的 addpass；一个是 forward add "LightMode" 处理 point light 的 add pass（在这类addpass中，无法计算太阳雾，因为_WorldSpaceLightPos0.xyz不再是主光源方向，而是点光源位置）by Guoyi
      // by Will: 这里将太阳的方向写死在了代码中（之后可以考虑用C Sharp传），目的是让不需要光照的Shader不再需要 multi_compile_fwdbase关键字，以减少变体数
      // heightFactor: 减淡高山山顶雾效，避免远处高山看上去生硬的纯色
      // heightFogDelta: 低于相机一定高度时，雾变浓，以解决从高处俯视远处低处很多物体没有加载出来，地块光秃秃并且都是lightmap的影子很丑的问题
      
      #define CALC_DISTANCE_FOG_PARAM(worldPosXYZ) \
        half cameraDis = distance( _WorldSpaceCameraPos, worldPosXYZ ); \
        half3 fogCameraVec = normalize( worldPosXYZ - _WorldSpaceCameraPos.xyz ); \
        cameraDis = saturate( (cameraDis - _DistanceFogParam1.x) / (_DistanceFogParam1.y - _DistanceFogParam1.x) ); \
        cameraDis = saturate( cameraDis * (_DistanceFogParam2.z - _DistanceFogParam2.y) + _DistanceFogParam2.y ); \
        cameraDis =  SAFE_POW( cameraDis, _DistanceFogParam2.x ); \
        half4 fogTexColor = tex2D(_DistanceFogTexture, float2(cameraDis, 0.5f)); \
        cameraDis = saturate( cameraDis * fogTexColor.a ); \
        half deltaHeight = worldPosXYZ.y - _WorldSpaceCameraPos.y;\
        half heightFactor = clamp( deltaHeight * 0.01, 0.0, 0.5);\
		    cameraDis = lerp( cameraDis, 0.0,heightFactor );\
        half heightFogDelta = -50.0 - deltaHeight - _DistanceFogParam1.z;\
        cameraDis = lerp( cameraDis, 1.0, saturate( sign(heightFogDelta) * abs(heightFogDelta) * 0.05 ));\
        half3 fogColorPart = saturate( fogTexColor.rgb * cameraDis ); \

      // !!! 这个目前主要在特效材质中使用，用来处理在 blend one one 等混合模式下，做了雾效渲染以后，
      // 原来完全透明的面片部分反而显示出来的效果问题 by GuoYi
      #define MODIFY_FOGCOLOR_BY_ALPHA(mainColorAlpha, refVal) \
        fogColorPart = fogColorPart * step(refVal, mainColorAlpha);

      // !!! 注意这里不要修改 color.a ，否则会影响地表不同层的融合效果
      #define APPLY_DISTANCE_FOG(color, addpassModifier) \
        color.rgb = fogColorPart * addpassModifier + (1 - cameraDis) * color.rgb; \


      #define DISTANCE_FOG_ADDPASS_COMBINE(color, gt, pblend) \
        color.rgb = (1 - cameraDis) * color.rgb * pblend[0] + (gt.rgb - fogColorPart) * pblend[1] + fogColorPart;

      // by Will
      // 只有在 DstBlend 为 One时， fd + (1-d)c 中，fd项要去掉，其他的都要按比例为1时乘进去.
      // 注：还有少数DstBlend 为其他的不同情况要进行别的计算，但这里都统一成跟 _DstBlend = OneMinusSrcAlpha 一样了。避免过多不重要的关键字
      #if _DST_BLEND_ONE 
        #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 0)      
      #else
        #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 1)
      #endif


// 
//------------------------------------------------------------------------

// #elif _USE_CUSTOM_HEIGHT_FOG
//       // #define CALC_DISTANCE_FOG_PARAM(worldPosXYZ) \
//       //   half cameraDis = distance( _WorldSpaceCameraPos, worldPosXYZ ); \
//       //   half cameraPixelLength = cameraDis; \
//       //   half3 fogCameraVec = normalize( -_WorldSpaceCameraPos.xyz + worldPosXYZ ); \
//       //   half3 fogLightVec = normalize( _WorldSpaceLightPos0.xyz ); \
//       //   half sunFogRatio =  SAFE_POW( saturate(dot(fogCameraVec, fogLightVec)), _SunFogParam1.w ); \
//       //   half4 fogTexColor = half4(_HeightFogParam2.rgb, 1); \
//       //   fogTexColor.rgb = lerp( fogTexColor.rgb, _SunFogParam1.rgb, sunFogRatio ); \
//       //   half heightFogRatio = _HeightFogParam1.x * exp(-_HeightFogParam1.y*(_WorldSpaceCameraPos.y+_HeightFogParam1.z)) * (1-exp(-_HeightFogParam1.y*fogCameraVec.y*cameraPixelLength)) / (_HeightFogParam1.y * fogCameraVec.y); \
//       //   cameraDis = heightFogRatio; \
//       //   cameraDis = 1 - exp(-_HeightFogParam1.w*cameraDis); \
//       //   half3 fogColorPart = fogTexColor.rgb * heightFogRatio;

//       #define CALC_DISTANCE_FOG_PARAM(worldPosXYZ) \
//         half cameraDis = saturate( (worldPosXYZ.y - _HeightFogParam1.x)/(_HeightFogParam1.y - _HeightFogParam1.x) ); \
//         cameraDis = saturate(1 - cameraDis); \
//         cameraDis =  SAFE_POW(cameraDis, _HeightFogParam2.w); \
//         cameraDis = _HeightFogParam1.z + cameraDis * (_HeightFogParam1.w - _HeightFogParam1.z); \
//         half3 fogColorPart = _HeightFogParam2.rgb * cameraDis; \
//         fogColorPart = fogColorPart * saturate(1-_WorldSpaceLightPos0.w);

//       #define MODIFY_FOGCOLOR_BY_ALPHA(mainColorAlpha, refVal) \
//         fogColorPart = fogColorPart * step(refVal, mainColorAlpha);

//       // 注意这里不要修改 color.a ，否则会影响地表不同层的融合效果
//       #define APPLY_DISTANCE_FOG(color, addpassModifier) \
//         color.rgb = fogColorPart * addpassModifier + (1 - cameraDis) * color.rgb; \

//       #define DISTANCE_FOG_ADDPASS_COMBINE(color, gt, pblend) \
//         color.rgb = (1 - cameraDis) * color.rgb * pblend[0] + (gt.rgb - fogColorPart) * pblend[1] + fogColorPart;

//         #if _DST_BLEND_ONE 
//         #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 0)      
//       #else
//         #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 1)
//       #endif
#else
      #define CALC_DISTANCE_FOG_PARAM(worldPosXYZ)
      #define MODIFY_FOGCOLOR_BY_ALPHA(mainColorAlpha, refVal)
      #define APPLY_DISTANCE_FOG(color, addpassModifier)
      #define DISTANCE_FOG_ADDPASS_COMBINE(color, gt, pblend) \
        color.rgb = color.rgb * pblend[0] + gt.rgb * pblend[1];
      #define APPLY_CUSTOM_FOG(color) APPLY_DISTANCE_FOG(color, 1)
#endif

// -------------------------------------------------------------------

#endif // UTIL_HEADER_SHADER_INCLUDED