//
//  Game.m
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GamePlaying.h"
#import "SpawnDelegate.h"
#import "ProximityDelegate.h"

@interface GamePlaying()

@property (nonatomic) GameModel* model;
@property ReoccuringEvent *spawnEvent, *proximityEvent;

@end

@implementation GamePlaying

- (instancetype)initWithGameModel:(GameModel *)model andViewController:(ViewController*)view
{
    self = [super init];
    
    if(!self) return nil;
    
    _model = model;
    
    _model.crosshair = [[Crosshair alloc] init];
    
    _model.pewPew = [SoundFactory createShoot];
    _model.spawn  = [SoundFactory createSpawn];
    _model.proximityWarning = [SoundFactory createProximity];
    
    _model.creeps = [[CreepRenderGroup alloc] initWithGLKView:(GLKView*)view.view];
    
    [_model.scene addRenderGroup:_model.creeps withName:@"creeps"];
    [_model.scene addObject:_model.background = [[Background alloc] initWithGLKview:view andGLContext:view.context]];
    
    [_model.scene addObject:_model.camera];
    
    [ParticleFactory initWithScene:_model.scene andCapacities:100];
    
    return self;
}

- (void)enterFromState:(GameState*)last
{
    GameModel* model = self.model;
    
    [model.scene removeObjects:model.enemies];
    [model.enemies removeAllObjects];
    [model.creeps addObject:model.crosshair];
    model.nearestEnemy = nil;
    model.viewRedness = 0.0f;
    
    _spawnEvent = [ReoccuringEvent addWithCallback:[[SpawnDelegate alloc] initWithGame:_model] andInterval:5.0f];
    _proximityEvent = [ReoccuringEvent addWithCallback:[[ProximityDelegate alloc] initWithGame:_model] andInterval:1.5f];

}

- (void)updateWithTimeElapsed:(double)dt
{
    GameModel* model = self.model;
    
    [model.background setHue:(float*)VEC3_ONE];

    if(model.nearestEnemy){
        float dist = vec3_dist((float*)VEC3_ZERO, model.nearestEnemy.position.v);
        float pitch = 10.0f - dist;
        [model.proximityWarning setPitch:pitch];
    }
    
    // update the enemies
    float closestDist = 1000;
    for (id object in model.scene.updatableObjects) {
        if([object conformsToProtocol:@protocol(Shootable)]){
            Creep* creep = (Creep*)object;
            
            float d = vec3_dist((float*)VEC3_ZERO, creep.position.v);
            if(d < closestDist){
                closestDist = d;
                model.nearestEnemy = creep;
            }
        }
    }
    
    [model.scene updateWithTimeElapsed:dt];
    [ReoccuringEvent updateWithTimeElapsed:dt];
    
    GLKMatrix4 VP = model.camera.viewProjection;
    [model.scene drawWithViewProjection:&VP];
}

- (void)receiveTouches:(NSSet*)touches
{
    GameModel* model = self.model;
    
    NSLog(@"Pew!");
    
    ray3 projectile;
    memcpy(&projectile.p, VEC3_ZERO, sizeof(vec3));
    memcpy(&projectile.n, model.camera.shootDir.v, sizeof(vec3));
    
    projectile.n[0] *= -1;
    projectile.n[1] *= -1;
    projectile.n[2] *= -1;
    
    NSMutableArray* killedEnemies = [[NSMutableArray alloc] init];
    
    // check to see what enemies, if any were shot and or killed
    for (int i = model.scene.updatableObjects.count; i--;) {
        id object = model.scene.updatableObjects[i];
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
                    
                    smoke[i] = p;
                }
                
                [ParticleFactory spawnParticleOfType:@"smoke" withParticles:smoke ofCount:10];
                
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
                        
                        smoke[i] = p;
                    }
                    [killedEnemies addObject:object];
                }
            }
        }
    }
    
    // clean up
    [model.enemies removeObjectsInArray:killedEnemies];
    [model.scene removeObjects: killedEnemies];
    
    [model.pewPew play];
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    GameModel* model = self.model;
    GLKMatrix4 VP = model.camera.viewProjection;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    [model.scene drawWithViewProjection:&VP];
}

- (void)exitToState:(GameState*)next
{
    [self.model.scene removeObject:self.model.crosshair];
    
    [_spawnEvent unregister];
    [_proximityEvent unregister];
}

@end
