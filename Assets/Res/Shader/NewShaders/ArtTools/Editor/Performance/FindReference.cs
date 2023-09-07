#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 显示某个场景里所有相关的脚本
/// 点击其中一个脚本获得挂载这个脚本的物体或预制体
/// </summary>
public class FindReference : EditorWindow
{
    SceneAsset selectScene;

    List<string> SceneAllScripts = new List<string>();

    //脚本序号与挂载脚本的Prefab，Scene的关联，获得project视图资源关联
    Dictionary<int, Dictionary<string, List<string>>> int_dict = new Dictionary<int, Dictionary<string, List<string>>>();

    //脚本序号与挂载脚本的GameObject的关联，获得Hierarchy视图物体关联
    Dictionary<int, List<Transform>> int_tra = new Dictionary<int, List<Transform>>();
    bool isFindAllScripts;
    bool isFindScriptReference;
    Vector2 mScroll = Vector2.zero; //用于ScrollView滚动条滚动
    List<bool> isOn = new List<bool>(); //记录每个脚本关联资源面板是否展开状态

    //获得脚本与project视图资源关联时 需要检查的路径，可添加多个具体路径
    static string[] checkPaths = new string[]
    {
        "Assets"
    };

    [MenuItem("Tools/SceneAllScriptDependance")]
    static void Init()
    {
        EditorWindow.GetWindow<FindReference>(false, "场景里所有脚本及其关联", true).Show();
    }

    void OnGUI()
    {
        mScroll = GUILayout.BeginScrollView(mScroll);
        GUILayout.Label("场景:");
        selectScene = (SceneAsset)EditorGUILayout.ObjectField(selectScene, typeof(SceneAsset), true);
        if (GUILayout.Button("Find"))
        {
            SceneAllScripts.Clear();
            Debug.Log("开始查找.");
            FindScript();
        }

        if (isFindAllScripts)
        {
            if (SceneAllScripts.Count > 0)
            {
                GUILayout.Label(SceneAllScripts.Count + "个脚本");
                for (int i = 0; i < SceneAllScripts.Count; i++)
                {
                    MonoScript go = AssetDatabase.LoadAssetAtPath(SceneAllScripts[i], typeof(MonoScript)) as MonoScript; //根据脚本名称找到MonoScript资源
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.ObjectField("", go, typeof(MonoScript), false);
                    if (GUILayout.Button("FindReference")) //点击查找关联展开，再点击收起
                    {
                        if (!isOn[i])
                        {
                            isOn[i] = true;
                            FindScriptDependance(go.GetInstanceID(), i, go);
                        }
                        else
                        {
                            isOn[i] = false;
                            //isFindScriptReference = false;
                        }
                    }

                    EditorGUILayout.EndHorizontal();
                    if (isFindScriptReference)
                    {
                        if (isOn[i])
                        {
                            ShowScriptDependance(i);
                        }
                    }
                }
            }
            else
            {
                GUILayout.Label("无数据");
            }
        }

        GUILayout.EndScrollView();
    }

    /// <summary>
    /// 找到某个场景关联的所有的脚本，使用GetDependencies查找的
    /// </summary>
    public void FindScript()
    {
        ShowProgress(0, 0, 0); //显示进度条
        string curPathName = AssetDatabase.GetAssetPath(selectScene.GetInstanceID()); //获得选中的SceneAsset的path
        //搜索对象的依赖资源
        string[] names = AssetDatabase.GetDependencies(new string[] { curPathName });
        int i = 0;
        foreach (string name in names)
        {
            if (name.EndsWith(".cs"))
            {
                SceneAllScripts.Add(name);
                isOn.Add(false);
            }

            ShowProgress((float)i / (float)names.Length, names.Length, i);
            i++;
        }

        EditorUtility.ClearProgressBar();
        isFindAllScripts = true;
    }

    /// <summary>
    /// 显示进度条
    /// </summary>
    /// <param name="val"></param>
    /// <param name="total"></param>
    /// <param name="cur"></param>
    public static void ShowProgress(float val, int total, int cur)
    {
        EditorUtility.DisplayProgressBar("Searching", string.Format("Checking ({0}/{1}), please wait...", cur, total), val);
    }

