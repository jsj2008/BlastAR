//
//  VerletParticle.m
//  Projective
//
//  Created by Kirk Roerig on 12/10/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "VerletParticle.h"


@interface VerletParticle()



@end

@implementation VerletParticle

struct VerletSimVertex* simVertexFromCreep(struct CreepVertex* v, CreepSkeleton* skeleton){
    struct VerletSimVertex* vertex = malloc(sizeof(struct VerletSimVertex));
    struct CreepVertex creepVert = [skeleton transformVertex:(v)];
    
    memcpy(vertex->drawing.color, creepVert.color, sizeof(vec4));
    memcpy(vertex->drawing.position, creepVert.position, sizeof(vec3));
 
    bzero(vertex->edges, sizeof(struct VerletSimVertex*) * 6);
    
    return vertex;
}

- (instancetype)initWithIndices:(NSMutableArray*)indices
                    andVertices:(struct CreepVertex*)verts
                     usingGraph:(NSMutableDictionary*)graph
                    andSkeleton:(CreepSkeleton *)skeleton
{
    self = [super init];
    if(!self) return nil;
    
    NSMutableDictionary* visited = [[NSMutableDictionary alloc] init];
    
    for(NSNumber* index in indices){
        NSSet* neighbors = graph[index];
        struct VerletSimVertex* myVertex;
        
        // don't recreate the vertex if it has been visited already
        if(visited[index]){
            myVertex = [((NSValue*)visited[index]) pointerValue];
        }
        else{
            myVertex = simVertexFromCreep(&verts[[index unsignedIntegerValue]], skeleton);
            visited[index] = [NSValue valueWithPointer:myVertex];
        }
        
        unsigned int count = 0;
        for(NSNumber* neighbor in neighbors){
            if(count >= 6) break;
            
            // if this vertex has been added before, don't re create it
            if(visited[neighbor]){
                myVertex->edges[count++] = [((NSValue*)visited[neighbor]) pointerValue];
                continue;
            }
            
            struct VerletSimVertex* neighborVertex = simVertexFromCreep(&verts[[neighbor unsignedIntegerValue]], skeleton);
            
            // mark this vertex as visited
            visited[neighbor] = [NSValue valueWithPointer:neighborVertex];
            myVertex->edges[count++] = neighborVertex;
        }
    
    }
    

    for(int i = 0; i < indices.count; ++i){
        
    }
    
    return self;
}


- (void)updateWithTimeElapsed:(double)dt
{
    
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    
}

@end
