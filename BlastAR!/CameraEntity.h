//
//  CameraEntity.h
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"

@interface CameraEntity : NSObject <Updateable, Ranked>

@property (nonatomic, readonly) GLKVector3 shootDir;
@property (nonatomic, readonly) GLKMatrix4 viewProjection;
@property (nonatomic, readonly) GLKQuaternion orientation;
@property (nonatomic) float aspect;

@end
