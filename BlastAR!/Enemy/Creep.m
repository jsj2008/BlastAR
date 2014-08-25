//
//  Creep.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Creep.h"

struct CreepVertex{
    vec3  Position;
    vec4  Color;
    float Size;
};

@interface Creep()

@property (nonatomic) float radius;
@property (nonatomic) float scaleVelocity;
@property (nonatomic) float scale;

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

- (struct CreepVertex*) genCreepWithVertexCount:(int*)count withRadiusOf:(float*)radius
{
    // determine how many verts will be in this creep
    int vertices = rand() % 256 + 128;
    //int halfVerts = vertices >> 1;
    
    // randomly generate 4 colors to be used in this creep
    vec4 colors[4] = {
        {RAND_F, RAND_F, RAND_F, 1.0f - (RAND_F * RAND_F)},
        {RAND_F, RAND_F, RAND_F, 1.0f - (RAND_F * RAND_F)},
        {RAND_F, RAND_F, RAND_F, 1.0f - (RAND_F * RAND_F)},
        {RAND_F, RAND_F, RAND_F, 1.0f - (RAND_F * RAND_F)}
    };
    
    // allocate a buffer to store them
    size_t geoBytes = sizeof(struct CreepVertex) * vertices;
    struct CreepVertex* geo = (struct CreepVertex*)malloc(geoBytes);
    bzero(geo, geoBytes);
    
    // now randomly construct the creep's body using a pdf function
    int side = pow(vertices, 1.0f / 3.0f);
    int depth  = side / 2;
    int bodySeed = rand();//, colorSeed = rand();
    int vi = 0; // vertex index
    
    // create the first half of the creep
    for(int z = depth; z--;){
        float pz = z / (float)depth;
        
        for (int y = side; y--;){
            float py = y / (float)side;
            
            for(int x = side; x--;){
                // compute the coordinate that will be fed to the pdf
                vec3 p = { x / (float)side, py, pz };
                float test = pdf(p, bodySeed);
                if(test > 0){
                    struct CreepVertex* vert = geo + vi; // grab a pointer to the current vertex for ease
                    vec3 pos = { p[2] * 0.5f - 0.25f, p[1] * 0.5f - 0.25f, p[0] * 0.5f - 0.25f }; // world coordinate of the vertex
                    
                    float distSqr = vec3_dot(pos, pos);
                    
                    if(distSqr > *radius){
                        *radius = distSqr;
                    }
                    
                    // copy the position, and color into the vertex
                    // set the size
                    memcpy(&vert->Position, pos, sizeof(vec3));
                    memcpy(&vert->Color, colors[((int)(fabs(test) * 4)) % 4], sizeof(vec4));
                    vert->Size = 10;
                    
                    ++vi;
                }
            }
        }
    }
    
    // mirror the creep
    for(int i = vi; i--;){
        struct CreepVertex* mirrored = geo + vi + i;
        
        // mirror across the y axis
        memcpy(mirrored, geo + i, sizeof(struct CreepVertex));
        mirrored->Position[0] *= -1;
    }
    
    *count = (vi << 1) - 2;
    *radius = sqrtf(*radius) / 2.0f;
    return geo;
}

- (id) init
{
    self = [super init];
    [super withAttributeName:"aPosition" andElements:3];
    [super withAttributeName:"aColor" andElements:4];
    [super withAttributeName:"aSize" andElements:1];
    
    static struct CreepVertex point = {
        {0, 0, 0},
        {1.0, 1.0, 0, 0.5},
        160.0f
    };
    _radius = 1.0f;
    
    static vec3 spawnLimiter = { 1, 0.25f, 1 };
    
    // generate geometry
    int vertexCount = 0;
    struct CreepVertex* body = [self genCreepWithVertexCount:&vertexCount withRadiusOf:&_radius];
    [super.mesh updateData:body ofSize:sizeof(struct CreepVertex) * vertexCount];
    //[super.mesh updateData:&point ofSize:sizeof(struct CreepVertex) * 1];
    free(body);
    
    // compile shaders
    [super buildWithVertexProg:@"Creep" andFragmentProg:@"Creep"];
    [Creep soundHit];
    
    vec3_rand_norm(_position.v);
    vec3_mul(_position.v, _position.v, spawnLimiter);
    vec3_scale(_position.v, _position.v, 15.0);
    
    vec3_rand_norm(_velocity.v);
    
    _HP = 3;
    
    return self;
}

- (void) updateWithTimeElapsed:(double)dt
{
    // for now, don't update if dead
    if(!_HP) return;
    
    // seek the player
    {
        vec3 dpos   = {0};
//        vec3 jitter = {0};
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
        
//        vec3_rand_norm(jitter);
//        vec3_add(jitter, jitter, dpos);
//        vec3_scale(jitter, jitter, (RAND_F + 1.0) * 2);
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
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    // for now, don't draw if dead
    if(!_HP) return;
    
    
    vec3 dir  = {0};
    vec3 up   = {0, 1, 0};
    vec3 left = {0};
    vec3_norm(dir, _velocity.v);
    
    vec3_mul_cross(left, up, dir);
    vec3_norm(left, left);
    
    vec3_mul_cross(up, left, dir);
    vec3_norm(up, up);
    
    //GLKMatrix4 modelMatrix = GLKMatrix4Identity;//GLKMatrix4MakeLookAt(dir[0], dir[1], dir[2], 0, 0, 0, 0, 1.0f, 0);
    //modelMatrix = GLKMatrix4Translate(modelMatrix, _position.x, _position.y, _position.z);

//    GLKMatrix4 modelMatrix =  GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z);
//    modelMatrix = GLKMatrix4RotateY(modelMatrix, r += 0.1f);
    
    GLKVector4 r0 = { left[0], up[0], dir[0], _position.x };
    GLKVector4 r1 = { left[1], up[1], dir[0], _position.y };
    GLKVector4 r2 = { left[2], up[2], dir[0], _position.z };
    GLKVector4 r3 = { 0,       0,     0,      1 };
    
    GLKMatrix4 modelMatrix = GLKMatrix4MakeWithRows(r0, r1, r2, r3);
    
    [self.shader bind];
    [self.shader usingMat4x4:viewProjection withName:"uVP"];
    [self.shader usingMat4x4:&modelMatrix withName:"uModel"];
    [self.shader usingFloat:&_scale ofLength:1 withName:"uScale"];
    [self drawAs:GL_POINTS];
}

- (BOOL) fireAt:(ray3)projectile
{
    // don't intersect things that are dead already.
    if(!_HP) return NO;
    
    vec3 hitPoint = {0};
    if(vec3_ray_sphere(hitPoint, projectile, _position.v, self.radius)){
        --_HP;
        [[Creep soundHit] play];
        
        return YES;
    }
    
    return NO;
}

@end
