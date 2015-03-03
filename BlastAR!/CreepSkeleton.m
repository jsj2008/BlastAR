//
//  CreepSkeleton.m
//  Projective
//
//  Created by Kirk Roerig on 12/1/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "CreepSkeleton.h"

@implementation CreepSkeleton

- (instancetype)init
{
    self = [super init];
    
    if(self){
        _bones = malloc(sizeof(struct genBone) * CREEP_BONES);
        bzero(_bones, sizeof(struct genBone) * CREEP_BONES);

        // connect the bones for the skeleton
        for(int i = CREEP_BONES; i--;){
            _bones[i].next = i + 1 <  CREEP_BONES ? _bones + i + 1 : NULL;
            _bones[i].last = i - 1 >= 0 ? _bones + i - 1 : NULL;
            _bones[i].maxDistance = 0.8f;
            _bones[i].rotation = GLKQuaternionIdentity;
            _bones[i].index = i;
        }
        
        _head = _bones;
    }
    
    return self;
}

- (void)updateWithTimeElapsed:(double)dt
{
    struct genBone* bone = _bones + 1;
    
    while(bone){
        struct genBone* last = bone->last; // toward the nose
        
        vec3 dirFromLast;
        float distToLast;
        float deltaToTargetLength;
        
        // find the vector pointing to the next bone
        // then calculate the length of that vector
        vec3_sub(dirFromLast, bone->position, last->position);
        distToLast = vec3_len(dirFromLast);

        if(distToLast == 0){
            bone = bone->next;
            continue;
        }

        GLKMatrix4 ori = GLKMatrix4MakeLookAt(
            bone->position[0], bone->position[1], bone->position[2],
            last->position[0], last->position[1], last->position[2],
            0, 1, 0
        );
        bone->rotation = GLKQuaternionMakeWithMatrix4(ori);
        
        // figure out how far off the bone position is
        deltaToTargetLength = bone->maxDistance - distToLast;
        
        // scale the vector between bones the the appropriate length
        vec3_scale(dirFromLast, dirFromLast, bone->maxDistance / distToLast);
        
        // update this vertex position
        vec3_add(bone->position, last->position, dirFromLast);
        
        // move toward the tail
        bone = bone->next;
    }
}

- (BOOL)checkIntersection:(vec3)intersection intersectedBone:(struct genBone **)hitBone withProjectile:(ray3)ray
{
    return [self checkIntersection:intersection intersectedBone:hitBone withProjectile:ray withSolutionLessThan:INFINITY];
}

- (BOOL)checkIntersection:(vec3)intersection
          intersectedBone:(struct genBone **)hitBone
           withProjectile:(ray3)ray
     withSolutionLessThan:(float)t
{
    GLfloat solution = 0;
    
    for(int i = CREEP_BONES; i--;){
        struct genBone* bone = _bones + i;
        if(vec3_ray_sphere(intersection, ray, bone->position, bone->radius, &solution)){
            if(solution <= t){
                *hitBone = bone;
                return YES;
            }
        }
    }
    
    return NO;
}

- (struct CreepVertex)transformVertex:(struct CreepVertex*)vertex
{
    struct CreepVertex copy = *vertex;
    struct genBone* bone = _bones + (unsigned int)(copy.bones[1]);
    
    GLKVector3 rot = GLKQuaternionRotateVector3(bone->rotation, GLKVector3MakeWithArray(copy.position));
    vec3_sub(copy.position, bone->position, rot.v);

    return copy;
}

- (void)translate:(vec3)offset
{
    for(int i = CREEP_BONES; i--;){
        struct genBone* bone = _bones + i;
        vec3_add(bone->position, bone->position, offset);
    }
}

- (void)dealloc
{
    free(_bones);
}

@end
