/*
当前正在使用的PostProcess
两种blur算法： Box Filtering / Dual Filtering

@author : Will
*/
Shader "Hidden/PostProcess/PostProcess Controller"
{
	// 注意，这个不能加，加了之后，使用CommandBuffer的情况下会导致 _MainTex_TexelSize 会无法正确传入！！！但是在 OnRenderImage()时没问题！
	// Properties
	// {
	// 	_MainTex("Base (RGB)", 2D) = "" {}
	// }

	CGINCLUDE

	#define EPSILON 1.0e-3

	#include "UnityCG.cginc"

	// 哪个环节是最后的一环
	#pragma multi_compile _ FINAL_BLOOM FINAL_DOF
	
	struct v2fb {
		float4 pos : POSITION;
		float4 uv : TEXCOORD0;
	};
	struct v2f {
		float4 pos : POSITION;
		float2 uv  : TEXCOORD0;
	};

	sampler2D _MainTex;
	sampler2D _BlurTex;
	uniform float _LutAmount;
	uniform float _BloomThreshold;
	uniform float _BloomAmount;
	uniform float _BlurAmount;
	float4 _MainTex_TexelSize; // (1 / width, 1 / height, width, height) passed by Unity

	// 深度纹理
	sampler2D _CameraDepthTexture;

	// Depth of Field
	uniform float4 _DofParams; // x: focusDistance  y: focusAreaRadius  z: bokehRadius
	sampler2D _CoCTex;
	sampler2D _DoFTex;

	// Color Grading and Tone mapping
	uniform float4 _ColorGradingParams; // x: Exposure 曝光值, y: 饱和度, Z: 对比度
	uniform float _ToneMappingIntensity;
	uniform float4 _ToneMappingCurveParams;
	//uniform float _ToneMappingWhitePoint;  这个写死了，省去一个uniform


	//----------------------------------------
	// Util functions

	struct AttributesTriangle
	{
		float3 vertex : POSITION;
	};
	// Vertex manipulation
	inline float2 TransformTriangleVertexToUV(float2 vertex)
	{
		float2 uv = (vertex + 1.0) * 0.5;
		return uv;
	}

	v2f VertTriangle(AttributesTriangle v)
	{
		v2f o;
		o.pos = float4(v.vertex.xy, 0.0, 1.0);
		o.uv = TransformTriangleVertexToUV(v.vertex.xy);

	#if UNITY_UV_STARTS_AT_TOP
		o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
	#endif

		return o;
	}

	// Color Grading Utils

	inline float3 SaturateAndContrast(float3 col, float saturate, float contrast){

		float3 finalColor = col;
		// Apply saturation 
		float luminance = 0.2125 * col. r + 0.7154 * col. g + 0.0721 * col. b; 
		float3 luminanceColor = float3( luminance, luminance, luminance); 
		finalColor = lerp( luminanceColor, finalColor, saturate); 
		// Apply contrast 不再修改对比度，因为它很容易让画面中的暗部区域丢失很多细节
		// float3 avgColor = float3( 0.5, 0.5, 0.5); 
		// finalColor = lerp( avgColor, finalColor, contrast);

		return finalColor;

	}

	// 使用了离线拟合aces曲线工具的实时aces计算 https://zhuanlan.zhihu.com/p/56377344
	// 为了拟合，将前四项除以第五项参数E，于是将五个需要求解的系数减少为4个。
	inline float3 ACESFilmFit_Scalar(float3 x, float4 param)
	{
		// clamp _x to whitePoint: (这里写死为10.0)
		float3 _x = min(x, 10.0f);
		// aces curve:
		//param = float4( 2.51/0.14, 0.03/0.14, 2.43/0.14, 0.59/0.14 ); // ACES Origin Params
		// 现在用的: 2.2112f, 0.78f, 2.2448f, 0.4f。能保留更多手绘的细节。原始参数会导致很多手绘纹理丢失
		return (_x*(param.r*_x + param.g)) / (_x*(param.b*_x + param.a) + 1.0f);
		
	}

	inline float4 ColorGrading(float4 color, float4 colorGradingParams, float4 toneMappingParams ){

		// return color;

		// Tone Mapping 因为影响了手绘风角色的色阶，故将它整个去掉了
		float3 acesColor = color.rgb * colorGradingParams.x; //adapted_lum;
		////acesColor.rgb = (color.rgb * (A * color.rgb + B)) / (color.rgb * (C * color.rgb + D) + E);
		//float3 acesColor = color.rgb;
		acesColor = ACESFilmFit_Scalar( acesColor, toneMappingParams );
		// Color Grading
		// acesColor = lerp( color.rgb, acesColor, saturate(color.a) ); // 让角色不受ToneMapping影响
		
		return float4( saturate(SaturateAndContrast( acesColor.rgb, colorGradingParams.y, colorGradingParams.z )), color.a);
		//return float4( saturate(SaturateAndContrast( color.rgb, colorGradingParams.y, colorGradingParams.z )), color.a); //No ToneMapping
	}

//----------------------------------------
// verts

	// uv has 4 dimentions
	v2fb vertBlur(AttributesTriangle v)
	{
		v2fb o;
		//o.pos = UnityObjectToClipPos(v.vertex);
		o.pos = float4 (v.vertex.xy,0.0,1.0);
		float2 offset = (_MainTex_TexelSize.xy) * _BlurAmount;

		o.uv.xy = TransformTriangleVertexToUV(v.vertex.xy);
	#if UNITY_UV_STARTS_AT_TOP
		o.uv.xy = o.uv.xy * float2(1.0, -1.0) + float2(0.0, 1.0);
	#endif

		o.uv = float4(o.uv.xy - offset, o.uv.xy + offset); // ( offsetLeftX, offsetBottomY, offsetRightX, offsetTopY )
		return o;
	}

	// uv has only 2 dimensions
	v2f vert( AttributesTriangle v ) 
	{
		// v2f o;
		// o.pos = UnityObjectToClipPos(v.vertex);
		// o.uv = v.texcoord.xy;
		// return o;

		v2f o;
		o.pos = float4(v.vertex.xy, 0.0, 1.0);
		o.uv = TransformTriangleVertexToUV(v.vertex.xy);

	#if UNITY_UV_STARTS_AT_TOP
		o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
	#endif

		return o;
	} 

	// vertex for 传统的四边形blit
	v2f vertRect( appdata_img v ){
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}



	v2fb vertUpSampleBox(appdata_img v)
	{
		v2fb o;
		o.pos = UnityObjectToClipPos(v.vertex);
		float2 offset = (_MainTex_TexelSize.xy) * _BlurAmount * 0.5; // 这里在UpSample 时乘以0.5，以小一倍的范围采样是参考的PPv2里的做法。这样的效果是光晕范围更小，亮度更加集中一点，看上去会更真实一点。
		o.uv = float4(v.texcoord.xy - offset, v.texcoord.xy + offset); // ( offsetLeftX, offsetBottomY, offsetRightX, offsetTopY )
		return o;
	}

	float2 GetUV(float4 c)
	{
		float b = floor(c.b * 256.0h);
		float by = floor(b *0.0625h);
		float bx = floor(b - by * 16.0h);
		float2 uv = c.rg *0.05859375h + 0.001953125h + float2(bx, by) *0.0625h;
		return uv;
	}

	// Frags

	float4 fragCopy(v2f i) : COLOR
	{
		return tex2D(_MainTex, i.uv.xy);
	}

	float4 fragBloom(v2fb i) : COLOR 
	{
		float4 result = tex2D(_MainTex, i.uv.xy); // sample (offsetLeftX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.xw); // sample (offsetLeftX, offsetTopY)
		result += tex2D(_MainTex, i.uv.zy); // sample (offsetRightX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.zw); // sample (offsetRightX, offsetTopY)
		return max(result*0.25h - _BloomThreshold, 0.0h);
	}
	float4 fragBloomFirstDualFiltering(v2f i) : COLOR
	{
		float2 halfpixel = (_MainTex_TexelSize.xy) * _BlurAmount * 0.5h; // offset
		float4 sum = tex2D(_MainTex, i.uv) * 4.0h;
		sum += tex2D(_MainTex, i.uv - halfpixel.xy);
		sum += tex2D(_MainTex, i.uv + halfpixel.xy);
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x, -halfpixel.y));
		sum += tex2D(_MainTex, i.uv - float2(halfpixel.x, -halfpixel.y));
		//return max( sum / 8.0 - _BloomThreshold , 0.0h);

		// 模仿ppv2的threshold计算方式，旧的方式会让光晕区域产生明显色偏
		sum = sum / 8.0;
		float br = max(sum.x, max( sum.y, sum.z));

		// 加一个这段代码，因为实测发现iPhoneXR上会出现在个别点上会采样到极大的值，原因暂时不明。Xcode中查看这段代码耗时很短
		if(br > 200.0){
			sum = 0.0;
		}

		 return max(0.0,sum * (br - _BloomThreshold ))/ max(br,EPSILON);
		//return max(0.0,sum * (br - 7 ))/ max(br,EPSILON); //test!!!!!!!!!!!!!!!!! 临时强制将bloom阈值调高，以避免因为角色反aces而过曝

	}
	float4 fragBloomWill(v2fb i) : COLOR 
	{
		float4 result = tex2D(_MainTex, i.uv.xy); // sample (offsetLeftX, offsetBottomY)
		return max(result - _BloomThreshold, 0.0h);
	}

	float4 fragBlur(v2fb i) : COLOR
	{
		float4 result = tex2D(_MainTex, i.uv.xy); // sample (offsetLeftX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.xw); // sample (offsetLeftX, offsetTopY)
		result += tex2D(_MainTex, i.uv.zy); // sample (offsetRightX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.zw); // sample (offsetRightX, offsetTopY)
		return result * 0.25h;
	}

	// Dual Filter 
	// https://community.arm.com/developer/tools-software/graphics/b/blog/posts/post-processing-effects-for-mobile-at-gdc18

	float4 fragDownSampleDualFilter(v2f i) : COLOR
	{
		float2 halfpixel = (_MainTex_TexelSize.xy) * _BlurAmount * 0.5; // offset
		float4 sum = tex2D(_MainTex, i.uv) * 4.0;
		sum += tex2D(_MainTex, i.uv - halfpixel.xy);
		sum += tex2D(_MainTex, i.uv + halfpixel.xy);
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x, -halfpixel.y));
		sum += tex2D(_MainTex, i.uv - float2(halfpixel.x, -halfpixel.y));
		return sum / 8.0;
	}

	float4 fragUpSampleDualFilter(v2f i) : COLOR
	{

		float2 halfpixel = (_MainTex_TexelSize.xy) * _BlurAmount * 0.5; // offset
		float4 sum = tex2D(_MainTex, i.uv + float2(-halfpixel.x * 2.0, 0.0));
		sum += tex2D(_MainTex, i.uv + float2(-halfpixel.x, halfpixel.y)) * 2.0;
		sum += tex2D(_MainTex, i.uv + float2(0.0, halfpixel.y * 2.0));
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x, halfpixel.y)) * 2.0;
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x * 2.0, 0.0));
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x, -halfpixel.y)) * 2.0;
		sum += tex2D(_MainTex, i.uv + float2(0.0, -halfpixel.y * 2.0));
		sum += tex2D(_MainTex, i.uv + float2(-halfpixel.x, -halfpixel.y)) * 2.0;
		sum = sum / 12.0;

		return sum;
	}

	float4 fragBloomUpSampleDualFilter(v2f i) : COLOR
	{

		float2 halfpixel = (_MainTex_TexelSize.xy) * _BlurAmount * 0.5; // offset
		float4 sum = tex2D(_MainTex, i.uv + float2(-halfpixel.x * 2.0, 0.0));
		sum += tex2D(_MainTex, i.uv + float2(-halfpixel.x, halfpixel.y)) * 2.0;
		sum += tex2D(_MainTex, i.uv + float2(0.0, halfpixel.y * 2.0));
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x, halfpixel.y)) * 2.0;
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x * 2.0, 0.0));
		sum += tex2D(_MainTex, i.uv + float2(halfpixel.x, -halfpixel.y)) * 2.0;
		sum += tex2D(_MainTex, i.uv + float2(0.0, -halfpixel.y * 2.0));
		sum += tex2D(_MainTex, i.uv + float2(-halfpixel.x, -halfpixel.y)) * 2.0;
		// sum = sum / 12.0;

		float4 upTex = sum * 0.0833333; // sum / 12.0;
		float4 bloomTex = tex2D(_BlurTex, i.uv );
		sum = upTex + bloomTex; 

		return sum;
	}

	float4 fragBloomFinal(v2f i) : COLOR
	{
		float4 c = tex2D(_MainTex, i.uv);
		c += tex2D(_BlurTex, i.uv) * _BloomAmount;

#if FINAL_BLOOM
		// Color Grading
		c = ColorGrading( c, _ColorGradingParams, _ToneMappingCurveParams );
#endif
		return c; 
	}

	//---------------------------------------------------------------
	// Depth of Field

	// 参考实现：https://catlikecoding.com/unity/tutorials/advanced-rendering/depth-of-field/


	// _DofParams: x: focusDistance  y: focusAreaRadius  z: bokehRadius
		
	// From https://github.com/Unity-Technologies/PostProcessing/
	// blob/v2/PostProcessing/Shaders/Builtins/DiskKernels.hlsl

	// 选择使用更小的disc kernel以节省开销，效果看上去接近
	// disc形状的优势是更像焦散，而不仅仅是模糊
	// #define BOKEH_KERNEL_MEDIUM
	#define BOKEH_KERNEL_SMALL

