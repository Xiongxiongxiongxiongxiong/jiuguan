/**
  * @file       DataTypes.cginc
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/07/04
  */

#ifndef DATA_TYPES_SHADER_INCLUDED
#define DATA_TYPES_SHADER_INCLUDED

#define DATA_HIGH 1 // 全用float
#define DATA_MID  2 // 按配置情况各自使用float/half/fixed
#define DATA_LOW  3 // 全用half(除已经配置为fixed的除外)
#define DATA_PRECISION DATA_MID // TODO ：现在unity shader编译系统没有记录*.shader和*.cginc的dependency，导致如果对*.cginc做了修改，对于引用这个头文件的*.shader文件，都需要手动修改这个shader，才能手动触发这个*.cginc在对应*.shader中的重新编译 ！！！


#if DATA_PRECISION == DATA_HIGH
	#define HighPrec  float
	#define HighPrec2 float2
	#define HighPrec3 float3
	#define HighPrec4 float4
	#define HighPrec2x2 float2x2
	#define HighPrec3x3 float3x3
	#define HighPrec4x4 float4x4

	#define MidPrec  float
	#define MidPrec2 float2
	#define MidPrec3 float3
	#define MidPrec4 float4
	#define MidPrec2x2 float2x2
	#define MidPrec3x3 float3x3
	#define MidPrec4x4 float4x4

	#define LowPrec  half
	#define LowPrec2 half2
	#define LowPrec3 half3
	#define LowPrec4 half4
#elif DATA_PRECISION == DATA_MID
	#define HighPrec  float
	#define HighPrec2 float2
	#define HighPrec3 float3
	#define HighPrec4 float4
	#define HighPrec2x2 float2x2
	#define HighPrec3x3 float3x3
	#define HighPrec4x4 float4x4

	#define MidPrec  half
	#define MidPrec2 half2
	#define MidPrec3 half3
	#define MidPrec4 half4
	#define MidPrec2x2 half2x2
	#define MidPrec3x3 half3x3
	#define MidPrec4x4 half4x4

	#define LowPrec  fixed
	#define LowPrec2 fixed2
	#define LowPrec3 fixed3
	#define LowPrec4 fixed4
#elif DATA_PRECISION == DATA_LOW
	#define HighPrec  half
	#define HighPrec2 half2
	#define HighPrec3 half3
	#define HighPrec4 half4
	#define HighPrec2x2 half2x2
	#define HighPrec3x3 half3x3
	#define HighPrec4x4 half4x4

	#define MidPrec  half
	#define MidPrec2 half2
	#define MidPrec3 half3
	#define MidPrec4 half4
	#define MidPrec2x2 half2x2
	#define MidPrec3x3 half3x3
	#define MidPrec4x4 half4x4

	#define LowPrec  fixed
	#define LowPrec2 fixed2
	#define LowPrec3 fixed3
	#define LowPrec4 fixed4
#endif

#endif // DATA_TYPES_SHADER_INCLUDED