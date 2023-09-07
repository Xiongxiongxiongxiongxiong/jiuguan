#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using UnityEngine.Serialization;

namespace ArtTools.Paint
{
    public class PaintPrefabsOnTarget : EditorWindow
    {
        const int ArrayCount = 7;
        public static bool Enable;
        private Transform _currentSelect;
        private GameObject _addObject;
        public static readonly GameObject[] Plants = new GameObject[ArrayCount];
        private readonly Texture[] _texObjects = new Texture[ArrayCount];
        public static int PlantSelect;
        public static bool DownOrDrag = true;
        public static float Frequency = 0.5f;
        public static bool GPUInstancing = true;

        public static LayerMask Layer;

        public static float RandomRotationXMin = 0;
        public static float RandomRotationXMax = 0;
        public string randomRotationXMin_s;
        public string randomRotationXMax_s;
        public static float RandomRotationYMin = 0;
        public static float RandomRotationYMax = 0;
        public string randomRotationYMin_s;
        public string randomRotationYMax_s;
        public static float RandomRotationZMin = 0;
        public static float RandomRotationZMax = 0;
        public string randomRotationZMin_s;
        public string randomRotationZMax_s;

        public static float RandomScaleXMin = 1;
        public static float RandomScaleXMax = 1;
        public string randomScaleXMin_s;
        public string randomScaleXMax_s;
        public static float RandomScaleYMin = 1;
        public static float RandomScaleYMax = 1;
        public string randomScaleYMin_s;
        public string randomScaleYMax_s;
        public static float RandomScaleZMin = 1;
        public static float RandomScaleZMax = 1;
        public string randomScaleZMin_s;
        public string randomScaleZMax_s;

        [MenuItem("Tools/Paint #%z")]
        static void Open()
        {
            var window = (PaintPrefabsOnTarget)EditorWindow.GetWindowWithRect(typeof(PaintPrefabsOnTarget), new Rect(0, 0, 440, 400), false, "刷植物");
            window.Show();
        }

        private void OnDisable()
        {
            Enable = false;
        }

        private void OnEnable()
        {
            for (int i = 0; i < Plants.Length; i++)
            {
                Plants[i] = LoadAssets(i);
            }

            Layer = int.Parse(LoadAssets("LayerMask"));
            Enable = true;
        }

        void OnInspectorUpdate()
        {
            Repaint();
        }

