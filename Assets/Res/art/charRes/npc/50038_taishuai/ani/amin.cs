using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class amin : MonoBehaviour
{
    // Start is called before the first frame update
    private Animator anim;
    void Start()
    {
        anim = transform.GetComponent<Animator>();
       // anim.applyRootMotion = true;
    }

    // Update is called once per frame
    void Update()
    {
       anim.SetBool("huanying",true);
    }
}
