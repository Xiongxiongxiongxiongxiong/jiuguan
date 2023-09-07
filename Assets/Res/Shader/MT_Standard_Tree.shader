Shader "MT/MT_Standard_Tree"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" { }
		_MRA ("MRA", 2D) = "white" { }
		_Roughness ("Roughness", Range(0, 1)) = 1
		_Metallic ("Metallic", Range(0, 1)) = 1
		_AO ("AO", Range(0, 1)) = 0
		
		[HDR]_EmissiveColor ("Emissive", Color) = (0, 0, 0, 0)
		_EmissiveTex ("Emissive", 2D) = "white" { }
		_Normal ("Normal", 2D) = "bump" { }
		_NormalScale ("Normal Scale", Range(0, 5)) = 1
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[Header(Wind)]
		[NoScaleOffset]_WindNoise ("_WindNoise", 2D) = "white" { }
		_NoiseAmount ("Noise Amount", Vector) = (0, 0, 0, 0)
		_NoiseScale ("Noise Texture Scale", Float) = 1.0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
	}
	SubShader
	{
		Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		LOD 200
		Cull [_CullMode]
		CGPROGRAM
		
		#pragma surface surf Standard addshadow  alphatest:_Cutoff vertex:vert
		
		#pragma target 3.0
		
		sampler2D _MainTex, _MRA, _Normal, _WindNoise, _EmissiveTex;
		
		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
			float4 vertCol: COLOR;
			INTERNAL_DATA
		};
		
		half _Roughness, _Metallic, _NormalScale, _AO,_NoiseScale;
		
		half4 _Color, _EmissiveColor;
		half4 _NoiseAmount;
		
		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			
			float2 UV = worldPos.xz;
			UV.xy += _Time * 2;
			float3 windNoise = tex2Dlod(_WindNoise, float4(UV, 0, 0) * _NoiseScale).rgb;
			
			
			v.vertex.z += sin(_Time * 20) * v.color.r * _NoiseAmount.z * v.color.r * windNoise.g;
			v.vertex.z += sin(_Time * 15) * v.color.r * _NoiseAmount.z * v.color.g * windNoise.g;
			v.vertex.z += sin(_Time * 25) * v.color.r * _NoiseAmount.z * v.color.b * windNoise.g;
			
			v.vertex.x += sin(_Time * 20) * v.color.r * _NoiseAmount.x * v.color.r * windNoise.r;
			v.vertex.x += sin(_Time * 15) * v.color.r * _NoiseAmount.x * v.color.g * windNoise.r;
			v.vertex.x += sin(_Time * 25) * v.color.r * _NoiseAmount.x * v.color.b * windNoise.r;
			
			v.vertex.y += windNoise.r * _NoiseAmount.y * v.color.r * v.color.r;
			v.vertex.y += windNoise.g * _NoiseAmount.y * v.color.r * v.color.g;
			v.vertex.y += windNoise.b * _NoiseAmount.y * v.color.r * v.color.b;

			//o.vertColor = v.color;
		}
		
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)
		
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Albedo comes from a texture tinted by color
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			half3 mra = tex2D(_MRA, IN.uv_MainTex);
			half3 emissive = tex2D(_EmissiveTex, IN.uv_MainTex).rgb * _EmissiveColor.rgb;
			half3 normal = UnpackNormalWithScale(tex2D(_Normal, IN.uv_MainTex), _NormalScale);
			
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = mra.r * _Metallic;
			o.Smoothness = pow(saturate(1 - mra.g * _Roughness), 2);
			o.Occlusion = lerp(mra.b, 1, _AO);
			o.Emission = emissive;
			o.Normal = normal;
			o.Alpha = c.a;
		}
		ENDCG
		
	}
	FallBack "Diffuse"
}
