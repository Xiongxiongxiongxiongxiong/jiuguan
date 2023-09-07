using System;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Rendering;

namespace Renderering.Sky
{
    public static class SkyDataManager
    {
        public static BindableProperty<float> SkyRotate = new BindableProperty<float>() { Value = 0 };
        private static void SetSkyRotate(float rotate)
        {
            if (SkyTimeController.Instance)
            {
                SkyTimeController.Instance.SetLongitude(rotate);
            }
        }

        public static BindableProperty<Transform> FollowTarget = new BindableProperty<Transform>() { Value = null };
        private static void SetFollowTarget(Transform t)
        {
            if(SkyTimeController.Instance)
                SkyTimeController.Instance.SetFollowTarget(t);
        }

        #region Time

        public static BindableProperty<float> CurrentTime = new BindableProperty<float>() { Value = 0.0f };
        private static float _dayTime, _nightTime;
        private static bool _day = false;
        private static bool _night = true;
        private static UnityEvent _onDay, _onNight;
        
        public static void SetDayTimeNightTime(float dayTime, float nightTime)
        {
            _dayTime = dayTime;
            _nightTime = nightTime;
        }

        public static void SetDayEvent(UnityEvent action)
        {
            _onDay = action;
        }

        public static void SetNightEvent(UnityEvent action)
        {
            _onNight = action;
        }

        public static void DeleteDayEvent()
        {
            _onDay = null;
        }

        public static void DeleteNightEvent()
        {
            _onNight = null;
        }

        private static void SetCurrentTime(float time)
        {
            if (!SkyTimeController.Instance) return;
            float remapTime = 0;
            if (time > _dayTime && time < _nightTime && !_day && _night)
            {
                Debug.Log("OnDay");
                _day = true;
                _night = false;
                _onDay?.Invoke();
            }
            else if ((time > _nightTime || time < _dayTime) && _day && !_night)
            {
                Debug.Log("OnNight");
                _day = false;
                _night = true;
                _onNight?.Invoke();
            }

            if (time >= _dayTime && time <= _nightTime)
            {
                remapTime = ReMapNumber(time, _dayTime, _nightTime, 6, 18);
            }
            else
            {
                if (time >= 0 && time < _dayTime)
                {
                    remapTime = ReMapNumber(time, 0, _dayTime, 0, 6);
                }
                else if (time <= 24 && time >= _nightTime)
                {
                    remapTime = ReMapNumber(time, _nightTime, 24, 18, 24);
                }
            }

            SkyTimeController.Instance.SetTimeline(remapTime);
        }
        
        #endregion
        
        #region Environment

        public static BindableProperty<float> SunSize = new BindableProperty<float>() { Value = 1.5f };
        public static BindableProperty<float> SunTextureIntensity = new BindableProperty<float>() { Value = 1.0f };
        public static BindableProperty<float> MoonSize = new BindableProperty<float>() { Value = 10.0f };
        public static BindableProperty<float> MoonTextureIntensity = new BindableProperty<float>() { Value = 10.0f };
        public static BindableProperty<float> DirectionLightIntensity = new BindableProperty<float>() { Value = 1.0f };
        public static BindableProperty<float> StarIntensity = new BindableProperty<float>() { Value = -1.0f };
        public static BindableProperty<Color> DirectionLightColor = new BindableProperty<Color>() { Value = Color.clear };
        private static ReflectionProbe _reflectionProbe;
        public static BindableProperty<ReflectionProbeRefreshMode> ReflectionRefreshMode = new BindableProperty<ReflectionProbeRefreshMode>() { Value = ReflectionProbeRefreshMode.OnAwake };
        public static BindableProperty<ReflectionProbeTimeSlicingMode> ReflectionTimeSlicingMode = new BindableProperty<ReflectionProbeTimeSlicingMode>() { Value = ReflectionProbeTimeSlicingMode.NoTimeSlicing };
        public static BindableProperty<float> ReflectionIntensity = new BindableProperty<float>() { Value = 1.0f };
        public static BindableProperty<float> EnvironmentIntensity = new BindableProperty<float>() { Value = 1.0f };
        public static BindableProperty<AmbientMode> AmbientMode = new BindableProperty<AmbientMode>();
        public static BindableProperty<Color> SkyColor = new BindableProperty<Color>() { Value = Color.clear };
        public static BindableProperty<Color> EquatorColor = new BindableProperty<Color>() { Value = Color.clear };
        public static BindableProperty<Color> GroundColor = new BindableProperty<Color>() { Value = Color.clear };
        
