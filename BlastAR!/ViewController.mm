//
//  ViewController.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "ViewController.h"

#import "Scene/Background.h"
#import "Scene/Starfield.h"
#import "Scene/Crosshair.h"
#import "Effects/SoundFactory.h"
#import "Effects/Particles.h"
#import "Effects/ParticleFactory.h"

#import "Singletons.h"

#import "SpawnDelegate.h"
#import "ProximityDelegate.h"

#import "States/GamePlaying.h"

@interface ViewController ()

@property (nonatomic) GamePlaying* playing;
@property (nonatomic) GameModel* game;
@property (nonatomic) UIPinchGestureRecognizer* pinch;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

static GLuint VIEW_FBO, VIEW_RBO;

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    glGenFramebuffers(1, &VIEW_FBO);
    glGenRenderbuffers(1, &VIEW_RBO);
    
//    glBindFramebuffer(GL_FRAMEBUFFER, VIEW_FBO);
//    glBindRenderbuffer(GL_RENDERBUFFER, VIEW_RBO);
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.view.layer];
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, VIEW_RBO);

    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    AR_WIDTH  = self.view.bounds.size.width * self.view.contentScaleFactor;
    AR_HEIGHT = self.view.bounds.size.height * self.view.contentScaleFactor;

    _game = [[GameModel alloc] init];
    _game.camera = [[CameraEntity alloc] init];
    _playing = [[GamePlaying alloc] initWithGameModel:_game andViewController:self];
    
    _game.camera.aspect = AR_ASPECT_RATIO = AR_WIDTH / (float)AR_HEIGHT;
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [view addGestureRecognizer:_pinch];
    
    [GameState switchToState:_playing];
}

- (void)handleGesture:(UIGestureRecognizer*)gesture
{
    [[GameState getActive]receiveGesture:gesture];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [PostEffect setVertexShader:@"FullscreenQuad"];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glCullFace(GL_BACK);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    
    [GameState updateActive];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // TODO invoke shoot event on GamePlaying state
    [GameState sendTouches:touches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [GameState sendTouchesEnded:touches];
}

@end
