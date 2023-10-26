using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class UnusedMash : EditorWindow
{
    private List<string> resourceNames = new List<string>();
    private List<string> sceneObjectNames = new List<string>();
    public Object wenjian;
    [MenuItem("Tool/查找未使用的模型")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow<UnusedMash>("查找未使用的模型");
    }

    private void OnGUI()
    {
      wenjian =   EditorGUILayout.ObjectField("拖一个文件见", wenjian, typeof(Object),true);
     GUILayout.Label(AssetDatabase.GetAssetPath(wenjian));
        if (GUILayout.Button("查找未使用的模型"))
        {
            resourceNames.Clear();
            sceneObjectNames.Clear();

            // 获取指定路径中的资源名称
            var resourcePaths = AssetDatabase.FindAssets("t:GameObject", new[] { AssetDatabase.GetAssetPath(wenjian) });
            foreach (var path in resourcePaths)
            {
                var assetPath = AssetDatabase.GUIDToAssetPath(path);
                var assetName = System.IO.Path.GetFileNameWithoutExtension(assetPath);
                resourceNames.Add(assetName);
            }

            // 获取场景中的游戏对象名称的一部分
            var gameObjects = FindObjectsOfType<GameObject>();
            foreach (var go in gameObjects)
            {
                if (go.GetComponent<MeshRenderer>() != null)
                {
                    var sceneObjectPartName = go.name.Split(' ')[0]; // 提取名称的第一部分
                    sceneObjectNames.Add(sceneObjectPartName);
                }
            }

            // 比较资源名称和场景对象名称的一部分，找到不匹配的对象
            foreach (var resourceName in resourceNames)
            {
                if (!sceneObjectNames.Contains(resourceName))
                {
                    Debug.Log("未使用的模型: " + resourceName);
                }
            }
        }
    }
    

       
}