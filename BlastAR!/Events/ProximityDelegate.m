//
//  ProximityDelegate.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ProximityDelegate.h"

@interface ProximityDelegate()
@property GameModel* game;
@end

@implementation ProximityDelegate

- (id) initWithGame:(GameModel*)model
{
    self = [super init];
    _game = model;
    return self;
}

- (void) tick:(float*)interval
{
    float dist = vec3_dist((float*)VEC3_ZERO, _game.nearestEnemy.position.v);
    if(_game.nearestEnemy != nil){
        [_game.proximityWarning play];
        
        if(dist < 0.75f){
            // TODO end game, player lost
        }
    }
}

@end
