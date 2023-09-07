using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectCheckLevel : ScriptableObject
{
    [Serializable]
    public class CheckType
    {
        public string m_name;
        public string m_searchTag;
        public List<LodLevel> m_lods;
    }

    [Serializable]
    public class LodLevel
    {
        public int m_drawCall;
        public int m_triangles;
        public int m_particleCount;
    }

    public List<CheckType> types;
}