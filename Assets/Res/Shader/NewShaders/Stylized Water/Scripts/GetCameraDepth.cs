using UnityEngine;

namespace StylizedWater
{

    [RequireComponent(typeof(Camera))]
    [ExecuteAlways]
    public class GetCameraDepth : MonoBehaviour
    {
        // private Material _mat;
        void Start()
        {
            Camera cam = GetComponent<Camera>();
            cam.depthTextureMode |= DepthTextureMode.Depth;
            // cam.allowHDR
        }
    }
}