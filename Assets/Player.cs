#region HeadComments
// ********************************************************************
//  Copyright (C) 2023 DefaultCompany
//  作    者：WIN-BLQASHI13
//  文件路径：Assets/Player.cs
//  创建日期：2023/10/11 14:52:14
//  功能描述：
//
// *********************************************************************
#endregion

using UnityEngine;
using System.Collections;

public class Player : MonoBehaviour 
{
    
    public float m_speed = 5.0f;
    public Camera CA;
    public GameObject cube;//获取角色，不推荐这个做法，建议测试使用
        Quaternion camaeraXAngle;//获取鼠标X轴偏移量当摄像机旋转角度
        Quaternion camaeraYAngle;//获取鼠标Y轴偏移量当摄像机旋转角度
     
        public Rigidbody rb_rigidbody;
       // public float m_speed;

     
        void LateUpdate()
        {

          
            float horizontal = Input.GetAxis("Horizontal");//AD
            float vertical = Input.GetAxis("Vertical");//WS
            if (Input.GetKey(KeyCode.W)|Input.GetKey(KeyCode.S))
            {
                rb_rigidbody.velocity = Vector3.forward * vertical * m_speed;
            }

            if (Input.GetKey(KeyCode.A) | Input.GetKey(KeyCode.D))
            {
                rb_rigidbody.velocity = Vector3.right * horizontal * m_speed;

            }

            if (Input.GetAxis("Mouse X") > 0.2)//当鼠标X轴偏移量大于0.3时执行，鼠标偏移量过小不执行(玩家也许只是想上下旋转摄像机但是难免会造成X轴偏移，所以当X轴偏移过小时不执行)
            {
                camaeraXAngle = Quaternion.Slerp(camaeraXAngle, Quaternion.Euler(0, Input.GetAxis("Mouse X"), 0), 0.1f);      //平滑设置旋转角度
                CA.transform.rotation *= camaeraXAngle;//旋转
            }
            else if (Input.GetAxis("Mouse X") < -0.2)
            {
                camaeraXAngle = Quaternion.Slerp(camaeraXAngle, Quaternion.Euler(0, Input.GetAxis("Mouse X"), 0), 0.1f);
                CA.transform.rotation *= camaeraXAngle;
            }
            // if (Input.GetAxis("Mouse Y") < -0.2 && CA.transform.rotation.x > 0.15)
            // {
            //     camaeraYAngle = Quaternion.Slerp(camaeraYAngle, Quaternion.Euler(Input.GetAxis("Mouse Y"), 0, 0), 0.1f);
            //     CA.transform.rotation *= camaeraYAngle;
            // }
            // else if (Input.GetAxis("Mouse Y") > 0.2 && CA.transform.rotation.x < 0.5)
            // {
            //     camaeraYAngle = Quaternion.Slerp(camaeraYAngle, Quaternion.Euler(Input.GetAxis("Mouse Y"), 0, 0), 0.1f);
            //     CA.transform.rotation *= camaeraYAngle;
            // }
            CA.transform.position = (CA.transform.rotation * new Vector3(0, 0, -5) + cube.transform.position);//摄像机的位置设置
          //  CA.transform.LookAt(cube.transform);//摄像机看向角色
        }

}
