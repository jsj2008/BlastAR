//
//  Projectiles.m
//  Projective
//
//  Created by Kirk Roerig on 12/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Projectiles.h"
#import "Shootable.h"

const unsigned int PROJECTILES_MAX = 100;

@interface Projectiles()

@property SEL intersectionSelector;

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

- (instancetype)initWithIntersectionSelector:(SEL)intersectionCallback
{
    self = [self init];
    if(!self) return nil;
    
    _intersectionSelector = intersectionCallback;
    
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
        _projectiles[_maxLiving].positionVelocity = originVelocity;
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
        
        switch (p->type) {
            case ProjectileSemi:
            default:
                break;
        }
        
        // update the position with respect to time
        vec3_scale(dp, p->positionVelocity.n, dt);
        vec3_add(p->positionVelocity.p, p->positionVelocity.p, dp);
        
        p->lived += dt;
        
        if(p->lived > 2.0f){
            [self killIndex:i];
        }
    }
    
    // update mesh data
    [self.mesh updateData:_projectiles ofSize:sizeof(struct Projectile) * _maxLiving];
}

- (void)performIntersctionCheck:(NSArray*)targets withDamage:(float)damage andElapsed:(float)dt
{
    vec3 hitPoint;
    
    for(id<Shootable> target in targets){
        for(unsigned int i = 0; i < _maxLiving; ++i){
            struct Projectile* p = _projectiles + i;
            
            if([target fireAt:p->positionVelocity
            withIntersection:hitPoint
         andSolutionLessThan:dt
                  withDamage:damage]){
                target.lastHitPoint = GLKVector3MakeWithArray(hitPoint);
                [self performSelector:self.intersectionSelector withObject:target];
            }
        }
    }
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    Shader* shader = [self.shaders firstObject];
    vec4 blue = { 0.1, 0.1, 1.0, 1.0 };
    [shader bind];
    [shader usingArray:blue ofLength:1 andType:vec4Array withName:"uColor"];
    [shader usingMat4x4:viewProjection withName:"uVP"];
    
    glDisable(GL_DEPTH_TEST);
    [self drawAs:GL_POINTS];
    glEnable(GL_DEPTH_TEST);
}

@end
