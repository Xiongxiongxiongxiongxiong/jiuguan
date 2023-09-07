Shader "XF/XF_Mountain"
{
    Properties
    {
        [NoScaleOffset]_BlendMap ("BlendMap", 2D) = "white" {}
        _BlendContrast ("BlendContrast", Range(0,1)) = 0.2

		[Header(LAYER1)]
        [NoScaleOffset]_Layer1_BaseColor ("Layer1_BaseColor", 2D) = "white" {}
        [NoScaleOffset]_Layer1_MRA ("Layer1_MRA", 2D) = "white" {}
		_Layer1_MRA_Control ("X1:Metallic Y1:Roughness Z1:AO", Vector) = (0, 1, 1)
        [NoScaleOffset]_Layer1_Normal ("Layer1_Normal", 2D) = "bump" {}
        _Layer1_Till ("Layer1_Till", Float) = 1
        _Layer1_NormalScale ("_Layer1_NormalScale", Range(0, 5)) = 1

		[Header(LAYER2)]
        [NoScaleOffset]_Layer2_BaseColor ("Layer2_BaseColor", 2D) = "white" {}
        [NoScaleOffset]_Layer2_MRA ("Layer2_MRA", 2D) = "white" {}
		_Layer2_MRA_Control ("X2:Metallic Y2:Roughness Z2:AO", Vector) = (0, 1, 1)
        [NoScaleOffset]_Layer2_Normal ("Layer2_Normal", 2D) = "bump" {}
        _Layer2_Till ("Layer2_Till", Float) = 1
        _Layer2_NormalScale ("_Layer2_NormalScale", Range(0, 5)) = 1

		[Header(LAYER3)]
        [NoScaleOffset]_Layer3_BaseColor ("Layer3_BaseColor", 2D) = "white" {}
        [NoScaleOffset]_Layer3_MRA ("Layer3_MRA", 2D) = "white" {}
		_Layer3_MRA_Control ("X3:Metallic Y3:Roughness Z3:AO", Vector) = (0, 1, 1)
        [NoScaleOffset]_Layer3_Normal ("Layer3_Normal", 2D) = "bump" {}
        _Layer3_Till ("Layer3_Till", Float) = 1
        _Layer3_NormalScale ("_Layer3_NormalScale", Range(0, 5)) = 1

		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[Space]
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
    }
    SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Cull [_CullMode]
		CGPROGRAM
		
		#pragma surface surf Standard fullforwardshadows
		
		#pragma target 3.0
		
		sampler2D _BlendMap;
        float _BlendContrast;

        sampler2D _Layer1_BaseColor;
        sampler2D _Layer1_MRA;
        sampler2D _Layer1_Normal;
		float3 _Layer1_MRA_Control;
        float _Layer1_Till;
        float _Layer1_NormalScale;

        sampler2D _Layer2_BaseColor;
        sampler2D _Layer2_MRA;
        sampler2D _Layer2_Normal;
		float3 _Layer2_MRA_Control;
        float _Layer2_Till;
        float _Layer2_NormalScale;

        sampler2D _Layer3_BaseColor;
        sampler2D _Layer3_MRA;
        sampler2D _Layer3_Normal;
		float3 _Layer3_MRA_Control;
        float _Layer3_Till;
        float _Layer3_NormalScale;
		
		struct Input
		{
			float2 uv_texcoord;
		};				
		
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)
		
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			half3 blendFactor = tex2D(_BlendMap, IN.uv_texcoord).rgb;
			half maxBlendFactor = max(blendFactor.r, blendFactor.g);
			maxBlendFactor = max(maxBlendFactor, blendFactor.b);
			half blendContrast = maxBlendFactor - _BlendContrast;
			blendFactor = blendFactor - blendContrast;
			blendFactor = max(0,blendFactor);
			half3 blendWeight = blendFactor / (blendFactor.r + blendFactor.g + blendFactor.b + 0.0001);

			//Layer1
			half4 layer1_c = tex2D(_Layer1_BaseColor, IN.uv_texcoord * _Layer1_Till);
			half3 layer1_mra = tex2D(_Layer1_MRA,  IN.uv_texcoord * _Layer1_Till);
			layer1_mra.x = layer1_mra.x * _Layer1_MRA_Control.x;
			layer1_mra.y = layer1_mra.y * _Layer1_MRA_Control.y;
			layer1_mra.z = lerp(layer1_mra.z, 1, _Layer1_MRA_Control.z);
			half3 layer1_normal = UnpackNormalWithScale(tex2D(_Layer1_Normal, IN.uv_texcoord * _Layer1_Till), _Layer1_NormalScale);

			//Layer2
			half4 layer2_c = tex2D(_Layer2_BaseColor, IN.uv_texcoord * _Layer2_Till);
			half3 layer2_mra = tex2D(_Layer2_MRA,  IN.uv_texcoord * _Layer2_Till);
			layer2_mra.x = layer2_mra.x * _Layer2_MRA_Control.x;
			layer2_mra.y = layer2_mra.y * _Layer2_MRA_Control.y;
			layer2_mra.z = lerp(layer2_mra.z, 1, _Layer2_MRA_Control.z);
			half3 layer2_normal = UnpackNormalWithScale(tex2D(_Layer2_Normal, IN.uv_texcoord * _Layer2_Till), _Layer2_NormalScale);

			//Layer3
			half4 layer3_c = tex2D(_Layer3_BaseColor, IN.uv_texcoord * _Layer3_Till);
			half3 layer3_mra = tex2D(_Layer3_MRA,  IN.uv_texcoord * _Layer3_Till);
			layer3_mra.x = layer3_mra.x * _Layer3_MRA_Control.x;
			layer3_mra.y = layer3_mra.y * _Layer3_MRA_Control.y;
			layer3_mra.z = lerp(layer3_mra.z, 1, _Layer3_MRA_Control.z);
			half3 layer3_normal = UnpackNormalWithScale(tex2D(_Layer3_Normal, IN.uv_texcoord * _Layer3_Till), _Layer3_NormalScale);
			


			// Albedo comes from a texture tinted by color
			half4 c = layer1_c * blendWeight.r + layer2_c * blendWeight.g + layer3_c * blendWeight.b;
			half3 mra = layer1_mra * blendWeight.r + layer2_mra * blendWeight.g + layer3_mra * blendWeight.b;
			half3 normal = layer1_normal * blendWeight.r + layer2_normal * blendWeight.g + layer3_normal * blendWeight.b;

			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = mra.x;
			o.Smoothness = saturate(1 - mra.y);
			o.Occlusion = mra.z;//lerp(mra.b, 1, _AO);
			o.Normal = normal;
			o.Alpha = 1;
		}
		ENDCG
		
	}
	FallBack "Diffuse"
}
