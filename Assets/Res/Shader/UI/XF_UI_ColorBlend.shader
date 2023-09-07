Shader "XF/UI/ColorBlend"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}

        _MaskTex ("MaskTex", 2D) = "white" {}
        _MaskColor ("MaskColor", COLOR) = (1, 1, 1, 1)

        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector]_Stencil ("Stencil ID", Float) = 0
		[HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255

		[HideInInspector]_ColorMask ("Color Mask", Float) = 15

		[HideInInspector][Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [Space][Space]
        [Toggle(TRANSPARENTMIX)] _TransparentMix ("正常透明度混合", Float) = 0
        [Toggle(DRAKEN)] _Draken ("变暗", Float) = 0
        [Toggle(MULTIPLY)] _Multiply ("正片叠底", Float) = 0
        [Toggle(COLORDEEPENING)] _ColorDeepening ("颜色加深", Float) = 0
        [Toggle(LIGHTEN)] _Lighten ("变亮", Float) = 0
        [Toggle(COLORFILTER)] _ColorFilter ("滤色", Float) = 0
        [Toggle(COLORDODGE)] _ColorDodge ("颜色减淡", Float) = 0
        [Toggle(SUPERPOSITION)] _Superposition ("叠加", Float) = 0
        [Toggle(SOFTLIGHT)] _SoftLight ("柔光", Float) = 0
        [Toggle(LIGHT)] _Light ("亮光", Float) = 0
        [Toggle(GLARE)] _Glare ("强光", Float) = 0
        [Toggle(LINEARDEEPENING)] _LinearDeepening ("线性加深", Float) = 0
        [Toggle(LINEARDODGE)] _LinearDodge ("线性减淡", Float) = 0
        [Toggle(POINTLIGHT)] _PointLight ("点光", Float) = 0
        [Toggle(LINEARLIGHT)] _LinearLight ("线性光", Float) = 0
        [Toggle(SOLIDCOLORMIXING)] _SolidColorMixing ("实色混合", Float) = 0
        [Toggle(EXCLUDE)] _Exclude ("排除", Float) = 0        
        [Toggle(INTERPOLATION)] _Interpolation ("差值", Float) = 0
        [Toggle(DRAKCOLOR)] _DarkColor ("深色", Float) = 0
        [Toggle(UNDERTONE)] _Undertone ("浅色", Float) = 0
        [Toggle(SUBTRACT)] _Subtract ("减去", Float) = 0
        [Toggle(DIVIDE)] _Divide ("划分", Float) = 0

    }
    SubShader
    {
        Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #pragma shader_feature _ TRANSPARENTMIX DRAKEN MULTIPLY COLORDEEPENING LIGHTEN COLORFILTER COLORDODGE SUPERPOSITION SOFTLIGHT LIGHT UNDERTONE
            #pragma shader_feature _ GLARE LINEARDEEPENING LINEARDODGE POINTLIGHT LINEARLIGHT SOLIDCOLORMIXING EXCLUDE INTERPOLATION DRAKCOLOR SUBTRACT DIVIDE
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _MaskTex;
            float4 _MaskColor;

            fixed4 TransparentMix(fixed4 A, fixed4 B){
                fixed4 C =A*(1-B.a)+B*(B.a);//正常透明度混合
                return C;
            }
            
            fixed4 Draken(fixed4 A, fixed4 B){
                fixed4 C =min(A,B);//变暗
                return C;
            }

            fixed4 Lighten(fixed4 A, fixed4 B){
                fixed4 C =max(A,B);//变亮
                return C;
            }

            fixed4 Multiply(fixed4 A, fixed4 B){
                fixed4 C =A*B;//正片叠底
                return C;
            }

            fixed4 ColorFilter(fixed4 A, fixed4 B){
                fixed4 C=1-((1-A)*(1-B));//滤色 A+B-A*B
                return C;
            }

            fixed4 ColorDeepening(fixed4 A, fixed4 B){
                fixed4 C =A-((1-A)*(1-B))/B; //颜色加深
                return C;
            }
            
            fixed4 ColorDodge(fixed4 A, fixed4 B){
                fixed4 C= A+(A*B)/(1-B); //颜色减淡
                return C;
            }
            
            fixed4 LinearDeepening(fixed4 A, fixed4 B){
                fixed4 C=A+B-1;//线性加深
                return C;
            }
            
            fixed4 LinearDodge(fixed4 A, fixed4 B){
                fixed4 C=A+B; //线性减淡
                return C;
            }

            fixed4 Superposition(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(A,fixed4(0.5,0.5,0.5,0.5));
                fixed4 C=ifFlag*A*B*2+(1-ifFlag)*(1-(1-A)*(1-B)*2);//叠加
                return C;
            }

            fixed4 Glare(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
                fixed4 C=ifFlag*A*B*2+(1-ifFlag)*(1-(1-A)*(1-B)*2); //强光
                return C;
            }

            fixed4 SoftLight(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
                fixed4 C=ifFlag*(A*B*2+A*A*(1-B*2))+(1-ifFlag)*(A*(1-B)*2+sqrt(A)*(2*B-1)); //柔光
                return C;
            }

            fixed4 Light(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
                fixed4 C=ifFlag*(A-(1-A)*(1-2*B)/(2*B))+(1-ifFlag)*(A+A*(2*B-1)/(2*(1-B))); //亮光
                return C;
            }

            fixed4 PointLight(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
                fixed4 C=ifFlag*(min(A,2*B))+(1-ifFlag)*(max(A,( B*2-1)));//点光
                return C;
            }

            fixed4 LinearLight(fixed4 A, fixed4 B){
                fixed4 C=A+2*B-1; //线性光
                return C;
            }

            fixed4 SolidColorMixing(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(A+B,fixed4(1,1,1,1));
                fixed4 C=ifFlag*(fixed4(0,0,0,0))+(1-ifFlag)*(fixed4(1,1,1,1));//实色混合
                return C;
            }

            fixed4 Exclude(fixed4 A, fixed4 B){
                fixed4 C=A+B-A*B*2; //排除
                return C;
            }
            
            fixed4 Interpolation(fixed4 A, fixed4 B){
                fixed4 C=abs(A-B); //差值
                return C;
            }

            fixed4 DarkColor(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(B.r+B.g+B.b,A.r+A.g+A.b);
                fixed4 C=ifFlag*(B)+(1-ifFlag)*(A);//深色
                return C;
            }

            fixed4 Undertone(fixed4 A, fixed4 B){
                fixed4 ifFlag= step(B.r+B.g+B.b,A.r+A.g+A.b);
                fixed4 C=ifFlag*(A)+(1-ifFlag)*(B); //浅色
                return C;
            }

            fixed4 Subtract(fixed4 A, fixed4 B){
                fixed4 C=A-B; //减去
                return C;
            }

            fixed4 Divide(fixed4 A, fixed4 B){
                fixed4 C=A/B; //划分
                return C;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 A = tex2D(_MainTex, i.uv);
                #ifdef UNITY_UI_ALPHACLIP
					clip (color.a - 0.01);
                #endif
                A *= i.color;

                half4 B = tex2D(_MaskTex, i.uv) * _MaskColor;

                half4 C = A;

                #ifdef TRANSPARENTMIX                    
                    C = TransparentMix(A,B);
                #endif
                
                #ifdef DRAKEN                    
                    C = Draken(A,B);
                #endif

                #ifdef MULTIPLY                    
                    C = Multiply(A,B);
                #endif

                #ifdef COLORDEEPENING                    
                    C = ColorDeepening(A,B);
                #endif

                #ifdef LIGHTEN                    
                    C = Lighten(A,B);
                #endif

                #ifdef COLORFILTER                    
                    C = ColorFilter(A,B);
                #endif

                #ifdef COLORDODGE                    
                    C = ColorDodge(A,B);
                #endif

                #ifdef SUPERPOSITION                    
                    C = Superposition(A,B);
                #endif

                #ifdef SOFTLIGHT                    
                    C = SoftLight(A,B);
                #endif

                #ifdef LIGHT                    
                    C = Light(A,B);
                #endif

                #ifdef GLARE                    
                    C = Glare(A,B);
                #endif

                #ifdef LINEARDEEPENING                    
                    C = LinearDeepening(A,B);
                #endif

                #ifdef LINEARDODGE                    
                    C = LinearDodge(A,B);
                #endif

                #ifdef POINTLIGHT                    
                    C = PointLight(A,B);
                #endif

                #ifdef LINEARLIGHT                    
                    C = LinearLight(A,B);
                #endif

                #ifdef SOLIDCOLORMIXING                    
                    C = SolidColorMixing(A,B);
                #endif

                #ifdef EXCLUDE                    
                    C = Exclude(A,B);
                #endif

                #ifdef INTERPOLATION                    
                    C = Interpolation(A,B);
                #endif

                #ifdef DRAKCOLOR                    
                    C = DarkColor(A,B);
                #endif

                #ifdef UNDERTONE                    
                    C = Undertone(A,B);
                #endif

                #ifdef SUBTRACT                    
                    C = Subtract(A,B);
                #endif

                #ifdef DIVIDE                    
                    C = Divide(A,B);
                #endif

                return C;
            }
            ENDCG
        }
    }
}
