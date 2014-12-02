//
//  Creep.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Creep.h"
#import "CreepSkeleton.h"
#import "CreepFactory.h"

@interface Creep()

@property (nonatomic) float radius;
@property (nonatomic) float scaleVelocity;
@property (nonatomic) float scale;
@property (nonatomic) CreepSkeleton* skeleton;
@property (nonatomic) unsigned int* indices;

@end

@implementation Creep

+ (Sound*) soundHit
{
    static Sound* hitSounds;
    
    if(!hitSounds){
        const int samples = 5525;
        short* pcm = (short*)malloc(sizeof(short) * samples);
        
        for(int i = samples; i--;){
            float p = (i - (samples >> 1)) / (float)(samples >> 1);
            p *= p;
            pcm[i] = (short)(RAND_F_NORM * SHRT_MAX * p);
        }
        
        hitSounds = [[Sound alloc] initWithData: pcm
                                       ofLength: samples * sizeof(short)
                                       asStereo: NO
                                 withSoundCount: 5
                     ];
    }
    
    return hitSounds;
}

- (id) init
{
    self = [super init];
    
    if(self){
        _skeleton = [[CreepSkeleton alloc] init];
        
        [self withAttributeName:"aPosition" andElements:3];
        [self withAttributeName:"aColor" andElements:4];
        [self withAttributeName:"aBones" andElements:3];
        
        const int vertexCount = 100;
        struct CreepVertex verts[vertexCount] = {0};

        int indexCount = [CreepFactory generateWithMesh:verts
                                                ofCount:vertexCount
                                      resultingIndicies:&_indices
                                           withSkeleton:_skeleton];
        [self.mesh updateData:verts ofSize:sizeof(verts) andIndicies:_indices ofSize:sizeof(unsigned int) * indexCount];
        
        _radius = 1.0f;
        
        static vec3 spawnLimiter = { 1, 0.25f, 1 };
        
        
        // compile shaders
        [super buildWithVertexProg:@"Creep" andFragmentProg:@"Creep"];
    
        [Creep soundHit];
        
        vec3_rand_norm(_position.v);
        vec3_mul(_position.v, _position.v, spawnLimiter);
        vec3_scale(_position.v, _position.v, 15.0);
        
        vec3_rand_norm(_velocity.v);
        
        _HP = 3;
    }
    
    return self;
}

- (void) updateWithTimeElapsed:(double)dt
{
    // for now, don't update if dead
    if(!_HP) return;
    
    // seek the player
    {
        vec3 dpos   = {0};
        vec3 left   = {0};
        vec3 up     = { 0, 1, 0 };
        
        vec3_sub(dpos, (float*)VEC3_ZERO, _position.v);
        float dist = vec3_len(dpos);
        
        // compute the left vector
        vec3_mul_cross(left, dpos, up);
        vec3_norm(left, left);
        vec3_scale(left, left, sin(dist * 2 * M_PI) * dist);
        
        // compute the up vector
        vec3_mul_cross(up, dpos, left);
        vec3_norm(up, up);
        vec3_scale(up, up, sin(dist * 2 * M_PI) * dist);
        
        vec3_add(dpos, dpos, left);
        vec3_add(dpos, dpos, up);
        
        vec3_norm(dpos, dpos);
        vec3_scale(dpos, dpos, dt);
        
        vec3_add(_velocity.v, _velocity.v, dpos);
        vec3_scale(_velocity.v, _velocity.v, 0.94f);
    }
    
    // update position
    {
        vec3 dpos = {0};
        vec3_scale(dpos, _velocity.v, dt);
        vec3_add(_position.v, _position.v, dpos);
    }
    
    _scaleVelocity += (1.0f - _scale) * 150 * dt / 2.0f;
    _scaleVelocity *= 0.9f;
    _scale += _scaleVelocity * dt;
    
    // update the head's position and update the skeleton
    memcpy(self.skeleton.head->position, _position.v, sizeof(vec3));
    [self.skeleton updateWithTimeElapsed:dt];
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    // for now, don't draw if dead
    if(!_HP) return;
    
    vec3 bonePositions[CREEP_BONES];
    vec4 boneRotations[CREEP_BONES];
    
    // copy bone positions and rotations for use as uniforms
    for(int i = CREEP_BONES; i--;){
        memcpy(bonePositions + i, _skeleton.bones[i].position, sizeof(vec3));
        memcpy(boneRotations + i, _skeleton.bones[i].rotation.q, sizeof(vec4));
    }
    
    glLineWidth(2);
    
    [self.shader bind];
    [self.shader usingMat4x4:viewProjection withName:"uVP"];
    [self.shader usingMat4x4:(GLKMatrix4*)&GLKMatrix4Identity withName:"uModel"];
    [self.shader usingArray:bonePositions ofLength:CREEP_BONES andType:vec3Array withName:"uBonePositions"];
    [self.shader usingArray:boneRotations ofLength:CREEP_BONES andType:vec4Array withName:"uBoneRotations"];
    [self drawAs:GL_LINE_STRIP];
}

- (BOOL) fireAt:(ray3)projectile
{
    // don't intersect things that are dead already.
    if(!_HP) return NO;
    
    vec3 hitPoint = {0};
    if([self.skeleton checkIntersection:hitPoint withProjectile:projectile]){
        --_HP;
    }
    
    return NO;
}

- (int) drawRank
{
    return 0;
}

- (int) updateRank
{
    return 0;
}

- (void)dealloc
{
    free(_indices);
}

@end
