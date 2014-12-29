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
    
    static vec3 iconVerts[] = {
        { 0, 0.025, 0 },
        { 0, -0.025, 0 }
    };
    
    self.iconOffset = GLKVector3Make(0, -0.65, 0);
    
    [self.mesh updateData:iconVerts ofSize:sizeof(iconVerts)];
    
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

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    Shader* shader = [self.shaders firstObject];
    
    [shader bind];
    [shader usingArray:self.iconOffset.v ofLength:1 andType:vec3Array withName:"uOffset"];
    
    glLineWidth(10.0);
    [self drawAs:GL_LINES];
}

@end
