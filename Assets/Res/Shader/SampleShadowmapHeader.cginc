/**
  * @file       SampleShadowmapHeader.cginc
  描边相关方法
  */

#ifndef SAMPLE_SHADOWMAP_HEADER_SHADER_INCLUDED
#define SAMPLE_SHADOWMAP_HEADER_SHADER_INCLUDED

#include "UnityCG.cginc"
#include "DataTypes.cginc"
#include "AutoLight.cginc"
#include "UtilHeader.cginc"


//--------------------------------------------------------------------
// 自定义的采样ShadowMap的方法，支持Shader中的PCF，以实现软阴影，减少锯齿问题
// 参考：https://xiaoiver.github.io/coding/2018/09/27/%E5%AE%9E%E6%97%B6%E9%98%B4%E5%BD%B1%E6%8A%80%E6%9C%AF%E6%80%BB%E7%BB%93.html

float4 _ShadowMapTexture_TexelSize;

inline fixed Custom_UnitySampleShadowmap ( float4 shadowCoord, float3 worldPos ){

#if defined (SHADOWS_SCREEN)

    #if defined(UNITY_NO_SCREENSPACE_SHADOWS) // 这个关键字在我们的项目中是被定义了的
		
		float3 coord = shadowCoord.xyz / shadowCoord.w;
		half4 shadows;

		//----------------------------------------------
		// 2x2 均值滤波

#if defined(_SHADOW_SOFT_2X2)

		float offsetSize = 1.0 * _ShadowMapTexture_TexelSize;
		shadows.x = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + float3(offsetSize,offsetSize,0));
		shadows.y = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + float3(-offsetSize,offsetSize,0));
		shadows.z = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + float3(offsetSize,-offsetSize,0));
		shadows.w = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + float3(-offsetSize,-offsetSize,0));
		return dot(shadows, 0.25f);

		//----------------------------------------------
		// Possion Disk 泊松分布采样 2x2

		// float offsetSize = 1.5 * _ShadowMapTexture_TexelSize;
		// static float poissonDisk[8] = {
		// 	-0.94201624, -0.39906216,
		// 	0.94558609, -0.76890725,
		// 	-0.094184101, -0.92938870,
		// 	0.34495938, 0.29387760
		// };
		// shadows.x = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
		// 				float3(poissonDisk[0], poissonDisk[1],0) * offsetSize);
		// shadows.y = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
		// 				float3(poissonDisk[2], poissonDisk[3],0) * offsetSize);
		// shadows.z = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
		// 				float3(poissonDisk[4], poissonDisk[5],0) * offsetSize);
		// shadows.w = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
		// 				float3(poissonDisk[6], poissonDisk[7],0) * offsetSize);
		// return dot(shadows, 0.25f);

		//----------------------------------------------
		// Stratified Possion Disk 泊松分布采样 2x2
		// 虽然模糊起来不会有明显带状效果，有点噪声抖动的感觉。

#elif defined(_SHADOW_SOFT_POSSION)

	    float offsetSize = 1.5 * _ShadowMapTexture_TexelSize;
		// static float poissonDisk[32] = {
		//  -0.94201624, -0.39906216 , 
		//  0.94558609, -0.76890725 , 
		//  -0.094184101, -0.92938870 , 
		//  0.34495938, 0.29387760 , 
		//  -0.91588581, 0.45771432 , 
		//  -0.81544232, -0.87912464 , 
		//  -0.38277543, 0.27676845 , 
		//  0.97484398, 0.75648379 , 
		//  0.44323325, -0.97511554 , 
		//  0.53742981, -0.47373420 , 
		//  -0.26496911, -0.41893023 , 
		//  0.79197514, 0.19090188 , 
		//  -0.24188840, 0.99706507 , 
		//  -0.81409955, 0.91437590 , 
		//  0.19984126, 0.78641367 , 
		//  0.14383161, -0.14100790  
		// };
        static float3 poissonDisk[16] =
        {
            float3(0.2770745, 0.6951455,0),
            float3(0.1874257, -0.02561589,0),
            float3(-0.3381929, 0.8713168,0),
            float3(0.5867746, 0.1087471,0),
            float3(-0.3078699, 0.188545,0),
            float3(0.7993396, 0.4595091,0),
            float3(-0.09242552, 0.5260149,0),
            float3(0.3657553, -0.5329605,0),
            float3(-0.3829718, -0.2476171,0),
            float3(-0.01085108, -0.6966301,0),
            float3(0.8404155, -0.3543923,0),
            float3(-0.5186161, -0.7624033,0),
            float3(-0.8135794, 0.2328489,0),
            float3(-0.784665, -0.2434929,0),
            float3(0.9920505, 0.0855163,0),
            float3(-0.687256, 0.6711345,0)
        };

		// int index = 0;
        // index = floor(fmod((worldPos.x + worldPos.y + worldPos.z) * 1837.562, 16));
        float4 randomNum = float4(1837.562215,940.392952,437.127831,1956.435569);
        int4 indexs = floor( fmod( randomNum * (worldPos.x + worldPos.y + worldPos.z), 16 ));
		shadows.x = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
						poissonDisk[indexs.x] * offsetSize);
		shadows.y = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
						poissonDisk[indexs.y] * offsetSize);
		shadows.z = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
						poissonDisk[indexs.z] * offsetSize);
		shadows.w = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, coord + 
						poissonDisk[indexs.w] * offsetSize);
		return dot(shadows, 0.25f);
#endif

		// PCF
		//--------------------------------------------------------

    #else
		return unitySampleShadow( shadowCoord);

    #endif
#endif

	return 1; // 如果没有定义SHADOWS_SCREEN，即在ShadowDistance区域之外，则返回1
}



// -------------------------------------------------------------------

#endif // SAMPLE_SHADOWMAP_HEADER_SHADER_INCLUDED