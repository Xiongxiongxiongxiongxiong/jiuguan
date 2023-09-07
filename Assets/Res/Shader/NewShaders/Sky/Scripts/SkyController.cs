using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

namespace Renderering.Sky
{
    public enum CustomAmbientMode
    {
        Skybox,
        Gradient,
    }

    [ExecuteAlways]
    public class SkyController : MonoBehaviour
    {
        [SerializeField] private float skyRotate;
        [SerializeField] private Transform target;
        [Header("时间控制-----------------------------------------------------------------------")] 
        [SerializeField] private bool autoTime;
        [SerializeField] private float speed = 0.1f;
        
        [Range(0, 24)] [SerializeField] private float currentTime = 6.0f;
        
        [Header("白天开始时间")] [Range(5, 7)] [SerializeField] private float dayTime = 6.0f;
        public UnityEvent OnDay;
        [Header("夜晚开始时间")] [Range(17, 19)] [SerializeField] private float nightTime = 18.0f;
        public UnityEvent OnNight;
        private bool _day, _night;

        [Header("天空控制---------------------------------------------------------------------")]
        [SerializeField] private float sunSize = 1.5f;
        [SerializeField] private float sunTextureIntensity = 1;
        [SerializeField] private float moonSize = 10.0f;
        [SerializeField] private float moonTextureIntensity = 1;
        [SerializeField] private AnimationCurve directionLightIntensity;
        [SerializeField] private Gradient directionLightColor;
        [SerializeField] private AnimationCurve starIntensity;
        
        
        [SerializeField] private Vector4 cloudTiling;
        [SerializeField] private float cloudAltitude = 7.5f;
        [Range(0,1)]
        [SerializeField] private float cloudDirection = 0.0f;
        [SerializeField] private float cloudSpeed = 0.1f;
        [SerializeField] private AnimationCurve cloudDensity;
        [SerializeField] private AnimationCurve cloudIntensity;
        [SerializeField] private Gradient cloudColor1;
        [SerializeField] private Gradient cloudColor2;
        [SerializeField] private Gradient mieColor;

        [Space(10)]
        [Header("反射球-----------------------------------------------------------------------")] 
        public ReflectionProbe reflectionProbe;
        public ReflectionProbeRefreshMode refreshMode = ReflectionProbeRefreshMode.ViaScripting;
        public ReflectionProbeTimeSlicingMode timeSlicingMode = ReflectionProbeTimeSlicingMode.NoTimeSlicing;
        public float reflectionIntensity = 1.0f;
        public bool updateAtFirstFrame = true;

        [Header("反射球刷新间隔，对应 refreshMode ViaScripting")]
        public float refreshInterval = 1.0f;
        private float _timeSinceLastProbeUpdate = 0.0f;


        [Header("环境光")] public CustomAmbientMode ambientMode;
        public AnimationCurve environmentIntensity;
        [GradientUsage(true)]public Gradient skyColor;
        [GradientUsage(true)]public Gradient equatorColor;
        [GradientUsage(true)]public Gradient groundColor;

        [Space(10)] [Header("极光-----------------------------------------------------------------------")]
        public AnimationCurve auroraIntensity;
        public float auroraBrightness;
        public float auroraContrast;
        public float auroraSpeed;

        private void OnEnable()
        {
            SkyDataManager.SetDayTimeNightTime(dayTime, nightTime);
            SkyDataManager.SetDayEvent(OnDay);
            SkyDataManager.SetNightEvent(OnNight);
            SkyDataManager.Init(currentTime, reflectionProbe);
            
            if (updateAtFirstFrame)
            {
                SkyDataManager.ReflectionRefreshMode.Value = refreshMode;
                if (refreshMode == ReflectionProbeRefreshMode.ViaScripting)
                {
                    _timeSinceLastProbeUpdate += Time.deltaTime;

                    if (_timeSinceLastProbeUpdate >= refreshInterval)
                    {
                        reflectionProbe.RenderProbe();
                        DynamicGI.UpdateEnvironment();
                        _timeSinceLastProbeUpdate = 0;
                    }
                }
                SkyDataManager.ReflectionTimeSlicingMode.Value = timeSlicingMode;
                SkyDataManager.ReflectionIntensity.Value = reflectionIntensity;
            }
        }

