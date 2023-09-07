using UnityEngine;

namespace Renderering.PlanarReflection
{
    public enum Resolution
    {
        Low256,
        Middle512,
        High1024,
        Ulti2048
    }
    
    // [ExecuteInEditMode]
    public class PlanarReflection : MonoBehaviour
    {
        public Camera followCamera;
        private Camera _reflectionCam;
        private bool _isRendering = false;
        private Matrix4x4 _reflectionMatrix;
        private RenderTexture _reflectionTex;
        public LayerMask reflectionLayerMask = ~0;
        public Resolution resolution = Resolution.Middle512;
        public float planeOffset = 0;
        private static readonly int ReflectionTex = Shader.PropertyToID("_ReflectionTex");

        public void Awake()
        {
            switch (resolution)
            {
                case Resolution.Low256:
                    _reflectionTex = new RenderTexture(256, 256, 0);
                    break;
                case Resolution.Middle512:
                    _reflectionTex = new RenderTexture(512, 512, 0);
                    break;
                case Resolution.High1024:
                    _reflectionTex = new RenderTexture(1024, 1024, 0);
                    break;
                case Resolution.Ulti2048:
                    _reflectionTex = new RenderTexture(2048, 2048, 0);
                    break;
            }
            
            if (!_reflectionCam)
            {
                GameObject cam = new GameObject("ReflectionCamera", typeof(Camera))
                {
                    hideFlags = HideFlags.HideAndDontSave
                };
                _reflectionCam = cam.GetComponent<Camera>();
                _reflectionCam.fieldOfView = followCamera.fieldOfView;
                _reflectionCam.aspect = followCamera.aspect;
                _reflectionCam.targetTexture = _reflectionTex;
                _reflectionCam.cullingMask = reflectionLayerMask;
                _reflectionCam.allowMSAA = false;
                _reflectionCam.useOcclusionCulling = false;
                _reflectionCam.allowHDR = true;
                _reflectionCam.enabled = false;
            }

        }

        private void OnWillRenderObject()
        {
            if (_isRendering) return;
            _isRendering = true;

            float d = -Dot(transform.up, transform.position) - planeOffset;
            Vector3 normal = transform.up;
            Vector4 plane = new Vector4(normal.x, normal.y, normal.z, d);
            _reflectionMatrix = Matrix4x4.identity;
            CalculateReflectionMatrix(ref _reflectionMatrix, plane);

            _reflectionCam.worldToCameraMatrix = followCamera.worldToCameraMatrix * _reflectionMatrix;

            Vector4 viewPlane = CameraSpacePlane(_reflectionCam.worldToCameraMatrix, transform.position, normal);
            _reflectionCam.projectionMatrix = _reflectionCam.CalculateObliqueMatrix(viewPlane);
            GL.invertCulling = true;
            _reflectionCam.Render();
            Shader.SetGlobalTexture(ReflectionTex, _reflectionTex);

            GL.invertCulling = false;
            _isRendering = false;
        }

        private float Dot(Vector3 a, Vector3 b)
        {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        private void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
        {
            reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
            reflectionMat.m01 = (-2F * plane[0] * plane[1]);
            reflectionMat.m02 = (-2F * plane[0] * plane[2]);
            reflectionMat.m03 = (-2F * plane[3] * plane[0]);

            reflectionMat.m10 = (-2F * plane[1] * plane[0]);
            reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
            reflectionMat.m12 = (-2F * plane[1] * plane[2]);
            reflectionMat.m13 = (-2F * plane[3] * plane[1]);

            reflectionMat.m20 = (-2F * plane[2] * plane[0]);
            reflectionMat.m21 = (-2F * plane[2] * plane[1]);
            reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
            reflectionMat.m23 = (-2F * plane[3] * plane[2]);
        }

        private Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal)
        {
            Vector3 offsetPos = pos + normal * planeOffset;
            Vector3 cpos = worldToCameraMatrix.MultiplyPoint3x4(offsetPos);
            Vector3 cnormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
            float d = -Dot(cpos, cnormal);
            return new Vector4(cnormal.x, cnormal.y, cnormal.z, d);
        }
    }
}