#if defined(BOKEH_KERNEL_SMALL)
	static const int kernelSampleCount = 16;
	static const float2 kernel[kernelSampleCount] = {
		float2(0, 0),
		float2(0.54545456, 0),
		float2(0.16855472, 0.5187581),
		float2(-0.44128203, 0.3206101),
		float2(-0.44128197, -0.3206102),
		float2(0.1685548, -0.5187581),
		float2(1, 0),
		float2(0.809017, 0.58778524),
		float2(0.30901697, 0.95105654),
		float2(-0.30901703, 0.9510565),
		float2(-0.80901706, 0.5877852),
		float2(-1, 0),
		float2(-0.80901694, -0.58778536),
		float2(-0.30901664, -0.9510566),
		float2(0.30901712, -0.9510565),
		float2(0.80901694, -0.5877853),
	};
#elif defined (BOKEH_KERNEL_MEDIUM)
	static const int kernelSampleCount = 22;
	static const float2 kernel[kernelSampleCount] = {
		float2(0, 0),
		float2(0.53333336, 0),
		float2(0.3325279, 0.4169768),
		float2(-0.11867785, 0.5199616),
		float2(-0.48051673, 0.2314047),
		float2(-0.48051673, -0.23140468),
		float2(-0.11867763, -0.51996166),
		float2(0.33252785, -0.4169769),
		float2(1, 0),
		float2(0.90096885, 0.43388376),
		float2(0.6234898, 0.7818315),
		float2(0.22252098, 0.9749279),
		float2(-0.22252095, 0.9749279),
		float2(-0.62349, 0.7818314),
		float2(-0.90096885, 0.43388382),
		float2(-1, 0),
		float2(-0.90096885, -0.43388376),
		float2(-0.6234896, -0.7818316),
		float2(-0.22252055, -0.974928),
		float2(0.2225215, -0.9749278),
		float2(0.6234897, -0.7818316),
		float2(0.90096885, -0.43388376),
	};
