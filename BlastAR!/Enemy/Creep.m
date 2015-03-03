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
#import "VerletParticle.h"

@interface Creep()

@property (nonatomic) float radius;
@property (nonatomic) float scaleVelocity;
@property (nonatomic) float scale;
@property (nonatomic) CreepSkeleton* skeleton;
@property (nonatomic) struct CreepVertex* vertices;
@property (nonatomic) unsigned int* indices;
@property (nonatomic) int indexCount, vertexCount;
@property (nonatomic) Graph* meshGraph;

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
        
        _vertexCount = 50;
        _vertices = malloc(_vertexCount * sizeof(struct CreepVertex));

        _indexCount = [CreepFactory generateWithMesh:_vertices
                                             ofCount:_vertexCount
                                       vertsPerSlice:5
                                   resultingIndicies:&_indices
                                        withSkeleton:_skeleton];
        _meshGraph = [CreepFactory generateMeshGraphFromIndices:_indices
                                                   withVertices:(struct CreepVertex*)_vertices
                                                        ofCount:_indexCount];
        
        [self.mesh updateData:_vertices
                       ofSize:sizeof(struct CreepVertex) * _vertexCount
                  andIndicies:_indices
                       ofSize:sizeof(unsigned int) * _indexCount];
        
        _radius = 1.0f;
        
        static vec3 spawnLimiter = { 1, 0.25f, 1 };
        
        
        // compile shaders
        [super buildWithVertexProg:@"Creep" andFragmentProg:@"Creep"];
    
        [Creep soundHit];
        
        vec3_rand_norm(_position.v);
        vec3_mul(_position.v, _position.v, spawnLimiter);
        vec3_scale(_position.v, _position.v, 60.0);
        
        [_skeleton translate:_position.v];
        
        vec3_rand_norm(_velocity.v);
        
        _HP = 20;
    
        [_skeleton updateWithTimeElapsed:0];
    }
    
    return self;
}

- (instancetype)initWithPosition:(GLKVector3)position
{
    self = [self init];
    if(!self) return nil;

    _position = position;
    [_skeleton translate:_position.v];

    return self;
}

- (void)dealloc
{
    free(_vertices);
    free(_indices);
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
        vec3_scale(left, left, sin(dist * M_PI) * 100);
        
        // compute the up vector
        vec3_mul_cross(up, dpos, left);
        vec3_norm(up, up);
        vec3_scale(up, up, sin(dist * M_PI) * 100);
        
        vec3_add(dpos, dpos, left);
        vec3_add(dpos, dpos, up);
        
//        vec3_norm(dpos, dpos);
        vec3_scale(dpos, dpos, dt);
        
        vec3_add(_velocity.v, _velocity.v, dpos);
        vec3_scale(_velocity.v, _velocity.v, 0.8f);
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
 
    Shader* shader = [self.shaders lastObject];
    
    vec3 bonePositions[CREEP_BONES];
    vec4 boneRotations[CREEP_BONES];
    
    // copy bone positions and rotations for use as uniforms
    for(int i = CREEP_BONES; i--;){
        memcpy(bonePositions + i, _skeleton.bones[i].position, sizeof(vec3));
        memcpy(boneRotations + i, _skeleton.bones[i].rotation.q, sizeof(vec4));
    }
    
//    glLineWidth(2 * [UIScreen mainScreen].scale);

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [shader bind];
    [shader usingMat4x4:viewProjection withName:"uVP"];
    [shader usingArray:bonePositions ofLength:CREEP_BONES andType:vec3Array withName:"uBonePositions"];
    [shader usingArray:boneRotations ofLength:CREEP_BONES andType:vec4Array withName:"uBoneRotations"];

    // render the black fill
//    vec4 black = { 0, 0, 0, 1 };
//    [shader usingArray:black ofLength:1 andType:vec4Array withName:"uColor"];
//    [self drawAs:GL_TRIANGLES];
//    
    // render the wire frame
    [shader usingArray:(GLfloat*)VEC4_ONE ofLength:1 andType:vec4Array withName:"uColor"];
    [self drawAs:GL_LINES];
    
//    glEnable(GL_DEPTH_TEST);
}

