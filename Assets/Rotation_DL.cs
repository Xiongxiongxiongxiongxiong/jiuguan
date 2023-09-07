using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation_DL : MonoBehaviour
{
    // Start is called before the first frame update
    public Material ma;
    void Start()
    {
       
        
    }

    // Update is called once per frame
    void Update()
    {
        ma.SetVector("_EmissionColor",new Vector4(Mathf.Sin(Time.time)*0.5f,Mathf.Sin(Time.time)*0.5f,Mathf.Sin(Time.time)*0.5f,Mathf.Sin(Time.time)*0.5f)*0.5f) ;
        transform.Rotate(Vector3.left,Mathf.Sin(Time.time)*0.05f);
        
    }
}
