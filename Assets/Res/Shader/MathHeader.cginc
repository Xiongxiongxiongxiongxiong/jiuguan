/**
  * @file       MathHeader.cginc
  提供一些复杂计算或者复杂函数的近似
  */

#ifndef MATH_HEADER_SHADER_INCLUDED
#define MATH_HEADER_SHADER_INCLUDED

#include "UnityCG.cginc"
#include "DataTypes.cginc"

// PI在半精度下只能表示为 3.140625 https://www.exploringbinary.com/pi-and-e-in-binary/
#define MATH_HALFP_PI            3.14h
#define MATH_HALFP_HALF_PI       1.57h
#define MATH_HALFP_DOUBLE_PI     6.28h
#define HALFP_FOUR_DIV_PI        1.273h // 4/pi
#define HALFP_FOUR_DIV_PI_PI     0.4053h // 4/(pi*pi)

// PI相关宏的float版本
#define MATH_FLOAT_PI            3.1415927f
#define MATH_FLOAT_HALF_PI       1.5707963f
#define MATH_FLOAT_DOUBLE_PI     6.2831853f
#define FLOAT_FOUR_DIV_PI        1.2732395f // 4/pi
#define FLOAT_FOUR_DIV_PI_PI     0.4052847f // 4/(pi*pi)

// 如果使用下面两个方法做为sincos()来旋转uv，会因为误差而使得旋转时贴图采样tilting有缩放的情况，如果不将贴图设置为clamp那么有可能周边会重复采样到靠近边缘的值。目前都只是用来设置为给粒子作为固定的旋转方向，所以这个问题影响不大。

// 输入x 的范围需要限定在[ -PI, PI ]
inline MidPrec Sin_FastHalfPrecision(MidPrec x )
{
    //4/pi x - 4/pi^2 x abs(x)
    return HALFP_FOUR_DIV_PI * x - HALFP_FOUR_DIV_PI_PI * x * abs(x);
}

// 输入x 的范围需要限定在[ -PI, PI ]
inline MidPrec Cos_FastHalfPrecision(MidPrec x )
{
    x += MATH_HALFP_HALF_PI; //MATH_HALFP_PI / 2;
    x -= ((x > MATH_HALFP_PI) ? MATH_HALFP_DOUBLE_PI : 0.0);
    return HALFP_FOUR_DIV_PI * x - HALFP_FOUR_DIV_PI_PI * x * abs(x); //sin(x)
}

// 输入x 的范围需要限定在[ -PI, PI ]
inline HighPrec Sin_FastHighPrecision(HighPrec x )
{
    //4/pi x - 4/pi^2 x abs(x)
    return FLOAT_FOUR_DIV_PI * x - FLOAT_FOUR_DIV_PI_PI * x * abs(x);
}
inline HighPrec4 Sin_FastHighPrecision(HighPrec4 x )
{
    //4/pi x - 4/pi^2 x abs(x)
    return FLOAT_FOUR_DIV_PI * x - FLOAT_FOUR_DIV_PI_PI * x * abs(x);
}

// 输入x 的范围需要限定在[ -PI, PI ]
inline HighPrec Cos_FastHighPrecision(HighPrec x )
{
    x += MATH_FLOAT_HALF_PI; //MATH_HALFP_PI / 2;
    x -= ((x > MATH_FLOAT_PI) ? MATH_FLOAT_DOUBLE_PI : 0.0);
    return FLOAT_FOUR_DIV_PI * x - FLOAT_FOUR_DIV_PI_PI * x * abs(x); //sin(x)
}
inline HighPrec4 Cos_FastHighPrecision(HighPrec4 x )
{
    x += MATH_FLOAT_HALF_PI; //MATH_HALFP_PI / 2;
    x -= ((x > MATH_FLOAT_PI) ? MATH_FLOAT_DOUBLE_PI : 0.0);
    return FLOAT_FOUR_DIV_PI * x - FLOAT_FOUR_DIV_PI_PI * x * abs(x); //sin(x)
}

/* ================================================================ */

// sin和cos用三角波近似
// Sin
inline MidPrec SinHalf_TriangleWave(MidPrec x)
{
    MidPrec t = abs(frac(x + 0.5) * 2.0 - 1.0);// 三角波
    return t * t * (3.0 - 2.0 * t); // 平滑
}

inline HighPrec Sin_TriangleWave(HighPrec x)
{
    HighPrec t = abs(frac(x + 0.5) * 2.0 - 1.0);// 三角波
    return t * t * (3.0 - 2.0 * t); // 平滑
}

inline HighPrec4 Sin_TriangleWave(HighPrec4 x)
{
    HighPrec4 t = abs(frac(x + 0.5) * 2.0 - 1.0);// 三角波
    return t * t * (3.0 - 2.0 * t); // 平滑
}

//Cos
inline MidPrec CosHalf_TriangleWave(MidPrec x)
{
    MidPrec t = abs(frac(x) * 2.0 - 1.0);// 三角波
    return t * t * (3.0 - 2.0 * t); // 平滑
}

inline HighPrec Cos_TriangleWave(HighPrec x)
{
    HighPrec t = abs(frac(x) * 2.0 - 1.0);// 三角波
    return t * t * (3.0 - 2.0 * t); // 平滑
}

inline HighPrec4 Cos_TriangleWave(HighPrec4 x)
{
    HighPrec4 t = abs(frac(x) * 2.0 - 1.0);// 三角波
    return t * t * (3.0 - 2.0 * t); // 平滑
}

/* ================================================================ */

// 求RGB的亮度值（不同于 Luminance()，该方法是将RGB三通道除以3然后相加）
// 用于在一些与太阳光相乘的场合比Luminance()更加适合美术同学调整。这种求亮度的方式，在与太阳光相乘时，不会在太阳光只改变色相的时候，就使计算结果出现大的明暗变化。该方法更多是用于适应昼夜变化太阳光明度的变化。如一些小花草不希望受太阳光的影响而改变色相但又希望有昼夜变化效果的情况。
inline MidPrec LuminanceAvgRgbMidPrecision( MidPrec3 color ){
    return dot( color.rgb, MidPrec3(0.333h,0.333h,0.333h) );
}
inline HighPrec LuminanceAvgRgbHighPrecision( HighPrec3 color ){
    return dot( color.rgb, HighPrec3(0.33333f,0.33333f,0.33333f) );
}
inline LowPrec LuminanceAvgRgbLowPrecision( LowPrec3 color ){
    return dot( color.rgb, LowPrec3(0.333,0.333,0.333) );
}

// 判断一个二维点是否在一个二维Rect之内
// 返回1表示在之内，0表示在之外
// UnityUI.cghin 中 UnityGet2DClipping() 的 MidPrec版本
// inline MidPrec UnityGet2DClipping (MidPrec2 position, MidPrec4 clipRect)
// {
//     MidPrec2 inside = step(clipRect.xy, position.xy) * step(position.xy, clipRect.zw);
//     return inside.x * inside.y;
// }

// -------------------------------------------------------------------

#endif // MATH_HEADER_SHADER_INCLUDED