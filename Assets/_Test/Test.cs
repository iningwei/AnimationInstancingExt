using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public AnimationInstancing.AnimationInstancing aniIns = null;
    private void Start()
    {

    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            //aniIns.PlayAnimation("idle_0");
            aniIns.CrossFade("idle_0", 0.1f);
        }
        if (Input.GetKeyDown(KeyCode.W))
        {
            //aniIns.PlayAnimation("walk");
            aniIns.CrossFade("walk_0", 0.1f);
        }
        if (Input.GetKeyDown(KeyCode.E))
        {
            //aniIns.PlayAnimation("attack");
            aniIns.CrossFade("attack_0", 0.1f);
        }
        if (Input.GetKeyDown(KeyCode.R))
        {
            aniIns.PlayAnimation("death_0");
        }
    }
}
