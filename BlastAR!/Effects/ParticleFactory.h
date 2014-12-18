//
//  ParticleFactory.h
//  Projective
//
//  Created by Kirk Roerig on 12/17/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Particles.h"
#import "VerletParticle.h"
#import "CreepSkeleton.h"

@interface ParticleFactory : NSObject

+ (void)initWithScene:(OrderedScene*)scene andCapacities:(unsigned int)capacities;
+ (void)spawnParticleOfType:(NSString*)type withParticles:(struct ParticleVertex*)particles ofCount:(unsigned int)count;
+ (void)spawnVerletWithIndices:(NSMutableArray*)indices
                   andVertices:(struct CreepVertex*)verts
                    usingGraph:(Graph*)graph
                   andSkeleton:(CreepSkeleton*)skeleton
                     andNormal:(vec3)normal;
+ (void)removeTypeFromScene:(NSString*)type;
+ (void)removeAllFromScene;

@end
