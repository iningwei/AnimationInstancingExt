using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace AnimationInstancing
{
    class UtilityHelper
    {
        public static Matrix4x4[] CalculateSkinMatrix(Transform[] bonePose,
            Matrix4x4[] bindPose,
            Matrix4x4 rootMatrix1stFrame,
            bool haveRootMotion)
        {
            if (bonePose.Length == 0)
                return null;

            Transform root = bonePose[0];
            while (root.parent != null)
            {
                root = root.parent;
            }
            Matrix4x4 rootMat = root.worldToLocalMatrix;

            Matrix4x4[] matrix = new Matrix4x4[bonePose.Length];
            for (int i = 0; i != bonePose.Length; ++i)
            {
                matrix[i] = rootMat * bonePose[i].localToWorldMatrix * bindPose[i];
            }
            return matrix;
        }

        public static Matrix4x4[] CalculateSkinMatrixRST(Transform[] bonePose,
  Matrix4x4[] bindPose,
  Matrix4x4 rootMatrix1stFrame,
  bool haveRootMotion)
        {
            if (bonePose.Length == 0)
                return null;

            Transform root = bonePose[0];
            while (root.parent != null)
            {
                root = root.parent;
            }
            Matrix4x4 rootMat = root.worldToLocalMatrix;
            Matrix4x4 boneMatrix = Matrix4x4.identity;
            Matrix4x4 tempMatrix = Matrix4x4.identity;
            Matrix4x4[] matrix = new Matrix4x4[bonePose.Length];
            for (int i = 0; i != bonePose.Length; ++i)
            {
                boneMatrix = rootMat * bonePose[i].localToWorldMatrix * bindPose[i];
                tempMatrix = QuaternionToMatrix(boneMatrix.rotation);
                matrix[i].m00 = boneMatrix.rotation.x;
                matrix[i].m01 = boneMatrix.rotation.y;
                matrix[i].m02 = boneMatrix.rotation.z;
                matrix[i].m03 = boneMatrix.rotation.w;
                matrix[i].m10 = boneMatrix.m03;
                matrix[i].m11 = boneMatrix.m13;
                matrix[i].m12 = boneMatrix.m23;
                matrix[i].m13 = 0;
            }
            return matrix;
        }


        public static Matrix4x4 QuaternionToMatrix(Quaternion quat) // convert quaterinion rotation to mat, zeros out the translation component.
        {

            float xx = quat[0] * quat[0];
            float yy = quat[1] * quat[1];
            float zz = quat[2] * quat[2];
            float xy = quat[0] * quat[1];
            float xz = quat[0] * quat[2];
            float yz = quat[1] * quat[2];
            float wx = quat[3] * quat[0];
            float wy = quat[3] * quat[1];
            float wz = quat[3] * quat[2];
            Matrix4x4 mat = Matrix4x4.identity;

            // mat.m00  = 1 - 2 * ( yy + zz );
            // mat.m10  =     2 * ( xy - wz );
            // mat.m20  =     2 * ( xz + wy );

            // mat.m01 =     2 * ( xy + wz );
            // mat.m11 = 1 - 2 * ( xx + zz );
            // mat.m21 =     2 * ( yz - wx );

            // mat.m02 =     2 * ( xz - wy );
            // mat.m12 =     2 * ( yz + wx );
            // mat.m22 = 1 - 2 * ( xx + yy );

            mat.m00 = 1 - 2 * (yy + zz);
            mat.m01 = 2 * (xy - wz);
            mat.m02 = 2 * (xz + wy);

            mat.m10 = 2 * (xy + wz);
            mat.m11 = 1 - 2 * (xx + zz);
            mat.m12 = 2 * (yz - wx);

            mat.m20 = 2 * (xz - wy);
            mat.m21 = 2 * (yz + wx);
            mat.m22 = 1 - 2 * (xx + yy);


            mat.m30 = mat.m31 = mat.m32 = 0.0f;
            mat.m03 = mat.m13 = mat.m23 = 0.0f;
            mat.m33 = 1.0f;

            return mat;
        }


        public static void CopyMatrixData(GenerateOjbectInfo dst, GenerateOjbectInfo src)
        {
            dst.animationTime = src.animationTime;
            dst.boneListIndex = src.boneListIndex;
            dst.frameIndex = src.frameIndex;
            dst.nameCode = src.nameCode;
            dst.stateName = src.stateName;
            dst.worldMatrix = src.worldMatrix;
            dst.boneMatrix = src.boneMatrix;
        }

        public static Color[] Convert2Color(Matrix4x4[] boneMatrix)
        {
            Color[] color = new Color[boneMatrix.Length * 4];
            int index = 0;
            foreach (var obj in boneMatrix)
            {
                color[index++] = obj.GetRow(0);
                color[index++] = obj.GetRow(1);
                color[index++] = obj.GetRow(2);
                color[index++] = obj.GetRow(3);
            }
            return color;
        }
    }
}
