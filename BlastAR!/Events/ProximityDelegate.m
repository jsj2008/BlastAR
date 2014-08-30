//
//  ProximityDelegate.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ProximityDelegate.h"

@interface ProximityDelegate()
@property ViewController* game;
@end

@implementation ProximityDelegate

- (id) initWithGame:(ViewController*)game
{
    self = [super init];
    _game = game;
    return self;
}

- (void) tick:(float*)interval
{
    float dist = vec3_dist((float*)VEC3_ZERO, _game.nearestEnemy.position.v);
    if(_game.nearestEnemy != nil){
        [_game.proximityWarning play];
        
        if(dist < 0.75f){
            _game.gameState = gameOver;
        }
    }
}

@end
