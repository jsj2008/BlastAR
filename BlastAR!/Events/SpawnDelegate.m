//
//  SpawnDelegate.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "SpawnDelegate.h"

@interface SpawnDelegate()
@property GameModel* game;
@property PostEffect* spawnFieldEffect;
@property GLfloat totalTime;
@end

@implementation SpawnDelegate

- (id) initWithGame:(GameModel*)model
{
    self = [super init];
    _game = model;
    _spawnFieldEffect = [[PostEffect alloc] initWithShader:@"SpawnField"];
    _spawnDirection = GLKVector3MakeWithArray((float*)VEC3_FORWARD);
    _spawnField = 1.0;
    _totalTime = 0;
    
    return self;
}

- (void) tick:(float*)interval
{
    *interval -= 0.05f;
    *interval = *interval < 0.25f ? 0.25f : *interval;
    
    Creep* enemy = [[Creep alloc] initWithPosition:GLKVector3MultiplyScalar(_game.camera.shootDir, 10)];
//    [_game.scene addObject:enemy toGroup:@"creeps"];
    [_game.scene addObject:enemy];
    [_game.spawn play];
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return -1;
}

- (void)updateWithTimeElapsed:(double)dt
{
    self.totalTime += dt;
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    glDisable(GL_DEPTH_TEST);
    [self.spawnFieldEffect bind];
    [self.spawnFieldEffect usingArray:self.game.camera.shootDir.v ofLength:1 andType:vec3Array withName:"uForward"];
    [self.spawnFieldEffect usingArray:self.game.camera.left.v     ofLength:1 andType:vec3Array withName:"uLeft"];
    [self.spawnFieldEffect usingArray:self.game.camera.up.v       ofLength:1 andType:vec3Array withName:"uUp"];
    [self.spawnFieldEffect usingArray:self.spawnDirection.v ofLength:1 andType:vec3Array withName:"uSpawnDirection"];
    [self.spawnFieldEffect usingFloat:&_spawnField ofLength:1 withName:"uField"];
    [self.spawnFieldEffect usingFloat:&_totalTime ofLength:1 withName:"uTime"];
    [self.spawnFieldEffect drawWithViewProjection:viewProjection];
}

@end
