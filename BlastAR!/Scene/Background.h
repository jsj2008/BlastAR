//
//  Background.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"
#import "RosyWriterVideoProcessor.h"

@interface Background : ShadedMesh <RosyWriterVideoProcessorDelegate, Drawable, Ranked>

- (id) initWithGLKview:(GLKViewController*)view andGLContext:(CVEAGLContext)context;
- (void) setHue:(vec3)color;

@end
