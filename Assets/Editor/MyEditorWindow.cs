using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class MyEditorWindow : EditorWindow
{
    private enum Xia
    {
        sky_zone,
        Time_for_day
    }
    
    private bool isFoldoutOpen = true;
    public Object draggedObject  ;
    private float thumbnailSize = 64.0f;
    private Xia myxiala;
   
    private Object wenjianmesh;
    
#if UNITY_ANDROID
    private Vector4 androidVector = Vector4.zero;
#elif UNITY_STANDALONE
    private Vector2 pcVector = Vector2.zero;
#endif
    
    [MenuItem("Window/Custom Window")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow<MyEditorWindow>("Custom Window");
     //   MyEditorWindow window = EditorWindow.GetWindow<MyEditorWindow>(typeof(MyEditorWindow));
      //  window.Show();
    }

    private void OnGUI()
    {


        
#if UNITY_ANDROID
        androidVector = EditorGUILayout.Vector4Field("Android Vector", androidVector);
#elif UNITY_STANDALONE
        pcVector = EditorGUILayout.Vector2Field("PC Vector", pcVector);
#endif
        
        
        //用一个bool制作一个折叠器
        isFoldoutOpen = EditorGUILayout.Foldout(isFoldoutOpen, "场景辅助工具");
        //判断折叠器是否打开
        if (isFoldoutOpen)
        {
            EditorGUILayout.LabelField("LOD：");
            EditorGUILayout.BeginHorizontal(); // 开始垂直布局

            if (GUILayout.Button("Low"))
            {

            }

            if (GUILayout.Button("Middle"))
            {
                // 处理按钮2的点击事件
            }

            if (GUILayout.Button("High"))
            {
                // 处理按钮3的点击事件
            }

            EditorGUILayout.EndHorizontal(); // 结束垂直布局
            
            if (GUILayout.Button("切换至低清资源"))
            {
                // 处理按钮3的点击事件
            }
            GUILayout.Space(10);
            GUILayout.Label("场景检查工具：");
            
           GUILayout.Label("Drag and Drop Object Here:");
           draggedObject =  EditorGUILayout.ObjectField("Drag and Drop Object", draggedObject, typeof(Object), true);
           myxiala = (Xia)EditorGUILayout.EnumPopup("OP", myxiala);
            if (draggedObject != null)
            {
                GUILayout.Label(AssetDatabase.GetAssetPath(draggedObject));
                // 在这里可以处理选定对象的操作
                Texture2D objectThumbnail = AssetPreview.GetAssetPreview(draggedObject);
           
                if (objectThumbnail != null)
                {
                    // 显示对象的缩略图，并根据滑杆调整大小
                    GUILayout.Label(objectThumbnail, GUILayout.Width(thumbnailSize), GUILayout.Height(thumbnailSize));
                   // GUILayout.Label(objectThumbnail,GUILayout.Height(thumbnailSize),GUILayout.Width(thumbnailSize));
                    GUILayout.Label("Thumbnail Size");
           
                    // 添加滑杆来调整缩略图的大小
                    thumbnailSize = EditorGUILayout.Slider("进度条",thumbnailSize, 32.0f, 256.0f);
                }
            }
            if (PlayerSettings.colorSpace==ColorSpace.Gamma)
            {
                if (GUILayout.Button(("点击gamma空间")))
                {
                  Debug.Log("点击了gamma空间");  
                }
            }
            else
            {
                if (GUILayout.Button(("点击Linear空间")))
                {
                    Debug.Log("点击了Linear空间");  
                }
            }
            
        }
    }
}





