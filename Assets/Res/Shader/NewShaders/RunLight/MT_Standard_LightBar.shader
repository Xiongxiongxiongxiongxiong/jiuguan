// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_LightBar"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering)]_CullMode("CullMode", Float) = 2
		[Enum(UnityEngine.Rendering.BlendMode)]_Src("Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_Dst("Dst", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_DepthTest("DepthTest", Float) = 4
		[Toggle]_DepthWrite("DepthWrite", Float) = 1
		_DepthOffset("DepthOffset", Float) = 0
		_Cutout("Cutout", Range( 0 , 1)) = 0
		[Header(PBR)]_MainColor("MainColor", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Range( 0 , 10)) = 1
		_MSA1("R:Metallic G:Smoothness B:AO", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_AO("AO", Range( 0 , 1)) = 1
		_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_MaskColor("MaskColor", Color) = (0,0,0,0)
		[Enum(Off,0,On,1)][Header(LightBar)]_UseTextureMask("UseTextureMask", Float) = 0
		[NoScaleOffset]_LightMask("LightMask", 2D) = "black" {}
		_TilingOffset("TilingOffset", Vector) = (1,1,0,0)
		_ColorfulIntensity("ColorfulIntensity", Range( 0 , 10)) = 1
		[HDR]_LightBaseColor("LightBaseColor", Color) = (1,1,1,1)
		_UVOffset("UVOffset", Float) = 0
		_UVSpeed("UVSpeed", Float) = 1
		_Width("Width", Float) = 1
		[IntRange]_Density("Density", Range( 0 , 100)) = 2
		_Edge("Edge", Range( 0 , 1)) = 0.5
		_SegmentCount("SegmentCount", Float) = 2
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_RefractionIntensity("RefractionIntensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite [_DepthWrite]
		ZTest [_DepthTest]
		Offset  [_DepthOffset] , 0
		Blend [_Src] [_Dst]
		
		GrabPass{ }
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		struct Input
		{
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			float4 screenPos;
			float3 worldPos;
		};

		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float4 _MaskColor;
		uniform float4 _LightBaseColor;
		uniform float _Edge;
		uniform float _UVSpeed;
		uniform float _Density;
		uniform float _UVOffset;
		uniform float _Width;
		uniform float _SegmentCount;
		uniform float _ColorfulIntensity;
		uniform float _UseTextureMask;
		uniform sampler2D _LightMask;
		uniform float4 _TilingOffset;
		uniform float4 _EmissionColor;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _RefractionIntensity;
		uniform float _Cutout;


		float4 ComputeLightBar1_g21( float2 uv , float4 baseColor , float edge , float speed , float density , float offset , float width , float segmentCount , float intensity , float useTexture , inout float mask )
		{
			edge = lerp(1,edge,density);
			float uv_x = uv.x + _Time.y * speed;
			float uv_y = uv.y + offset;
			float xCol = uv_x * 3.0;
			xCol = xCol - 3.0 * floor(xCol / 3.0);
			float3 horColour = baseColor;
			float s = sin(uv_x * density);
			if(!useTexture)
			{
			mask = saturate(lerp(saturate(s), lerp(0, 1, step(0, s)), edge) * smoothstep(edge,1, abs(width * 0.01 / (frac(uv_y * segmentCount) - 0.5))));
			}
			fixed d = step(xCol, 1);
			fixed d1 = step(xCol, 2);
			fixed d2 = step(xCol, 3);
			horColour.r += (1.0 - xCol) * d * intensity;
			horColour.g += xCol * d * intensity;
			d1 -= d;
			xCol -= 1.0 * d1;
			horColour.g += (1.0 - xCol) * d1 * intensity;
			horColour.b += xCol * d1 * intensity;
			d2 -= d1 + d;
			xCol -= 2.0 * d2;
			horColour.b += (1.0 - xCol) * d2 * intensity;
			horColour.r += xCol * d2 * intensity;
			return fixed4(mask * horColour, 1.0);
		}


		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, _RefractionIntensity, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode31_g20 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 switchResult58_g20 = (((i.ASEVFace>0)?(tex2DNode31_g20):(-tex2DNode31_g20)));
			float3 NormalMap32_g20 = switchResult58_g20;
			o.Normal = NormalMap32_g20;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g20 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g20 = ( (_MainColor).rgb * (tex2DNode35_g20).rgb );
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 tex2DNode13_g20 = tex2D( _EmissionMap, uv_EmissionMap );
			float EmissionAlpha21_g20 = tex2DNode13_g20.a;
			float temp_output_82_56 = EmissionAlpha21_g20;
			float2 uv1_g21 = i.uv_texcoord;
			float4 baseColor1_g21 = _LightBaseColor;
			float edge1_g21 = _Edge;
			float speed1_g21 = _UVSpeed;
			float density1_g21 = _Density;
			float offset1_g21 = _UVOffset;
			float width1_g21 = _Width;
			float segmentCount1_g21 = _SegmentCount;
			float intensity1_g21 = _ColorfulIntensity;
			float useTexture1_g21 = _UseTextureMask;
			float2 appendResult79 = (float2(_TilingOffset.x , _TilingOffset.y));
			float mulTime76 = _Time.y * _UVSpeed;
			float2 appendResult80 = (float2(_TilingOffset.z , _TilingOffset.w));
			float2 uv_TexCoord72 = i.uv_texcoord * appendResult79 + ( ( mulTime76 * float2( 1,0 ) ) + appendResult80 );
			float mask1_g21 = tex2D( _LightMask, uv_TexCoord72 ).r;
			float4 localComputeLightBar1_g21 = ComputeLightBar1_g21( uv1_g21 , baseColor1_g21 , edge1_g21 , speed1_g21 , density1_g21 , offset1_g21 , width1_g21 , segmentCount1_g21 , intensity1_g21 , useTexture1_g21 , mask1_g21 );
			float temp_output_63_0 = ( 1.0 - mask1_g21 );
			o.Albedo = ( ( float4( ( Albedo40_g20 * ( 1.0 - temp_output_82_56 ) ) , 0.0 ) + ( temp_output_82_56 * _MaskColor ) ) * temp_output_63_0 ).rgb;
			float4 Emission18_g20 = ( _EmissionColor * tex2DNode13_g20 );
			o.Emission = ( ( Emission18_g20 * temp_output_63_0 ) + localComputeLightBar1_g21 ).rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g20 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g20 = ( tex2DNode7_g20.r * _Metallic );
			o.Metallic = Metallic19_g20;
			float Smoothness16_g20 = ( ( 1.0 - tex2DNode7_g20.g ) * _Smoothness );
			o.Smoothness = Smoothness16_g20;
			float AO14_g20 = ( tex2DNode7_g20.b * _AO );
			o.Occlusion = AO14_g20;
			float Alpha38_g20 = ( _MainColor.a * tex2DNode35_g20.a );
			float temp_output_82_43 = Alpha38_g20;
			o.Alpha = temp_output_82_43;
			clip( temp_output_82_43 - _Cutout );
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
3021;399;1710;890;965.6956;-1229.291;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;48;-1529.492,1570.745;Inherit;False;Property;_UVSpeed;UVSpeed;26;0;Create;True;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;74;-1286.027,1777.661;Inherit;False;Constant;_Vector0;Vector 0;28;0;Create;True;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;76;-1322.788,1662.628;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;78;-1329.354,1932.547;Inherit;False;Property;_TilingOffset;TilingOffset;22;0;Create;True;0;0;True;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1114.8,1708.639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-1117.636,1844.693;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-937.9037,1727.243;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;-952.0372,1873.167;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-742.0331,1667.217;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0.5,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;70;-407.9098,1569.426;Inherit;False;Property;_UseTextureMask;UseTextureMask;20;1;[Enum];Create;True;2;Off;0;On;1;0;True;1;Header(LightBar);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;-386.2801,859.2779;Inherit;False;Property;_LightBaseColor;LightBaseColor;24;1;[HDR];Create;True;0;0;True;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-456.9123,1036.259;Inherit;False;Property;_Edge;Edge;29;0;Create;True;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-343.6939,1310.4;Inherit;False;Property;_Width;Width;27;0;Create;True;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-412.5421,734.8649;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;71;-466.9464,1675.778;Inherit;True;Property;_LightMask;LightMask;21;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;82;-656.9514,302.2584;Inherit;False;PBR;7;;20;1bdad994f2fe8074b907eff23b7831db;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.RangedFloatNode;46;-341.7877,1225.189;Inherit;False;Property;_UVOffset;UVOffset;25;0;Create;True;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-457.372,1144.913;Inherit;False;Property;_Density;Density;28;1;[IntRange];Create;True;0;0;True;0;False;2;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-382.8318,1402.439;Inherit;False;Property;_SegmentCount;SegmentCount;30;0;Create;True;0;0;True;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-473.6276,1482.857;Inherit;False;Property;_ColorfulIntensity;ColorfulIntensity;23;0;Create;True;0;0;True;0;False;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-671.4243,555.6274;Inherit;False;Property;_MaskColor;MaskColor;19;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;35;-61.07117,-72.29313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;77;287.1984,734.5478;Inherit;False;LightBar;-1;;21;5ca240a03f1255a4d8de3b98833390a8;0;11;2;FLOAT2;0,0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;2;FLOAT4;8;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;63;675.9261,705.2692;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-354.2911,537.405;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;144.3289,-176.2931;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;395.2289,-29.39314;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;947.0487,668.5527;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1176.6,-364.4003;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;848.4257,150.2698;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;83;1082.121,577.5338;Inherit;False;Property;_RefractionIntensity;RefractionIntensity;33;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1170.963,270.2649;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1178.441,-68.76704;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1183.641,132.733;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;1187.782,709.9507;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1173.24,-263.767;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1178.24,-170.2671;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1182.341,30.03297;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1347.603,389.4349;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_LightBar;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;True;5;10;True;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;31;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;76;0;48;0
WireConnection;75;0;76;0
WireConnection;75;1;74;0
WireConnection;80;0;78;3
WireConnection;80;1;78;4
WireConnection;81;0;75;0
WireConnection;81;1;80;0
WireConnection;79;0;78;1
WireConnection;79;1;78;2
WireConnection;72;0;79;0
WireConnection;72;1;81;0
WireConnection;71;1;72;0
WireConnection;35;0;82;56
WireConnection;77;2;47;0
WireConnection;77;4;50;0
WireConnection;77;5;53;0
WireConnection;77;6;48;0
WireConnection;77;7;54;0
WireConnection;77;9;46;0
WireConnection;77;10;49;0
WireConnection;77;11;52;0
WireConnection;77;12;55;0
WireConnection;77;13;70;0
WireConnection;77;14;71;1
WireConnection;63;0;77;0
WireConnection;34;0;82;56
WireConnection;34;1;33;0
WireConnection;36;0;82;0
WireConnection;36;1;35;0
WireConnection;37;0;36;0
WireConnection;37;1;34;0
WireConnection;61;0;82;50
WireConnection;61;1;63;0
WireConnection;64;0;37;0
WireConnection;64;1;63;0
WireConnection;62;0;61;0
WireConnection;62;1;77;8
WireConnection;0;0;64;0
WireConnection;0;1;82;49
WireConnection;0;2;62;0
WireConnection;0;3;82;51
WireConnection;0;4;82;52
WireConnection;0;5;82;53
WireConnection;0;8;83;0
WireConnection;0;9;82;43
WireConnection;0;10;82;43
ASEEND*/
//CHKSM=215EB9AD7E874E79D6157D9BADCDEE1359457E70