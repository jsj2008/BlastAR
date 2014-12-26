//
//  Weapon.m
//  Projective
//
//  Created by Kirk Roerig on 12/25/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Weapon.h"

@implementation Weapon

- (instancetype)initWithProjectiles:(Projectiles *)projectiles andCamera:(CameraEntity *)cam
{
    self = [super init];
    if(!self) return nil;
    
    _projectiles = projectiles;
    _cam = cam;
    
    [self withAttributeName:"aPosition" andElements:3];
    [self buildWithVertexProg:@"ScreenSpace" andFragmentProg:@"CrossHair"];
    
    return self;
}

- (void)beginFiring
{
    _isTriggerHeld = YES;
}

- (void)endFiring
{
    _isTriggerHeld = NO;
    _timeFiring = 0;
}

- (void)generateProjectiles:(ray3)projectile withOffset:(vec3)off
{
    projectile.n[0] *= -1;
    projectile.n[1] *= -1;
    projectile.n[2] *= -1;
    
    vec3_add(projectile.n, projectile.n, off);
    [self.projectiles fireWithRay:projectile andType:_type];
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return 0;
}

- (GLKVector3)inaccuracyOffset:(float)inaccuracy
{
    GLKVector3 left = GLKVector3MultiplyScalar(self.cam.left, inaccuracy * RAND_F_NORM);
    GLKVector3 up = GLKVector3MultiplyScalar(self.cam.up, inaccuracy * RAND_F_NORM);
    
    return GLKVector3Add(left, up);
}

- (int)damage
{
    return 1;
}

- (void)updateWithTimeElapsed:(double)dt
{
    self.coolDown -= dt;
    
    if(_isTriggerHeld){
        _timeFiring += dt;
    }
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    
}

@end