// public class MyEditorWindow : EditorWindow
// {
//     private bool isFoldoutOpen = true;
//     private Object[] selectedObjects;
//     private float thumbnailSize = 64.0f;
//     private string[] objectPaths;
//     private Vector2 scrollPosition = Vector2.zero;
//
//     [MenuItem("Window/Custom Window")]
//     public static void ShowWindow()
//     {
//         GetWindow<MyEditorWindow>("Custom Window");
//     }
//
//     private void OnGUI()
//     {
//         isFoldoutOpen = EditorGUILayout.Foldout(isFoldoutOpen, "Buttons");
//
//         if (isFoldoutOpen)
//         {
//             EditorGUILayout.BeginVertical("box"); // 开始垂直布局
//
//             if (GUILayout.Button("Button 1"))
//             {
//                 // 处理按钮1的点击事件
//             }
//
//             if (GUILayout.Button("Button 2"))
//             {
//                 // 处理按钮2的点击事件
//             }
//
//             if (GUILayout.Button("Button 3"))
//             {
//                 // 处理按钮3的点击事件
//             }
//
//             EditorGUILayout.EndVertical(); // 结束垂直布局
//         }
//
//         GUILayout.Space(10); // 添加空白行
//
//         EditorGUILayout.LabelField("Drag and Drop Objects");
//
//         scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
//
//         if (selectedObjects != null && selectedObjects.Length > 0)
//         {
//             for (int i = 0; i < selectedObjects.Length; i++)
//             {
//                 EditorGUILayout.BeginHorizontal();
//
//                 selectedObjects[i] = EditorGUILayout.ObjectField("Object " + (i + 1), selectedObjects[i], typeof(Object), true);
//
//                 if (GUILayout.Button("Remove"))
//                 {
//                     // 移除选定的物体
//                     RemoveObject(i);
//                 }
//
//                 EditorGUILayout.EndHorizontal();
//             }
//         }
//
//         EditorGUILayout.EndScrollView();
//
//         GUILayout.Space(10); // 添加空白行
//
//         if (GUILayout.Button("Add Object"))
//         {
//             AddObject();
//         }
//
//         if (selectedObjects != null && selectedObjects.Length > 0)
//         {
//             // 获取所选对象的资源路径
//             objectPaths = new string[selectedObjects.Length];
//             for (int i = 0; i < selectedObjects.Length; i++)
//             {
//                 objectPaths[i] = AssetDatabase.GetAssetPath(selectedObjects[i]);
//             }
//
//             // 获取对象的缩略图
//             GUILayout.Label("Thumbnails:");
//             EditorGUILayout.BeginHorizontal();
//             for (int i = 0; i < selectedObjects.Length; i++)
//             {
//                 Texture2D objectThumbnail = AssetPreview.GetAssetPreview(selectedObjects[i]);
//                 if (objectThumbnail != null)
//                 {
//                     GUILayout.Label(objectThumbnail, GUILayout.Width(thumbnailSize), GUILayout.Height(thumbnailSize));
//                 }
//             }
//             EditorGUILayout.EndHorizontal();
//
//             // 添加滑杆来调整缩略图的大小
//             GUILayout.Label("Thumbnail Size");
//             thumbnailSize = EditorGUILayout.Slider(thumbnailSize, 32.0f, 256.0f);
//         }
//
//         GUILayout.Space(10); // 添加空白行
//
//         if (objectPaths != null && objectPaths.Length > 0)
//         {
//             for (int i = 0; i < objectPaths.Length; i++)
//             {
//                 EditorGUILayout.LabelField("Object " + (i + 1) + " Path:", objectPaths[i]);
//             }
//         }
//     }
//
//     private void AddObject()
//     {
//         if (selectedObjects == null)
//         {
//             selectedObjects = new Object[1];
//         }
//         else
//         {
//             Array.Resize(ref selectedObjects, selectedObjects.Length + 1);
//         }
//     }
//
//     private void RemoveObject(int index)
//     {
//         if (selectedObjects != null && index >= 0 && index < selectedObjects.Length)
//         {
//             List<Object> objectList = selectedObjects.ToList();
//             objectList.RemoveAt(index);
//             selectedObjects = objectList.ToArray();
//         }
//     }
// }






