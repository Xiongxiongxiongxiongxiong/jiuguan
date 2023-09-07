using System;
using UnityEngine.Events;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace Renderering.Sky
{
    /// <summary>
    /// Used to set how the time system will work.
    /// </summary>
    public enum TimeSystem
    {
        [Tooltip("This option sets a simple rotation for the sun and moon transforms. Best for performance.")]
        Simple,
        [Tooltip("This option sets a realistic astronomical coordinate for the sun and moon transforms.")]
        Realistic
    }

    /// <summary>
    /// Used to set the direction in which the time of day will flow.
    /// </summary>
    public enum TimeDirection
    {
        Forward,
        Backward
    }

    /// <summary>
    /// Used to set the date loop.
    /// </summary>
    public enum DateLoop
    {
        Off,
        ByDay,
        ByMonth,
        ByYear
    }

    public enum OutputType
    {
        Float,
        Color
    }

    public enum OutputFloatType
    {
        Slider,
        TimelineBasedCurve,
        SunElevationBasedCurve,
        MoonElevationBasedCurve
    }

    public enum OutputColorType
    {
        ColorField,
        TimelineBasedGradient,
        SunElevationBasedGradient,
        MoonElevationBasedGradient
    }

    public enum OverrideType
    {
        Field,
        Property,
        ShaderProperty
    }

    public enum ShaderUpdateMode
    {
        Local,
        Global
    }

    public enum ScatteringMode
    {
        Automatic,
        Custom
    }

    public enum CloudMode
    {
        Off,
        Static,
        Dynamic
    }

    public enum EventScanMode
    {
        ByMinute,
        ByHour
    }

    public enum ReflectionProbeState
    {
        On,
        Off
    }

    public sealed class Settings
    {
        public float floatValue;
        public Color colorValue;

        public Settings(float floatValue, Color colorValue)
        {
            this.floatValue = floatValue;
            this.colorValue = colorValue;
        }
    }

    [Serializable]
    public sealed class CustomEvent
    {
        public UnityEvent unityEvent;
        public int hour = 6;
        public int minute = 0;
        public int year = 2020;
        public int month = 1;
        public int day = 1;
        public int executedHour = 0;
        public bool isAlreadyExecutedOnThisHour = false;
    }

    [Serializable]
    public sealed class OverrideProperty
    {
        // Not included in build
        #if UNITY_EDITOR
        public string name;
        public string description;
        #endif

        public float floatOutput = 0f;
        public Color colorOutput = Color.white;
        public List<OverridePropertySetup> overridePropertySetupList = new List<OverridePropertySetup>();

        [Serializable]
        public sealed class OverridePropertySetup
        {
            // Not included in build
            #if UNITY_EDITOR
            //public string targetComponentName;
            //public string targetPropertyName;
            #endif

            public OverrideType targetType;
            public GameObject targetGameObject;
            public Material targetMaterial;
            public ShaderUpdateMode targetShaderUpdateMode;
            public Component targetComponent;
            public FieldInfo targetField;
            public PropertyInfo targetProperty;
            public int targetUniformID;
            public float multiplier = 1.0f;

            public string targetComponentName;
            public string targetPropertyName;
        }
    }

    /// <summary>
    /// An celestial body instance.
    /// </summary>
    [Serializable]
    public sealed class CelestialBody
    {
        [Tooltip("The Transform that will receive the celestial body coordinate.")]
        public Transform transform;

        [Tooltip("The celestial body that this instance will simulate.")]
        public Type type;

        [Tooltip("How the transform direction should behaves.")]
        public Behaviour behaviour;

        [Tooltip("The distance between the celestial body and Earth's center.")]
        public float distance;

        /// <summary>
        /// A preset of celestial bodies that the system can simulate.
        /// </summary>
        public enum Type
        {
            Mercury,
            Venus,
            Mars,
            Jupiter,
            Saturn,
            Uranus,
            Neptune,
            Pluto
        }
    }

    /// <summary>
    /// Thunder settings container.
    /// </summary>
    [Serializable]
    public sealed class ThunderSettings
    {
        public Transform thunderPrefab;
        public AudioClip audioClip;
        public AnimationCurve lightFrequency;
        public float audioDelay;
        public Vector3 position;
    }
}