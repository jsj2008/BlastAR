//
//  GenTest.vsh
//  BlastAR!
//
//  Created by Kirk Roerig on 8/31/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//
attribute vec3  aPosition;

uniform mat4 uModel;
uniform mat4 uVP;

void main(){
    vec4 worldPos = uModel * vec4(aPosition, 1.0);
    gl_Position = uVP * worldPos;
}