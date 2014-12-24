//
//  Projectiles.m
//  Projective
//
//  Created by Kirk Roerig on 12/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Projectiles.h"

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
    
    if(_maxLiving >= 1){
        _projectiles[i] = _projectiles[i - 1];
        --_maxLiving;
    }
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return 0;
}

- (void)updateWithTimeElapsed:(double)dt
{
    for(unsigned int i = _maxLiving; i--;){
        struct Projectile* p = _projectiles + i;
        vec3 dp;
        
        // update the position with respect to time
        vec3_scale(dp, p->origin.n, dt);
        vec3_add(p->origin.p, p->origin.p, dp);
        
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
    
    [self.mesh drawAs:GL_POINTS];
}

@end
