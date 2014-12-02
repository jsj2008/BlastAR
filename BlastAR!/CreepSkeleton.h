//
//  CreepSkeleton.h
//  Projective
//
//  Created by Kirk Roerig on 12/1/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"

#define CREEP_BONES 10

struct genBone;
struct genBone{
    vec3 offsetFromBase;
    vec3 position;
    vec3 velocity;
    float radius;
    GLKQuaternion rotation;
    float maxDistance;
    struct genBone* last;
    struct genBone* next;
};

@interface CreepSkeleton : NSObject <Updateable>

@property (nonatomic) struct genBone* bones;
@property (nonatomic) struct genBone* head;

- (BOOL)checkIntersection:(vec3)intersection withProjectile:(ray3)ray;

@end
