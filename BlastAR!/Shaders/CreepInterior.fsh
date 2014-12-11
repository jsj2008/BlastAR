//
//  CreepInterior.fsh
//  BlastAR!
//
//  Created by Kirk Roerig on 12/10/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

varying lowp vec4 vColor;

void main(void){
    
    if(vColor.a < 0.5) discard;
    
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}