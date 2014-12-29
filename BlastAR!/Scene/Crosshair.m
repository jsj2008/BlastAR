//
//  Crosshair.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Crosshair.h"
#import "Singletons.h"

@interface Crosshair()

@end

@implementation Crosshair

- (id) init
{
    self = [super init];
    
    [self withAttributeName:"aPosition" andElements:3];
    
    // cross hair geometry
    const unsigned int meshLen = 80;
    float s = 0.1f;
    vec3 mesh[meshLen];
    bzero(mesh, sizeof(mesh));
    float dt = (M_PI * 2.0f) / (float)meshLen;
    for(int i = 0; i < meshLen; ++i){
        float t = dt * i;
        
        mesh[i][0] = cos(t) * s;
        mesh[i][1] = sin(t) * s;
    }
    
    [self.mesh updateData:mesh ofSize:sizeof(mesh)];
    [self buildWithVertexProg:@"ScreenSpace" andFragmentProg:@"CrossHair"];
    
    return self;
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    glEnable(GL_BLEND);
    glLineWidth(1.0f);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    
    vec4 blue = { 0.6, 0.6, 0.9, 0.25f };
    vec4 light = { 0.1, 0.1, 0.1, 0.125f };
    
    Shader* shader = (Shader*)[self.shaders lastObject];
    
    [shader bind];
    [shader usingFloat:&AR_ASPECT_RATIO ofLength:1 withName:"uAspect"];
    [shader usingArray:VEC3_ZERO ofLength:1 andType:vec3Array withName:"uOffset"];
    
    [shader usingArray:light ofLength:1 andType:vec4Array withName:"uColor"];
    [self drawAs:GL_TRIANGLE_FAN];
    
    [shader usingArray:blue ofLength:1 andType:vec4Array withName:"uColor"];
    [self drawAs:GL_LINE_LOOP];
    
    glEnable(GL_DEPTH_TEST);
}

- (int) drawRank
{
    return 1;
}

- (int) updateRank
{
    return 0;
}

@end
