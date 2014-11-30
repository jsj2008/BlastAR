//
//  GenTest.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/30/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GenTest.h"

@implementation GenSkeleton

- (instancetype)init
{
    self = [super init];
    
    if(self){
        _bones = malloc(sizeof(struct genBone) * CREEP_BONES);

        // connect the bones for the skeleton
        for(int i = CREEP_BONES; i--;){
            _bones[i].next = i + 1 <  CREEP_BONES ? _bones + i + 1 : NULL;
            _bones[i].last = i - 1 >= 0 ? _bones + i - 1 : NULL;
        }
    }
    
    return self;
}

- (void)updateWithTimeElapsed:(double)dt
{
    
}

- (void)dealloc
{
    free(_bones);
}

@end

@implementation GenTest

void top(vec4 pos, float x, float z){
    float s = 4 * (sqrtf(z) - z);
    
    pos[0] = x * s * (cos(z * M_2_PI * 2) + 1.0);
    pos[1] = cos(x * M_PI * 0.5f) * s;// * cos(x * M_PI_2 * 10);
    pos[2] = z * 10;
}

void bottom(vec4 pos, float x, float z){
    float s = 4 * (sqrtf(z) - z);
    
    pos[0] = x * s * (cos(z * M_2_PI * 2) + 1.0);
    pos[1] = -cos(x * M_PI * 0.5f) * s;
    pos[2] = z * 10;
}

void assignBones(struct vertex* v, int slice, int slices)
{
    // assign bones here
    v->bones[0] = slice > 0 ? slice - 1 : slice;
    v->bones[1] = slice;
    v->bones[2] = slice < slices - 1 ? slice + 1 : slice;
}

- (int) generateWithMesh:(struct vertex*)mesh andIndicies:(unsigned int**)indices ofSize:(int)size withSliceSize:(int)vertsPerSlice
{
    const int half   = vertsPerSlice >> 1;
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
    int slicesPerBone = slices / CREEP_BONES;
    
    int s = sizeof(int);
    unsigned int* ind = malloc(indexCount * sizeof(unsigned int));
    
    int ii = 0; // index counter
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
            
            struct vertex *topVert = mesh + si + i, *bottomVert = mesh + si + half + i;
            
            assignBones(topVert, s, slices);
            assignBones(bottomVert, s, slices);
            
            vec3 color = {
                random() % 1000 / 1000.0, random() % 1000 / 1000.0, random() % 1000 / 1000.0
            };
        
            memcpy(topVert->color, color, sizeof(vec3));
            memcpy(bottomVert->color, color, sizeof(vec3));
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
    
    [self withAttributeName:"aPosition" andElements:3];
    [self withAttributeName:"aColor" andElements:4];
    [self withAttributeName:"aBones" andElements:3];
    
    struct vertex verts[100] = {0};
    unsigned int* indices = NULL;
    
    int indexCount = [self generateWithMesh:verts andIndicies:&indices ofSize:sizeof(verts) / sizeof(struct vertex) withSliceSize:10];
    
    [self.mesh updateData:verts ofSize:sizeof(verts) andIndicies:indices ofSize:sizeof(unsigned int) * indexCount];
    [self buildWithVertexProg:@"GenTest" andFragmentProg:@"GenTest"];
    
    return self;
}

- (int) drawRank { return 2; };
- (int) updateRank { return 0; };

float r = 0;
- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    vec3 bones[CREEP_BONES];
    
    GLKMatrix4 model = GLKMatrix4Identity;
    
    model = GLKMatrix4MakeRotation(-M_PI_2, 1, 0, 0);
    model = GLKMatrix4Translate(model, 0, 10, -5);
    model = GLKMatrix4RotateZ(model, r);
    bzero(bones, sizeof(bones));
    
    r += 0.01f;
    
    for(int i = CREEP_BONES; i--;){
        float p = i * M_PI / (float)CREEP_BONES;
        // p * p - 1 = 0
        // (p + 1)(p - 1) = 0
        // p = -1, p = 1
        bones[i][0] = cos(-(p /*+ r*/) * M_PI + M_PI);
        
    }
    
    [self.shader bind];
    [self.shader usingMat4x4:viewProjection withName:"uVP"];
    [self.shader usingMat4x4:&model withName:"uModel"];
    [self.shader usingArray:bones ofLength:CREEP_BONES andType:vec3Array withName:"uBones"];
    [self drawAs:GL_LINE_STRIP];
}

@end