#endif

	half fragDofCalcCOC(v2f i):COLOR
	{
		float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv).r;
		depth = LinearEyeDepth(depth);

		float coc = (depth - _DofParams.x) / _DofParams.y;
		// coc = clamp(coc, -1, 1) * _DofParams.z; 
		coc = clamp(coc, 0, 1) * _DofParams.z; // 改成不考虑前景，因为策划调距离时容易将角色脸调成前景里而被糊掉
		return coc;
	}

	half DofPreFilterWeight (half3 c) {
		return 1 / (1 + max(max(c.r, c.g), c.b));
	}

	half4 fragDofPreFilter(v2f i):COLOR
	{
		float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;

		half3 s0 = tex2D(_MainTex, i.uv + o.xy).rgb;
		half3 s1 = tex2D(_MainTex, i.uv + o.zy).rgb;
		half3 s2 = tex2D(_MainTex, i.uv + o.xw).rgb;
		half3 s3 = tex2D(_MainTex, i.uv + o.zw).rgb;

		half w0 = DofPreFilterWeight(s0);
		half w1 = DofPreFilterWeight(s1);
		half w2 = DofPreFilterWeight(s2);
		half w3 = DofPreFilterWeight(s3);

		half3 color = s0 * w0 + s1 * w1 + s2 * w2 + s3 * w3;
		color /= max(w0 + w1 + w2 + w3, 0.00001);

		half coc0 = tex2D(_CoCTex, i.uv + o.xy).r;
		half coc1 = tex2D(_CoCTex, i.uv + o.zy).r;
		half coc2 = tex2D(_CoCTex, i.uv + o.xw).r;
		half coc3 = tex2D(_CoCTex, i.uv + o.zw).r;

		half cocMin = min(min(min(coc0, coc1), coc2), coc3); // Coc尽量不要糊
		half cocMax = max(max(max(coc0, coc1), coc2), coc3);
		half coc = cocMax >= -cocMin ? cocMax : cocMin;

		return half4(color, coc);

	}

	half DofBokehWeight (half coc, half radius) {
		return saturate((coc - radius + 2) / 2);
	}

	half4 fragDofBokeh(v2f i):COLOR
	{
		half coc = tex2D(_MainTex, i.uv).a;
		
		half3 bgColor = 0, fgColor = 0;
		half bgWeight = 0, fgWeight = 0;
		for (int k = 0; k < kernelSampleCount; k++) {
			float2 o = kernel[k] * _DofParams.z; //_BokehRadius
			half radius = length(o);
			o *= _MainTex_TexelSize.xy;
			half4 s = tex2D(_MainTex, i.uv + o);

			half bgw = DofBokehWeight(max(0, min(s.a, coc)), radius);
			bgColor += s.rgb * bgw;
			bgWeight += bgw;

			// 放弃了前景coc
			// half fgw = DofBokehWeight(-s.a, radius);
			// fgColor += s.rgb * fgw;
			// fgWeight += fgw;
		}
		
		bgColor *= 1 / (bgWeight + (bgWeight == 0));
		return half4(bgColor, 1);

		// 放弃了前景coc
		// fgColor *= 1 / (fgWeight + (fgWeight == 0));
		// half bgfg = min(1, fgWeight * 3.14159265359 / kernelSampleCount);
		// half3 color = lerp(bgColor, fgColor, bgfg);
		// return half4(color, bgfg);

	}

	half4 fragDofPostFilter(v2f i):COLOR
	{
		float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;
		half4 s =
			tex2D(_MainTex, i.uv + o.xy) +
			tex2D(_MainTex, i.uv + o.zy) +
			tex2D(_MainTex, i.uv + o.xw) +
			tex2D(_MainTex, i.uv + o.zw);
		return s * 0.25;
	}

	half4 fragDofCombine(v2f i):COLOR
	{
		half4 source = tex2D(_MainTex, i.uv);
		half coc = tex2D(_CoCTex, i.uv).r;
		half4 dof = tex2D(_DoFTex, i.uv);

		half dofStrength = smoothstep(0.3, 1, abs(coc));
		half4 color = half4( lerp( source.rgb, dof.rgb, dofStrength ), source.a);

		// 放弃了前景coc
		// half4 color = half4( lerp(
		// 	source.rgb, dof.rgb,
		// 	dofStrength + dof.a - dofStrength * dof.a
		// ), source.a); // 这个考虑前景权重的插值方式虽然景深感会更明显，但容易前景权重泛滥，导致角色不够清晰。

		// return half4(dofStrength,dofStrength,dofStrength,1.0);
		// return half4( dofStrength + dof.a - dofStrength * dof.a,dofStrength + dof.a - dofStrength * dof.a,dofStrength + dof.a - dofStrength * dof.a, 1.0);

#if FINAL_DOF
		color = ColorGrading( color, _ColorGradingParams, _ToneMappingCurveParams );
#endif

		return color;

	}

	float4 fragDofCombineCheap(v2f i) : COLOR
	{
		// calc distance 
		float dep = tex2D(_CameraDepthTexture,i.uv).r;  
        // 深度Z缓存，从摄像机到最远平截面[0,1]  透视投影变换中 dep(Z)= f*n/[(n-f)*z] + f/(f-n); 
        //dep = Linear01Depth(dep); // 带入上面的公式，其实是 z/f
		dep = LinearEyeDepth(dep); // 改用转为真实距离，目的是后续计算可利用精度比(0,1)高

		float weight = 0.0;

		// 二次函数 weight = a(x-x1)(x-x2)
		weight = saturate( _DofParams.z * ( dep - _DofParams.x ) * ( dep - _DofParams.y) );

		// 三段分段函数，每段都是一次函数
		// if(dep < _DofParams.x - _DofParams.y){
		// 	weight = (_DofParams.y - _DofParams.x == 0.0 )? EPSILON : (_DofParams.y - _DofParams.x);
		// 	weight = saturate( dep / weight + 1.0 );
		// }
		// else if( dep < _DofParams.x + _DofParams.y ){
		// 	weight = 0;
		// }
		// else{
		// 	weight = (_DofParams.z - _DofParams.x - _DofParams.y == 0.0 )? EPSILON : ( _DofParams.z - _DofParams.x - _DofParams.y  );
		// 	weight = saturate( ( dep - _DofParams.x - _DofParams.y ) / weight );
		// }

		float4 origin = tex2D(_MainTex, i.uv);
		float4 blurred = tex2D(_BlurTex, i.uv);
		origin = lerp( origin, blurred, weight ); 

#if FINAL_DOF
		origin = ColorGrading( origin, _ColorGradingParams, _ToneMappingCurveParams );
#endif
		return origin;
		
	}

	// Depth of Field
	//---------------------------------------------------------------


	//--------------------------------------
	// Color Crading

	//---------------------------------------------------------------------------------------
	// Tone Mapping

	// ACES Tone Mapping  https://zhuanlan.zhihu.com/p/21983679
	float4 fragColorGradingAndACESToneMapping(v2f i) :COLOR
	{
		float4 color = tex2D(_MainTex, i.uv);
		return ColorGrading( color, _ColorGradingParams, _ToneMappingCurveParams );
		//return float4( saturate(color - 1.0).rgb,1.0);
		
		//  float A = 2.51f;
		//  float B = 0.03f;
		//  float C = 2.43f;
		//  float D = 0.59f;
		//  float E = 0.14f;

		// float3 acesColor = color.rgb * _ColorGradingParams.x; //adapted_lum;
		// //color.rgb = (color.rgb * (A * color.rgb + B)) / (color.rgb * (C * color.rgb + D) + E);
		// acesColor = ACESFilmFit_Scalar( acesColor, _ToneMappingCurveParams );
		// acesColor = lerp( color.rgb, acesColor, _ToneMappingIntensity );

		// // Color Grading
		// return float4( saturate(SaturateAndContrast( acesColor, _ColorGradingParams.y, _ColorGradingParams.z )), color.a);

	}

	

	// 神秘海域2的 Tone Mapping
	float3 ToneMapCalc(float3 x)
	{
		const float A = 0.22;
		const float B = 0.3;
		const float C = 0.1;
		const float D = 0.2;
		const float E = 0.01;
		const float F = 0.3;
	
		return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
	}

	float4 fragUncharted2ToneMapping(v2f i) :COLOR
	{
		float4 color = tex2D(_MainTex, i.uv);
		float WHITE = 11.2;
		return float4(( ToneMapCalc(1.6 * _ColorGradingParams.x * color.rgb) / ToneMapCalc(WHITE) ),color.a);
	}
	
	// Neutral tonemapping (Hable/Hejl/Frostbite) from PPv2
	float3 NeutralCurve(float3 x, float a, float b, float c, float d, float e, float f)
	{
		return ((x * (a * x + c * b) + d * e) / (x * (a * x + b) + d * f)) - e / f;
	}
	float3 NeutralTonemap(float3 x)
	{
		// Tonemap
		float a = 0.2;
		float b = 0.29;
		float c = 0.24;
		float d = 0.272;
		float e = 0.02;
		float f = 0.3;
		float whiteLevel = 5.3;
		float whiteClip = 1.0;

		float3 whiteScale = (1.0).xxx / NeutralCurve(whiteLevel, a, b, c, d, e, f);
		x = NeutralCurve(x * whiteScale, a, b, c, d, e, f);
		x *= whiteScale;

		// Post-curve white point adjustment
		x /= whiteClip.xxx;

		return x;
	}

	float4 fragNeutralMapping(v2f i) :COLOR
	{
		float4 color = tex2D(_MainTex, i.uv);
		return float4( NeutralTonemap(color.rgb), color.a );

	}

	// Tone Mapping
	//-------------------------------------------------------------------------------

	ENDCG 
		
	Subshader 
	{
		Pass //0 blur Downsample for Rect
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }      

	      CGPROGRAM
	      #pragma vertex vertRect
	      #pragma fragment fragDownSampleDualFilter
	      #pragma fragmentoption ARB_precision_hint_fastest
	      ENDCG
	  	}
		Pass //1 blur Downsample Dual Fitlering
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }      

	      CGPROGRAM
	      #pragma vertex vert
	      #pragma fragment fragDownSampleDualFilter
	      #pragma fragmentoption ARB_precision_hint_fastest
	      ENDCG
	  	}
		Pass //2 bloom first Box Filtering
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }

		  CGPROGRAM
		  #pragma vertex vertBlur
		  #pragma fragment fragBloom
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //3 bloom first Dual Filtering
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }

		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragBloomFirstDualFiltering
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //4 blur up Sample For Rect
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vertRect
		  #pragma fragment fragUpSampleDualFilter
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //5 blur up Sample Dual Filtering
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragUpSampleDualFilter
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //6 bloom final
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragBloomFinal
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //7 Color Grading and Tone Mapping
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragColorGradingAndACESToneMapping  
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //8 Copy
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragCopy  
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //9 Depth of Field : (Deprecated) Simple lerp with Depth
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragDofCombineCheap
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //10 Depth of Field: Calc COC from Depth Texture
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragDofCalcCOC
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
		Pass //11 Depth of Field: preFilter
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragDofPreFilter
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
		Pass //12 Depth of Field: bokeh
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragDofBokeh
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
		Pass //13 Depth of Field: postFilter
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragDofPostFilter
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
		Pass //14 Depth of Field : Combine
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragDofCombine
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //15 bloom up Sample Dual Filtering
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragBloomUpSampleDualFilter
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		
	}

	Fallback off
}


























































