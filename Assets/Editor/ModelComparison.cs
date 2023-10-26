using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
public class MyEditorWindows : EditorWindow
{
    private Object wenjianmesh;
    [MenuItem("Window/Custom Window")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow<MyEditorWindow>("Custom Window");

    }

    private void OnGUI()
    {
        if (GUILayout.Button("Low"))
        {

            var scenemoldes = AssetDatabase.FindAssets("t:GameObject", new[] { "Assets/Res/art/scenes/jg/mesh/prop" });
            foreach (var path in scenemoldes)
            {
                var gopath = AssetDatabase.GUIDToAssetPath(path);
                wenjianmesh = AssetDatabase.LoadAssetAtPath(gopath, typeof(GameObject));
                //  Debug.Log(wenjianmesh.name);

            }

            var gos = FindObjectsOfType<GameObject>();

            foreach (var go in gos)
            {
                if (go.GetComponent<MeshRenderer>() != null)
                {
                    // Debug.Log(go.name);
                    var secenemoldeindex = go.name.IndexOf(" ");
                    string secenemoldename = "";
                    if (secenemoldeindex > 0)
                    {
                        secenemoldename = go.name.Substring(0, secenemoldeindex);

                    }
                    else
                    {
                        secenemoldename = go.name;
                    }

                }

            }



        }



    }


}