//
//  VerletParticle.h
//  Projective
//
//  Created by Kirk Roerig on 12/10/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Rendering/ShadedMesh.h"
#import "CreepFactory.h"

#define VERLET_MAX_EDGES 6

struct VerletVertex{
    vec3 position;
    vec4 color;
};

struct VerletSimVertex{
    struct VerletVertex drawing;
    vec3 velocity;
    unsigned int indexKey;
    struct VerletSimVertex* edges[VERLET_MAX_EDGES];
};

@interface VerletParticle : ShadedMesh<Drawable, Updateable>

- (void)appendVertex:(struct CreepVertex*)vertex withIndex:(unsigned int)indexKey;

@end
