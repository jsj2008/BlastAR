//
//  Background.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <QuartzCore/CAEAGLLayer.h>
#import "Background.h"
#import "OPjective.h"

const float s = 1.0f;

struct QuadVertex{
    vec4 position;
    vec2 uv;
};

@interface Background()

@property (nonatomic, strong) RosyWriterVideoProcessor* videoProcessor;
@property (nonatomic) CVOpenGLESTextureCacheRef videoTextureCache;
@property (nonatomic) GLuint videoTextureId;
@property (nonatomic, strong) GLKViewController* view;
@property (nonatomic) EAGLContext* context;
@property (nonatomic) CVOpenGLESTextureRef texture;

@property (nonatomic) GLint renderBufferWidth;
@property (nonatomic) GLint renderBufferHeight;
@end

@implementation Background

//- (BOOL) generateFramebuffer
//{
//    glGenFramebuffers(1, &_frameBufferHandle);
//    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
//    
//    glGenRenderbuffers(1, &_colorBufferHandle);
//    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
//    
//    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)_view.view.layer];
//    
//	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderBufferWidth);
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderBufferHeight);
//    
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
//	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
//        NSLog(@"Failure with framebuffer generation");
//        return NO;
//	}
//    
//    glBindRenderbuffer(GL_RENDERBUFFER, 0);
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//    
//    [self checkError];
//    
//    return YES;
//}

- (id) initWithGLKview:(GLKViewController *)view andGLContext:(CVEAGLContext)context
{
    self = [super init];
    
    _view = view;
    _context = context;
    
    [self withAttributeName:"aPosition" andElements:4];
    [self withAttributeName:"aUV" andElements:2];
    
    static struct QuadVertex quad[] = {
        {
            { s, -s, 0, 1},
            { 1, 1 },
        },
        {
            {-s, -s, 0, 1},
            { 0,  1 },
        },
        {
            { s,  s, 0, 1},
            { 1,  0 },
        },
        {
            {-s, s, 0, 1},
            { 0, 0 },
        }
    };
    
    static short indicies[] = {
        1, 2, 0,
        1, 3, 2
    };
    
    [self.mesh updateData:quad ofSize:sizeof(quad) andIndicies:indicies ofSize:sizeof(indicies)];
    //[self.mesh updateData:quad ofSize:sizeof(quad)];
    
    // Initialize the class responsible for managing AV capture session and asset writer
    self.videoProcessor = [[RosyWriterVideoProcessor alloc] init];
	self.videoProcessor.delegate = self;
    
    // Setup and start the capture session
    [self.videoProcessor setupAndStartCaptureSession];
    
    //  Create a new CVOpenGLESTexture cache
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return nil;
    }

//    if(![self generateFramebuffer]){
//        return nil;
//    }
    
    [self buildWithVertexProg:@"FullscreenQuad" andFragmentProg:@"FullscreenQuad"];
    
    return self;
}

- (void) pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
    [self checkError];
    if(_videoTextureCache == NULL)
        return;
    
    // Create a CVOpenGLESTexture from the CVImageBuffer
	size_t frameWidth = CVPixelBufferGetWidth(pixelBuffer);
	size_t frameHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    if(_texture)
        CFRelease(_texture);
    
    glActiveTexture(GL_TEXTURE0);
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                _videoTextureCache,
                                                                pixelBuffer,
                                                                NULL,
                                                                GL_TEXTURE_2D,
                                                                GL_RGBA,
                                                                (GLint)frameWidth,
                                                                (GLint)frameHeight,
                                                                GL_BGRA,
                                                                GL_UNSIGNED_BYTE,
                                                                0,
                                                                &_texture);
    [self checkError];
    
    if (!_texture || err) {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
        return;
    }
    
	glBindTexture(CVOpenGLESTextureGetTarget(_texture), CVOpenGLESTextureGetName(_texture));
    [self checkError];
    
    // Set texture parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
}

- (void) setHue:(vec3)color
{
    [self.shader bind];
    [self.shader usingFloat:color ofLength:3 withName:"uHue"];
}

- (void) drawWithViewProjection:(GLKMatrix4*)viewProjection{
    [self checkError];
    glDisable(GL_DEPTH_TEST);

    [self checkError];
    
    [self.shader bind];
    glUniform1i(glGetUniformLocation(self.shader.programId, "uTexture"), 0);
    [self drawAs:GL_TRIANGLE_STRIP];
    [self checkError];
    
    glEnable(GL_DEPTH_TEST);
    [self checkError];
}

- (int) drawRank
{
    return -1;
}

- (int) updateRank
{
    return 0;
}

@end
