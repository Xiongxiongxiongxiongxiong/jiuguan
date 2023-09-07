using UnityEngine;
using UnityEngine.Rendering;

namespace StylizedWater
{
	[RequireComponent(typeof(Light))]
	[ExecuteAlways]
	public class GrabShadowMap : MonoBehaviour
	{
		public string textureName = "_MainDirectionalShadowMap";

		private CommandBuffer cmd = null;

		void OnEnable()
		{
			Debug.Log(gameObject);
			Setup();
		}

		void OnValidate()
		{
			Setup();
		}

		void Start()
		{
			Setup();
		}

		void OnDestroy()
		{
			Cleanup();
		}

		void Setup()
		{
			Cleanup();
			cmd = new CommandBuffer();
			cmd.name = textureName + " (Shadow Map Copy)";
			cmd.SetGlobalTexture(textureName, new RenderTargetIdentifier(BuiltinRenderTextureType.CurrentActive));
			Light light = GetComponent<Light>();
			if (light != null)
			{
				light.AddCommandBuffer(LightEvent.AfterShadowMap, cmd);
			}
		}

		void Cleanup()
		{
			Light light = GetComponent<Light>();
			if (light != null)
			{
				light.RemoveAllCommandBuffers();
			}

			Shader.SetGlobalTexture(textureName, null);
		}
	}
}