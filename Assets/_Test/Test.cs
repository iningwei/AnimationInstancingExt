using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public AnimationInstancing.AnimationInstancing aniIns = null;
    private void Start()
    {
        Vector3 pos1 = new Vector3(361.58f, 2.08f, 91.05f);
        Vector3 pos2 = new Vector3(345.78f, 1.11f, 96.47f);
        float dis = Vector3.Distance(pos2, pos1);
        Debug.LogError("dis:::" + dis);
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
