using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class jiupai_animtion : MonoBehaviour
{
    // Start is called before the first frame update
    private Transform[] go;
    private List<int> _a = new List<int>();

    void Start()
    {
        go = GetComponentsInChildren<Transform>();
        for (int i = 0; i < go.Length; i++)
        {
            var c = (int)Random.Range(-60, 61);
            _a.Add(c);
        }
    }

    void Update()
    {
        
        for (int i = 2; i < go.Length; i++)
        {
           
            go[i].Rotate(Vector3.up,Time.deltaTime*_a[i]);


        }

       

        // go[2].Rotate(Vector3.up,Time.deltaTime*20f);
        // go[3].Rotate(Vector3.up,Time.deltaTime*-8f);
        // go[4].Rotate(Vector3.up,Time.deltaTime*14f);
        // go[5].Rotate(Vector3.up,Time.deltaTime*-11f);
        // go[6].Rotate(Vector3.up,Time.deltaTime*18f);
        // go[7].Rotate(Vector3.up,Time.deltaTime*-6f);
        // go[8].Rotate(Vector3.up,Time.deltaTime*34f);
        // go[9].Rotate(Vector3.up,Time.deltaTime*-25f);
        // go[10].Rotate(Vector3.up,Time.deltaTime*16f);
        // go[11].Rotate(Vector3.up,Time.deltaTime*-12f);
        // go[12].Rotate(Vector3.up,Time.deltaTime*29f);
        // go[13].Rotate(Vector3.up,Time.deltaTime*-15f);
        // go[14].Rotate(Vector3.up,Time.deltaTime*7f);
        // go[15].Rotate(Vector3.up,Time.deltaTime*-9f);
        // go[16].Rotate(Vector3.up,Time.deltaTime*3f);
        // go[17].Rotate(Vector3.up,Time.deltaTime*-14f);
        // go[18].Rotate(Vector3.up,Time.deltaTime*62f);
        // go[19].Rotate(Vector3.up,Time.deltaTime*-12f);
        // go[20].Rotate(Vector3.up,Time.deltaTime*21f);
        // go[21].Rotate(Vector3.up,Time.deltaTime*-8f);
        // go[22].Rotate(Vector3.up,Time.deltaTime*52f);
        // go[23].Rotate(Vector3.up,Time.deltaTime*-10f);
        // go[24].Rotate(Vector3.up,Time.deltaTime*20f);
        // go[25].Rotate(Vector3.up,Time.deltaTime*-10f);
        // go[23].Rotate(Vector3.up,Time.deltaTime*-8f);
        // go[24].Rotate(Vector3.up,Time.deltaTime*15f);
        // go[25].Rotate(Vector3.up,Time.deltaTime*-7f);
        // go[26].Rotate(Vector3.up,Time.deltaTime*-8f);
        // go[27].Rotate(Vector3.up,Time.deltaTime*15f);
        // go[28].Rotate(Vector3.up,Time.deltaTime*-7f);
    }


}
