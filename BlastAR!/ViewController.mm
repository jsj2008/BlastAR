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

#import "Background.h"
#import "Scene/Starfield.h"
#import "Scene/Crosshair.h"
#import "Effects/SoundFactory.h"
#import "Effects/Particles.h"

#import "GenTest.h"

#import "Singletons.h"

#import "SpawnDelegate.h"
#import "ProximityDelegate.h"


@interface ViewController () {

}
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *tapToBegin;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) id <Drawable, Ranked> crosshair;
@property (strong, nonatomic) Background* background;
@property (nonatomic) GLKQuaternion orientation;

@property (nonatomic) Particles* smoke;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

- (NSDate*) lastTime{
    if(!_lastTime){
        _lastTime = [NSDate date];
    }
    
    return _lastTime;
}

- (CMMotionManager*) motionManager
{
    if(!_motionManager){
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    return _motionManager;
}

- (NSMutableArray*) enemies{
    if(!_enemies){
        _enemies = [[NSMutableArray alloc] init];
    }
    
    return _enemies;
}

- (OrderedScene*) scene{
    if(!_scene){
        _scene = [[OrderedScene alloc] init];
    }
    
    return _scene;
}

- (float) proximityInterval
{
    return 1.5f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // setup the core motion stuffs
    [self.motionManager startDeviceMotionUpdates];
    self.motionManager.deviceMotionUpdateInterval = 0.01;
    self.orientation = GLKQuaternionIdentity;
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    self.crosshair = [[Crosshair alloc] init];
    
    self.pewPew = [SoundFactory createShoot];
    self.spawn  = [SoundFactory createSpawn];
    self.proximityWarning = [SoundFactory createProximity];
    
    self.smoke = [[Particles alloc] initWithCapacity:1000];
    
    
    [self.scene addObject:_background = [[Background alloc] initWithGLKview:self andGLContext:self.context]];
//    [self.scene addObject:[[GenTest alloc]init]];
    [self.scene addObject:self.smoke];

    [ReoccuringEvent addWithCallback:[[SpawnDelegate alloc] initWithGame:self] andInterval:5.0f];
    [ReoccuringEvent addWithCallback:[[ProximityDelegate alloc] initWithGame:self] andInterval:1.5f];
    
    self.viewRedness = 0;
    
    self.gameState = gameMainMenu;
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
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glCullFace(GL_BACK);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void) startGame
{
    [self.scene removeObjects:self.enemies];
    [self.enemies removeAllObjects];
    [self.scene addObject:self.crosshair];
    self.nearestEnemy = nil;
    self.gameState = gamePlaying;
    self.viewRedness = 0.0f;
}

GLKMatrix4 VP;
vec3 YPR = {0};
vec3 shootDir = {0};

- (void)UpdateViewProjectionMatrix
{
    // create and update the view projection matrix
    float aspect = AR_ASPECT_RATIO = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    static const GLKVector3 forward = { 0, 0, 1 };
    static const GLKVector3 up      = { 1, 0, 0 };
    
    CMQuaternion q = self.motionManager.deviceMotion.attitude.quaternion;
    _orientation = GLKQuaternionMake(q.x, q.y, q.z, q.w);
    
    GLKVector3 adjForward = GLKQuaternionRotateVector3(_orientation, forward);
    GLKVector3 adjUp = GLKQuaternionRotateVector3(_orientation, up);
    
    GLKVector3Normalize(adjForward);
    GLKVector3Normalize(adjUp);
    memcpy(shootDir, adjForward.v, sizeof(vec3));
    
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(
                                                 adjForward.x, adjForward.y, adjForward.z,
                                                 0, 0, 0,
                                                 adjUp.x, adjUp.y, adjUp.z//adjUp.x, adjUp.y, adjUp.z
                                                 );
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(54.0f), aspect, 0.1f, 100.0f);
    VP = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
}

