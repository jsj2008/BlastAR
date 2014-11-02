//
//  GenTest.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/30/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GenTest.h"

struct vertex{
    vec4 position;
};

@implementation GenTest

void top(vec4 pos, float x, float z){
    float s = 4 * (sqrtf(z) - z);
    
    pos[0] = x * s * (cos(z * M_2_PI * 2) + 1.0);
    pos[1] = cos(x * M_PI * 0.5f) * s;// * cos(x * M_PI_2 * 10);
    pos[2] = z * 10;
    pos[3] = 1.0f;
}

void bottom(vec4 pos, float x, float z){
    float s = 4 * (sqrtf(z) - z);
    
    pos[0] = x * s * (cos(z * M_2_PI * 2) + 1.0);
    pos[1] = -cos(x * M_PI * 0.5f) * s;
    pos[2] = z * 10;
    pos[3] = 1.0f;
}

- (int) generateWithMesh:(struct vertex*)mesh andIndicies:(unsigned int**)indices ofSize:(int)size withSliceSize:(int)vertsPerSlice
{
    int half   = vertsPerSlice >> 1;
    int slices = size / vertsPerSlice;
    
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
    
    int s = sizeof(int);
    unsigned int* ind = malloc(indexCount * sizeof(unsigned int));
    
    int ii = 0;            // index counter
    for(int s = 0; s < slices; ++s){
        int si = s * vertsPerSlice;
        float z = s / (float)slices;
   
        //bzero(indices[0], sizeof(short) * indexCount);
        NSLog(@"z: %f", 4 * (sqrtf(z) - z));
        NSLog(@"Slice %d", s);
        
        // create the ring of vertices for this
        // segment of the body
        for(int i = half; i--;){
            float p = i / (float)half;
            float x0 =  (p * 2.0f - 1.0f);
            float x1 = -(p * 2.0f - 1.0f);
            
            top((mesh + si + i)->position, x0, z);
            bottom((mesh + si + half + i)->position, x1, z);
            
            vec4 topVert, bottomVert;
            memcpy(topVert, (mesh + si + i)->position, sizeof(vec4));
            memcpy(bottomVert, (mesh + si + half + i)->position, sizeof(vec4));
            
            //NSLog(@"\ttop    %f, %f, %f (%d)", topVert[0], topVert[1], topVert[2], si + i);
            //NSLog(@"\tbottom %f, %f, %f (%d)", bottomVert[0], bottomVert[1], bottomVert[2], si + half + i);
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

- (id) init
{
    self = [super init];
    
    [self withAttributeName:"aPosition" andElements:4];
    
    struct vertex verts[400] = {0};
    unsigned int* indices = NULL;
    
    int indexCount = [self generateWithMesh:verts andIndicies:&indices ofSize:400 withSliceSize:10];
    
    [self.mesh updateData:verts ofSize:sizeof(verts) andIndicies:indices ofSize:sizeof(unsigned int) * indexCount];
    [self buildWithVertexProg:@"GenTest" andFragmentProg:@"CrossHair"];
    
    return self;
}


- (int) drawRank { return 2; };
- (int) updateRank { return 0; };


float r = 0;
- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    GLKMatrix4 model = GLKMatrix4MakeTranslation(0, 0, -10);
    model = GLKMatrix4RotateY(model, r += 0.01f);
    
    [self.shader bind];
    [self.shader usingMat4x4:viewProjection withName:"uVP"];
    [self.shader usingMat4x4:&model withName:"uModel"];
    [self drawAs:GL_TRIANGLES];
}

@end
