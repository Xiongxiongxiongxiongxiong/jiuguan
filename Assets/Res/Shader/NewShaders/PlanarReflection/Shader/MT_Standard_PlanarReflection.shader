// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_PlanarReflection"
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
		[Header(PlanarReflection)]_PlanarReflectionIntensity("PlanarReflectionIntensity", Float) = 0.1
		_BlurRadius("BlurRadius", Range( 0 , 1)) = 0
		_NormalIntensity("NormalIntensity", Float) = 0.1
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
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			float4 screenPos;
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
		uniform sampler2D _ReflectionTex;
		uniform float _NormalIntensity;
		float4 _ReflectionTex_TexelSize;
		uniform float _BlurRadius;
		uniform float _PlanarReflectionIntensity;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform float _Cutout;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode31_g7 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 switchResult58_g7 = (((i.ASEVFace>0)?(tex2DNode31_g7):(-tex2DNode31_g7)));
			float3 NormalMap32_g7 = switchResult58_g7;
			float3 temp_output_45_49 = NormalMap32_g7;
			o.Normal = temp_output_45_49;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g7 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g7 = ( (_MainColor).rgb * (tex2DNode35_g7).rgb );
			o.Albedo = Albedo40_g7;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 tex2DNode13_g7 = tex2D( _EmissionMap, uv_EmissionMap );
			float4 Emission18_g7 = ( _EmissionColor * tex2DNode13_g7 );
			float3 NormalTS264 = temp_output_45_49;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 appendResult256 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
			float2 UV153 = (( -( NormalTS264 * _NormalIntensity ) + float3( appendResult256 ,  0.0 ) )).xy;
			float2 appendResult278 = (float2(_ReflectionTex_TexelSize.z , _ReflectionTex_TexelSize.w));
			float2 Reflectionxy279 = appendResult278;
			float BlurRadius283 = ( _BlurRadius * 0.0001 );
			float2 UV1289 = ( UV153 + ( Reflectionxy279 * float2( 1,0 ) * BlurRadius283 ) );
			float2 UV2296 = ( UV153 + ( Reflectionxy279 * float2( -1,0 ) * BlurRadius283 ) );
			float2 UV3303 = ( UV153 + ( Reflectionxy279 * float2( 0,1 ) * BlurRadius283 ) );
			float2 UV4310 = ( UV153 + ( Reflectionxy279 * float2( 0,-1 ) * BlurRadius283 ) );
			float2 UV5317 = ( UV153 + ( Reflectionxy279 * float2( 1,1 ) * BlurRadius283 ) );
			float2 UV6318 = ( UV153 + ( Reflectionxy279 * float2( -1,1 ) * BlurRadius283 ) );
			float2 UV7331 = ( UV153 + ( Reflectionxy279 * float2( 1,-1 ) * BlurRadius283 ) );
			float2 UV8332 = ( UV153 + ( Reflectionxy279 * float2( -1,-1 ) * BlurRadius283 ) );
			float4 Blur388 = ( ( ( tex2D( _ReflectionTex, UV153 ) + tex2D( _ReflectionTex, UV1289 ) + tex2D( _ReflectionTex, UV2296 ) + tex2D( _ReflectionTex, UV3303 ) + tex2D( _ReflectionTex, UV4310 ) + tex2D( _ReflectionTex, UV5317 ) + tex2D( _ReflectionTex, UV6318 ) + tex2D( _ReflectionTex, UV7331 ) + tex2D( _ReflectionTex, UV8332 ) ) / float4(9,9,9,9) ) * _PlanarReflectionIntensity );
			o.Emission = ( Emission18_g7 + Blur388 ).rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g7 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g7 = ( tex2DNode7_g7.r * _Metallic );
			o.Metallic = Metallic19_g7;
			float Smoothness16_g7 = ( ( 1.0 - tex2DNode7_g7.g ) * _Smoothness );
			o.Smoothness = Smoothness16_g7;
			float AO14_g7 = ( tex2DNode7_g7.b * _AO );
			o.Occlusion = AO14_g7;
			float Alpha38_g7 = ( _MainColor.a * tex2DNode35_g7.a );
			float temp_output_45_43 = Alpha38_g7;
			o.Alpha = temp_output_45_43;
			clip( temp_output_45_43 - _Cutout );
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
2560;0;2560;1378;-148.5625;-674.2486;1.3;True;True
Node;AmplifyShaderEditor.FunctionNode;45;-665.8909,22.34528;Inherit;False;PBR;7;;7;1bdad994f2fe8074b907eff23b7831db;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-423.4722,-69.91161;Inherit;False;NormalTS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;-2103.804,-1131.958;Inherit;False;264;NormalTS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;391;-2127.945,-1000.431;Inherit;False;Property;_NormalIntensity;NormalIntensity;23;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;249;-2112.597,-894.8608;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;392;-1883.945,-1071.431;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexelSizeNode;277;-1383.63,232.0115;Inherit;False;366;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;281;-1550.765,443.0916;Inherit;False;Property;_BlurRadius;BlurRadius;22;0;Create;True;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;263;-1683.31,-1063.643;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;256;-1681.836,-983.1014;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;-1132.233,413.9377;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.0001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;-1476.293,-1030.981;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;278;-1130.17,293.6093;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;254;-1342.564,-1028.477;Inherit;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;279;-974.6618,290.5798;Inherit;False;Reflectionxy;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;-985.6003,415.3997;Inherit;False;BlurRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-1250.616,2142.294;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;306;-253.0875,1377.123;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;334;-314.493,2210.344;Inherit;False;Constant;_Vector10;Vector 10;20;0;Create;True;0;0;False;0;False;-1,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;321;-332.7979,1892.814;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;298;-1114.482,1255.553;Inherit;False;Constant;_Vector5;Vector 5;20;0;Create;True;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;280;-1162.485,680.3624;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;-204.1048,632.6588;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-1225.497,1912.615;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;284;-1119.062,768.2135;Inherit;False;Constant;_Vector0;Vector 0;20;0;Create;True;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;333;-357.9159,2122.493;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;312;-1194.192,1771.244;Inherit;False;Constant;_Vector7;Vector 7;20;0;Create;True;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;299;-1145.787,1396.924;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-1237.615,1683.393;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;-1157.905,1167.702;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;335;-345.7979,2351.715;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-344.9158,1663.592;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;291;-160.6818,720.5098;Inherit;False;Constant;_Vector4;Vector 4;20;0;Create;True;0;0;False;0;False;-1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;286;-1150.367,909.5853;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;320;-301.4929,1751.443;Inherit;False;Constant;_Vector8;Vector 8;20;0;Create;True;0;0;False;0;False;-1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-1107.354,-1019.903;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;326;-1207.193,2230.145;Inherit;False;Constant;_Vector9;Vector 9;20;0;Create;True;0;0;False;0;False;1,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;305;-221.7826,1235.752;Inherit;False;Constant;_Vector6;Vector 6;20;0;Create;True;0;0;False;0;False;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;304;-265.2055,1147.901;Inherit;False;279;Reflectionxy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;292;-191.9868,861.8817;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;327;-1238.498,2371.516;Inherit;False;283;BlurRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;29.15962,714.4515;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-963.0915,563.7241;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;-1051.222,2025.654;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;-924.6406,1249.494;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;336;-124.6509,2204.285;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-958.5117,1051.063;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;314;-1004.351,1765.185;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-111.6508,1745.384;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-31.94045,1229.693;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;337;-158.522,2005.853;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;-145.5218,1546.953;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;-1038.222,1566.754;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-4.711105,516.0205;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;285;-929.2207,762.1552;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;-1017.351,2224.086;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-65.81143,1031.262;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;295;242.2269,627.6089;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;330;-804.2835,2137.244;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-711.5735,1162.652;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;324;101.416,1658.542;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;316;-791.2839,1678.343;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;309;181.1265,1142.851;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;338;88.41602,2117.442;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;287;-716.1533,675.3126;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;-642.716,2143.312;Inherit;False;UV7;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-554.5857,682.381;Inherit;False;UV1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;342.6943,1148.919;Inherit;False;UV4;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;262.9839,1664.61;Inherit;False;UV6;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;332;249.9839,2123.51;Inherit;False;UV8;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;-629.7164,1684.411;Inherit;False;UV5;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;296;403.7945,633.6773;Inherit;False;UV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;303;-550.0059,1168.72;Inherit;False;UV3;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;893.653,2376.558;Inherit;False;332;UV8;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;887.214,2150.421;Inherit;False;331;UV7;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;900.603,815.9216;Inherit;False;289;UV1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;884.239,1931.724;Inherit;False;318;UV6;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;887.2136,1717.49;Inherit;False;317;UV5;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;890.1879,1033.131;Inherit;False;296;UV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;375;890.1889,1485.404;Inherit;False;310;UV4;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;885.7258,1259.268;Inherit;False;303;UV3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;907.2402,609.9401;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;382;1132.802,2104.161;Inherit;True;Property;_TextureSample16;Texture Sample 16;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;372;1135.779,986.8714;Inherit;True;Property;_TextureSample11;Texture Sample 11;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;380;1129.829,1885.464;Inherit;True;Property;_TextureSample15;Texture Sample 15;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;368;1152.83,563.6808;Inherit;True;Property;_TextureSample9;Texture Sample 9;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;370;1146.194,769.6623;Inherit;True;Property;_TextureSample10;Texture Sample 10;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;374;1131.316,1213.008;Inherit;True;Property;_TextureSample12;Texture Sample 12;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;378;1132.803,1671.23;Inherit;True;Property;_TextureSample14;Texture Sample 14;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;384;1140.241,2330.298;Inherit;True;Property;_TextureSample17;Texture Sample 17;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;376;1135.779,1439.144;Inherit;True;Property;_TextureSample13;Texture Sample 13;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;385;1759.5,1382.182;Inherit;False;9;9;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;387;1762.005,1658.71;Inherit;False;Constant;_Vector11;Vector 11;20;0;Create;True;0;0;False;0;False;9,9,9,9;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;394;1853.301,1858.474;Inherit;False;Property;_PlanarReflectionIntensity;PlanarReflectionIntensity;19;0;Create;True;0;0;False;1;Header(PlanarReflection);False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;386;2013.766,1540.862;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;393;2188.418,1725.492;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;2451.765,1671.817;Inherit;False;Blur;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;142;1743.217,-720.2934;Inherit;False;1225.561;315.229;右下;10;219;209;207;185;172;168;159;154;148;270;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;509.085,-1078.991;Inherit;False;919.5605;325.429;中;5;221;211;198;184;272;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;151;-617.1847,-1071.049;Inherit;False;1104;315;左;8;223;215;194;189;181;164;156;273;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;158;1550.712,-1450.95;Inherit;False;994.5605;338.429;右上;7;226;213;203;188;178;177;268;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;163;-618.4733,-1447.934;Inherit;False;985;348;左上;7;239;238;220;216;201;183;266;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;146;1461.884,-1088.922;Inherit;False;1082.561;336.429;右;8;224;214;192;187;175;174;162;269;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-625.4872,328.7989;Inherit;False;388;Blur;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;143;-615.093,-726.7064;Inherit;False;1236;325;左下;10;222;210;202;190;170;169;161;157;149;274;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;147;400.0389,-1450.879;Inherit;False;1119.184;346.5623;上;8;218;212;205;186;179;176;160;267;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;150;640.4553,-724.8474;Inherit;False;1079.561;319.429;下;8;225;217;200;182;180;173;155;271;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;1520.444,-1028.099;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;160.5268,-1302.934;Inherit;False;leftUp;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;225;1517.016,-618.0242;Inherit;False;Down;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;1061.645,-944.1684;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;166;-1641.299,-655.5594;Inherit;False;Constant;_Vector2;Vector2;8;0;Create;True;0;0;False;0;False;0.118318,0.118318,0.118318,0.118318;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;190;-170.6661,-636.6424;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-585.0929,-676.7064;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;77.34885,-88.15485;Inherit;False;240;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-610.6661,-593.6426;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;647.4552,-526.8281;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;238;-604.4733,-1388.934;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;1469.884,-923.9033;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;180;819.39,-548.5081;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;165;-1643.299,-830.5593;Inherit;False;Constant;_Vector1;Vector1;8;0;Create;True;0;0;False;0;False;0.0947416,0.0947416,0.0947416,0.0947416;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;157;-436.666,-588.6426;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;2343.445,-982.0994;Inherit;False;Right;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;187;1765.563,-996.128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1818.265,-6.756513;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;1748.374,-507.6213;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1821.625,-107.3898;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;141;-1293.488,-1279.284;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;748.3429,-213.1443;Inherit;False;GaussianBlur;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;950.134,-641.0535;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1473.738,-1371.048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.000625;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;1752.217,-583.2742;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;268;1883.798,-1400.513;Inherit;True;Property;_TextureSample2;Texture Sample 2;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;1380.015,-616.0242;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;-604.4733,-1313.934;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;1753.391,-1342.156;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-1291.782,-458.297;Inherit;False;V0147761;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;189;-297.1846,-1001.049;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;-433.98,-921.6523;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;186;718.2233,-1365.879;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;411.6628,-1205.683;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;65.42722,-286.1922;Inherit;False;218;up;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;271;1074.798,-686.5129;Inherit;True;Property;_TextureSample5;Texture Sample 5;26;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;420.9071,-602.7066;Inherit;False;leftDown;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-77.1846,-832.0493;Inherit;False;241;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;272;725.7976,-1021.513;Inherit;True;Property;_TextureSample6;Texture Sample 6;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;173;646.015,-656.0242;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;240;-1261.299,-772.5593;Inherit;False;V00947416;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;241;-1229.299,-603.5587;Inherit;False;V0118318;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;140;-1626.677,-1260.713;Inherit;True;Property;_Mask;Mask;20;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;183;-424.4732,-1385.934;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;527.6447,-982.168;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-601.1846,-1015.049;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1860.526,438.8223;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;1964.633,-1200.521;Inherit;False;240;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;492.2231,-1395.879;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1967.848,559.3543;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1823.466,188.2433;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;808.0057,-831.5623;Inherit;False;242;V0147761;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;366;-1644.318,-1640.784;Inherit;True;Global;_ReflectionTex;ReflectionTex;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;266;-281.9575,-1406.362;Inherit;True;Property;_TextureSample0;Texture Sample 0;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;201;-198.4732,-1185.934;Inherit;False;240;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;2181.896,-651.4993;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;167;-1637.582,-471.2963;Inherit;False;Constant;_Vector3;Vector3;8;0;Create;True;0;0;False;0;False;0.147761,0.147761,0.147761,0.147761;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;390;-167.2449,273.3503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;154;1919.374,-501.6213;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;260.3488,-82.15485;Inherit;False;219;rightDown;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;1565.272,-1383.127;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;1560.712,-1281.931;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;283.9073,-596.7066;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0947416,0.0947416,0.0947416,0.09411765;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;234;253.3879,-279.6275;Inherit;False;226;rightUp;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;226;2347.273,-1320.127;Inherit;False;rightUp;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;1179.223,-1304.879;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;269;1886.798,-1039.513;Inherit;True;Property;_TextureSample3;Texture Sample 3;24;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;229;262.3488,-182.1549;Inherit;False;218;up;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;-121.6512,-92.15486;Inherit;False;222;leftDown;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;1750.777,-675.4705;Inherit;False;153;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;274;-27.20239,-679.5129;Inherit;True;Property;_TextureSample8;Texture Sample 8;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;1219.646,-953.1684;Inherit;False;Middle;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;-119.3118,-285.3702;Inherit;False;220;leftUp;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;235;530.343,-273.1443;Inherit;False;9;9;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;170;-305.8882,-552.3096;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;1320.223,-1311.879;Inherit;False;up;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-1655.079,-1390.711;Inherit;False;Property;_Blur;Blur;21;0;Create;True;0;0;False;0;False;0;8.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;176;582.6625,-1290.683;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;270;2307.798,-679.5129;Inherit;True;Property;_TextureSample4;Texture Sample 4;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;228;71.34885,-191.1549;Inherit;False;221;Middle;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-119.6512,-189.1549;Inherit;False;223;left;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-610.093,-497.7065;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;155.8154,-941.0493;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0947416,0.0947416,0.0947416,0.09411765;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;-605.1848,-840.0494;Inherit;False;145;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;22.52678,-1309.934;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0947416,0.0947416,0.0947416,0.09411765;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1857.226,320.1223;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;2208.272,-1320.127;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;267;866.4536,-1418.685;Inherit;True;Property;_TextureSample1;Texture Sample 1;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;286.8153,-940.0493;Inherit;False;left;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;2206.444,-977.0994;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;2409.139,-484.8641;Inherit;False;241;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;928.6629,-1209.683;Inherit;False;241;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;2762.778,-613.4705;Inherit;False;rightDown;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;192;1968.805,-837.4933;Inherit;False;241;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;1160.376,-482.4181;Inherit;False;241;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;2619.777,-609.4705;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;273;-156.2024,-1032.513;Inherit;True;Property;_TextureSample7;Texture Sample 7;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;366;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;202;78.90716,-479.7065;Inherit;False;240;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1882.265,90.7433;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;2054.152,-581.9543;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-1046.6,-1237.773;Inherit;False;Offset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;174;1645.819,-896.5833;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;659.3999,58.29999;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_PlanarReflection;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;8;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;True;True;True;True;0;False;-1;False;1;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;True;5;10;True;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.01;1,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0.01;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;264;0;45;49
WireConnection;392;0;265;0
WireConnection;392;1;391;0
WireConnection;263;0;392;0
WireConnection;256;0;249;1
WireConnection;256;1;249;2
WireConnection;389;0;281;0
WireConnection;257;0;263;0
WireConnection;257;1;256;0
WireConnection;278;0;277;3
WireConnection;278;1;277;4
WireConnection;254;0;257;0
WireConnection;279;0;278;0
WireConnection;283;0;389;0
WireConnection;153;0;254;0
WireConnection;293;0;290;0
WireConnection;293;1;291;0
WireConnection;293;2;292;0
WireConnection;300;0;297;0
WireConnection;300;1;298;0
WireConnection;300;2;299;0
WireConnection;336;0;333;0
WireConnection;336;1;334;0
WireConnection;336;2;335;0
WireConnection;314;0;311;0
WireConnection;314;1;312;0
WireConnection;314;2;313;0
WireConnection;322;0;319;0
WireConnection;322;1;320;0
WireConnection;322;2;321;0
WireConnection;307;0;304;0
WireConnection;307;1;305;0
WireConnection;307;2;306;0
WireConnection;285;0;280;0
WireConnection;285;1;284;0
WireConnection;285;2;286;0
WireConnection;328;0;325;0
WireConnection;328;1;326;0
WireConnection;328;2;327;0
WireConnection;295;0;294;0
WireConnection;295;1;293;0
WireConnection;330;0;329;0
WireConnection;330;1;328;0
WireConnection;302;0;301;0
WireConnection;302;1;300;0
WireConnection;324;0;323;0
WireConnection;324;1;322;0
WireConnection;316;0;315;0
WireConnection;316;1;314;0
WireConnection;309;0;308;0
WireConnection;309;1;307;0
WireConnection;338;0;337;0
WireConnection;338;1;336;0
WireConnection;287;0;276;0
WireConnection;287;1;285;0
WireConnection;331;0;330;0
WireConnection;289;0;287;0
WireConnection;310;0;309;0
WireConnection;318;0;324;0
WireConnection;332;0;338;0
WireConnection;317;0;316;0
WireConnection;296;0;295;0
WireConnection;303;0;302;0
WireConnection;382;1;381;0
WireConnection;372;1;371;0
WireConnection;380;1;379;0
WireConnection;368;1;367;0
WireConnection;370;1;369;0
WireConnection;374;1;373;0
WireConnection;378;1;377;0
WireConnection;384;1;383;0
WireConnection;376;1;375;0
WireConnection;385;0;368;0
WireConnection;385;1;370;0
WireConnection;385;2;372;0
WireConnection;385;3;374;0
WireConnection;385;4;376;0
WireConnection;385;5;378;0
WireConnection;385;6;380;0
WireConnection;385;7;382;0
WireConnection;385;8;384;0
WireConnection;386;0;385;0
WireConnection;386;1;387;0
WireConnection;393;0;386;0
WireConnection;393;1;394;0
WireConnection;388;0;393;0
WireConnection;220;0;216;0
WireConnection;225;0;217;0
WireConnection;211;0;272;0
WireConnection;211;1;198;0
WireConnection;190;0;169;0
WireConnection;190;1;170;0
WireConnection;180;1;155;0
WireConnection;157;0;149;0
WireConnection;224;0;214;0
WireConnection;187;0;175;0
WireConnection;187;1;174;0
WireConnection;141;1;139;0
WireConnection;141;2;140;1
WireConnection;236;0;235;0
WireConnection;182;0;173;0
WireConnection;182;1;180;0
WireConnection;139;0;138;0
WireConnection;268;1;188;0
WireConnection;217;0;271;0
WireConnection;217;1;200;0
WireConnection;188;0;178;0
WireConnection;188;1;177;0
WireConnection;242;0;167;0
WireConnection;189;0;164;0
WireConnection;189;1;181;0
WireConnection;181;0;156;0
WireConnection;186;0;179;0
WireConnection;186;1;176;0
WireConnection;271;1;182;0
WireConnection;222;0;210;0
WireConnection;272;1;184;0
WireConnection;240;0;165;0
WireConnection;241;0;166;0
WireConnection;183;0;238;0
WireConnection;183;1;239;0
WireConnection;266;1;183;0
WireConnection;185;0;168;0
WireConnection;185;1;172;0
WireConnection;390;0;45;50
WireConnection;390;1;275;0
WireConnection;154;0;148;0
WireConnection;210;0;274;0
WireConnection;210;1;202;0
WireConnection;226;0;213;0
WireConnection;212;0;267;0
WireConnection;212;1;205;0
WireConnection;269;1;187;0
WireConnection;274;1;190;0
WireConnection;221;0;211;0
WireConnection;235;0;237;0
WireConnection;235;1;233;0
WireConnection;235;2;234;0
WireConnection;235;3;227;0
WireConnection;235;4;228;0
WireConnection;235;5;229;0
WireConnection;235;6;230;0
WireConnection;235;7;231;0
WireConnection;235;8;232;0
WireConnection;170;0;157;0
WireConnection;170;1;161;0
WireConnection;218;0;212;0
WireConnection;176;1;160;0
WireConnection;270;1;185;0
WireConnection;215;0;273;0
WireConnection;215;1;194;0
WireConnection;216;0;266;0
WireConnection;216;1;201;0
WireConnection;213;0;268;0
WireConnection;213;1;203;0
WireConnection;267;1;186;0
WireConnection;223;0;215;0
WireConnection;214;0;269;0
WireConnection;214;1;192;0
WireConnection;219;0;209;0
WireConnection;209;0;270;0
WireConnection;209;1;207;0
WireConnection;273;1;189;0
WireConnection;172;0;159;0
WireConnection;172;1;154;0
WireConnection;145;0;141;0
WireConnection;174;0;162;0
WireConnection;0;0;45;0
WireConnection;0;1;45;49
WireConnection;0;2;390;0
WireConnection;0;3;45;51
WireConnection;0;4;45;52
WireConnection;0;5;45;53
WireConnection;0;9;45;43
WireConnection;0;10;45;43
ASEEND*/
//CHKSM=EB97E9984FB9A364CA75064EF336E66DA0575D13