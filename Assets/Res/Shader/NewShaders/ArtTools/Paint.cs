using System;
using System.Collections.Generic;
using UnityEngine;

namespace ArtTools.Paint
{
    [RequireComponent(typeof(MeshCollider))]
    public class Paint : MonoBehaviour
    {
#if UNITY_EDITOR

        [SerializeField] private List<GameObject> _gameObjects = new List<GameObject>();
        [SerializeField] private int stepCount;
        [SerializeField] private List<int> startIndex;
        [SerializeField] private List<int> endIndex;

        public List<GameObject> GameObjects
        {
            get => _gameObjects;
            set => _gameObjects = value;
        }

        public List<int> StartIndex
        {
            get => startIndex;
            set { startIndex = value; }
        }

        public List<int> EndIndex
        {
            get => endIndex;
            set { endIndex = value; }
        }

        public int StepCount
        {
            get => stepCount;
            set
            {
                if (value < 0) return;
                stepCount = value;
            }
        }

        /// <summary>
        /// 撤回
        /// </summary>
        public void Undo()
        {
            stepCount--;
            for (int i = endIndex[stepCount] - 1; i >= startIndex[stepCount]; i--)
            {
                DestroyImmediate(GameObjects[i]);
            }

            GameObjects.RemoveRange(startIndex[stepCount], endIndex[stepCount] - startIndex[stepCount]);
            startIndex.RemoveAt(stepCount);
            endIndex.RemoveAt(stepCount);
        }

        /// <summary>
        /// 清空
        /// </summary>
        public void Clear()
        {
            foreach (var obj in GameObjects)
            {
                DestroyImmediate(obj);
            }

            stepCount = 0;
            startIndex.Clear();
            endIndex.Clear();
            GameObjects.Clear();
        }
#endif
    }
}