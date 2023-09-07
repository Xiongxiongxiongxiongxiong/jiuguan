#ifndef BUILTIN_BLUR_INCLUDED
#define BUILTIN_BLUR_INCLUDED

fixed4 GaussianBlur(float2 uv, sampler2D tex, fixed blur,half mask)
{
    // 1 / 16
    float offset = blur * 0.0625f;
    offset = lerp(0,offset,mask);
    // 左上
    fixed4 color = tex2D(tex, float2(uv.x - offset, uv.y - offset)) * 0.0947416f;
    // 上
    color += tex2D(tex, float2(uv.x, uv.y - offset)) * 0.118318f;
    // 右上
    color += tex2D(tex, float2(uv.x + offset, uv.y + offset)) * 0.0947416f;
    // 左
    color += tex2D(tex, float2(uv.x - offset, uv.y)) * 0.118318f;
    // 中
    color += tex2D(tex, float2(uv.x, uv.y)) * 0.147761f;
    // 右
    color += tex2D(tex, float2(uv.x + offset, uv.y)) * 0.118318f;
    // 左下
    color += tex2D(tex, float2(uv.x - offset, uv.y + offset)) * 0.0947416f;
    // 下
    color += tex2D(tex, float2(uv.x, uv.y + offset)) * 0.118318f;
    // 右下
    color += tex2D(tex, float2(uv.x + offset, uv.y - offset)) * 0.0947416f;
    return color;
}

#endif
