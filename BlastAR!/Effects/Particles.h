//
//  Particles.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/24/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"
#import "ShadedMesh.h"
#import "Updateable.h"
#import "Drawable.h"

struct ParticleVertex{
    vec3 position;
    vec3 velocity;
    vec4 color;
    float size;
    float birth;
    float life;
};

@interface Particles : ShadedMesh<Drawable, Updateable>

- (id) initWithCapacity:(int)capacity;
- (void) spawnParticleAtPosition:(vec3)position withVelocity:(vec3)velocity andColor:(vec4)color andSize:(float)size andLifespan:(float)lifespan;
- (void) spawnParticles:(struct ParticleVertex*)particles ofCount:(int)count;

@end
