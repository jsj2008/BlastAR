//
//  Creep.fsh
//  BlastAR!
//
//  Created by Kirk Roerig on 8/31/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

varying lowp vec4 vColor;

uniform lowp vec4 uColor;

void main(void){
    
    if(vColor.a < 0.5) discard;
    
    gl_FragColor = uColor * vColor;
}