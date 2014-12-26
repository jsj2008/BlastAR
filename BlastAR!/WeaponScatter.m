//
//  WeaponScatter.m
//  Projective
//
//  Created by Kirk Roerig on 12/25/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "WeaponScatter.h"

@implementation WeaponScatter

- (instancetype)initWithProjectiles:(Projectiles *)projectiles andCamera:(CameraEntity *)cam
{
    self = [super initWithProjectiles:projectiles andCamera:cam];
    if(!self) return nil;
    
    return self;
}

- (void)updateWithTimeElapsed:(double)dt
{
    [super updateWithTimeElapsed:dt];
    
    if(self.isTriggerHeld && self.coolDown <= 0){
        
        for(int i = 10; i--;){
            ray3 projectile;
            memcpy(&projectile.p, VEC3_ZERO, sizeof(vec3));
            memcpy(&projectile.n, self.cam.shootDir.v, sizeof(vec3));
            
            vec3_scale(projectile.n, projectile.n, 200);
            
            [self generateProjectiles:projectile withOffset:[self inaccuracyOffset:5].v];
        }
        
        self.coolDown = 0.5;
    }
}

- (int)damage
{
    return 2;
}

@end
