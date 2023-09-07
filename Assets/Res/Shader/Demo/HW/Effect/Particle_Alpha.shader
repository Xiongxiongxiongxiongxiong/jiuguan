// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HW/Effect/particleAlpha" {
    Properties {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _RotationAng ("RotationAng", Float ) = 0 
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Lighting Off
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			
            uniform sampler2D _Diffuse;
			uniform float4 _Diffuse_ST;
            uniform float _RotationAng;
			
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float i_cos = cos(_RotationAng*0.0174);
                float i_sin = sin(_RotationAng*0.0174);
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX((mul(i.uv0-float2(0.5,0.5),float2x2(i_cos, -i_sin, i_sin, i_cos))+float2(0.5,0.5)), _Diffuse));
                return fixed4((i.vertexColor.rgb*_Diffuse_var.rgb),(_Diffuse_var.a*i.vertexColor.a));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
