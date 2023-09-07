/**
  * @file       WavingEffectHeader.cginc
  摆动效果
  */

#ifndef WAVING_EFFECT_HEADER_SHADER_INCLUDED
#define WAVING_EFFECT_HEADER_SHADER_INCLUDED

#include "UnityCG.cginc"
#include "DataTypes.cginc"
#include "MathHeader.cginc"

// 这里是Unity Terrain 的草摆动效果
// 特点：大范围的正弦摆动，有类似于mac鱼眼效果的感觉。整体摆动比较统一
inline float4 TerrainBuiltInGrassWave( float4 vertex, float waveAmount)
{
    float timeVal = _Time.x % 100.0;
    float4 _WaveAndDistance = float4( timeVal, 1.0f, 1.0f,0.0f );
    float4 _waveXSize = float4(0.012, 0.02, 0.06, 0.024) * _WaveAndDistance.y;
    float4 _waveZSize = float4 (0.006, .02, 0.02, 0.05) * _WaveAndDistance.y;
    float4 waveSpeed = float4 (0.3, .5, .4, 1.2) * 4;

    float4 _waveXmove = float4(0.012, 0.02, -0.06, 0.048) * 2;
    float4 _waveZmove = float4 (0.006, .02, -0.02, 0.1);

    float4 waves;
    waves = vertex.x * _waveXSize;
    waves += vertex.z * _waveZSize;

    // Add in time to model them over time
    waves += _WaveAndDistance.x * waveSpeed;

    // s 定义为float4是为了最后一步通过dot对s乘以不同的权重相加求和得到waveMove。这样比通过分别几次加法来叠加波动来得更省 
    waves = frac (waves);// 先 frac()得到会随着时间和距离较为连续变化的相位，然后将它作为sin()的自变量。
    waves = waves * MATH_FLOAT_DOUBLE_PI - MATH_FLOAT_PI;
    float4 s = Sin_FastHighPrecision( waves);
    s = s * s;
    s = s * s;
    float lighting = dot (s, normalize (float4 (1,1,.4,.2))) * .7;

    s = s * waveAmount;

    float3 waveMove = float3 (0,0,0);
    waveMove.x = dot (s, _waveXmove);
    waveMove.z = dot (s, _waveZmove);

    vertex.xz -= waveMove.xz * _WaveAndDistance.z;

    return vertex;
}

// 应用了噪声的随风摆动。草的摆动有更多的随机性
inline HighPrec4 GrassWaveWithNoise( HighPrec4 posWorld, HighPrec2 phaseScale, HighPrec waveSpeed, HighPrec windStrength, HighPrec windDirection , HighPrec noiseByWorldPos ){

    HighPrec timeVal = _Time.x % 100.0;
    HighPrec2 waves = HighPrec2( posWorld.x * phaseScale.x * ( noiseByWorldPos * 0.83f), posWorld.z * phaseScale.y * (0.63f + noiseByWorldPos * 1.42f));
    // HighPrec2 waves = HighPrec2( posWorld.x * phaseScale.x , posWorld.z * phaseScale.y);
    waves += timeVal * waveSpeed;
    waves = frac(waves) - 0.5f;//将范围从[0,2*PI]转到[-PI,PI]，以使用快速模拟的三角函数
    HighPrec2 s;
    s = Sin_FastHighPrecision( waves * MATH_FLOAT_DOUBLE_PI );
    s = s * s; 
    s = s * s; // 将波形s多乘几次，是为了让波形变得更加陡峭，减少大幅度摆动的草的比例

    windDirection = windDirection * MATH_FLOAT_DOUBLE_PI / 360.0f - MATH_FLOAT_PI;
    // 二维旋转s，以实现模拟修改风的方向。（s可看作一个尾部在原点的二维向量）
    s.x = s.x * windStrength * Cos_FastHighPrecision(windDirection );
    s.y = s.y * windStrength * Sin_FastHighPrecision(windDirection );
    posWorld.x += s.x;
    posWorld.z += s.y;
    return posWorld;
}

// 可以设置风向的摆动，没有噪声
// 插片草或者树、小灌木适合
inline HighPrec4 WavingWithRegularSin( HighPrec4 worldPos, HighPrec2 phaseScale, HighPrec waveSpeed, HighPrec windStrength, HighPrec windDirection ){

    HighPrec timeVal = _Time.x % 100.0;
    HighPrec2 waves = HighPrec2( worldPos.x * phaseScale.x, worldPos.z * phaseScale.y);
    waves += timeVal * waveSpeed;
    waves = frac(waves) - 0.5;//将范围从[0,2*PI]转到[-PI,PI]，以使用快速模拟的三角函数

    HighPrec2 s;
    s = Sin_FastHighPrecision( waves * MATH_HALFP_DOUBLE_PI );
    s = s * s;
    s = s * s;
    windDirection = windDirection * MATH_FLOAT_DOUBLE_PI / 360 - 0.5;
    s.x = s.x * windStrength * Cos_FastHighPrecision(windDirection);
    s.y = s.y * windStrength * Sin_FastHighPrecision(windDirection);
    //
    worldPos.x += s.x;
    worldPos.z += s.y;
    return worldPos;
}

// -------------------------------------------------------------------

#endif // WAVING_EFFECT_HEADER_SHADER_INCLUDED