        private static void SetSunSize(float size)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.sunTextureSize = size;
        }
        private static void SetSunTextureIntensity(float intensity)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.sunTextureIntensity = intensity;
        }
        private static void SetMoonSize(float size)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.moonTextureSize = size;
        }
        private static void SetMoonTextureIntensity(float intensity)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.moonTextureIntensity = intensity;
        }
        private static void SetDirectionLightColor(Color color)
        {
            if (SkyTimeController.Instance)
                SkyTimeController.Instance.SetDirectionalLightColor(color);
        }
        private static void SetDirectionLightIntensity(float intensity)
        {
            if (SkyTimeController.Instance)
                SkyTimeController.Instance.SetDirectionalLightIntensity(intensity);
        }
        private static void SetReflectionProbe(ReflectionProbe reflectionProbe)
        {
            _reflectionProbe = reflectionProbe;
        }
        private static void SetReflectionRefreshMode(ReflectionProbeRefreshMode mode)
        {
            if (!_reflectionProbe) return;
            _reflectionProbe.refreshMode = mode;
            if (_reflectionProbe.refreshMode == ReflectionProbeRefreshMode.ViaScripting)
            {
                _reflectionProbe.RenderProbe();
                DynamicGI.UpdateEnvironment();
            }
        }
        private static void SetReflectionTimeSlicingMode(ReflectionProbeTimeSlicingMode timeSlicingMode)
        {
            if(_reflectionProbe)
                _reflectionProbe.timeSlicingMode = timeSlicingMode;
        }
        private static void SetReflectionIntensity(float reflectionIntensity)
        {
            if(_reflectionProbe)
                _reflectionProbe.intensity = reflectionIntensity;
        }
        
        private static void SetEnvironmentIntensity(float intensity)
        {
            RenderSettings.ambientIntensity = intensity;
        }

        private static void SetAmbientMode(AmbientMode mode)
        {
            RenderSettings.ambientMode = mode;
        }
        private static void SetSkyColor(Color color)
        {
            RenderSettings.ambientSkyColor = color;
        }
        private static void SetEquatorColor(Color color)
        {
            RenderSettings.ambientEquatorColor = color;
        }
        private static void SetGroundColor(Color color)
        {
            RenderSettings.ambientGroundColor = color;
        }

        #endregion

        #region Sky

        private static void SetStarIntensity(float intensity)
        {
            if (SkyRenderController.Instance)
            {
                SkyRenderController.Instance.starsIntensity = intensity;
                SkyRenderController.Instance.milkyWayIntensity = intensity * 2;
            }
        }
        public static Vector4 CloudTiling
        {
            set
            {
                SetCloudsTiling(value);
            }
        }
        public static BindableProperty<float> CloudAltitude = new BindableProperty<float>() { Value = 7.5f };
        public static BindableProperty<float> CloudDirection = new BindableProperty<float>() { Value = 0.0f };
        public static BindableProperty<float> CloudSpeed = new BindableProperty<float>() { Value = 0.1f };
        public static float CloudDensity
        {
            set
            {
                SetCloudsDensity(value);
            }
        }
        public static BindableProperty<float> CloudIntensity = new BindableProperty<float>() { Value = 0.0f };
        public static BindableProperty<Color> CloudColor1 = new BindableProperty<Color>() { Value = Color.clear };
        public static BindableProperty<Color> CloudColor2 = new BindableProperty<Color>() { Value = Color.clear };
        public static BindableProperty<Color> MieColor = new BindableProperty<Color>() { Value = Color.clear };
        
        private static void SetCloudsTiling(Vector4 t)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.SetCloudTiling(t);
        }
        private static void SetCloudsAltitude(float altitude)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.dynamicCloudsAltitude = altitude;
        }
        private static void SetCloudsDirection(float intensity)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.dynamicCloudsDirection = intensity;
        }
        private static void SetCloudsSpeed(float speed)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.dynamicCloudsSpeed = speed;
        }
        private static void SetCloudsDensity(float density)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.dynamicCloudsDensity = density;
        }
        private static void SetCloudsIntensity(float intensity)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.SetCloudIntensity(intensity);
        }
        private static void SetCloudsColor1(Color color1)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.dynamicCloudsColor1 = color1;
        }
        private static void SetCloudsColor2(Color color2)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.dynamicCloudsColor2 = color2;
        }
        private static void SetMieColor(Color color)
        {
            if (SkyRenderController.Instance)
                SkyRenderController.Instance.mieColor = color;
        }

        #endregion

        #region Aurora

        public static BindableProperty<float> AuroraIntensity = new BindableProperty<float>() { Value = 1 };
        public static BindableProperty<float> AuroraBrightness = new BindableProperty<float>() { Value = 10 };
        public static BindableProperty<float> AuroraContrast = new BindableProperty<float>() { Value = 10 };
        public static BindableProperty<float> AuroraSpeed = new BindableProperty<float>() { Value = 0.005f };

        private static void SetAuroraIntensity(float value)
        {
            SkyRenderController.Instance.SetAuroraIntensity(value);
        }
        private static void SetAuroraBrightness(float value)
        {
            SkyRenderController.Instance.SetAuroraBrightness(value);
        }
        private static void SetAuroraContrast(float value)
        {
            SkyRenderController.Instance.SetAuroraContrast(value);
        }
        private static void SetAuroraSpeed(float value)
        {
            SkyRenderController.Instance.SetAuroraSpeed(value);
        }

        #endregion

        private static float ReMapNumber(float oXY, float oMin, float oMax, float nMin, float nMax)
        {
            float result = 0;
            result = (nMax - nMin) / (oMax - oMin) * (oXY - oMin) + nMin;
            return result;
        }

        public static void Init(float time, ReflectionProbe reflectionProbe)
        {
            if (time >= _dayTime && time <= _nightTime)
            {
                _day = true;
                _night = false;
            }
            else
            {
                _day = false;
                _night = true;
            }
            SkyRotate.RegisterOnValueChanged(SetSkyRotate);
            FollowTarget.RegisterOnValueChanged(SetFollowTarget);

            CurrentTime.RegisterOnValueChanged(SetCurrentTime);

            SunSize.RegisterOnValueChanged(SetSunSize);
            SunTextureIntensity.RegisterOnValueChanged(SetSunTextureIntensity);
            MoonSize.RegisterOnValueChanged(SetMoonSize);
            MoonTextureIntensity.RegisterOnValueChanged(SetMoonTextureIntensity);
            DirectionLightIntensity.RegisterOnValueChanged(SetDirectionLightIntensity);
            DirectionLightColor.RegisterOnValueChanged(SetDirectionLightColor);
            SetReflectionProbe(reflectionProbe);
            ReflectionRefreshMode.RegisterOnValueChanged(SetReflectionRefreshMode);
            ReflectionTimeSlicingMode.RegisterOnValueChanged(SetReflectionTimeSlicingMode);
            ReflectionIntensity.RegisterOnValueChanged(SetReflectionIntensity);
            EnvironmentIntensity.RegisterOnValueChanged(SetEnvironmentIntensity);
            AmbientMode.RegisterOnValueChanged(SetAmbientMode);
            SkyColor.RegisterOnValueChanged(SetSkyColor);
            EquatorColor.RegisterOnValueChanged(SetEquatorColor);
            GroundColor.RegisterOnValueChanged(SetGroundColor);
            StarIntensity.RegisterOnValueChanged(SetStarIntensity);
            
            CloudAltitude.RegisterOnValueChanged(SetCloudsAltitude);
            CloudDirection.RegisterOnValueChanged(SetCloudsDirection);
            CloudSpeed.RegisterOnValueChanged(SetCloudsSpeed);
            CloudIntensity.RegisterOnValueChanged(SetCloudsIntensity);
            CloudColor1.RegisterOnValueChanged(SetCloudsColor1);
            CloudColor2.RegisterOnValueChanged(SetCloudsColor2);
            MieColor.RegisterOnValueChanged(SetMieColor);
            
            AuroraIntensity.RegisterOnValueChanged(SetAuroraIntensity);
            AuroraBrightness.RegisterOnValueChanged(SetAuroraBrightness);
            AuroraContrast.RegisterOnValueChanged(SetAuroraContrast);
            AuroraSpeed.RegisterOnValueChanged(SetAuroraSpeed);
        }

        public static void OnDisable()
        {
            SkyRotate.UnRegisterOnValueChanged(SetSkyRotate);
            FollowTarget.UnRegisterOnValueChanged(SetFollowTarget);
            CurrentTime.UnRegisterOnValueChanged(SetCurrentTime);

            SunSize.UnRegisterOnValueChanged(SetSunSize);
            SunTextureIntensity.UnRegisterOnValueChanged(SetSunTextureIntensity);
            MoonSize.UnRegisterOnValueChanged(SetMoonSize);
            MoonTextureIntensity.UnRegisterOnValueChanged(SetMoonTextureIntensity);
            DirectionLightIntensity.UnRegisterOnValueChanged(SetDirectionLightIntensity);
            DirectionLightColor.UnRegisterOnValueChanged(SetDirectionLightColor);
            ReflectionRefreshMode.UnRegisterOnValueChanged(SetReflectionRefreshMode);
            ReflectionTimeSlicingMode.UnRegisterOnValueChanged(SetReflectionTimeSlicingMode);
            ReflectionIntensity.UnRegisterOnValueChanged(SetReflectionIntensity);
            EnvironmentIntensity.UnRegisterOnValueChanged(SetEnvironmentIntensity);
            AmbientMode.UnRegisterOnValueChanged(SetAmbientMode);
            SkyColor.UnRegisterOnValueChanged(SetSkyColor);
            EquatorColor.UnRegisterOnValueChanged(SetEquatorColor);
            GroundColor.UnRegisterOnValueChanged(SetGroundColor);            
            StarIntensity.UnRegisterOnValueChanged(SetStarIntensity);

            CloudAltitude.UnRegisterOnValueChanged(SetCloudsAltitude);
            CloudDirection.UnRegisterOnValueChanged(SetCloudsDirection);
            CloudSpeed.UnRegisterOnValueChanged(SetCloudsSpeed);
            CloudIntensity.UnRegisterOnValueChanged(SetCloudsIntensity);
            CloudColor1.UnRegisterOnValueChanged(SetCloudsColor1);
            CloudColor2.UnRegisterOnValueChanged(SetCloudsColor2);
            MieColor.UnRegisterOnValueChanged(SetMieColor);
            
            AuroraIntensity.UnRegisterOnValueChanged(SetAuroraIntensity);
            AuroraBrightness.UnRegisterOnValueChanged(SetAuroraBrightness);
            AuroraContrast.UnRegisterOnValueChanged(SetAuroraContrast);
            AuroraSpeed.UnRegisterOnValueChanged(SetAuroraSpeed);
        }
    }
}