        private void OnDisable()
        {
            SkyDataManager.DeleteDayEvent();
            SkyDataManager.DeleteNightEvent();
            SkyDataManager.OnDisable();
        }


        private void LateUpdate()
        {
            if (autoTime)
            {
                if (currentTime > 24)
                {
                    currentTime %= 24;
                }
                else if (currentTime < 0)
                {
                    currentTime = 24;
                }

                currentTime += Time.deltaTime * speed;
            }

            SkyDataManager.SkyRotate.Value = skyRotate;
            SkyDataManager.FollowTarget.Value = target;
            SkyDataManager.CurrentTime.Value = currentTime;
            float process = SkyDataManager.CurrentTime.Value / 24.0f;
            
            SkyDataManager.SunSize.Value = sunSize;
            SkyDataManager.SunTextureIntensity.Value = sunTextureIntensity;
            SkyDataManager.MoonSize.Value = moonSize;
            SkyDataManager.MoonTextureIntensity.Value = moonTextureIntensity;
            SkyDataManager.DirectionLightIntensity.Value = directionLightIntensity.Evaluate(process);
            SkyDataManager.DirectionLightColor.Value = directionLightColor.Evaluate(process);
            SkyDataManager.StarIntensity.Value = starIntensity.Evaluate(process);
            
            switch (ambientMode)
            {
                case CustomAmbientMode.Skybox:
                    SkyDataManager.AmbientMode.Value = AmbientMode.Skybox;
                    SkyDataManager.EnvironmentIntensity.Value = environmentIntensity.Evaluate(process);
                    break;
                case CustomAmbientMode.Gradient:
                    SkyDataManager.AmbientMode.Value = AmbientMode.Trilight;
                    SkyDataManager.SkyColor.Value = skyColor.Evaluate(process);
                    SkyDataManager.EquatorColor.Value = equatorColor.Evaluate(process);
                    SkyDataManager.GroundColor.Value = groundColor.Evaluate(process);
                    break;
                
            }
            SkyDataManager.ReflectionRefreshMode.Value = refreshMode;
            if (refreshMode == ReflectionProbeRefreshMode.ViaScripting)
            {
                _timeSinceLastProbeUpdate += Time.deltaTime;

                if (_timeSinceLastProbeUpdate >= refreshInterval)
                {
                    reflectionProbe.RenderProbe();
                    DynamicGI.UpdateEnvironment();
                    _timeSinceLastProbeUpdate = 0;
                }
            }
            SkyDataManager.ReflectionTimeSlicingMode.Value = timeSlicingMode;
            SkyDataManager.ReflectionIntensity.Value = reflectionIntensity;

            SkyDataManager.CloudTiling = cloudTiling;
            SkyDataManager.CloudAltitude.Value = cloudAltitude;
            SkyDataManager.CloudDirection.Value = cloudDirection;
            SkyDataManager.CloudSpeed.Value = cloudSpeed;
            SkyDataManager.CloudDensity = cloudDensity.Evaluate(process);
            SkyDataManager.CloudIntensity.Value = cloudIntensity.Evaluate(process);
            SkyDataManager.CloudColor1.Value = cloudColor1.Evaluate(process);
            SkyDataManager.CloudColor2.Value = cloudColor2.Evaluate(process);
            SkyDataManager.MieColor.Value = mieColor.Evaluate(process);
            
            SkyDataManager.AuroraIntensity.Value = auroraIntensity.Evaluate(process);
            SkyDataManager.AuroraBrightness.Value = auroraBrightness;
            SkyDataManager.AuroraContrast.Value = auroraContrast;
            SkyDataManager.AuroraSpeed.Value = auroraSpeed;
            

        }
    }
}