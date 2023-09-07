// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Plant"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering)]_CullMode("CullMode", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_Src("Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_Dst("Dst", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_DepthTest("DepthTest", Float) = 4
		[Toggle]_DepthWrite("DepthWrite", Float) = 1
		_DepthOffset("DepthOffset", Float) = 0
		_Cutout("Cutout", Range( 0 , 1)) = 0.5
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
		_Hue2("色相", Range( -1 , 1)) = 0
		_Saturation2("饱和度", Range( 0 , 5)) = 1
		_Contrast2("对比度", Range( 0 , 5)) = 1
		[Header(SSS)]_SatterColor("SatterColor", Color) = (0.1872,0.48,0.19696,1)
		_ThicknessMap("ThicknessMap", 2D) = "white" {}
		_BasePassPower("BasePassPower", Float) = 1
		_BasePassScale("BasePassScale", Float) = 2
		[Header(Wind)]_Scale("Scale:Width Height", Vector) = (2,5,0,0)
		_Flex("Flex:Stem Branch Leaf", Vector) = (0.1,1,3,0)
		_Frequency("Frequency:Stem Branch Leaf", Vector) = (0.25,2,3,0)
		_WindParams("XYZ:WindDir  W:WindMain", Vector) = (0.3,0,1,0.35)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TreeTransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float2 _Scale;
		uniform float3 _Flex;
		uniform float3 _Frequency;
		uniform float4 _WindParams;
		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _Hue2;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _Saturation2;
		uniform float _Contrast2;
		uniform float _BasePassPower;
		uniform float _BasePassScale;
		uniform sampler2D _ThicknessMap;
		uniform float4 _ThicknessMap_ST;
		uniform float4 _SatterColor;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform float _Cutout;


		float3 GeneralWind23_g80( float3 positionOS , float2 widthHeight , float3 i_flex , float3 frequency , float4 windParams )
		{
			float3 worldOffset = float3(unity_ObjectToWorld._m03,unity_ObjectToWorld._m13,unity_ObjectToWorld._m23); 
			float3 nrmObjDistVector = (worldOffset - _WorldSpaceCameraPos) / 1000;
			float nrmSqrdDist = 1 - saturate(dot(nrmObjDistVector,nrmObjDistVector));
			nrmSqrdDist *= nrmSqrdDist;
			if(nrmSqrdDist > 0.0f)
			{
				float3 windDir = windParams.xyz;
				float windMain = windParams.w;
				float3 flex = i_flex * float3(saturate(windMain * 3),saturate(windMain * 2),1-windMain * windMain * 0.5) * windMain * nrmSqrdDist;
				float3 up = float3(0,1,0);
				float3 zScaleRotVec = mul((float3x3)unity_ObjectToWorld,up);
				float3 zScaleRotVecNrm = normalize(zScaleRotVec);
				float xDot = max(dot(zScaleRotVec,zScaleRotVecNrm),0.4f);
				float upDot = saturate(dot(zScaleRotVecNrm,up));
				widthHeight.xy = lerp(widthHeight.yy * float2(2,2),widthHeight.xy,upDot*upDot) * xDot;
				flex *= xDot;
				frequency *= xDot;
				float3 localWorldPos = mul((float3x3)unity_ObjectToWorld,positionOS.xyz);
				float3 normLocalWorldPos = localWorldPos / float3(widthHeight.x,widthHeight.y,widthHeight.x);
				float stemheight = normLocalWorldPos.y; 
				float lengthA = dot(localWorldPos,localWorldPos);
				float gust = ((sin(dot(frequency.xxx,worldOffset)) * 0.3 + windMain * 0.5) + (_SinTime.y * 0.4 + windMain) * windMain) * (_SinTime.w * 0.3 + 0.7);
				float3 flexTally = 0;
				flexTally.xz = windDir.xz * (stemheight * stemheight * gust * flex.x);
				float3 vertOffset = localWorldPos + flexTally;
				float flexNorm =  saturate(lengthA/dot(vertOffset,vertOffset));
				flexTally = vertOffset * flexNorm; 
				float3 localWorldPosOffset = flexTally - localWorldPos;
				return mul((float3x3)unity_WorldToObject,localWorldPosOffset.xyz);
			}
			return 0;
		}


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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 positionOS23_g80 = ase_vertex3Pos;
			float2 widthHeight23_g80 = _Scale;
			float3 i_flex23_g80 = _Flex;
			float3 frequency23_g80 = _Frequency;
			float4 windParams23_g80 = _WindParams;
			float3 localGeneralWind23_g80 = GeneralWind23_g80( positionOS23_g80 , widthHeight23_g80 , i_flex23_g80 , frequency23_g80 , windParams23_g80 );
			v.vertex.xyz += localGeneralWind23_g80;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode31_g78 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 NormalMap32_g78 = tex2DNode31_g78;
			float3 temp_output_113_49 = NormalMap32_g78;
			o.Normal = temp_output_113_49;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g78 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g78 = ( (_MainColor).rgb * (tex2DNode35_g78).rgb );
			float3 hsvTorgb2_g82 = RGBToHSV( Albedo40_g78 );
			float3 hsvTorgb8_g82 = HSVToRGB( float3(( _Hue2 + hsvTorgb2_g82.x ),( hsvTorgb2_g82.y * _Saturation2 ),( hsvTorgb2_g82.z * _Contrast2 )) );
			float3 Albedo29_g79 = hsvTorgb8_g82;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 NormalWS32_g79 = normalize( (WorldNormalVector( i , temp_output_113_49 )) );
			float3 normalizeResult54_g79 = normalize( ( ase_worldlightDir + NormalWS32_g79 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult70_g79 = dot( -normalizeResult54_g79 , ase_worldViewDir );
			float2 uv_ThicknessMap = i.uv_texcoord * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
			float3 appendResult68_g79 = (float3(_SatterColor.r , _SatterColor.g , _SatterColor.b));
			o.Albedo = ( Albedo29_g79 + ( ( max( pow( max( dotResult70_g79 , 0.0 ) , _BasePassPower ) , 0.0 ) * _BasePassScale ) * tex2D( _ThicknessMap, uv_ThicknessMap ).r * appendResult68_g79 ) );
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 tex2DNode13_g78 = tex2D( _EmissionMap, uv_EmissionMap );
			float4 Emission18_g78 = ( _EmissionColor * tex2DNode13_g78 );
			o.Emission = Emission18_g78.rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g78 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g78 = ( tex2DNode7_g78.r * _Metallic );
			o.Metallic = Metallic19_g78;
			float Smoothness16_g78 = ( tex2DNode7_g78.g * _Smoothness );
			o.Smoothness = Smoothness16_g78;
			float AO14_g78 = ( tex2DNode7_g78.b * _AO );
			o.Occlusion = AO14_g78;
			o.Alpha = 1;
			float Alpha38_g78 = ( _MainColor.a * tex2DNode35_g78.a );
			clip( Alpha38_g78 - _Cutout );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
209;217;2170;1079;1690.472;909.4334;1.391565;True;True
Node;AmplifyShaderEditor.FunctionNode;113;-697.993,264.5161;Inherit;False;TreePBR;7;;78;e6c6ac04646782a4d900a8f5a1bd4715;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.CommentaryNode;8;-998.968,-667.5902;Inherit;False;352;765.6652;Rendering;7;1;2;3;4;5;6;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;124;-296.1235,28.48136;Inherit;False;HueSaturateValue;19;;82;7d143dd0dcaf6524386bf88da977cb14;0;1;9;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-845.245,-420.457;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-844.245,-516.9569;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-847.605,-617.5902;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-849.446,-321.957;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-853.3459,-223.157;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-854.646,-120.4569;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-948.968,-16.92505;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;108;216.7585,377.5934;Inherit;False;WindVertex;30;;80;6ee50fa8fc8815e429f8e9f8c05e0901;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;107;36.64028,9.01245;Inherit;False;SSS;23;;79;9bc0a6fa46f0ab6458795347ac482880;0;2;18;FLOAT3;0,0,0;False;19;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;553.3951,-24.48434;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Plant;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;5;0;True;4;True;0;True;1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TreeTransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;True;6;10;True;3;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;2;-1;0;True;7;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;124;9;113;0
WireConnection;107;18;124;0
WireConnection;107;19;113;49
WireConnection;0;0;107;0
WireConnection;0;1;113;49
WireConnection;0;2;113;50
WireConnection;0;3;113;51
WireConnection;0;4;113;52
WireConnection;0;5;113;53
WireConnection;0;10;113;43
WireConnection;0;11;108;0
ASEEND*/
//CHKSM=EB6625DC995EA10760FF27B7CF3CBD573C0D27C2