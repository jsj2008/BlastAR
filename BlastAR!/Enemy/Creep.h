//
//  Creep.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"
#import "Updateable.h"
#import "ShadedMesh.h"
#import "Shootable.h"

static inline float pdf(vec3 x, int seed){
    float result = 1.0f;
    
    for(int i = 3; i--;){
        int select = seed % 5;
        switch (select) {
            case 0:
                result *= sin(x[i]);
                break;
            case 1:
                result *= cos(x[i]);
                break;
            case 3:
                result *= x[i] * x[i];
                break;
            case 4:
                result *= x[i] * x[i] * x[i];
                break;
            default:
                result += x[i];
                break;
        }
        seed += rand();
    }
    
    return result;
}

@interface Creep : ShadedMesh <Drawable, Updateable, Shootable>

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 velocity;
@property (nonatomic, readonly) int HP;

+ (Sound*) soundHit;

@end
