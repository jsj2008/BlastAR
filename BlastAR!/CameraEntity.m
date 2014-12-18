//
//  CameraEntity.m
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "CameraEntity.h"

@interface CameraEntity()

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation CameraEntity

- (instancetype)init
{
    self = [super init];
    
    if(!self) return nil;
    
    _motionManager = [[CMMotionManager alloc] init];    
    [_motionManager startDeviceMotionUpdates];
    _motionManager.deviceMotionUpdateInterval = 0.01;
    _orientation = GLKQuaternionIdentity;
    
    return self;
}

- (void)dealloc
{
    [_motionManager stopDeviceMotionUpdates];
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return -100;
}

- (void)updateWithTimeElapsed:(double)dt
{
    // create and update the view projection matrix
    static const GLKVector3 forward = { 0, 0, 1 };
    static const GLKVector3 up      = { 1, 0, 0 };
    
    CMQuaternion q = self.motionManager.deviceMotion.attitude.quaternion;
    _orientation = GLKQuaternionMake(q.x, q.y, q.z, q.w);
    
    _shootDir = GLKQuaternionRotateVector3(_orientation, forward);
    GLKVector3 adjUp = GLKQuaternionRotateVector3(_orientation, up);
    
    GLKVector3Normalize(_shootDir);
    GLKVector3Normalize(adjUp);
    
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(
                                                 _shootDir.x, _shootDir.y, _shootDir.z,
                                                 0, 0, 0,
                                                 adjUp.x, adjUp.y, adjUp.z
                                                 );
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(54.0f), _aspect, 0.1f, 100.0f);
    _viewProjection = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
}

@end
