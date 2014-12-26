//
//  WeaponSemi.m
//  Projective
//
//  Created by Kirk Roerig on 12/25/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "WeaponSemi.h"

@implementation WeaponSemi

- (instancetype)initWithProjectiles:(Projectiles *)projectiles andCamera:(CameraEntity *)cam
{
    self = [super initWithProjectiles:projectiles andCamera:cam];
    if(!self) return nil;
    
    return self;
}

- (void)beginFiring
{
    [super beginFiring];
    
    ray3 projectile;
    memcpy(&projectile.p, VEC3_ZERO, sizeof(vec3));
    memcpy(&projectile.n, self.cam.shootDir.v, sizeof(vec3));
    
    vec3_scale(projectile.n, projectile.n, 200);
    
    [self generateProjectiles:projectile withOffset:[self inaccuracyOffset:0.1].v];
}

- (int)damage
{
    return 10;
}

@end
