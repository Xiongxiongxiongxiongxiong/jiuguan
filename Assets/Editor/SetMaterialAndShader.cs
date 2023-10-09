using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

public class SetMaterialAndShader : EditorWindow
{
    private Dictionary<int, Shader> Shaders= new Dictionary<int, Shader>();
    private Dictionary<int, Material> materials=new Dictionary<int, Material>();

    [MenuItem("Tool/SetMaterialAndSetShader")]
    private static void OpenWindow()
    {
        SetMaterialAndShader window = GetWindow<SetMaterialAndShader>();
      //  window.titleContent = new GUIContent("Material Manager");
        window.Show();
    }

    private void OnEnable()
    {

        GetMaterials();
    }

    private void GetMaterials()
    {
        Renderer[] renderers = FindObjectsOfType<Renderer>();

        foreach (Renderer renderer in renderers)
        {
            Material[] rendererMaterials = renderer.sharedMaterials;

            foreach (Material material in rendererMaterials)
            {
                int materialID = material.GetInstanceID();

                if (!Shaders.ContainsKey(materialID))
                {
                    Shaders.Add(materialID, material.shader);
                }

                if (!materials.ContainsKey(materialID))
                {
                    materials.Add(materialID, material);
                }
            }
        }
    }

    private void OnGUI()
    {
        GUILayout.Space(10);
        GUILayout.Label("设置到M");
        if (GUILayout.Button("SetMatersM"))
        {
            SetShaderToM();
        }
        GUILayout.Label("设置到R");
        if (GUILayout.Button("SetMatersR"))
        {
            SetShaderToR();
        }
        GUILayout.Label("设置到O");
        if (GUILayout.Button("SetMatersO"))
        {
            SetShaderToO();
        }
        GUILayout.Label("还原到以前的shader");
        if (GUILayout.Button("RestoreShader"))
        {
            RestoreOriginalShader();
        }
    }

    private void SetShaderToM()
    {
        foreach (KeyValuePair<int, Material> kvp in materials)
        {
            Material material = kvp.Value;
            material.shader = Shader.Find("XH/Test_color");
            Shader.EnableKeyword("_a");
            Shader.DisableKeyword("_b");
            Shader.DisableKeyword("_c");
        }
    }
    private void SetShaderToR()
    {
        foreach (KeyValuePair<int, Material> kvp in materials)
        {
            Material material = kvp.Value;
            material.shader = Shader.Find("XH/Test_color");
            Shader.DisableKeyword("_a");
            Shader.EnableKeyword("_b");
            Shader.DisableKeyword("_c");
        }
    }
    private void SetShaderToO()
    {
        foreach (KeyValuePair<int, Material> kvp in materials)
        {
            Material material = kvp.Value;
            material.shader = Shader.Find("XH/Test_color");
            Shader.DisableKeyword("_a");
            Shader.DisableKeyword("_b");
            Shader.EnableKeyword("_c");
        }
    }
    private void RestoreOriginalShader()
    {
        foreach (KeyValuePair<int, Material> kvp in materials)
        {
            Material material = kvp.Value;
            int materialID = kvp.Key;

            if (Shaders.ContainsKey(materialID))
            {
                Shader originalShader = Shaders[materialID];
                material.shader = originalShader;
            }
        }
    }
}
