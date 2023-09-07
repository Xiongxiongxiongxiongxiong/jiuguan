using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightController : MonoBehaviour
{
    public bool defaultState;
    public string emissionName;
    public Material[] emissionMaterials;
    private Color[] _emissionColor;
    public Light[] lights;
    

    private void Start()
    {
        for (int i = 0; i < lights.Length; i++)
        {
            lights[i].enabled = defaultState;
        }

        _emissionColor = new Color[emissionMaterials.Length];
        for (int i = 0; i < emissionMaterials.Length; i++)
        {
            _emissionColor[i] = emissionMaterials[i].GetColor(emissionName);
            emissionMaterials[i].SetColor(emissionName, Color.black);
        }
    }

    public void OpenLight()
    {
        for (int i = 0; i < lights.Length; i++)
        {
            lights[i].enabled = true;
        }
        for (int i = 0; i < emissionMaterials.Length; i++)
        {
            emissionMaterials[i].SetColor(emissionName, _emissionColor[i]);
        }
    }

    public void CloseLight()
    {
        for (int i = 0; i < lights.Length; i++)
        {
            lights[i].enabled = false;
        }
        for (int i = 0; i < emissionMaterials.Length; i++)
        {
            emissionMaterials[i].SetColor(emissionName, Color.black);
        }
    }
}