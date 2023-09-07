#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public class FindUsedShader : EditorWindow
{
    [SerializeField] private List<SceneAsset> _selectScene;
    [SerializeField] private List<GameObject> _selectPrefabs;

    private Vector2 _scroll = Vector2.zero;

    private HashSet<string> _shaderNames = new HashSet<string>();
    private string _targetShaderName;

    private SerializedObject _serializedObject;
    private SerializedProperty _sceneProperty;
    private SerializedProperty _prefabsProperty;

    private bool _hasFindShader;
    private bool _hasFoundShader;

    private void OnEnable()
    {
        _serializedObject = new SerializedObject(this);
        _sceneProperty = _serializedObject.FindProperty("_selectScene");
        _prefabsProperty = _serializedObject.FindProperty("_selectPrefabs");
    }

    [MenuItem("性能查看/美术资源中使用到的shader")]
    private static void Init()
    {
        EditorWindow.GetWindow<FindUsedShader>(false, "美术资源中使用到的shader", true).Show();
    }

    private void OnGUI()
    {
        _scroll = GUILayout.BeginScrollView(_scroll);

        _serializedObject.Update();
        EditorGUI.BeginChangeCheck();

        GUILayout.Label("场景选择:");
        EditorGUILayout.PropertyField(_sceneProperty, true);

        GUILayout.Label("预设体选择:");
        EditorGUILayout.PropertyField(_prefabsProperty, true);

        if (EditorGUI.EndChangeCheck())
        {
            _serializedObject.ApplyModifiedProperties();
        }

        if (GUILayout.Button("Find Shaders"))
        {
            if (_selectScene == null)
            {
                return;
            }

            _shaderNames.Clear();
            Debug.Log("开始查找");
            foreach (var sceneAsset in _selectScene)
            {
                GetUsedShaderInScene(sceneAsset);
            }

            foreach (var prefab in _selectPrefabs)
            {
                GetUsedShaderInPrefab(prefab);
            }

            _hasFindShader = true;
        }

        if (_hasFindShader)
        {
            GUILayout.Label("共找到： "+_shaderNames.Count+" 个Shaders");
            foreach (var s in _shaderNames)
            {
                if (s.Contains("Assets/"))
                {
                    Shader shader = AssetDatabase.LoadAssetAtPath(s, typeof(Shader)) as Shader;
                    if (shader)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.TextField("", s);
                        EditorGUILayout.ObjectField("", shader, typeof(Shader), false);
                        EditorGUILayout.EndHorizontal();
                    }
                }
                else
                {
                    Shader shader = Shader.Find(s);
                    if (shader)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.TextField("", s);
                        EditorGUILayout.ObjectField("", shader, typeof(Shader), false);
                        EditorGUILayout.EndHorizontal();
                    }
                }
            }
        }

        _targetShaderName = EditorGUILayout.TextField("目标Shader:", _targetShaderName);
        if (GUILayout.Button("查找"))
        {
            foreach (var name in _shaderNames)
            {
                Debug.Log(name);
                if (name.Equals(_targetShaderName))
                {
                    _hasFoundShader = true;
                    break;
                }
                else
                {
                    _hasFoundShader = false;
                }
            }
        }

        if (_hasFoundShader)
        {
            GUILayout.Label("在美术资源中 找到 目标shader!");
        }
        else
        {
            GUILayout.Label("在美术资源中 未找到 目标shader!");
        }

        GUILayout.EndScrollView();
    }

    private void GetUsedShaderInScene(SceneAsset selectScene)
    {
        string curPathName = AssetDatabase.GetAssetPath(selectScene.GetInstanceID());
        string[] names = AssetDatabase.GetDependencies(new string[] { curPathName });
        foreach (string name in names)
        {
            if (name.EndsWith(".shader"))
            {
                _shaderNames.Add(name);
            }
        }
    }

    private void GetUsedShaderInPrefab(GameObject obj)
    {
        Transform t = obj.transform;
        var renderers = t.GetComponentsInChildren<Renderer>();
        foreach (var r in renderers)
        {
            var m = r.sharedMaterials;
            foreach (var material in m)
            {
                if (material && _shaderNames != null)
                {
                    var path = AssetDatabase.GetAssetPath(material.shader);
                    if (path.EndsWith(".shader"))
                    {
                        Debug.Log(path);
                        _shaderNames.Add(path);
                    }
                }
            }
        }
    }
}
#endif