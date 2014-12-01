//
//  GenTest.vsh
//  BlastAR!
//
//  Created by Kirk Roerig on 8/31/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//
attribute vec3 aPosition;
attribute vec4 aColor;
attribute vec3 aBones;

uniform mat4 uModel;
uniform mat4 uVP;

uniform vec3 uBonePositions[10];
uniform vec4 uBoneRotations[10];

varying lowp vec4 vColor;

vec4 multQuat(vec4 q1, vec4 q2)
{
    return vec4(
                q1.w * q2.x + q1.x * q2.w + q1.z * q2.y - q1.y * q2.z,
                q1.w * q2.y + q1.y * q2.w + q1.x * q2.z - q1.z * q2.x,
                q1.w * q2.z + q1.z * q2.w + q1.y * q2.x - q1.x * q2.y,
                q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
                );
}

vec3 rotate_vector( vec4 quat, vec3 vec )
{
    vec4 qv = multQuat( quat, vec4(vec, 0.0) );
    return multQuat( qv, vec4(-quat.x, -quat.y, -quat.z, quat.w) ).xyz;
}

void main(){
    int li = int(aBones.x);
    int i  = int(aBones.y);
    int ni = int(aBones.z);
    
    vec3 modelPos = rotate_vector(uBoneRotations[i], aPosition.xyz);
    modelPos += (uBonePositions[li] + uBonePositions[ni]) * 0.25 + uBonePositions[i] * 0.75;
    vec4 worldPos = uModel * vec4(modelPos, 1.0);
    
    vColor = aColor;
    
    gl_Position = uVP * worldPos;
}