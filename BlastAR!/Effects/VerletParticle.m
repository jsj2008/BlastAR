//
//  VerletParticle.m
//  Projective
//
//  Created by Kirk Roerig on 12/10/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "VerletParticle.h"


@interface VerletParticle()

@property (nonatomic) struct VerletSimVertex* simVerts;
@property (nonatomic) unsigned int* indicies;
@property (nonatomic) unsigned int indexCount, vertexCount;

@property (nonatomic) float lifespan;

@end

@implementation VerletParticle

struct VerletSimVertex* simVertexFromCreep(struct CreepVertex* v, CreepSkeleton* skeleton)
{
    struct VerletSimVertex* vertex = malloc(sizeof(struct VerletSimVertex));
    struct CreepVertex creepVert = [skeleton transformVertex:(v)];
    
    memcpy(vertex->drawing.color, creepVert.color, sizeof(vec4));
    memcpy(vertex->drawing.position, creepVert.position, sizeof(vec3));
 
    bzero(vertex->edges, sizeof(struct VerletSimVertex*) * VERLET_MAX_EDGES);
    
    return vertex;
}

void addSimEdge(struct VerletSimVertex* vertex, struct VerletSimVertex* edge)
{
    for(int i = 0; i < VERLET_MAX_EDGES; ++i){
        if(!vertex->edges[i]){
            vertex->edges[i] = edge;
            return;
        }
        else if(vertex->edges[i] == edge){
            return;
        }
    }
}

- (unsigned int)computeIndexCount:(NSMutableArray*)indices withGraph:(Graph*)graph
{
    unsigned int count = 0;
    
    for(NSNumber* index in indices){
        ++count; // take this
        for(GraphNode* neighbor in graph[index].edges){
            NSNumber* neighborKey = neighbor.key;
            if(neighborKey != index && [indices containsObject:neighborKey]){
                ++count;
            }
        }
    }
    
    return count;
}

- (instancetype)initWithIndices:(NSMutableArray*)indices
                    andVertices:(struct CreepVertex*)verts
                     usingGraph:(Graph*)graph
                    andSkeleton:(CreepSkeleton *)skeleton
{
    self = [super init];
    if(!self) return nil;
    
    // figure out how many vertices we will need
    NSMutableSet* uniqueVerts = [[NSMutableSet alloc] init];
    [uniqueVerts addObjectsFromArray:indices];
    
    _vertexCount = (unsigned int)uniqueVerts.count;
    _indexCount = [self computeIndexCount:indices withGraph:graph];
    
    // allocate the space needed for the unique vertices
    _simVerts = malloc(sizeof(struct VerletSimVertex) * _vertexCount);
    _indicies = malloc(sizeof(unsigned int) * _indexCount);
    
    // copy vertices into the sim buffer
    unsigned int vi = 0;
    for(NSNumber* index in uniqueVerts){
        struct CreepVertex transformed = [skeleton transformVertex:(verts + [index unsignedIntegerValue])];
        struct VerletSimVertex vert = {
            
        };
        
        // copy only the position and color to the drawing structure of the sim vertex
        memcpy(&vert.drawing, &transformed, sizeof(struct VerletVertex));
        
        // copy the vertex and tag it for index construction later
        _simVerts[vi] = vert;
        graph[index].tag = [NSNumber numberWithUnsignedInteger:vi++];
    }
    
    // TODO reference indices, right now we are looking at vertices
    unsigned int i = 0;
    for(NSNumber* index in indices){
        GraphNode* node = graph[index];
        unsigned int vi =  _indicies[i++] = [node.tag unsignedIntValue];
        
        for(GraphNode* neighbor in node.edges){
            if(neighbor.tag){
                addSimEdge(_simVerts + vi, _simVerts + [neighbor.tag unsignedIntValue]);
            }
        }
    }
    
    [self withAttributeName:"aPosition" andElements:3];
    [self withAttributeName:"aColor" andElements:4];
    [self withExplicitStride:sizeof(struct VerletSimVertex)];
    
    [self.mesh updateData:_simVerts
                   ofSize:sizeof(struct VerletSimVertex) * _vertexCount
              andIndicies:_indicies
                   ofSize:sizeof(unsigned int) * _indexCount];
    
    [self buildWithVertexProg:@"VerletParticle" andFragmentProg:@"Creep"];
    
    // live any where from 0 to 2 * vertex count seconds
    _lifespan = RAND_F * 2 * _vertexCount;
    
    return self;
}

- (void)dealloc
{
    free(_simVerts);
    free(_indicies);
}

- (void)addVelocity:(vec3)v withRandomness:(float)r
{
    for(int i = _vertexCount; i--;){
        vec3_scale(v, v, 1.0f - r * RAND_F);
        vec3_add(_simVerts[i].velocity, _simVerts[i].velocity, v);
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
    if(_lifespan == 0) return;
    
    for(int i = _vertexCount; i--;){
        struct VerletSimVertex* vert = _simVerts + i;
        vec3 pull = { 0, 0, 0 };
        
        // iterate over all connected vertices, computing the linear
        // pull for each one
        for(int j = 0; j < VERLET_MAX_EDGES; ++j){
            if(!vert->edges[j]) break;
            
            // local vars
            struct VerletSimVertex* n = vert->edges[j];
            float len;
            vec3 dir;
            
            // calculate the direction to the other vertex, compute the length
            // and normalize it
            vec3_sub(dir, vert->drawing.position, n->drawing.position);
            len = vec3_len(dir);
            if(len != 0.0) vec3_scale(dir, dir, 1.0 / len);
            
            // scale the direction to the other vertex by
            // the difference between the dir's length and
            // the optimal distance between vertices (1.0)
            vec3_scale(dir, dir, (len - 1.0));
            vec3_add(pull, pull, dir);
        }
        
        // respect time, add the pull to the velocity
        vec3_scale(pull, pull, dt);
        vec3_add(vert->velocity, vert->velocity, pull);
    }
    
    // update vertex data using new positions and stuff
    [self.mesh updateData:_simVerts
                   ofSize:sizeof(struct VerletSimVertex) * _vertexCount
              andIndicies:_indicies
                   ofSize:sizeof(unsigned int) * _indexCount];
    
    // age
    _lifespan = _lifespan > 0 ? _lifespan - dt : 0;
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    Shader* shader = [self.shaders lastObject];
    
    [shader bind];
    [shader usingMat4x4:viewProjection withName:"uVP"];
    [shader usingArray:(GLfloat*)VEC4_ONE ofLength:1 andType:vec4Array withName:"uColor"];
    
    [self.mesh drawAs:GL_LINES];
}

- (BOOL)perished
{
    return _lifespan == 0;
}

@end
