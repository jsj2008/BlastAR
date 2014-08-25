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
    GLfloat mesh[] = {
         0.0f,  0.1f, 0.0,
         0.0f, -0.1f, 0.0,
         0.1f,  0.0f, 0.0,
        -0.1f,  0.0f, 0.0
    };
    
    [self.mesh updateData:mesh ofSize:sizeof(mesh)];
    [self buildWithVertexProg:@"ScreenSpace" andFragmentProg:@"CrossHair"];
    
    return self;
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    
    [self.shader bind];
    [self.shader usingFloat:&AR_ASPECT_RATIO ofLength:1 withName:"uAspect"];
    [self drawAs:GL_LINES];
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
}

@end
