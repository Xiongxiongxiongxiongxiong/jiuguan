Shader "XingFei/Skybox/Skybox_HandPainted"
{
	Properties
	{
		[Header(Sky)]
		_StarAndCloudMap("星空和噪声：R:星星 G:闪星噪声 B:云噪声 A:天空颜色渐变",2D) = "black"{} 
		//_StarAndCloudChannelST("星空和噪声tiling：R:星星 G:闪星噪声 B:云噪声",Vector) = (1.0,1.0,1.0,0.0)

		[HDR]_NightSkyColDelta("天空高处颜色", Color) = (0.6, 0.75, 0.82, 0.4)
		[HDR]_NightSkyColBase("天空低处颜色", Color) = (0, 0.7, 1, 1)
		_SmoothStepSkyUp("控制天空高处颜色范围", Range(0.0, 1.0)) = 0.5
        _SmoothStepSkyDown("控制天空低处颜色范围", Range(0.0, 1.0)) = 0.4

		[HDR]_GlobalSunColor("全局太阳光颜色", Color) = (1, 1, 1, 1)
		_SunIntensity("太阳强度", Range(0, 10)) = 1
		_SunScale("太阳缩放", Range(100, 9000)) = 2000
		_SunHaloIntensity("太阳光晕强度", Range(0, 2)) = 0.5
		_SunPos("太阳Forward方向", Vector) = (-0.7, -0.6, 0.2,0.0) // 目前光源方向下，_LightDir 为 (-0.7,-0.6,0.2). 这里实际是要光源方向

		// Cloud
		[Header(Cloud)]
		_CloudDarkColor("云亮处颜色", Color) = (1,1,1,1)
        _CloudColor("云暗处颜色", Color) = (0,0,0,0)
        _CloudLightColor("云透光颜色", Color) = (1,1,1,1)
		_CloudVisible("云渐隐渐显", Range(0.0, 1.0)) = 1
		[Toggle]_CloudToggle("云和天空二极化", Float) = 0.0

		[Header(Mountains)]
		[Toggle]_DistantViewToggle("显示远景山",Float ) = 1.0
		_DistantViewMap("远景山贴图,r:纹理，g:云mask, b:云透光和山细节, a:山mask", 2D) = "white" {}
		_DistantViewLightTint("远景山亮部颜色",Color) = (1,1,1,0.0)
		_DistantViewDarkTint("远景山暗部颜色",Color) = (1,1,1,0.0)
		_DistantViewFogColor("远景山雾效",Color) = (1,1,1,0.5)
		_DistantViewTexColor("远景山纹理颜色",Color) = (1,1,1,0)
        _SmoothStepUp("山以上部分雾效", Range(0.0, 1.0)) = 0.5
        _SmoothStepDown("山以下部分雾效", Range(0.0, 1.0)) = 0.4


        [HideInInspector]_HawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.0
        [HideInInspector][HDR]_HawkEyeColor("HawkEyeColor", Color) = (1,1,1,1)
        [HideInInspector]_TimeStopHawkEyeColorRatio("HawkEyeColorRatio", Range(0.0, 1.0)) = 0.35
        [HideInInspector][HDR]_TimeStopHawkEyeColor("HawkEyeColor", Color) = (0.254902,0.3490196,0.7843138,1)
	
	}

	//---------------------------------------------------------------------------
	// SHADER_LOD_VERY_HIGH / SHADER_LOD_HIGH 

	SubShader
		{
			Tags { "RenderType" = "Background" "Queue" = "AlphaTest+45" "PreviewType" = "Skybox" }
			Cull Back
			LOD 400
			ZWrite Off
			// Offset 60000, 60000

			Pass
			{
				Name "SKYBOX_VERY_HIGH"

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "../UtilHeader.cginc"
				#include "../HawkEyeHeader.cginc"

				#pragma multi_compile _ _DISTANTVIEWTOGGLE_ON

				struct appdata
				{
					HighPrec4 vertex : POSITION;
					HighPrec2 uv : TEXCOORD0;
					HighPrec2 uv2 : TEXCOORD1;
					HighPrec2 uv3 : TEXCOORD2;
				};

				struct v2f
				{
					HighPrec4 vertex : SV_POSITION;
					HighPrec4 uv : TEXCOORD0;
					//MidPrec4 uv2 : TEXCOORD1;
					HighPrec3 localVertex : TEXCOORD2;
					// HighPrec2 cloudUV : TEXCOORD3;
					HighPrec4 worldPos : TEXCOORD4;
				};

				uniform MidPrec4 _GlobalSunColor;

				// 远景山
				LowPrec _DistantViewToggle;
				sampler2D _DistantViewMap;
				MidPrec4 _DistantViewMap_ST;
				MidPrec4 _DistantViewLightTint;
				MidPrec4 _DistantViewDarkTint;
				MidPrec4 _DistantViewFogColor;
				MidPrec4 _DistantViewTexColor;

				MidPrec _SmoothStepUp;
				MidPrec _SmoothStepDown;

				MidPrec4 _NightSkyColBase;
				MidPrec4 _NightSkyColDelta;
				MidPrec _SmoothStepSkyUp;
				MidPrec _SmoothStepSkyDown;

				MidPrec _SunIntensity;
				MidPrec _SunScale;
				MidPrec _SunHaloIntensity;

				sampler2D _StarAndCloudMap;
				MidPrec4 _StarAndCloudMap_ST;
				
				HighPrec4 _SunPos; 

				uniform MidPrec4 _CloudColor;
				uniform MidPrec4 _CloudDarkColor;
				uniform MidPrec4 _CloudLightColor;
				uniform LowPrec _CloudVisible;
				uniform LowPrec _CloudToggle;

				uniform MidPrec4 _PlayerPosition;

			// Fog
			DECLARE_DISTANCE_FOG_TEXTURE(_DistanceFogTexture);

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					//o.vertex.z = o.vertex.w - 1e-5; 这个用起来达不到想要的效果，然后通过Offset能够实现推远的效果
					o.uv.xy = v.uv.xy;
					o.uv.zw = TRANSFORM_TEX(v.uv3.xy, _DistantViewMap);
					
					o.localVertex = v.vertex.xyz;
					
					o.worldPos = mul(unity_ObjectToWorld, v.vertex); // for Hawkeye effect
					return o;
				}

				MidPrec4 frag(v2f i) : SV_Target
				{
					MidPrec4 color = 1.0;

					HighPrec3 viewDir = normalize(i.localVertex);
					HighPrec VdotL = dot(normalize(_SunPos.xyz), viewDir);

					// Sky background Color
					//MidPrec3 skyCol = tex2D(_StarAndCloudMap,i.uv.xy).aaa;
					MidPrec3 skyCol = lerp( _NightSkyColBase.rgb, _NightSkyColDelta.rgb, smoothstep(_SmoothStepSkyDown, _SmoothStepSkyUp, i.uv.y)); //test

					//Sun
					MidPrec3 sunCol =  pow( max(0.001h,-VdotL * 0.5 + 0.5) , _SunScale) * _SunIntensity;
					sunCol = (dot( sunCol,MidPrec3(1.0,1.0,1.0)) >= 2.0) ?( MidPrec3(4.0,4.0,4.0) * _GlobalSunColor.rgb ) : MidPrec3(0,0,0); //改成这样是为了减少渐变时在手机上出现色阶的问题
				
					// sky + sun
					color.rgb = skyCol + sunCol;

#ifdef _DISTANTVIEWTOGGLE_ON
					// Distant View
					MidPrec4 distantViewColor = tex2D(_DistantViewMap, i.uv.zw);

					//Cloud
					MidPrec3 cloudColor = distantViewColor.r;
					cloudColor = lerp( _CloudColor,_CloudDarkColor, distantViewColor.r);
					MidPrec lerpRatio =  distantViewColor.g * _CloudVisible;
					if(_CloudToggle > PROPERTY_ZERO)
					{
						lerpRatio = step(0.1, distantViewColor.g * _CloudVisible);
					}
					cloudColor = lerp(color.rgb, cloudColor, lerpRatio);				
					
					//mountain
					MidPrec3 mountainColor = lerp( _DistantViewDarkTint.rgb, _DistantViewLightTint.rgb, distantViewColor.r);
					mountainColor = lerp(mountainColor, _DistantViewTexColor, distantViewColor.b);
					// 提取山的边缘,将灰色边缘设置成纯黑色
					// MidPrec mountainEdge = step(0.8, 1 - distantViewColor.a) + step(1, distantViewColor.a);
					// mountainColor = lerp(_DistantViewLightTint.rgb, mountainColor, mountainEdge);

					mountainColor = lerp(_DistantViewFogColor, mountainColor, smoothstep(_SmoothStepDown, _SmoothStepUp, i.uv.y));

					color.rgb = lerp(mountainColor.rgb, cloudColor.rgb, (1 - distantViewColor.a));// 与a通道相乘，形成新的mask

#endif


			if(  _EnableHawkEye > PROPERTY_ZERO ){
                color.rgb = HawkEyeColor(color.rgb, i.worldPos.xyz);
        		return MidPrec4( color.rgb, 1 );
			}


					return color;
				}
				ENDCG
			}
		}


	//-----------------------------------------------------------------------------
	// SHADER_LOD_MEDIUM / SHADER_LOD_LOW


	SubShader
		{
			Tags { "RenderType" = "Background" "Queue" = "AlphaTest+50" "PreviewType" = "Skybox" }
			Cull Back
			LOD 300
			ZWrite Off
			// Offset 60000, 60000

			Pass
			{
				Name "SKYBOX_MEIDUM"

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "../UtilHeader.cginc"
				#include "../HawkEyeHeader.cginc"

				struct appdata
				{
					HighPrec4 vertex : POSITION;
					MidPrec2 uv : TEXCOORD0;
				};

				struct v2f
				{
					HighPrec4 vertex : SV_POSITION;
					HighPrec4 worldPos : TEXCOORD4;
					MidPrec2 uv : TEXCOORD0;
				};

				
				MidPrec4 _NightSkyColBase;
				MidPrec4 _NightSkyColDelta;
				MidPrec _SmoothStepSkyDown;
				MidPrec _SmoothStepSkyUp;
				
				uniform MidPrec4 _PlayerPosition;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv.xy = v.uv.xy;

					o.worldPos = mul(unity_ObjectToWorld, v.vertex); // for Hawkeye effect
					return o;
				}

				MidPrec4 frag(v2f i) : SV_Target
				{
					MidPrec3 color = lerp( _NightSkyColBase.rgb, _NightSkyColDelta.rgb, smoothstep(_SmoothStepSkyDown, _SmoothStepSkyUp, i.uv.y)); //test

					if(  _EnableHawkEye > PROPERTY_ZERO ){
						color.rgb = HawkEyeColor(color.rgb, i.worldPos.xyz);
        				return MidPrec4( color.rgb, 1 );
					}

					return MidPrec4(color, 1.0);
				}
				ENDCG
			}
		}

}
