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
@property (nonatomic) PostEffect* blur;
@property (nonatomic) GLKView* view;

@end

@implementation CreepRenderGroup

- (instancetype)initWithGLKView:(GLKView*)view
{
    self = [super init];
    
    if(self){
        _renderTarget = [[RenderTarget alloc] initWithWidth:AR_WIDTH >> 1
                                                  andHeight:AR_HEIGHT >> 1
                                                   andFlags:RENDER_TARGET_COLOR
                         ];
        
        _blur = [[PostEffect alloc] initWithShader:@"Blur"];
    
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
    [self.blur bind];
    [self.blur usingTexture:self.renderTarget.color withName:"uTexture"];
    [self.blur drawWithViewProjection:viewProjection];
}

@end
