//
//  ParticleFactory.m
//  Projective
//
//  Created by Kirk Roerig on 12/17/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ParticleFactory.h"

@implementation ParticleFactory

static NSMutableDictionary* PARTICLE_DICT;
static OrderedScene* PARTICLE_SCENE;
static unsigned int PARTICLE_CAPACITIES;

+ (void)initWithScene:(OrderedScene*)scene andCapacities:(unsigned int)capacities;
{
    PARTICLE_SCENE = scene;
    PARTICLE_CAPACITIES = capacities;

    if(PARTICLE_DICT){
        for(id item in PARTICLE_DICT){
            [scene removeObject:item];
        }
    }
    
    PARTICLE_DICT = [[NSMutableDictionary alloc] init];
}

+ (void)spawnParticleOfType:(NSString *)type
              withParticles:(struct ParticleVertex*)particles
                    ofCount:(unsigned int)count
{
    // if the di
    
    if(!PARTICLE_DICT[type]){
        Particles* system = [[Particles alloc] initWithCapacity:PARTICLE_CAPACITIES];
        [PARTICLE_SCENE addObject: system];
        PARTICLE_DICT[type] = system;
    }
    
    [PARTICLE_DICT[type] spawnParticles:particles ofCount:count];
}

+ (void)removeTypeFromScene:(NSString*)type
{
    [PARTICLE_SCENE removeObject:PARTICLE_DICT[type]];
    PARTICLE_DICT[type] = nil;
}

+ (void)removeAllFromScene
{
    for(Particles* system in PARTICLE_DICT){
        [PARTICLE_SCENE removeObject:system];
    }
    
    PARTICLE_DICT = [[NSMutableDictionary alloc] init];
}

+ (void)spawnVerletWithIndices:(NSMutableArray*)indices
                   andVertices:(struct CreepVertex*)verts
                    usingGraph:(Graph*)graph
                   andSkeleton:(CreepSkeleton*)skeleton
                     andNormal:(vec3)normal
{
    VerletParticle* particle = [[VerletParticle alloc] initWithIndices:indices
                                                           andVertices:verts
                                                            usingGraph:graph
                                                           andSkeleton:skeleton];
    [particle addVelocity:normal withRandomness:0.75];
    
    // just add to the scene, no need to keep in the dict,
    // since that is for systems only. And VerletParticles are
    // perishable
    [PARTICLE_SCENE addObject:particle];
}

@end
