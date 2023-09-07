// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_GlassCup"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering)]_CullMode("CullMode", Float) = 2
		[Enum(UnityEngine.Rendering.CompareFunction)]_DepthTest("DepthTest", Float) = 4
		[Toggle]_DepthWrite("DepthWrite", Float) = 1
		_DepthOffset("DepthOffset", Float) = 0
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
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_RefractionIntensity("RefractionIntensity", Range( -10 , 10)) = 0
		_FresnelScale("FresnelScale", Float) = 5
		_FresnelPower("FresnelPower", Float) = 4.5
		_CubeMap("CubeMap", CUBE) = "white" {}
		_CubemapIntensity("CubemapIntensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		GrabPass{ }
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldRefl;
			float4 screenPos;
		};

		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform samplerCUBE _CubeMap;
		uniform float _CubemapIntensity;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _RefractionIntensity;

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
			float3 tex2DNode31_g8 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 switchResult58_g8 = (((i.ASEVFace>0)?(tex2DNode31_g8):(-tex2DNode31_g8)));
			float3 NormalMap32_g8 = switchResult58_g8;
			float3 temp_output_68_49 = NormalMap32_g8;
			o.Normal = temp_output_68_49;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 NormalTS48 = temp_output_68_49;
			float fresnelNdotV44 = dot( (WorldNormalVector( i , NormalTS48 )), ase_worldViewDir );
			float fresnelNode44 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV44, _FresnelPower ) );
			float clampResult50 = clamp( fresnelNode44 , 0.0 , 1.2 );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g8 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g8 = ( (_MainColor).rgb * (tex2DNode35_g8).rgb );
			float3 PBRAlbedo55 = Albedo40_g8;
			float4 FinalAlbedo58 = ( ( 1.0 - clampResult50 ) + saturate( ( texCUBE( _CubeMap, WorldReflectionVector( i , NormalTS48 ) ) * _CubemapIntensity ) ) + float4( PBRAlbedo55 , 0.0 ) );
			o.Albedo = FinalAlbedo58.rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 tex2DNode13_g8 = tex2D( _EmissionMap, uv_EmissionMap );
			float4 Emission18_g8 = ( _EmissionColor * tex2DNode13_g8 );
			o.Emission = Emission18_g8.rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g8 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g8 = ( tex2DNode7_g8.r * _Metallic );
			o.Metallic = Metallic19_g8;
			float Smoothness16_g8 = ( ( 1.0 - tex2DNode7_g8.g ) * _Smoothness );
			o.Smoothness = Smoothness16_g8;
			float AO14_g8 = ( tex2DNode7_g8.b * _AO );
			o.Occlusion = AO14_g8;
			float Alpha38_g8 = ( _MainColor.a * tex2DNode35_g8.a );
			o.Alpha = Alpha38_g8;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred 

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
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
2560;0;2560;1378;1413.753;1265.968;1.3;True;True
Node;AmplifyShaderEditor.FunctionNode;68;-81.30661,33.63904;Inherit;False;PBR;4;;8;1bdad994f2fe8074b907eff23b7831db;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.CommentaryNode;64;-198.6636,-883.7758;Inherit;False;1742.794;552.6693;玻璃菲涅尔与反射;16;61;62;63;54;57;56;58;51;50;44;47;46;45;49;53;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;181.4482,25.77005;Inherit;False;NormalTS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-148.6636,-833.7758;Inherit;False;48;NormalTS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-140.0757,-504.4022;Inherit;False;48;NormalTS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;45;58.93256,-830.5569;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;46;70.93211,-692.557;Inherit;False;Property;_FresnelScale;FresnelScale;19;0;Create;True;0;0;False;0;False;5;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;66.93212,-615.5573;Inherit;False;Property;_FresnelPower;FresnelPower;20;0;Create;True;0;0;False;0;False;4.5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;61;96.88203,-503.2671;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;44;304.1337,-804.0173;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;424.3662,-416.751;Inherit;False;Property;_CubemapIntensity;CubemapIntensity;22;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;391.6816,-628.1989;Inherit;True;Property;_CubeMap;CubeMap;21;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;50;565.8547,-796.5471;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;726.5566,-561.4552;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;181.0303,-56.87021;Inherit;False;PBRAlbedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;51;825.9742,-710.1135;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;918.6131,-585.036;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;860.2899,-447.692;Inherit;False;55;PBRAlbedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;1137.811,-631.0851;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;1318.406,-692.218;Inherit;False;FinalAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1183.641,132.733;Inherit;False;Property;_DepthOffset;DepthOffset;3;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1172.6,-156.4003;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1178.441,-68.76704;Inherit;False;Property;_DepthTest;DepthTest;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1182.341,30.03297;Inherit;False;Property;_DepthWrite;DepthWrite;2;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;294.0676,319.3705;Inherit;False;Property;_RefractionIntensity;RefractionIntensity;18;0;Create;True;0;0;False;0;False;0;0.75;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;397.722,-59.69733;Inherit;False;58;FinalAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;637.3999,24.29999;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_GlassCup;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;5;10;False;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;16;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;0;68;49
WireConnection;45;0;49;0
WireConnection;61;0;53;0
WireConnection;44;0;45;0
WireConnection;44;2;46;0
WireConnection;44;3;47;0
WireConnection;62;1;61;0
WireConnection;50;0;44;0
WireConnection;54;0;62;0
WireConnection;54;1;63;0
WireConnection;55;0;68;0
WireConnection;51;0;50;0
WireConnection;67;0;54;0
WireConnection;56;0;51;0
WireConnection;56;1;67;0
WireConnection;56;2;57;0
WireConnection;58;0;56;0
WireConnection;0;0;59;0
WireConnection;0;1;68;49
WireConnection;0;2;68;50
WireConnection;0;3;68;51
WireConnection;0;4;68;52
WireConnection;0;5;68;53
WireConnection;0;8;42;0
WireConnection;0;9;68;43
ASEEND*/
//CHKSM=9E3905EA419F50CAD706AF268010A63A0C735319