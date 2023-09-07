// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/**
  * @file       OutlineHeader.cginc
  描边相关方法
  */

#ifndef OUTLINE_HEADER_SHADER_INCLUDED
#define OUTLINE_HEADER_SHADER_INCLUDED

#include "UnityCG.cginc"
#include "DataTypes.cginc"

//
// Expand vertex alone normal in View Space
//
inline HighPrec4 OutlineCalcInViewSpace( HighPrec4x4 modelMatrix, HighPrec4x4 viewMatrix, HighPrec4 modelPos, HighPrec3 modelNormal, HighPrec4 vertexColor, HighPrec outlineUseVertexColor ,HighPrec outlineThickness ){

    // 算法4：法线归一方式是参考崩坏3，另外增加了随着距离变化描边粗细的因子，避免拉远相机时描边变细出现断开产生锯齿
    HighPrec3 viewNormal = mul(UNITY_MATRIX_IT_MV, modelNormal.xyz);
    // HighPrec3 viewNormal = mul(UNITY_MATRIX_MV, normal.xyz); // 如果能确定只有等比缩放，则可以修改为UNITY_MATRIX_MV（但目前Unity的资料里没有说到不使用IT矩阵就能给它减负，说不定仍然会计算出这个矩阵，所以干脆就直接用IT矩阵了）。而Unity编辑器推荐的UnityObjectToViewPos()用在这里则会有问题。详见：https://matrix64.github.io/Pit-UNITY_MATRIX_IT_MV-post/

    //viewNormal.xy = normalize(viewNormal.xy);
    HighPrec oneDivNormalLength = rsqrt( dot( viewNormal.xyz,viewNormal.xyz ) );
    viewNormal.xy = viewNormal.xy * oneDivNormalLength; // 现在法线变量只剩下方向，剔除了长度因素（相当于归一化）。z分量没用了
    //HighPrec2 tempNorV = viewNormal.yy * UNITY_MATRIX_P[1].xy; // 这是参考崩坏3的代码，但是很奇怪在编辑器里会导致描边效果有问题，就去掉了
    //viewNormal.xy = UNITY_MATRIX_P[0].xy * viewNormal.xx + tempNorV.xy; // 根据FOV和Aspect对viewNormal.xy进行了调整
    HighPrec pixelWidth = outlineThickness;
    HighPrec4 viewPos = mul(viewMatrix, mul(modelMatrix, modelPos)); //mul(UNITY_MATRIX_MV, input.pos);

    HighPrec startPoint = 0.4;
    HighPrec slope = lerp( 0.2, 0.15, step( 3.0, unity_CameraProjection._m11) ); //0.2;// 在对话等情景，为了角色不畸变或者相机能够拉远不被近处的武器穿插而FOV往往小至25.于是考虑FOV对slope进行选择，FOV小的，那么减小描边的宽度以避免过粗

    viewPos.xy +=((viewNormal.xy*pixelWidth) \
                *clamp(  abs(viewPos.z ) * slope - startPoint * slope ,0.35, 1.2) \
                * lerp(1.0, vertexColor.r, outlineUseVertexColor) \
                ); // 限制当距离相机超过一个距离之后，描边就不再随着距离变粗，避免远处太粗的效果    
    
    return mul(UNITY_MATRIX_P, viewPos);

}

inline HighPrec4 OutlineCalcInClipSpace( HighPrec4x4 modelMatrix, HighPrec4x4 viewMatrix, HighPrec4 modelPos, HighPrec3 modelNormal, HighPrec4 vertexColor, HighPrec outlineUseVertexColor ,HighPrec outlineThickness ){

    HighPrec3 clipNormal = UnityObjectToClipPos(modelNormal.xyz);
    clipNormal.xy = normalize(clipNormal.xy);
    // HighPrec pixelWidth = outlineThickness * 0.2;
    HighPrec pixelWidth = 2.0;

    HighPrec4 clipPos = mul(UNITY_MATRIX_P,(mul(viewMatrix, mul(modelMatrix, modelPos))));
    // clipPos.xy += sign(clipNormal.xy) * 2.0 * clipPos.w * pixelWidth / HighPrec2(1334,750);

    float2 sign = float2(0, 0); // the surrounded kernel cells
    sign.xy = step(float2(0, 0), clipNormal.xy)*2 - 1; //set kernel value for four quadrants
	sign.xy *= step(abs(clipNormal.yx), abs(8*clipNormal.xy)); //set horizontal & vertical kernel cell
    clipPos.xy += ((float2(1.0/1334.0, 1.0/750.0)*sign*pixelWidth)*clipPos.w);


    return clipPos;

}


/*
    // 算法1：综合 NdotV 以及 backface normal 
    // 用法线与相机的夹角来影响法线向外扩的长短。夹角越大，外扩越远，夹角越小，外扩越短。
    HighPrec4 objSpaceCameraPos = mul(unity_WorldToObject, _WorldSpaceCameraPos);
    MidPrec3 objSpaceViewDir = normalize((objSpaceCameraPos - input.pos).rgb);
    MidPrec3 objSpaceNormDir = normalize(input.nor);
    MidPrec objSpaceNDotV = abs(dot(objSpaceViewDir, objSpaceNormDir)); // 需要加abs，因为backface rendering的nDotV<=0
    HighPrec4 newpos = HighPrec4(0,0,0,1);
    newpos = input.pos + HighPrec4(objSpaceNormDir,0.0)
                * lerp(_OutlineMinThickness,_OutlineMaxThickness,max(_OutlineThreshold-objSpaceNDotV,0.0h)/_OutlineThreshold);
    o.pos = UnityObjectToClipPos(newpos);

    // 算法2：backface noraml(可能出现不连续，但算法比较简单)
        MidPrec3 objSpaceNormDir = normalize(input.nor);
        HighPrec4 newpos = HighPrec4(0,0,0,1);
        newpos = input.pos + HighPrec4(objSpaceNormDir,0.0) * _OutlineThickness;
        o.pos = UnityObjectToClipPos(newpos);
*/
    // 算法3：model scale
    // _PreScaleWorldMat = unity_ObjectToWorld;
    // float4x4 scaleMat = float4x4( 1+_OutlineThickness, 0, 0, 0,
    //                               0, 1+_OutlineThickness, 0, 0,
    //                               0, 0, 1+_OutlineThickness, 0,
    //                               0, 0, 0, 1 );
    // _PreScaleWorldMat = mul(unity_ObjectToWorld, scaleMat); // unity_ObjectToWorld作用到向量上时需要向量右乘（column-major）；本身unity_ObjectToWorld是TRS(先缩放，再旋转，最后平移)S
    // o.pos = mul( UNITY_MATRIX_VP, mul( _PreScaleWorldMat, input.pos ) );
                        
/**/



inline HighPrec LuminanceAvgRgbHighPrecision( HighPrec3 color ){
    return dot( color.rgb, HighPrec3(0.33333f,0.33333f,0.33333f) );
}

// -------------------------------------------------------------------

#endif // OUTLINE_HEADER_SHADER_INCLUDED