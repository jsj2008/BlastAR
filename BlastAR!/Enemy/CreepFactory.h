//
//  CreepFactory.h
//  Projective
//
//  Created by Kirk Roerig on 12/1/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"
#import "CreepSkeleton.h"

@class CreepSkeleton;

struct CreepVertex{
    vec3 position;
    vec4 color;
    vec3 bones;
};

@interface CreepFactory : NSObject

+ (void)seed:(unsigned int)seed;
+ (int)generateWithMesh:(struct CreepVertex *)mesh
                ofCount:(unsigned int)size
          vertsPerSlice:(unsigned int)vertsPerSlice
      resultingIndicies:(unsigned int **)indices
           withSkeleton:(CreepSkeleton*)skeleton;
+ (Graph*)generateMeshGraphFromIndices:(unsigned int*)indices
                          withVertices:(struct CreepVertex*)vertices
                               ofCount:(unsigned int)count;
@end
