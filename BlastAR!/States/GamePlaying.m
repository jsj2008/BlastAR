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
#import "Starfield.h"

@interface GamePlaying()

@property (nonatomic) GameModel* model;
@property (nonatomic) ReoccuringEvent *spawnEvent, *proximityEvent;
@property (nonatomic) BOOL firing;
@property (nonatomic) float scalingStart;

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
    
    _model.creeps = [[CreepGroup alloc] initWithGLKView:(GLKView*)view.view];
    
//    [_model.scene addRenderGroup:_model.creeps withName:@"creeps"];
//    [_model.scene addObject:_model.background = [[Background alloc] initWithGLKview:view andGLContext:view.context]];
    [_model.scene addObject:_model.background = [[Starfield alloc] initWithStars:1000]];
//    [_model.scene addObject:_model.projectiles = [[Projectiles alloc] initWithIntersectionSelector:@selector(enemyShot:)]];
    [_model.scene addObject:_model.camera];
    
//    [_model.allWeapons addObject:[[WeaponAuto alloc] initWithProjectiles:_model.projectiles andCamera:_model.camera]];
//    [_model.allWeapons addObject:[[WeaponScatter alloc] initWithProjectiles:_model.projectiles andCamera:_model.camera]];
//    [_model.allWeapons addObject:[[WeaponSemi alloc] initWithProjectiles:_model.projectiles andCamera:_model.camera]];
//    [_model.scene addObjects:_model.allWeapons];
//    _model.selectedWeapon = [_model.allWeapons firstObject];

    [ParticleFactory initWithScene:_model.scene andCapacities:100];
    
    return self;
}

- (void)enterFromState:(GameState*)last
{
    GameModel* model = self.model;
    
    [model.scene addObject:model.crosshair];
    model.nearestEnemy = nil;
    model.viewRedness = 0.0f;
    
    _spawnEvent = [ReoccuringEvent addWithCallback:[[SpawnDelegate alloc] initWithGame:_model] andInterval:5.0f];
    _proximityEvent = [ReoccuringEvent addWithCallback:[[ProximityDelegate alloc] initWithGame:_model] andInterval:1.5f];
    
//    [_model.scene addObject:(SpawnDelegate*)self.spawnEvent.callback];
}

- (void)enemyShot:(id<Shootable>)target
{
    Creep* creep = (Creep*)target;
    struct ParticleVertex smoke[3];
    vec4 red = { 1, 0, 0, 1 };
    vec4 green = { 0, 1, 0, 1 };
    
    for(int i = 3; i--;){
        struct ParticleVertex p = {
            .position = { creep.lastHitPoint.x, creep.lastHitPoint.y, creep.lastHitPoint.z },
            .velocity = {RAND_F_NORM * RAND_F * 4, RAND_F_NORM * RAND_F * 4, RAND_F_NORM * RAND_F * 4},
            .size = 100.0f * (RAND_F + 1.0f),
            .life = (RAND_F + 2.0f)
        };
        
        vec4_lerp(p.color, red, green, RAND_F);
        
        smoke[i] = p;
    }
    [ParticleFactory spawnParticleOfType:@"smoke" withParticles:smoke ofCount:3];
    
    if(creep.HP <= 0){
        struct ParticleVertex deathSmoke[10];
        
        for(int i = 10; i--;){
            struct ParticleVertex p = {
                .position = { creep.position.x, creep.position.y, creep.position.z },
                .velocity = {RAND_F_NORM * RAND_F, RAND_F_NORM * RAND_F, RAND_F_NORM * RAND_F},
                .color = { RAND_F, 1.0, 1.0f, RAND_F },
                .size = 400.0f * (RAND_F + 1.0f),
                .life = 10 * (RAND_F + 1.0f)
            };
            
            deathSmoke[i] = p;
        }
        [ParticleFactory spawnParticleOfType:@"smoke" withParticles:deathSmoke ofCount:10];
    }
}

- (void)checkForKilledEnemies:(GameModel *)model withElapsedTime:(float)dt
{
    NSMutableArray* enemies = [model.scene objectsFromGroup:@"creeps"];
    
    // check to see what enemies, if any were shot and or killed
    [model.projectiles performIntersctionCheck:enemies
                                    withDamage:model.selectedWeapon.damage
                                    andElapsed:dt];
    
    // clean up
    for(unsigned int i = (unsigned int)enemies.count; i--;){
        if(((Creep*)enemies[i]).HP <= 0){
            [enemies removeObjectAtIndex:i];
        }
    }
}

- (void)updateWeapon:(float)dt
{
    GameModel* model = self.model;
    
    [model.selectedWeapon updateWithTimeElapsed:dt];
}

- (void)updateWithTimeElapsed:(double)dt
{
    GameModel* model = self.model;
    
//    [model.background setHue:(float*)VEC3_ONE];

    if(model.nearestEnemy){
        float dist = vec3_dist((float*)VEC3_ZERO, model.nearestEnemy.position.v);
        float pitch = 10.0f - dist;
        [model.proximityWarning setPitch:pitch];
    }
    
    [self updateWeapon:dt];
    
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
    
    NSLog(@"Nearest creep %f", closestDist);
    
    [self checkForKilledEnemies:model withElapsedTime:dt];
    
    
    [model.scene updateWithTimeElapsed:dt];
    [ReoccuringEvent updateWithTimeElapsed:dt];
    
    GLKMatrix4 VP = model.camera.viewProjection;
    [model.scene drawWithViewProjection:&VP];
    [model.selectedWeapon drawWithViewProjection:&VP];
}

- (void)receiveTouches:(NSSet*)touches
{
    GLKVector2 screenPos = [OPjective cannonicalFromTouch:[touches anyObject]];
    
    for(Weapon* w in self.model.allWeapons){
        if([w isTouchedBy:[touches anyObject]])
        {
            self.model.selectedWeapon = w;
            break;
        }
    }
    
    [self.model.selectedWeapon beginFiring];
}

- (void)receiveTouchesEnded:(NSSet *)touches
{
    [self.model.selectedWeapon endFiring];
}

- (void)receiveGesture:(UIGestureRecognizer *)gesture
{
    if(![gesture isKindOfClass:[UIPinchGestureRecognizer class]]) return;
    
    UIPinchGestureRecognizer* pinch = gesture;
    
    SpawnDelegate* spawner = (SpawnDelegate*)self.spawnEvent.callback;
    spawner.spawnDirection = self.model.camera.shootDir;
    
    if(pinch.state == UIGestureRecognizerStateBegan){
        self.scalingStart = spawner.spawnField;
    }
    
    spawner.spawnField = self.scalingStart * pinch.scale;
    
    NSLog(@"Pinch: %f", spawner.spawnField);
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