- (BOOL) fireAt:(ray3)projectile withIntersection:(vec3)hitPoint andSolutionLessThan:(float)t withDamage:(float)dmg
{
    // don't intersect things that are dead already.
    if(!_HP) return NO;
    
    struct genBone* hitBone;
    if([self.skeleton checkIntersection:hitPoint intersectedBone:&hitBone withProjectile:projectile withSolutionLessThan:t]){
        int vertsPerBone = _vertexCount / CREEP_BONES;
        int offset = vertsPerBone * (hitBone->index > 0 ? hitBone->index - 1 : 0);
        NSMutableArray* intersectedVerts = [[NSMutableArray alloc] init];
        
        for(int i = offset; i < offset + (vertsPerBone << 1); ++i){
            struct CreepVertex* v = _vertices + i;
            
            if(_vertices[i].color[3] > 0.001f){
                vec3 pos;
                GLfloat soln;
                memcpy(pos, [self.skeleton transformVertex:v].position, sizeof(vec3));
                
                if(vec3_ray_sphere(hitPoint, projectile, pos, hitBone->radius / 4, &soln)){
                    
                    // color the hole's perimeter white
                    for(int j = 3; j--;){
                        _vertices[i].color[j] = 1;
                    }
                    
                    _vertices[i].color[3] = 0;
                    
                    [intersectedVerts addObject:@(i)];
                    
                    _HP -= dmg;
                }
            }
        }
        
        VerletParticle* p = [[VerletParticle alloc] initWithIndices:intersectedVerts
                                                        andVertices:_vertices
                                                         usingGraph:_meshGraph
                                                        andSkeleton:_skeleton];
        
        [self.mesh updateData:_vertices
                       ofSize:sizeof(struct CreepVertex) * _vertexCount
                  andIndicies:_indices
                       ofSize:sizeof(unsigned int) * _indexCount];
        
        
        return YES;
    }
    
    return NO;
}

- (BOOL) fireAt:(ray3)projectile withIntersection:(vec3)hitPoint
{
    // don't intersect things that are dead already.
    if(!_HP) return NO;
    
    struct genBone* hitBone;
    if([self.skeleton checkIntersection:hitPoint intersectedBone:&hitBone withProjectile:projectile]){
        int vertsPerBone = _vertexCount / CREEP_BONES;
        int offset = vertsPerBone * (hitBone->index > 0 ? hitBone->index - 1 : 0);
        NSMutableArray* intersectedVerts = [[NSMutableArray alloc] init];
        
        for(int i = offset; i < offset + (vertsPerBone << 1); ++i){
            struct CreepVertex* v = _vertices + i;
            
            if(_vertices[i].color[3] > 0.001f){
                vec3 pos;
                GLfloat soln;
                memcpy(pos, [self.skeleton transformVertex:v].position, sizeof(vec3));
                
                if(vec3_ray_sphere(hitPoint, projectile, pos, hitBone->radius / 4, &soln)){
                    
                    // color the hole's perimeter white
                    for(int j = 3; j--;){
                        _vertices[i].color[j] = 1;
                    }
                    
                    _vertices[i].color[3] = 0;
                    
                    [intersectedVerts addObject:@(i)];
                    
                    --_HP;
                }
            }
        }
        
        VerletParticle* p = [[VerletParticle alloc] initWithIndices:intersectedVerts
                                                        andVertices:_vertices
                                                         usingGraph:_meshGraph
                                                        andSkeleton:_skeleton];
        
        [self.mesh updateData:_vertices
                       ofSize:sizeof(struct CreepVertex) * _vertexCount
                  andIndicies:_indices
                       ofSize:sizeof(unsigned int) * _indexCount];
        
        
        return YES;
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

@end
