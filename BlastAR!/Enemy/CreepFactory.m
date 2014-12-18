//
//  CreepFactory.m
//  Projective
//
//  Created by Kirk Roerig on 12/1/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "CreepFactory.h"

@implementation CreepFactory

void creepCrossSection(vec4 pos, float p, float z){
    float s = 4 * (sqrtf(z) - z);
    pos[0] = cosf(p * M_PI * 2) * s;
    pos[1] = sinf(p * M_PI * 2) * s;
    pos[2] = 0;//z * 10;
}

void assignCreepBones(struct CreepVertex* v, CreepSkeleton* skel, int slice, int slices)
{
    // assign bones here
    v->bones[0] = slice > 0 ? slice - 1 : slice;
    v->bones[1] = slice;
    v->bones[2] = slice < slices - 1 ? slice + 1 : slice;
    
    float distFromOrigin = vec3_len(v->position);
    float oldRadius = skel.bones[slice].radius;
    
    // update the bone's radius, and position as needed
    skel.bones[slice].position[2] = slice * 0.8;
    skel.bones[slice].radius = oldRadius < distFromOrigin ? distFromOrigin : oldRadius;
}

+ (int)generateWithMesh:(struct CreepVertex *)mesh
                ofCount:(unsigned int)size
      resultingIndicies:(unsigned int **)indices
           withSkeleton:(CreepSkeleton *)skeleton
{
    const int vertsPerSlice = 10;
    const int slices = size / vertsPerSlice;
    
    // verts/slice = 5
    // slices = 2
    // o----o----o----o----
    // |\   |\   |\   |\
    // | \  | \  | \  | \
    // |  \ |  \ |  \ |  \
    // |   \|   \|   \|   \
    // o----o----o----o----
    // 24 indices
    
    int indexCount = vertsPerSlice * 6 * (slices - 1);
    unsigned int* ind = malloc(indexCount * sizeof(unsigned int));
    
    int ii = 0; // index counter
    for(int s = 0; s < slices; ++s){
        int si = s * vertsPerSlice;
        float z = s / (float)slices;
        
        //bzero(indices[0], sizeof(short) * indexCount);
//        NSLog(@"z: %f", 4 * (sqrtf(z) - z));
//        NSLog(@"Slice %d", s);
        
        // create the ring of vertices for this
        // segment of the body
        for(int i = vertsPerSlice; i--;){
            float p = i / (float)vertsPerSlice;
            struct CreepVertex* vert = mesh + si + i;
            
            creepCrossSection(vert->position, p, z);
            assignCreepBones(vert, skeleton, s, slices);
            
            vec4 color = {
                z, 1.0 - z, 0, 1
            };
            
            memcpy(vert->color, color, sizeof(vec4));
        }
        
        // generate the triangles for the mesh if we already
        // have genereated one strip
        if(s > 0){
            for(int i = vertsPerSlice; i--;){
                
                int tv  = i + si; // this vertex
                int lv  = tv - vertsPerSlice;
                int nv  = si + ((i + 1) % vertsPerSlice);
                int lnv = si - vertsPerSlice + ((i + 1) % vertsPerSlice);
                
                // alternate triangulation for everyother vertex.
                // even         odd
                // lv           lv----nv
                //  | \           \    |
                //  |  \           \   |
                //  |   \           \  |
                // tv----nv           tv
                //
                // lv---lnv     lv----nv
                //  | \  |        \    |
                //  |  \ |         \   |
                //  |   \|          \  |
                // tv----nv           tv
                
                // assign the indices for the triangle
                ind[ii++] = lv;
                ind[ii++] = tv;
                ind[ii++] = nv;
                
                ind[ii++] = lnv;
                ind[ii++] = lv;
                ind[ii++] = nv;
            }
        }
    }
    
    *indices = ind;
    
    return indexCount;
}

+ (Graph*)generateMeshGraphFromIndices:(unsigned int*)indices withVertices:(struct CreepVertex*)vertices ofCount:(unsigned int)count
{
    Graph* graph = [[Graph alloc] init];
    
    for(int i = 0; i < count; i += 2){
        NSNumber* ind = [NSNumber numberWithUnsignedInt:indices[i]];
        NSNumber* next = [NSNumber numberWithUnsignedInt:indices[i + 1]];
        
        graph[ind]  = [NSValue valueWithPointer:vertices + [ind unsignedIntegerValue]];
        graph[next] = [NSValue valueWithPointer:vertices + [next unsignedIntegerValue]];
        
        GraphNode* indNeighbors  = graph[ind];
        GraphNode* nextNeighbors = graph[next];
    
        [indNeighbors connectToBoth:nextNeighbors];
    }
    
    return graph;
}

+ (void)seed:(unsigned int)seed
{
    // TODO
}

@end
