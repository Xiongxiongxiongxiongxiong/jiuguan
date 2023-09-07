// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_SSS"
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
		_AddColor("AddColor", Color) = (0,0,0,0)
		[Header(SSS)]_SatterColor("SatterColor", Color) = (1,1,1,1)
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_ThicknessMap("ThicknessMap", 2D) = "white" {}
		_ThicknessIntensity("ThicknessIntensity", Float) = 1
		_BasePassPower("BasePassPower", Float) = 1
		_BasePassScale("BasePassScale", Float) = 2
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
		
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
		};

		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float _BasePassPower;
		uniform float _BasePassScale;
		uniform sampler2D _ThicknessMap;
		uniform float4 _ThicknessMap_ST;
		uniform float4 _SatterColor;
		uniform float _ThicknessIntensity;
		uniform float4 _AddColor;
		uniform float _Opacity;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform float _Cutout;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode31_g96 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 switchResult58_g96 = (((i.ASEVFace>0)?(tex2DNode31_g96):(-tex2DNode31_g96)));
			float3 NormalMap32_g96 = switchResult58_g96;
			float3 temp_output_63_49 = NormalMap32_g96;
			o.Normal = temp_output_63_49;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g96 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g96 = ( (_MainColor).rgb * (tex2DNode35_g96).rgb );
			float3 temp_output_63_0 = Albedo40_g96;
			o.Albedo = temp_output_63_0;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 tex2DNode13_g96 = tex2D( _EmissionMap, uv_EmissionMap );
			float4 Emission18_g96 = ( _EmissionColor * tex2DNode13_g96 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 NormalWS117 = (WorldNormalVector( i , temp_output_63_49 ));
			float3 normalizeResult81 = normalize( ( ase_worldlightDir + NormalWS117 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult82 = dot( -normalizeResult81 , ase_worldViewDir );
			float2 uv_ThicknessMap = i.uv_texcoord * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
			float3 appendResult92 = (float3(_SatterColor.r , _SatterColor.g , _SatterColor.b));
			float3 Adbedo116 = temp_output_63_0;
			float dotResult104 = dot( NormalWS117 , ase_worldlightDir );
			float dotResult96 = dot( NormalWS117 , float3( 0,1,0 ) );
			o.Emission = ( Emission18_g96 + float4( ( ( pow( max( dotResult82 , 0.0 ) , _BasePassPower ) * _BasePassScale ) * ( 1.0 - tex2D( _ThicknessMap, uv_ThicknessMap ).r ) * appendResult92 * _ThicknessIntensity ) , 0.0 ) + ( _AddColor + float4( ( Adbedo116 * saturate( dotResult104 ) ) , 0.0 ) + float4( ( _Opacity * ( ( dotResult96 + 1.0 ) * 0.5 ) * Adbedo116 ) , 0.0 ) ) ).rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g96 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g96 = ( tex2DNode7_g96.r * _Metallic );
			o.Metallic = Metallic19_g96;
			float Smoothness16_g96 = ( ( 1.0 - tex2DNode7_g96.g ) * _Smoothness );
			o.Smoothness = Smoothness16_g96;
			float AO14_g96 = ( tex2DNode7_g96.b * _AO );
			o.Occlusion = AO14_g96;
			float Alpha38_g96 = ( _MainColor.a * tex2DNode35_g96.a );
			float temp_output_63_43 = Alpha38_g96;
			o.Alpha = temp_output_63_43;
			clip( temp_output_63_43 - _Cutout );
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
2560;0;2560;1378;1196.58;-810.6548;1.151497;True;True
Node;AmplifyShaderEditor.FunctionNode;63;-126.3066,67.63904;Inherit;False;PBR;7;;96;1bdad994f2fe8074b907eff23b7831db;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.WorldNormalVector;112;-13.28853,334.711;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;304.9916,399.0652;Inherit;False;NormalWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;84;-777.1526,1355.437;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;85;-749.8525,1522.637;Inherit;False;117;NormalWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-517.7979,1385.113;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;81;-354.6103,1386.278;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;83;-195.6536,1383.74;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;80;-347.5244,1499.132;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;119;-260.7239,1215.882;Inherit;False;117;NormalWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;82;-36.79459,1448.672;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;105;-157.2421,1020.036;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;96;8.804401,1232.826;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-129.2652,902.744;Inherit;False;117;NormalWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;148.8044,1233.826;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;207.5421,30.88718;Inherit;False;Adbedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;104;156.8044,948.8259;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;87;134.1812,1494.794;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;31.63831,1645.544;Inherit;False;Property;_BasePassPower;BasePassPower;24;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;289.8045,1234.826;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;339.517,1549.916;Inherit;False;Property;_BasePassScale;BasePassScale;25;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;157.8044,1140.826;Inherit;False;Property;_Opacity;Opacity;21;0;Create;True;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;255.8044,822.8259;Inherit;False;116;Adbedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;91;294.318,1857.547;Inherit;False;Property;_SatterColor;SatterColor;20;0;Create;True;0;0;False;1;Header(SSS);False;1,1,1,1;0.6068233,0.8301887,0.4111783,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;89;335.9693,1451.479;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;111;277.9765,965.1121;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;249.8044,1340.826;Inherit;False;116;Adbedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;90;289.7584,1630.373;Inherit;True;Property;_ThicknessMap;ThicknessMap;22;0;Create;True;0;0;False;0;False;-1;f8d0bb20a13088447aaad64776385194;f8d0bb20a13088447aaad64776385194;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;92;593.3181,1843.547;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;122;284.2452,2118.755;Inherit;False;Property;_ThicknessIntensity;ThicknessIntensity;23;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;446.805,1214.826;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;567.5127,1467.008;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;94;582.3773,1571.796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;457.8049,964.8259;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;114;195.2952,575.9977;Inherit;False;Property;_AddColor;AddColor;19;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;103;677.8938,928.2776;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;797.2578,1471.672;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;1262.89,259.1518;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1038.932,50.04516;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1048.033,343.8451;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1102.932,147.545;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1036.655,584.077;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1042.292,-50.58816;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1044.133,245.045;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1049.333,446.5451;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1558.775,109.1;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_SSS;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;8;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;True;True;True;True;0;False;-1;False;1;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;True;5;10;True;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.01;1,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0.01;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;112;0;63;49
WireConnection;117;0;112;0
WireConnection;86;0;84;0
WireConnection;86;1;85;0
WireConnection;81;0;86;0
WireConnection;83;0;81;0
WireConnection;82;0;83;0
WireConnection;82;1;80;0
WireConnection;96;0;119;0
WireConnection;100;0;96;0
WireConnection;116;0;63;0
WireConnection;104;0;118;0
WireConnection;104;1;105;0
WireConnection;87;0;82;0
WireConnection;97;0;100;0
WireConnection;89;0;87;0
WireConnection;89;1;88;0
WireConnection;111;0;104;0
WireConnection;92;0;91;1
WireConnection;92;1;91;2
WireConnection;92;2;91;3
WireConnection;98;0;107;0
WireConnection;98;1;97;0
WireConnection;98;2;101;0
WireConnection;121;0;89;0
WireConnection;121;1;120;0
WireConnection;94;0;90;1
WireConnection;110;0;102;0
WireConnection;110;1;111;0
WireConnection;103;0;114;0
WireConnection;103;1;110;0
WireConnection;103;2;98;0
WireConnection;93;0;121;0
WireConnection;93;1;94;0
WireConnection;93;2;92;0
WireConnection;93;3;122;0
WireConnection;95;0;63;50
WireConnection;95;1;93;0
WireConnection;95;2;103;0
WireConnection;0;0;63;0
WireConnection;0;1;63;49
WireConnection;0;2;95;0
WireConnection;0;3;63;51
WireConnection;0;4;63;52
WireConnection;0;5;63;53
WireConnection;0;9;63;43
WireConnection;0;10;63;43
ASEEND*/
//CHKSM=B550E39B08475DB23348563F24CBC153AFD2D776