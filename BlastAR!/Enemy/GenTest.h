//
//  GenTest.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/30/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"

#define CREEP_BONES 10

struct genBone;
struct genBone{
    vec3 basePosition;
    vec3 position;
    vec3 velocity;
    struct genBone* last;
    struct genBone* next;
};

struct vertex{
    vec3 position;
    vec4 color;
    vec3 bones;
};

@interface GenSkeleton : NSObject<Updateable>

@property (nonatomic) struct genBone* bones;

@end

@interface GenTest : ShadedMesh<Drawable, Ranked>

@end
