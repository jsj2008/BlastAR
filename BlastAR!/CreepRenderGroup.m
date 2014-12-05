//
//  CreepRenderGroup.m
//  Projective
//
//  Created by Kirk Roerig on 12/5/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "CreepRenderGroup.h"
#import "Rendering/RenderTarget.h"
#import "Creep.h"

@interface CreepRenderGroup()

@property (nonatomic) RenderTarget* renderTarget;

@end

@implementation CreepRenderGroup

- (instancetype)init
{
    self = [super init];
    
    if(self){
        _renderTarget = [[RenderTarget alloc] initWithWidth:AR_WIDTH
                                                  andHeight:AR_HEIGHT
                                                   andFlags:RENDER_TARGET_COLOR
                         ];
    }
    
    return self;
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    for(Creep* creep in self.drawableObjects){
        [creep drawWithViewProjection:viewProjection];
    }
}

@end
