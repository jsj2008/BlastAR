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
            _bones[i].maxDistance = 0.8f;
            _bones[i].rotation = GLKQuaternionIdentity;
        }
    }
    
    return self;
}

- (void)updateWithTimeElapsed:(double)dt
{
    struct genBone* bone = _bones + 1;
    
    while(bone){
        struct genBone* last = bone->last; // toward the nose
        
        vec3 dirFromLast;
        float distToLast;
        float deltaToTargetLength;
        
        // find the vector pointing to the next bone
        // then calculate the length of that vector
        vec3_sub(dirFromLast, bone->position, last->position);
        distToLast = vec3_len(dirFromLast);
        
//        vec3 forwardProj = { dirFromLast[0], 0,              dirFromLast[2] };
//        vec3 upProj      = { 0,              dirFromLast[1], dirFromLast[2] };
//        vec3 leftProj    = { dirFromLast[0], dirFromLast[1], 0              };
//        float yaw   = vec3_angle_between_vec3(forwardProj, (float*)VEC3_FORWARD);
//        float pitch = vec3_angle_between_vec3(upProj, (float*)VEC3_UP);
//        float roll  = vec3_angle_between_vec3(leftProj, (float*)VEC3_LEFT);
//        bone->rotation = GLKQuaternionIdentity;
//        GLKQuaternion q1 = GLKQuaternionMakeWithAngleAndAxis(
//                                                             yaw,
//                                                             0, 1, 0
//                                                             );
//        GLKQuaternion q2 = GLKQuaternionMakeWithAngleAndAxis(
//                                                             pitch - M_PI_2,
//                                                             1, 0, 0
//                                                             );
//        GLKQuaternion q3 = GLKQuaternionMakeWithAngleAndAxis(
//                                                             roll,
//                                                             0, 0, 1
//                                                             );
//        bone->rotation = GLKQuaternionMultiply(bone->rotation, q1);
//        bone->rotation = GLKQuaternionMultiply(bone->rotation, q2);
//        bone->rotation = GLKQuaternionMultiply(bone->rotation, q3);
        GLKMatrix4 ori = GLKMatrix4MakeLookAt(
            bone->position[0], bone->position[1], bone->position[2],
            last->position[0], last->position[1], last->position[2],
            0, 1, 0
        );
        bone->rotation = GLKQuaternionMakeWithMatrix4(ori);
        
        // figure out how far off the bone position is
        deltaToTargetLength = bone->maxDistance - distToLast;
        
        // scale the vector between bones the the appropriate length
        vec3_scale(dirFromLast, dirFromLast, bone->maxDistance / distToLast);
        
        // update this vertex position
        vec3_add(bone->position, last->position, dirFromLast);
        
        // move toward the tail
        bone = bone->next;
    }
}

- (void)dealloc
{
    free(_bones);
}

@end

@implementation GenTest

void circle(vec4 pos, float p, float z){
    float s = 4 * (sqrtf(z) - z);
    pos[0] = cosf(p * M_PI * 2) * s;
    pos[1] = sinf(p * M_PI * 2) * s;
    pos[2] = 0;//z * 10;
}

void assignBones(struct vertex* v, GenSkeleton* skel, int slice, int slices)
{
    // assign bones here
    v->bones[0] = slice > 0 ? slice - 1 : slice;
    v->bones[1] = slice;
    v->bones[2] = slice < slices - 1 ? slice + 1 : slice;
    
    skel.bones[slice].position[2] = slice * 0.8;
}

- (int) generateWithMesh:(struct vertex*)mesh andIndicies:(unsigned int**)indices ofSize:(int)size withSliceSize:(int)vertsPerSlice
{
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
        NSLog(@"z: %f", 4 * (sqrtf(z) - z));
        NSLog(@"Slice %d", s);
        
        // create the ring of vertices for this
        // segment of the body
        for(int i = vertsPerSlice; i--;){
            float p = i / (float)vertsPerSlice;
            struct vertex* vert = mesh + si + i;
            
            circle(vert->position, p, z);
            assignBones(vert, _skel, s, slices);
            
            vec3 color = {
                z, 1.0 - z, 0
            };
        
            memcpy(vert->color, color, sizeof(vec3));
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
    
    if(self){
        
        [self withAttributeName:"aPosition" andElements:3];
        [self withAttributeName:"aColor" andElements:4];
        [self withAttributeName:"aBones" andElements:3];
        
        struct vertex verts[100] = {0};
        unsigned int* indices = NULL;
        
        _skel = [[GenSkeleton alloc] init];
        int indexCount = [self generateWithMesh:verts andIndicies:&indices ofSize:sizeof(verts) / sizeof(struct vertex) withSliceSize:10];
        
        [self.mesh updateData:verts ofSize:sizeof(verts) andIndicies:indices ofSize:sizeof(unsigned int) * indexCount];
        [self buildWithVertexProg:@"GenTest" andFragmentProg:@"GenTest"];
        
    }
    
    return self;
}

- (int) drawRank { return 2; };
- (int) updateRank { return 0; };

float r = 0;
- (void)updateWithTimeElapsed:(double)dt
{
    float rad = sin(-(r) * M_PI * 8);
    self.skel.bones[0].position[0] = cos(-(r) * M_PI) * (10 + rad);
    self.skel.bones[0].position[1] = sin(r * M_PI * 8);
    self.skel.bones[0].position[2] = sin(-(r) * M_PI) * (8 + rad);
//    self.skel.bones[0].position[0] = cos(-(r) * M_PI) * (10 + rad);
//    self.skel.bones[0].position[1] = sin(-(r) * M_PI) * (8 + rad);
//    self.skel.bones[0].position[2] = 0;//sin(r * M_PI * 8);
    r += dt * 0.1;
    
    [self.skel updateWithTimeElapsed:dt];
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    vec3 bonePositions[CREEP_BONES];
    vec4 boneRotations[CREEP_BONES];
    
    GLKMatrix4 model = GLKMatrix4Identity;
    
    model = GLKMatrix4Translate(model, 0, 0, -20);
//    model = GLKMatrix4RotateZ(model, r);
    bzero(bonePositions, sizeof(bonePositions));
    bzero(boneRotations, sizeof(boneRotations));
    
    for(int i = CREEP_BONES; i--;){
        
        memcpy(bonePositions + i, self.skel.bones[i].position, sizeof(vec3));
        memcpy(boneRotations + i, self.skel.bones[i].rotation.q, sizeof(vec4));
    }
    
    glLineWidth(2);
    
    [self.shader bind];
    [self.shader usingMat4x4:viewProjection withName:"uVP"];
    [self.shader usingMat4x4:&model withName:"uModel"];
    [self.shader usingArray:bonePositions ofLength:CREEP_BONES andType:vec3Array withName:"uBonePositions"];
    [self.shader usingArray:boneRotations ofLength:CREEP_BONES andType:vec4Array withName:"uBoneRotations"];
    [self drawAs:GL_LINE_STRIP];
}

@end
