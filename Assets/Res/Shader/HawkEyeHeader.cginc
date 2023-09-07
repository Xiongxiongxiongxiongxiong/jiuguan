#include "DataTypes.cginc"
#include "UtilHeader.cginc"
#include "PbrHeader.cginc"

uniform LowPrec _EnableHawkEye;
uniform MidPrec _HawkEyeDepthMin;
uniform MidPrec _HawkEyeDepthMax;
uniform MidPrec _HawkEyeDepthPow;
uniform MidPrec4 _HawkEyeColor;
uniform MidPrec _HawkEyeShadowAdd;
uniform MidPrec _HawkEyeColorRatio;
uniform MidPrec _HawkEyeMergeMax;
uniform MidPrec _HawkEyeMergePow;
uniform MidPrec _HawkEyeGrayRatio;

uniform LowPrec _ReceiveHawkeye;
uniform MidPrec _UseDepthHawkEye;

uniform LowPrec _EnableTimeStop;
uniform MidPrec4 _TimeStopHawkEyeColor;
uniform MidPrec _TimeStopHawkEyeColorRatio;


inline MidPrec3 HawkEyeColor(MidPrec3 finalColor, HighPrec3 worldPos)
{
    MidPrec4 hawkEyeColor = lerp(_HawkEyeColor, _TimeStopHawkEyeColor, _EnableTimeStop);
    MidPrec hawkEyeColorRatio = lerp(_HawkEyeColorRatio, _TimeStopHawkEyeColorRatio, _EnableTimeStop);

    MidPrec hawkEyeDepth = length( _WorldSpaceCameraPos - worldPos.xyz );

    MidPrec hawkEyeDist = hawkEyeDepth;//length( _PlayerPosition.xyz - i.worldPos.xyz );
    hawkEyeDist = saturate( (hawkEyeDist - _HawkEyeDepthMin) / (_HawkEyeMergeMax - _HawkEyeDepthMin) );
    hawkEyeDist =  SAFE_POW(hawkEyeDist, _HawkEyeMergePow);
    MidPrec hawkEyeGray = dot(finalColor.rgb, MidPrec3(0.2126h, 0.7152h, 0.0722h));

    hawkEyeDepth = saturate( (hawkEyeDepth - _HawkEyeDepthMin) / (_HawkEyeDepthMax - _HawkEyeDepthMin) );
    hawkEyeDepth =  SAFE_POW(hawkEyeDepth, _HawkEyeDepthPow);
    MidPrec3 hawkEyeResult = hawkEyeDepth * hawkEyeColor.rgb;
	// hawkEyeResult = lerp( hawkEyeResult, hawkEyeResult.rgb + _HawkEyeColor.rgb * 0.5, SaturateFromRGB_MidPrec(_HawkEyeColor.rgb) );
    hawkEyeResult = lerp( hawkEyeGray.rrr, hawkEyeResult, hawkEyeDist );
    hawkEyeResult = lerp( hawkEyeResult, finalColor.rgb, hawkEyeColorRatio );
    return hawkEyeResult;
}

inline MidPrec4 HawkEyeColorAlpha(MidPrec4 finalColor, HighPrec3 worldPos)
{
    MidPrec4 hawkEyeColor = lerp(_HawkEyeColor, _TimeStopHawkEyeColor, _EnableTimeStop);
    MidPrec hawkEyeColorRatio = lerp(_HawkEyeColorRatio, _TimeStopHawkEyeColorRatio, _EnableTimeStop);

    MidPrec hawkEyeDepth = length( _WorldSpaceCameraPos - worldPos.xyz );

    MidPrec hawkEyeDist = hawkEyeDepth;//length( _PlayerPosition.xyz - i.worldPos.xyz );
    hawkEyeDist = saturate( (hawkEyeDist - _HawkEyeDepthMin) / (_HawkEyeMergeMax - _HawkEyeDepthMin) );
    hawkEyeDist =  SAFE_POW(hawkEyeDist, _HawkEyeMergePow);
    MidPrec hawkEyeGray = dot(finalColor.rgb, MidPrec3(0.2126h, 0.7152h, 0.0722h));

    hawkEyeDepth = saturate( (hawkEyeDepth - _HawkEyeDepthMin) / (_HawkEyeDepthMax - _HawkEyeDepthMin) );
    hawkEyeDepth =  SAFE_POW(hawkEyeDepth, _HawkEyeDepthPow);
    MidPrec3 hawkEyeResult = hawkEyeDepth * hawkEyeColor.rgb;
	// hawkEyeResult = lerp( hawkEyeResult, hawkEyeResult.rgb + _HawkEyeColor.rgb * 0.5, SaturateFromRGB_MidPrec(_HawkEyeColor.rgb) );
    hawkEyeResult = lerp( hawkEyeGray.rrr, hawkEyeResult, hawkEyeDist );
    hawkEyeResult = lerp( hawkEyeResult, finalColor.rgb, hawkEyeColorRatio );
    return MidPrec4(hawkEyeResult, lerp(finalColor.a, 0, step(1, hawkEyeDist)));
}

inline MidPrec3 HawkEyeCharacter(MidPrec3 finalColor, HighPrec3 worldPos)
{
    MidPrec3 hawkEyeGray = GetGraylevel(finalColor.rgb).rrr;
    MidPrec hawkEyeDepth = length( _WorldSpaceCameraPos - worldPos.xyz );
    hawkEyeDepth = saturate( (hawkEyeDepth - _HawkEyeDepthMin) / (_HawkEyeDepthMax - _HawkEyeDepthMin) );
    hawkEyeGray = lerp( hawkEyeDepth.rrr, hawkEyeGray, _HawkEyeGrayRatio );

    MidPrec3 hawkEyeRes = _HawkEyeColor.rgb * hawkEyeGray;

    hawkEyeRes = lerp( hawkEyeRes, finalColor.rgb, _HawkEyeColorRatio );

    // hawkEyeRes = hawkEyeRes * saturate( atten + _HawkEyeShadowAdd ); // TODO: finalColor里面已经包含了 atten，所以这里其实把 atten 计算了两次；最正确的做法是在前面也加个 _GLOBAL_HAWKEYE_ON 宏，把 atten 从 finalColor 里面排除掉
    // TODO: 现在大世界阴影比较粗糙，直接把这个 atten 加到角色上，效果不好，暂时去掉，等大世界场景的烘焙问题处理好了再来打开这个

    // MidPrec3 hsvVal = RgbToHsv(finalColor.rgb);
    // hsvVal.x = _HawkEyeHue; // 直接重新设置色相
    // hsvVal.y = saturate( hsvVal.y * _HawkEyeSaturation ); // 在原基础上调整饱和度
    // hsvVal.z = hsvVal.z * _HawkEyeIntensity; // 在原基础上调整亮度
    // MidPrec3 hsvReturn = HsvToRgb(hsvVal);
    // return MidPrec4( hsvReturn, finalColor.a );

    return hawkEyeRes;
}

inline MidPrec3 HawkEyeEffect(MidPrec3 finalColor)
{
    MidPrec grayVal = dot(finalColor.rgb, MidPrec3(0.2126h, 0.7152h, 0.0722h));
    MidPrec3 hawkEyeGray = grayVal * _HawkEyeColor.rgb;
    finalColor.rgb = lerp(hawkEyeGray, finalColor.rgb, _HawkEyeColorRatio);
    return finalColor;
}