    /// <summary>
    /// 获得Hierarchy视图中挂载这个脚本的Transform和资源视图里关联的Prefab和Scene
    /// </summary>
    /// <param name="GID">MonoScript资源ID号</param>
    /// <param name="toggleID">脚本序号</param>
    /// <param name="g">MonoScript</param>
    public void FindScriptDependance(int GID, int toggleID, MonoScript g)
    {
        ShowProgress(0, 0, 0);
        Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();
        List<Transform> gameObjectList = new List<Transform>();
        List<string> levelList = new List<string>(); //场景列表
        List<string> prefabList = new List<string>(); //prefab列表
        gameObjectList = GetAllObjsOfType(g, false); //Transform列表      
        string curPathName = AssetDatabase.GetAssetPath(GID); //获得选中的asset的path
        //搜索对象的依赖资源
        //string[] names = AssetDatabase.GetDependencies(new string[] { curPathName });
        //int i = 0;
        //foreach (string name in names)
        //{
        //    if (name.EndsWith(".cs"))
        //    {
        //        scriptList.Add(name);
        //    }
        //    Debug.Log("Dependence:" + name);
        //    ShowProgress((float)i / (float)names.Length, names.Length, i);
        //    i++;
        //}
        //这里只检查是否在Prefab和Scene有引用，如果要检查其他，在这里添加筛选类型，并且打开下面的对应的注释
        string checkType = "t:Prefab t:Scene";
        int i = 0;
        string[] allGuids = AssetDatabase.FindAssets(checkType, checkPaths); //根据asset类型找asset，获得GUID
        foreach (string guid in allGuids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            string[] names = AssetDatabase.GetDependencies(new string[] { assetPath });
            foreach (string name in names)
            {
                if (name.Equals(curPathName))
                {
                    if (assetPath.EndsWith(".prefab"))
                    {
                        prefabList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.ToLower().EndsWith(".unity"))
                    {
                        levelList.Add(assetPath);
                        break;
                    }
                    //else if (assetPath.EndsWith(".cs"))
                    //{
                    //    scriptList.Add(assetPath);
                    //    break;
                    //}
                }
            }

            ShowProgress((float)i / (float)allGuids.Length, allGuids.Length, i);
            i++;
        }

        dic.Add("level", levelList);
        dic.Add("prefab", prefabList);
        //dic.Add("cs", scriptList);
        if (!int_dict.ContainsKey(toggleID))
        {
            int_dict.Add(toggleID, dic);
            Debug.Log(int_dict[toggleID].Count);
        }

        if (!int_tra.ContainsKey(toggleID))
        {
            int_tra.Add(toggleID, gameObjectList);
        }

        EditorUtility.ClearProgressBar();
        isFindScriptReference = true;
    }

    public void ShowScriptDependance(int toggleID)
    {
        List<Transform> TransformList = int_tra[toggleID];
        if (TransformList != null && TransformList.Count > 0)
        {
            if (DrawHeader("Hierarchy", toggleID.ToString() + "0", false, false))
            {
                foreach (Transform item in TransformList)
                {
                    EditorGUILayout.ObjectField("", item, typeof(Transform), false);
                }
            }

            TransformList = null;
        }

        List<string> list = int_dict[toggleID]["level"];
        if (list != null && list.Count > 0)
        {
            if (DrawHeader("Level", toggleID.ToString() + "1", false, false))
            {
                foreach (string item in list)
                {
                    SceneAsset go1 = AssetDatabase.LoadAssetAtPath(item, typeof(SceneAsset)) as SceneAsset;
                    EditorGUILayout.ObjectField("Level:", go1, typeof(SceneAsset), false);
                }
            }

            list = null;
        }

        list = int_dict[toggleID]["prefab"];
        if (list != null && list.Count > 0)
        {
            if (DrawHeader("Prefab", toggleID.ToString() + "2", false, false))
            {
                foreach (string item in list)
                {
                    GameObject go2 = AssetDatabase.LoadAssetAtPath(item, typeof(GameObject)) as GameObject;
                    EditorGUILayout.ObjectField("Prefab", go2, typeof(GameObject), false);
                }
            }

            list = null;
        }
        //list = int_dict[toggleID]["cs"];
        //if (list != null && list.Count > 0)
        //{
        //    if (DrawHeader("Script"))
        //    {
        //        foreach (string item in list)
        //        {
        //            MonoScript go = AssetDatabase.LoadAssetAtPath(item, typeof(MonoScript)) as MonoScript;
        //            EditorGUILayout.ObjectField("Script", go, typeof(MonoScript), false);

        //        }
        //    }
        //    list = null;
        //}
    }

