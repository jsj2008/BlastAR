//
//  Particles.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/24/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Particles.h"

@interface Particles()

@property (nonatomic) struct ParticleVertex* particles;
@property (nonatomic) int maxIndex;
@property (nonatomic) int capacity;
@property (nonatomic) float totalTime;

@end

@implementation Particles

- (id) initWithCapacity:(int)particleCount
{
    self = [super init];
    
    // define the attributes of the vertex structure
    [super withAttributeName:"aPosition" andElements:3];
    [super withAttributeName:"aVelocity" andElements:3];
    [super withAttributeName:"aColor" andElements:4];
    [super withAttributeName:"aSize" andElements:1];
    [super withAttributeName:"aBirth" andElements:1];
    [super withAttributeName:"aLife" andElements:1];

    // allocate space for the vertices
    int bytes = sizeof(struct ParticleVertex) * (particleCount);
    _particles = (struct ParticleVertex*)malloc(bytes);
    bzero(_particles, bytes);
    
    // send the particle buffer to GL
    [self.mesh updateData:_particles ofSize:bytes];
    
    _capacity = particleCount;
    _maxIndex = 0;
    
    [self buildWithVertexProg:@"Particles" andFragmentProg:@"Particles"];
    
    return self;
}

- (void) dealloc
{
    free(self.particles);
}

- (void) spawnParticles:(struct ParticleVertex*)particles ofCount:(int)count
{
    // don't spawn if we are out of space
    if(_maxIndex + count > _capacity) return;
    
    // update the birth time to be correct
    for (int i = count; i--;) {
        particles[i].birth = _totalTime;
    }
    
    memcpy(_particles + _maxIndex, particles, sizeof(struct ParticleVertex) * count);
    _maxIndex += count;
    
    // update the buffer on the GPU
    [self.mesh updateData:_particles ofSize:_capacity * sizeof(struct ParticleVertex)];
}

- (void) spawnParticleAtPosition:(vec3)p
                    withVelocity:(vec3)v
                        andColor:(vec4)c
                         andSize:(float)size
                     andLifespan:(float)lifespan
{
    struct ParticleVertex particle = {
        {p[0], p[1], p[2]},
        {v[0], v[1], v[2]},
        {c[0], c[1], c[2], c[3]},
        size,
        _totalTime,
        lifespan
    };
    
    // copy the new particle into the buffer
    [self spawnParticles:&particle ofCount:1];
}

-(void)updateWithTimeElapsed:(double)dt
{
    _totalTime += dt;
    
    for(int i = _maxIndex; i--;){
        struct ParticleVertex* p = _particles + i;
        
        // check to see if the particle is dead, and if it needs to be deleted
        if(_totalTime - p->birth > p->life && _maxIndex > 2){
            struct ParticleVertex temp = {0};

            // copy the particle that was at the end to the place where the newly dead
            // particle was located.
            if(i != _maxIndex - 1){
                memcpy(_particles + i, _particles + _maxIndex - 1, sizeof(temp));
            }
            
            --_maxIndex;
        }
    }
    
}

-(void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    [super checkError];
    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_ONE, GL_ONE, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    [super checkError];
    
    [self.shader bind];
    [super checkError];
    
    [self.shader usingFloat:&_totalTime ofLength:1 withName:"uTime"];
    [self.shader usingMat4x4:viewProjection withName:"uVP"];
    [super checkError];
    
    [self drawAs:GL_POINTS];
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
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
