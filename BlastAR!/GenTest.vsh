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

uniform vec3 uBones[10];

varying lowp vec4 vColor;

void main(){
    int li = int(aBones.x);
    int i  = int(aBones.y);
    int ni = int(aBones.z);
    
    vec3 modelPos = aPosition.xyz + (uBones[li] + uBones[ni]) * 0.25 + uBones[i] * 0.75;
    vec4 worldPos = uModel * vec4(modelPos, 1.0);
    
    vColor = aColor;
    
    gl_Position = uVP * worldPos;
}