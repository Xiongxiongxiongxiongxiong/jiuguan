using UnityEngine;

namespace StylizedWater
{

    [RequireComponent(typeof(Camera))]
    [ExecuteAlways]
    public class GetCameraDepth : MonoBehaviour
    {
        // private Material _mat;
        private Camera _cam;
        void Start()
        {
            _cam = GetComponent<Camera>();
            _cam.depthTextureMode |= DepthTextureMode.Depth;
            // cam.allowHDR
        }
        private void Update()
        {
            if (!_cam.depthTextureMode.HasFlag(DepthTextureMode.Depth))
            {
                _cam.depthTextureMode |= DepthTextureMode.Depth;
            }
        }
    }
}