//
//  Projectiles.m
//  Projective
//
//  Created by Kirk Roerig on 12/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Projectiles.h"

const unsigned int PROJECTILES_MAX = 100;

@interface Projectiles()

@property (nonatomic) struct Projectile* projectiles;
@property (nonatomic) unsigned int maxLiving;

@end

@implementation Projectiles

- (instancetype)init
{
    self = [super init];
    if(!self) return nil;
    
    _projectiles = malloc(sizeof(struct Projectile) * PROJECTILES_MAX);
    
    [self withAttributeName:"aPosition" andElements:3];
    [self withExplicitStride:sizeof(struct Projectile)];
    
    [self buildWithVertexProg:@"Projectiles" andFragmentProg:@"Projectiles"];
    
    return self;
}

- (void)killIndex:(unsigned int)i
{
    assert(i >= 0 && i < _maxLiving);
    
    if(_maxLiving > 0){
        _projectiles[i] = _projectiles[_maxLiving - 1];
    }
    
    --_maxLiving;
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return 10;
}

- (void)fireWithRay:(ray3)originVelocity andType:(enum ProjectileType)type
{
    if(_maxLiving < PROJECTILES_MAX){
        _projectiles[_maxLiving].lived = 0;
        memcpy(_projectiles[_maxLiving].position, originVelocity.p, sizeof(vec3));
        memcpy(_projectiles[_maxLiving].velocity, originVelocity.n, sizeof(vec3));
        _projectiles[_maxLiving].type = type;
        
        ++_maxLiving;
    }
}

- (void)updateWithTimeElapsed:(double)dt
{
    if(isnan(dt)) return;
    
    for(unsigned int i = 0; i < _maxLiving; ++i){
        struct Projectile* p = _projectiles + i;
        vec3 dp;
        float speed = 100;
        
        switch (p->type) {
            case ProjectileSemi:
            default:
                break;
        }
        
        // update the position with respect to time
        vec3_scale(dp, p->velocity, dt * speed);
        vec3_add(p->position, p->position, dp);
        
        p->lived += dt;
        
        if(p->lived > 1.0f){
            [self killIndex:i];
        }
    }
    
    // update mesh data
    [self.mesh updateData:_projectiles ofSize:sizeof(struct Projectile) * _maxLiving];
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    Shader* shader = [self.shaders firstObject];
    vec4 blue = { 0.1, 0.1, 1.0, 1.0 };
    [shader bind];
    [shader usingArray:blue ofLength:1 andType:vec4Array withName:"uColor"];
    [shader usingMat4x4:viewProjection withName:"uVP"];
    
    [self drawAs:GL_POINTS];
}

@end