        void OnGUI()
        {
            _currentSelect = Selection.activeTransform;

            GUILayout.Space(5);

            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical("box");
            GUILayout.BeginHorizontal();
            GUILayout.Label("添加预设", GUILayout.Width(115));

            _addObject = (GameObject)EditorGUILayout.ObjectField("", _addObject, typeof(GameObject), true, GUILayout.Width(200));
            if (GUILayout.Button("添加到列表", GUILayout.Width(100)))
            {
                for (int i = 0; i < ArrayCount; i++)
                {
                    if (Plants[i] == null)
                    {
                        Plants[i] = _addObject;
                        break;
                    }
                }
            }

            GUILayout.EndHorizontal();
            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();

            for (int i = 0; i < ArrayCount; i++)
            {
                if (Plants[i] != null)
                    _texObjects[i] = AssetPreview.GetAssetPreview(Plants[i]) as Texture;
                else _texObjects[i] = null;
            }

            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical("box");
            PlantSelect = GUILayout.SelectionGrid(PlantSelect, _texObjects, ArrayCount, "gridlist", GUILayout.Width(420), GUILayout.Height(53));

            GUILayout.BeginHorizontal();
            for (int i = 0; i < ArrayCount; i++)
            {
                GUILayout.Label("  序号：" + (i + 1), GUILayout.Width(57));
            }

            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            for (int i = 0; i < ArrayCount; i++)
            {
                if (GUILayout.Button("移除当前", GUILayout.Width(57)))
                {
                    if (EditorUtility.DisplayDialog("移除当前资源", "是否确认移除目标资源？\n\n确定：移除\n\n取消：取消移除", "确定", "取消"))
                    {
                        Plants[i] = null;
                    }
                    else
                    {
                        Debug.Log("取消移除");
                    }
                }
            }

            GUILayout.EndHorizontal();

            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();

            GUILayout.BeginVertical();
            GUILayout.FlexibleSpace();


            GUILayout.BeginHorizontal();
            GUILayout.Label("当前选中的序号为：", GUILayout.Width(100));
            EditorGUILayout.IntField("", PlantSelect + 1, GUILayout.Width(50));
            GUILayout.Space(90);
            GUILayout.Label("目标层级：", GUILayout.Width(60));
            Layer = EditorGUILayout.LayerField("", Layer, GUILayout.Width(120));
            GUILayout.EndHorizontal();

            if (GUILayout.Button("存储预设参数"))
            {
                if (EditorUtility.DisplayDialog("存储预设参数", "是否覆盖已存在的预设资源？\n\n确定：覆盖\n\n取消：取消保存", "确定", "取消"))
                {
                    for (int i = 0; i < Plants.Length; i++)
                    {
                        SaveAssets(i, Plants[i]);
                        Debug.Log("保存了当前: " + Plants[i]);
                    }

                    SaveAssets("LayerMask", ((int)Layer).ToString());
                }
                else
                {
                    Debug.Log("取消保存");
                }
            }

            GUILayout.BeginHorizontal();
            GUILayout.Label("True:点击生成，False:拖拽生成：", GUILayout.Width(180));
            DownOrDrag = EditorGUILayout.Toggle("", DownOrDrag, GUILayout.Width(30));
            GUILayout.Label("拖拽生成频率：", GUILayout.Width(80));
            Frequency = EditorGUILayout.FloatField("", Frequency, GUILayout.Width(50));
            GUILayout.Label("秒", GUILayout.Width(80));
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("True:开启GPU实例化，False:关闭GPU实例化", GUILayout.Width(250));
            GPUInstancing = EditorGUILayout.Toggle("", GPUInstancing, GUILayout.Width(30));
            GUILayout.EndHorizontal();

            #region 旋转

            GUILayout.BeginVertical("box");
            GUILayout.Label("随机旋转", GUILayout.Width(145));
            GUILayout.BeginHorizontal();
            GUILayout.Label("X轴随机旋转范围：", GUILayout.Width(100));
            randomRotationXMin_s = EditorGUILayout.TextField("", RandomRotationXMin.ToString(), GUILayout.Width(50));
            RandomRotationXMin = float.Parse(randomRotationXMin_s);
            EditorGUILayout.MinMaxSlider(ref RandomRotationXMin, ref RandomRotationXMax, 0, 360);
            randomRotationXMax_s = EditorGUILayout.TextField("", RandomRotationXMax.ToString(), GUILayout.Width(50));
            RandomRotationXMax = float.Parse(randomRotationXMax_s);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Y轴随机旋转范围：", GUILayout.Width(100));
            randomRotationYMin_s = EditorGUILayout.TextField("", RandomRotationYMin.ToString(), GUILayout.Width(50));
            RandomRotationYMin = float.Parse(randomRotationYMin_s);
            EditorGUILayout.MinMaxSlider(ref RandomRotationYMin, ref RandomRotationYMax, 0, 360);
            randomRotationYMax_s = EditorGUILayout.TextField("", RandomRotationYMax.ToString(), GUILayout.Width(50));
            RandomRotationYMax = float.Parse(randomRotationYMax_s);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Z轴随机旋转范围：", GUILayout.Width(100));
            randomRotationZMin_s = EditorGUILayout.TextField("", RandomRotationZMin.ToString(), GUILayout.Width(50));
            RandomRotationZMin = float.Parse(randomRotationZMin_s);
            EditorGUILayout.MinMaxSlider(ref RandomRotationZMin, ref RandomRotationZMax, 0, 360);
            randomRotationZMax_s = EditorGUILayout.TextField("", RandomRotationZMax.ToString(), GUILayout.Width(50));
            RandomRotationZMax = float.Parse(randomRotationZMax_s);
            GUILayout.EndHorizontal();
            GUILayout.EndVertical();

            #endregion

            #region 缩放

            GUILayout.BeginVertical("box");
            GUILayout.Label("随机缩放", GUILayout.Width(145));

            GUILayout.BeginHorizontal();
            GUILayout.Label("X轴随机缩放范围：", GUILayout.Width(100));
            randomScaleXMin_s = EditorGUILayout.TextField("", RandomScaleXMin.ToString(), GUILayout.Width(50));
            RandomScaleXMin = float.Parse(randomScaleXMin_s);
            EditorGUILayout.MinMaxSlider(ref RandomScaleXMin, ref RandomScaleXMax, 0, 10);
            randomScaleXMax_s = EditorGUILayout.TextField("", RandomScaleXMax.ToString(), GUILayout.Width(50));
            RandomScaleXMax = float.Parse(randomScaleXMax_s);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Y轴随机缩放范围：", GUILayout.Width(100));
            randomScaleYMin_s = EditorGUILayout.TextField("", RandomScaleYMin.ToString(), GUILayout.Width(50));
            RandomScaleYMin = float.Parse(randomScaleYMin_s);
            EditorGUILayout.MinMaxSlider(ref RandomScaleYMin, ref RandomScaleYMax, 0, 10);
            randomScaleYMax_s = EditorGUILayout.TextField("", RandomScaleYMax.ToString(), GUILayout.Width(50));
            RandomScaleYMax = float.Parse(randomScaleYMax_s);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Z轴随机缩放范围：", GUILayout.Width(100));
            randomScaleZMin_s = EditorGUILayout.TextField("", RandomScaleZMin.ToString(), GUILayout.Width(50));
            RandomScaleZMin = float.Parse(randomScaleZMin_s);
            EditorGUILayout.MinMaxSlider(ref RandomScaleZMin, ref RandomScaleZMax, 0, 10);
            randomScaleZMax_s = EditorGUILayout.TextField("", RandomScaleZMax.ToString(), GUILayout.Width(50));
            RandomScaleZMax = float.Parse(randomScaleZMax_s);
            GUILayout.EndHorizontal();
            GUILayout.EndVertical();

            #endregion

            if (GUILayout.Button("重置参数"))
            {
                Layer = 0;

                RandomRotationXMin = 0;
                RandomRotationXMax = 0;
                RandomRotationYMin = 0;
                RandomRotationYMax = 0;
                RandomRotationZMin = 0;
                RandomRotationZMax = 0;

                RandomScaleXMin = 1;
                RandomScaleXMax = 1;
                RandomScaleYMin = 1;
                RandomScaleYMax = 1;
                RandomScaleZMin = 1;
                RandomScaleZMax = 1;

                DownOrDrag = true;
                GPUInstancing = true;
                Frequency = 0.5f;
            }

            GUILayout.FlexibleSpace();
            GUILayout.EndVertical();
        }

        void SaveAssets(int index, GameObject target)
        {
            var s = AssetDatabase.GetAssetPath(target);
            PlayerPrefs.SetString(index.ToString(), s);
            PlayerPrefs.Save();
        }

        void SaveAssets(string key, string value)
        {
            PlayerPrefs.SetString(key, value);
            PlayerPrefs.Save();
        }

        GameObject LoadAssets(int index)
        {
            string path = PlayerPrefs.GetString(index.ToString());
            return AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
        }

        string LoadAssets(string key)
        {
            return PlayerPrefs.GetString(key);
        }
    }
}
#endif