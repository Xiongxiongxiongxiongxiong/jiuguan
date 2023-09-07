using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
[ExecuteInEditMode]
public class CustomMaterialLighting : MonoBehaviour
{
    private MeshRenderer[] _meshRenderers;
    private SkinnedMeshRenderer[] _skinnedMeshRenderers;

    public Vector3 lightDir = new Vector3(1, 1, 1);
    [ColorUsageAttribute(true, true)] public Color lightColor = Color.white;
    public Cubemap envCube;
    [ColorUsageAttribute(true, true)] public Color ambientColor = Color.gray;
    public float iBL;

    void OnEnable()
    {
        _meshRenderers = this.GetComponentsInChildren<MeshRenderer>();
        _skinnedMeshRenderers = this.GetComponentsInChildren<SkinnedMeshRenderer>();
    }

    void Update()
    {
        //Set Mesh Renders
        if (_meshRenderers.Length > 0)
        {
            foreach (MeshRenderer meshrd in _meshRenderers)
            {
                foreach (Material mat in meshrd.sharedMaterials)
                {
                    if (mat.shader.name == "MT/MT_CustomPBR")
                    {
                        SetMaterialPrem(mat);
                    }
                    else
                    {
                        Debug.Log(meshrd.name + "未使用角色Shader，设置失败!");
                    }
                }
            }
        }

        //Set Skin Mesh Renders
        if (_skinnedMeshRenderers.Length > 0)
        {
            foreach (SkinnedMeshRenderer meshrd in _skinnedMeshRenderers)
            {
                foreach (Material mat in meshrd.sharedMaterials)
                {
                    if (mat.shader.name == "MT/MT_CustomPBR")
                    {
                        SetMaterialPrem(mat);
                    }
                    else
                    {
                        Debug.Log(meshrd.name + "未使用角色Shader，设置失败!");
                    }
                }
            }
        }
    }

    void SetMaterialPrem(Material mat)
    {
        mat.SetVector("_LightDir", new Vector4(lightDir.x, lightDir.y, lightDir.z, 1f));
        mat.SetColor("_LightColor", lightColor);
        mat.SetTexture("_EnvCube", envCube);
        mat.SetColor("_AmbientColor", ambientColor);
        mat.SetFloat("_IBL", iBL);
    }
}
#endif