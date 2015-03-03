//
//  Starfield.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Starfield.h"
#import "OPjective.h"

@interface Starfield()

@end

@implementation Starfield

#pragma mark - methods
- (id) initWithStars:(int)stars
{
    self = [super init];
    
    [super withAttributeName:"aPosition" andElements:3];
    
    vec3* starPositions = malloc(sizeof(vec3) * stars);
    
    for(int i = stars; i--;){
        vec3_rand_norm(starPositions[i]);
        vec3_scale(starPositions[i], starPositions[i], RAND_F_NORM + 2.0f);
    }
    [self.mesh updateData:starPositions ofSize:sizeof(vec3) * stars];
    
    free(starPositions);
    
    // build the shaders
    [super buildWithVertexProg:@"Starfield" andFragmentProg:@"Starfield"];
    
    return self;
}

- (int) drawRank
{
    return -3;
}

- (int) updateRank
{
    return 0;
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    Shader* shader = (Shader*)[self.shaders lastObject];
    
    [shader bind];
    [shader usingMat4x4:viewProjection withName:"uVP"];
    [self drawAs:GL_POINTS];
}

@end
