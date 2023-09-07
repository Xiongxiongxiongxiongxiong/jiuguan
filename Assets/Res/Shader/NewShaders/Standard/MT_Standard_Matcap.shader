// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_MatCap"
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
		[Header(MatCap)]_MatCapTex("MatCapTex", 2D) = "black" {}
		_Hue("色相", Range( -1 , 1)) = 0
		_Saturation("饱和度", Range( 0 , 5)) = 1
		_Contrast("对比度", Range( 0 , 5)) = 1
		[Toggle(_USENORMALMAP_ON)] _UseNormalMap("UseNormalMap", Float) = 0
		_NormalEffect("NormalEffect", Range( 0 , 1)) = 1
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
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _USENORMALMAP_ON
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
		uniform float _Hue;
		uniform sampler2D _MatCapTex;
		uniform float _NormalEffect;
		uniform float _Saturation;
		uniform float _Contrast;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform float _Cutout;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

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
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 appendResult84 = (float4(ase_vertex3Pos , 1.0));
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 NormalTS101 = temp_output_45_49;
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float4 ase_vertexTangent = mul( unity_WorldToObject, float4( ase_worldTangent, 0 ) );
			float3 lerpResult113 = lerp( ase_vertexNormal , mul( NormalTS101, float3x3(cross( ase_vertexNormal , ase_vertexTangent.xyz ), ase_vertexTangent.xyz, ase_vertexNormal) ) , _NormalEffect);
			#ifdef _USENORMALMAP_ON
				float3 staticSwitch76 = lerpResult113;
			#else
				float3 staticSwitch76 = ase_vertexNormal;
			#endif
			float3 NormalOS104 = staticSwitch76;
			float4 appendResult89 = (float4(NormalOS104 , 1.0));
			float3 normalizeResult96 = normalize( reflect( (mul( UNITY_MATRIX_V, mul( unity_ObjectToWorld, appendResult84 ) )).xyz , (mul( UNITY_MATRIX_IT_MV, appendResult89 )).xyz ) );
			float4 tex2DNode100 = tex2D( _MatCapTex, ( ( (normalizeResult96).xy * float2( 0.5,0.5 ) ) + float2( 0.5,0.5 ) ) );
			float3 hsvTorgb120 = RGBToHSV( tex2DNode100.rgb );
			float3 hsvTorgb134 = HSVToRGB( float3(( _Hue + hsvTorgb120.x ),( hsvTorgb120.y * _Saturation ),( hsvTorgb120.z * _Contrast )) );
			float3 MatCap106 = hsvTorgb134;
			o.Emission = ( Emission18_g7 + float4( MatCap106 , 0.0 ) ).rgb;
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
390;184;2170;1085;-553.8194;-579.0816;1.120893;True;True
Node;AmplifyShaderEditor.CommentaryNode;103;-2440.532,1041.116;Inherit;False;1600.115;595.111;Normal;11;104;76;77;53;102;52;58;57;60;111;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TangentVertexDataNode;57;-2429.039,1291.275;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;45;1495.505,121.9426;Inherit;False;PBR;7;;7;1bdad994f2fe8074b907eff23b7831db;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.NormalVertexDataNode;58;-2421.133,1444.514;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CrossProductOpNode;60;-2186.052,1270.237;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;1756.508,21.7306;Inherit;False;NormalTS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MatrixFromVectors;52;-1996.193,1395.658;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-2193.301,1152.29;Inherit;False;101;NormalTS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;77;-1794.429,1100.116;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;111;-1769.677,1505.406;Inherit;False;Property;_NormalEffect;NormalEffect;25;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1734.84,1287.548;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,0,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;113;-1522.944,1295.913;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;76;-1369.139,1176.438;Inherit;False;Property;_UseNormalMap;UseNormalMap;24;0;Create;True;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1058.011,1262.477;Inherit;False;NormalOS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;83;-436.7271,860.0632;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;85;-216.7271,783.0634;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;84;-161.7271,861.0632;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-377.2073,1110.891;Inherit;False;104;NormalOS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;88;-8.72718,686.0637;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.InverseTranspMVMatrixNode;90;-242.7272,976.0632;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-108.7272,1108.063;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-0.7271762,827.0632;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;103.2727,1029.063;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;167.2728,826.0632;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;94;293.2729,1111.063;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;93;318.2729,934.0632;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;95;551.2728,1001.063;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;96;723.2728,1001.063;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;97;896.2729,997.0633;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;1117.273,1038.063;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;1273.273,1082.064;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;100;1428.273,1059.063;Inherit;True;Property;_MatCapTex;MatCapTex;19;0;Create;True;0;0;False;1;Header(MatCap);False;-1;ddc3a3cd91ac8dc49bdeb43a6349e266;ddc3a3cd91ac8dc49bdeb43a6349e266;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;120;1932.411,1116.89;Inherit;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;117;1978.724,1005.787;Inherit;False;Property;_Hue;色相;21;0;Create;False;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;1942.99,1382.963;Inherit;False;Property;_Saturation;饱和度;22;0;Create;False;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;1964.097,1528.962;Inherit;False;Property;_Contrast;对比度;23;0;Create;False;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;2375.637,1465.574;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;2375.173,1095.645;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;2387.832,1342.582;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;134;2731.56,1206.913;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;3450.768,1128.709;Inherit;False;MatCap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;1555.187,391.3939;Inherit;False;106;MatCap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;1738.141,1206.612;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;109;1494.622,1294.008;Inherit;False;Property;_MatCapIntensity;MatCapIntensity;20;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1401.491,-156.9798;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1340.851,-355.1129;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1347.892,142.0201;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1335.214,279.5522;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;1836.187,370.3939;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1342.692,-59.47976;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1346.592,39.32014;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1337.491,-254.4797;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2080.3,123.3;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_MatCap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;1;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;True;5;10;True;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.01;1,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0.01;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;60;0;58;0
WireConnection;60;1;57;0
WireConnection;101;0;45;49
WireConnection;52;0;60;0
WireConnection;52;1;57;0
WireConnection;52;2;58;0
WireConnection;53;0;102;0
WireConnection;53;1;52;0
WireConnection;113;0;77;0
WireConnection;113;1;53;0
WireConnection;113;2;111;0
WireConnection;76;1;77;0
WireConnection;76;0;113;0
WireConnection;104;0;76;0
WireConnection;84;0;83;0
WireConnection;89;0;105;0
WireConnection;87;0;85;0
WireConnection;87;1;84;0
WireConnection;91;0;90;0
WireConnection;91;1;89;0
WireConnection;92;0;88;0
WireConnection;92;1;87;0
WireConnection;94;0;91;0
WireConnection;93;0;92;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;96;0;95;0
WireConnection;97;0;96;0
WireConnection;98;0;97;0
WireConnection;99;0;98;0
WireConnection;100;1;99;0
WireConnection;120;0;100;0
WireConnection;130;0;120;3
WireConnection;130;1;131;0
WireConnection;123;0;117;0
WireConnection;123;1;120;1
WireConnection;128;0;120;2
WireConnection;128;1;127;0
WireConnection;134;0;123;0
WireConnection;134;1;128;0
WireConnection;134;2;130;0
WireConnection;106;0;134;0
WireConnection;110;0;100;0
WireConnection;110;1;109;0
WireConnection;107;0;45;50
WireConnection;107;1;108;0
WireConnection;0;0;45;0
WireConnection;0;1;45;49
WireConnection;0;2;107;0
WireConnection;0;3;45;51
WireConnection;0;4;45;52
WireConnection;0;5;45;53
WireConnection;0;9;45;43
WireConnection;0;10;45;43
ASEEND*/
//CHKSM=A6C116E7FFEDFF83120B61BFD1B666430F1FA667