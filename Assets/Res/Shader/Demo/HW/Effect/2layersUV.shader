// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HW/Effect/doubleMeshUV" {
    Properties {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _Alpha ("Alpha", 2D) = "white" {}
        _color ("color", Color) = (1,1,1,1)
        _Uspeed ("Uspeed", Float ) = 0
        _Vspeed ("Vspeed", Float ) = 0
        _BrightLevel ("BrightLevel", Float ) = 1
        _USpeed_alpha ("USpeed_alpha", Float ) = 0
        _VSpeed_alpha ("VSpeed_alpha", Float ) = 0
		[Enum(Additive,1,AlphaBlend,11)] _BlendMode ("Blend Mode",Float) = 11
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Lighting Off
            Blend SrcAlpha [_BlendMode]
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"
 
            uniform float4 _TimeEditor;
            uniform sampler2D _Diffuse; 
			uniform float4 _Diffuse_ST;
            uniform sampler2D _Alpha; 
			uniform float4 _Alpha_ST;
            uniform float4 _color;
            uniform float _Uspeed;
            uniform float _Vspeed;
            uniform float _BrightLevel;
            uniform float _USpeed_alpha;
            uniform float _VSpeed_alpha;
	    
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float4 node_120 = _Time + _TimeEditor;
                float2 node_146 = (i.uv0*0.5); 
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX(((node_146+(node_120.g*_Uspeed)*float2(1,0))+(node_146+(node_120.g*_Vspeed)*float2(0,1))), _Diffuse));
                float4 _Alpha_var = tex2D(_Alpha,TRANSFORM_TEX(((node_146+(node_120.g*_USpeed_alpha)*float2(1,0))+(node_146+(node_120.g*_VSpeed_alpha)*float2(0,1))), _Alpha));
                return fixed4((_BrightLevel*(_color.rgb*_Diffuse_var.rgb)),(_color.a*(_Diffuse_var.a*_Alpha_var.a)));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"

}
