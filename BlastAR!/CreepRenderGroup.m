//
//  CreepRenderGroup.m
//  Projective
//
//  Created by Kirk Roerig on 12/5/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "CreepRenderGroup.h"
#import "Creep.h"

@interface CreepRenderGroup()

@property (nonatomic) RenderTarget* renderTarget;
@property (nonatomic) PostEffect *blurV, *blurH;
@property (nonatomic) GLKView* view;

@end

@implementation CreepRenderGroup

- (instancetype)initWithGLKView:(GLKView*)view
{
    self = [super init];
    
    if(self){
        _renderTarget = [[RenderTarget alloc] initWithWidth:512//AR_WIDTH >> 1
                                                  andHeight:512//AR_HEIGHT >> 1
                                                   andFlags:RENDER_TARGET_COLOR
                         ];
        
        _blurV = [[PostEffect alloc] initWithShader:@"BlurV"];
        _blurH = [[PostEffect alloc] initWithShader:@"BlurH"];
        
        _view = view;
    }
    
    return self;
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    // render to the framebuffer for post processing
    [self.renderTarget bind];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    for(Creep* creep in self.drawableObjects){
        [creep drawWithViewProjection:viewProjection];
    }
    [self.renderTarget unbind];
    
    // GLK views are stupid
    [self.view bindDrawable];
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
    for(Creep* creep in self.drawableObjects){
        [creep drawWithViewProjection:viewProjection];
    }
    
    glBlendFunc(GL_ONE, GL_ONE);
    glDisable(GL_DEPTH_TEST);
    [self.blurV bind];
    [self.blurV usingTexture:self.renderTarget.color withName:"uTexture"];
    [self.blurV drawWithViewProjection:viewProjection];
    
    [self.blurH bind];
    [self.blurH usingTexture:self.renderTarget.color withName:"uTexture"];
    [self.blurH drawWithViewProjection:viewProjection];
}

@end
