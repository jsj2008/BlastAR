//
//  Shader.vsh
//  BlastAR!
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

attribute vec4 aPosition;
attribute vec3 aNormal;

varying lowp vec4 colorVarying;

uniform mat4 uWorld;
uniform mat4 uVP;

void main()
{
    vec3 eyeNormal = normalize(-aNormal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = vec4(aNormal * 0.5 + vec3(0.5), 1.0);
    
    gl_Position = uVP * uWorld * aPosition;
}