double lastTime = CFAbsoluteTimeGetCurrent();
- (void)update
{
    double now = CFAbsoluteTimeGetCurrent();
    double dt = now - lastTime;

    [self UpdateViewProjectionMatrix];
    [self.background setHue:(float*)VEC3_ONE];

    switch (_gameState) {
        case gamePlaying:
            if(_nearestEnemy){
                float dist = vec3_dist((float*)VEC3_ZERO, _nearestEnemy.position.v);
                float pitch = 10.0f - dist;
                [self.proximityWarning setPitch:pitch];
            }
            break;
        case gameOver:
            _viewRedness += (1.0f - _viewRedness) * dt / 2.0f;
            vec3 hue = { 1.0f, 1.0f - _viewRedness, 1.0f - _viewRedness };
            [self.background setHue:hue];
            break;
    }
    
    if(_gameState == gamePlaying){
    // update the enemies
    float closestDist = 1000;
    for (id object in self.scene.updatableObjects) {
        if([object conformsToProtocol:@protocol(Shootable)]){
            Creep* creep = (Creep*)object;
            
            float d = vec3_dist((float*)VEC3_ZERO, creep.position.v);
            if(d < closestDist){
                closestDist = d;
                _nearestEnemy = creep;
            }
        }
    }
    }

    if(_gameState == gamePlaying){
        [self.scene updateWithTimeElapsed:dt];
        [ReoccuringEvent updateWithTimeElapsed:dt];
    }
    
    lastTime = now;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    glEnable(GL_DEPTH_TEST);
    [self.scene drawWithViewProjection:&VP];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    if(self.gameState == gameOver && _viewRedness < 0.95f)
        return;
    if(self.gameState != gamePlaying){
        [self startGame];
        return;
    }
    
    NSLog(@"Pew!");
    
    ray3 projectile;
    memcpy(&projectile.p, VEC3_ZERO, sizeof(vec3));
    memcpy(&projectile.n, shootDir, sizeof(vec3));
    
    projectile.n[0] *= -1;
    projectile.n[1] *= -1;
    projectile.n[2] *= -1;
    
    NSMutableArray* killedEnemies = [[NSMutableArray alloc] init];
    
    // check to see what enemies, if any were shot and or killed
    for (id object in self.scene.updatableObjects) {
        if([object conformsToProtocol:@protocol(Shootable)]){
            vec3 hitPoint;
            if([object fireAt:projectile withIntersection:hitPoint]){
                Creep* creep = (Creep*)object;
                
                struct ParticleVertex smoke[10];
                
                for(int i = 10; i--;){
                    struct ParticleVertex p = {
                        .position = { hitPoint[0], hitPoint[1], hitPoint[2] },
                        .velocity = {RAND_F_NORM * RAND_F, RAND_F_NORM  * RAND_F, RAND_F_NORM * RAND_F},
                        .color = { 0.6f, 0.6f, 0.6f, RAND_F },
                        .size = 200.0f * (RAND_F + 1.0f),
                        .life = 2 * (RAND_F + 1.0f)
                    };
                    memcpy(smoke + i, &p, sizeof(struct ParticleVertex));
                }
                [self.smoke spawnParticles:smoke ofCount:10];
                
                if(creep.HP <= 0){
                    struct ParticleVertex smoke[10];
                    
                    for(int i = 3; i--;){
                        struct ParticleVertex p = {
                            .position = { creep.position.x, creep.position.y, creep.position.z },
                            .velocity = {RAND_F_NORM * RAND_F, RAND_F_NORM  * RAND_F, RAND_F_NORM * RAND_F},
                            .color = { 1.0f, RAND_F, 0.0f, RAND_F },
                            .size = 400.0f * (RAND_F + 1.0f),
                            .life = 1 * (RAND_F + 1.0f)
                        };
                        memcpy(smoke + i, &p, sizeof(struct ParticleVertex));
                    }
                    [killedEnemies addObject:object];
                }
            }
        }
    }
    
    // clean up
    [self.enemies removeObjectsInArray:killedEnemies];
    [self.scene removeObjects: killedEnemies];
    
    [self.pewPew play];
}
@end