    /// <summary>
    /// 获得这个脚本所有相关联的物体，去掉Asset视图里物体
    /// </summary>
    /// <param name="m">MonoScript</param>
    /// <param name="onlyRoot">是否只查找Hierarchy视图中父物体</param>
    /// <returns></returns>
    public static List<Transform> GetAllObjsOfType(MonoScript m, bool onlyRoot)
    {
        Debug.Log(m.GetClass());
        Transform[] Objs = (Transform[])Resources.FindObjectsOfTypeAll(typeof(Transform));

        List<Transform> returnObjs = new List<Transform>();

        foreach (Transform obj in Objs)
        {
            if (onlyRoot)
            {
                if (obj.transform.parent != null)
                {
                    continue;
                }
            }

            if (obj.hideFlags == HideFlags.NotEditable || obj.hideFlags == HideFlags.HideAndDontSave)
            {
                continue;
            }

            if (Application.isEditor)
            {
                //检测资源是否存在，不存在会返回null或empty的字符串，存在会返回文件名
                string sAssetPath = AssetDatabase.GetAssetPath(obj.transform.root.gameObject);
                if (!string.IsNullOrEmpty(sAssetPath))
                {
                    continue;
                }
            }

            if (obj.GetComponent(m.GetClass()) != null)
            {
                returnObjs.Add(obj);
            }
            //returnObjs.Add(Obj);
        }

        return returnObjs;
    }

    //集成NGUI方法，显示可折叠窗口
    public bool DrawHeader(string text)
    {
        return DrawHeader(text, text, false, false);
    }

    /// <summary>
    /// 可折叠窗口
    /// </summary>
    /// <param name="text">折叠窗口的title</param>
    /// <param name="key">若两个窗口是同一个key，则展开或折叠的状态一样</param>
    /// <param name="forceOn">默认false,true则标题样式为展开样式</param>
    /// <param name="minimalistic">默认false,true则标题与左边无空隙</param>
    /// <returns></returns>
    public bool DrawHeader(string text, string key, bool forceOn, bool minimalistic)
    {
        bool state = EditorPrefs.GetBool(key, true);

        if (!minimalistic) GUILayout.Space(3f);
        if (!forceOn && !state) GUI.backgroundColor = new Color(0.8f, 0.8f, 0.8f);
        GUILayout.BeginHorizontal();
        GUI.changed = false;

        if (minimalistic)
        {
            if (state) text = "\u25BC" + (char)0x200a + text;
            else text = "\u25BA" + (char)0x200a + text;

            GUILayout.BeginHorizontal();
            GUI.contentColor = EditorGUIUtility.isProSkin ? new Color(1f, 1f, 1f, 0.7f) : new Color(0f, 0f, 0f, 0.7f);
            if (!GUILayout.Toggle(true, text, "PreToolbar2", GUILayout.MinWidth(20f))) state = !state;
            GUI.contentColor = Color.white;
            GUILayout.EndHorizontal();
        }
        else
        {
            text = "<b><size=11>" + text + "</size></b>";
            if (state) text = "\u25BC " + text;
            else text = "\u25BA " + text;
            if (!GUILayout.Toggle(true, text, "dragtab", GUILayout.MinWidth(20f))) state = !state;
        }

        if (GUI.changed) EditorPrefs.SetBool(key, state);

        if (!minimalistic) GUILayout.Space(2f);
        GUILayout.EndHorizontal();
        GUI.backgroundColor = Color.white;
        if (!forceOn && !state) GUILayout.Space(3f);
        return state;
    }
}
#endif