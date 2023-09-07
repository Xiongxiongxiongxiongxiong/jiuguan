#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Random = UnityEngine.Random;

namespace ArtTools.Paint
{
    [CustomEditor(typeof(Paint))]
    public class PaintEX : Editor
    {
        public override void OnInspectorGUI()
        {
            if (GUILayout.Button("撤回"))
            {
                ((Paint)target).GetComponent<Paint>().Undo();
            }

            if (GUILayout.Button("清空"))
            {
                ((Paint)target).GetComponent<Paint>().Clear();
            }

            base.OnInspectorGUI();
        }

        private float _time;

        private void OnEnable()
        {
            _time = PaintPrefabsOnTarget.Frequency;
        }

        void OnSceneGUI()
        {
            if (PaintPrefabsOnTarget.Enable)
            {
                Planting();
            }
        }

        private void OnPreSceneGUI()
        {
            if (_isPlant && Event.current.type == EventType.MouseUp && Event.current.button == 0)
            {
                // Debug.LogError(EventType.MouseUp);
                _isPlant = false;
                _isUp = true;
            }
        }

        private bool _isUp;
        private bool _isPlant;

        void Planting()
        {
            Event e = Event.current;
            RaycastHit raycastHit = new RaycastHit();
            Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);
            var temp = (Paint)target;
            
            if (Physics.Raycast(ray, out raycastHit, Mathf.Infinity, -1))
            {
                if (raycastHit.transform.gameObject.layer != PaintPrefabsOnTarget.Layer) return;

                if (PaintPrefabsOnTarget.DownOrDrag)
                {
                    if (Event.current.type == EventType.MouseDown && Event.current.button == 0)
                    {
                        if (!PaintPrefabsOnTarget.Plants[PaintPrefabsOnTarget.PlantSelect])
                        {
                            Debug.LogError("目标为空，检查资源选择是否正确！");
                            return;
                        }

                        _isPlant = true;
                        var obj = GameObject.Instantiate(PaintPrefabsOnTarget.Plants[PaintPrefabsOnTarget.PlantSelect], temp.transform).transform;
                        obj.position = raycastHit.point;
                        obj.eulerAngles = new Vector3(Random.Range(PaintPrefabsOnTarget.RandomRotationXMin, PaintPrefabsOnTarget.RandomRotationXMax),
                            Random.Range(PaintPrefabsOnTarget.RandomRotationYMin, PaintPrefabsOnTarget.RandomRotationYMax),
                            Random.Range(PaintPrefabsOnTarget.RandomRotationZMin, PaintPrefabsOnTarget.RandomRotationZMax));
                        obj.localScale = new Vector3(Random.Range(PaintPrefabsOnTarget.RandomScaleXMin, PaintPrefabsOnTarget.RandomScaleXMax),
                            Random.Range(PaintPrefabsOnTarget.RandomScaleYMin, PaintPrefabsOnTarget.RandomScaleYMax),
                            Random.Range(PaintPrefabsOnTarget.RandomScaleZMin, PaintPrefabsOnTarget.RandomScaleZMax));
                        obj.GetComponent<MeshRenderer>().sharedMaterial.enableInstancing = PaintPrefabsOnTarget.GPUInstancing;
                        // obj.hideFlags = HideFlags.HideInHierarchy;
                        temp.StartIndex.Add(temp.GameObjects.Count);
                        temp.GameObjects.Add(obj.gameObject);
                        Selection.activeTransform = obj;
                    }
                }
                else
                {
                    if (Event.current.type == EventType.MouseDown && Event.current.button == 0)
                    {
                        _isPlant = true;
                        temp.StartIndex.Add(temp.GameObjects.Count);
                    }
                    else if (_isPlant && Event.current.type == EventType.Used && Event.current.button == 0)
                    {
                        if (!PaintPrefabsOnTarget.Plants[PaintPrefabsOnTarget.PlantSelect])
                        {
                            Debug.LogError("目标为空，检查资源选择是否正确！");
                            return;
                        }

                        if (_time > 0)
                        {
                            _time -= Time.deltaTime;
                            return;
                        }

                        _time = PaintPrefabsOnTarget.Frequency;

                        var obj = GameObject.Instantiate(PaintPrefabsOnTarget.Plants[PaintPrefabsOnTarget.PlantSelect], temp.transform).transform;
                        obj.position = raycastHit.point;
                        obj.eulerAngles = new Vector3(Random.Range(PaintPrefabsOnTarget.RandomRotationXMin, PaintPrefabsOnTarget.RandomRotationXMax),
                            Random.Range(PaintPrefabsOnTarget.RandomRotationYMin, PaintPrefabsOnTarget.RandomRotationYMax),
                            Random.Range(PaintPrefabsOnTarget.RandomRotationZMin, PaintPrefabsOnTarget.RandomRotationZMax));
                        obj.localScale = new Vector3(Random.Range(PaintPrefabsOnTarget.RandomScaleXMin, PaintPrefabsOnTarget.RandomScaleXMax),
                            Random.Range(PaintPrefabsOnTarget.RandomScaleYMin, PaintPrefabsOnTarget.RandomScaleYMax),
                            Random.Range(PaintPrefabsOnTarget.RandomScaleZMin, PaintPrefabsOnTarget.RandomScaleZMax));
                        // obj.hideFlags = HideFlags.HideInHierarchy;
                        temp.GameObjects.Add(obj.gameObject);
                        Selection.activeTransform = obj;
                    }
                }
            }

            if (_isUp)
            {
                _isUp = false;
                temp.EndIndex.Add(temp.GameObjects.Count);
                temp.StepCount++;
            }
        }
    }
}
#endif