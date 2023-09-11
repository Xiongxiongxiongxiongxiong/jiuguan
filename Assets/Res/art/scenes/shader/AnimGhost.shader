Shader "XH/AnimGhost"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
       _Int("明度",Range(1,5))=1
      //  _ScaleParams    ("天使圈缩放 X:强度 Y:速度 Z:校正", vector) = (0.2, 1.0, 4.5, 0.0)
        _SwingXParams   ("X轴扭动 X:强度 Y:速度 Z:波长", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingZParams   ("Z轴扭动 X:强度 Y:速度 Z:波长", vector) = (1.0, 3.0, 1.0, 0.0)
      //  _SwingYParams   ("Y轴起伏 X:强度 Y:速度 Z:滞后", vector) = (1.0, 3.0, 0.3, 0.0)
        _ShakeYParams   ("Y轴摇头 X:强度 Y:速度 Z:滞后", vector) = (20.0, 3.0, 0.3, 0.0)

    }
    SubShader
    {
        Tags {                "RenderType"="Opaque"
        } 

        LOD 100

        Pass
        {
                      Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
                        #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 color : COLOR;          
            };
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 uv1 : TEXCOORD2;
                float4 color : COLOR;
                LIGHTING_COORDS(5,6)          // 投影相关
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;

          //  uniform float4 _ScaleParams;
            uniform float3 _SwingXParams;
            uniform float3 _SwingZParams;
           // uniform float3 _SwingYParams;
            uniform float3 _ShakeYParams;
            uniform float _Int;
void AnimGhost (inout float3 vertex, inout float3 color)
            {

                // 幽灵摆动
                float swingX = _SwingXParams.x * sin(frac(_Time.z * _SwingXParams.y + vertex.y * _SwingXParams.z) * 3.1415926*2);
                float swingZ = _SwingZParams.x * sin(frac(_Time.z * _SwingZParams.y + vertex.y * _SwingZParams.z) * 3.1415926*2);
                vertex.xz += float2(swingX, swingZ) * color.r;
                // 幽灵摇头
              float radY = radians(_ShakeYParams.x) *  color.r * sin(frac(_Time.z * _ShakeYParams.y - color.r * _ShakeYParams.z) * 3.1415926*2);
              float sinY, cosY = 0;
              sincos(radY, sinY, cosY);
              vertex.xz = float2(
              vertex.x * cosY - vertex.z * sinY,
              vertex.x * sinY + vertex.z * cosY
                );
                // 幽灵起伏
             //   float swingY = _SwingYParams.x * sin(frac(_Time.z * _SwingYParams.y - color.r * _SwingYParams.z) * 3.1415926*2);
              //  vertex.y += swingY;
                // 处理顶点色
             //   float lightness = 1.0 + color.g * 1.0 + scale * 2.0;
              //  color = float3(lightness, lightness, lightness);
            }
            v2f vert (appdata v)
            {
                v2f o;
    
                AnimGhost(v.vertex.xyz, v.color.rgb);
                o.uv1  = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                 TRANSFER_VERTEX_TO_FRAGMENT(o)                  // 投影相关
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #if defined(LIGHTMAP_ON)
                // 提取lightmap
                float4 var_LightMap  = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                float  mainLightInt  = var_LightMap.r;
                float  skyLightInt   = var_LightMap.g;
                float  emissionGIInt = var_LightMap.b;
                fixed4 col = tex2D(_MainTex, i.uv)*var_LightMap*_Int;
#else
                float  mainLightInt  = LIGHT_ATTENUATION(i);
                float  skyLightInt   = 0.0f;
                float  emissionGIInt = 0.0f;
                fixed4 col = tex2D(_MainTex, i.uv)*mainLightInt*_Int;
#endif
                // sample the texture
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
               // clip(col.a - _Cutoff);                  // 透明剪切
                return col;
            }
            ENDCG
        }

        Pass {
            Name "META"
            Tags {
                "LightMode" = "Meta"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityMetaPass.cginc"
            // 声明分支
            #pragma shader_feature __ _BAKE_MAINLIGHT _BAKE_SKYLIGHT _BAKE_EMISSIONGI
            // 输入参数
            uniform sampler2D   _MainTex;
            // 输入结构
            struct VertexInput {
                float4 vertex   : POSITION;     // 顶点位置 总是必要
                float2 uv0      : TEXCOORD0;    // UV信息 采样贴图用
                float2 uv1      : TEXCOORD1;    // 其他UV信息 MetaPass需要
                float2 uv2      : TEXCOORD2;    // 同上
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                
                    o.pos = UnityMetaVertexPosition(v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST);
                    o.uv = v.uv0;
                return o;
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                UnityMetaInput metaIN;
                    UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
                    metaIN.Albedo = Luminance(tex2D(_MainTex, i.uv).rgb);
                    metaIN.SpecularColor = 0.0f;
                    metaIN.Emission = 0.0f;
                return UnityMetaFragment(metaIN);
            }
            ENDCG
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert( appdata_base v )
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag( v2f i ) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

    }


}
