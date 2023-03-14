using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public AnimationInstancing.AnimationInstancing aniIns = null;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            //aniIns.PlayAnimation("idle");
            aniIns.CrossFade("idle", 0.1f);
        }
        if (Input.GetKeyDown(KeyCode.W))
        {
            //aniIns.PlayAnimation("walk");
            aniIns.CrossFade("walk", 0.1f);
        }
        if (Input.GetKeyDown(KeyCode.E))
        {
            //aniIns.PlayAnimation("attack");
            aniIns.CrossFade("attack", 0.1f);
        }
        if (Input.GetKeyDown(KeyCode.R))
        {
            aniIns.PlayAnimation("death");
        }
    }
}
