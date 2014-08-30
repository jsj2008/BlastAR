//
//  SpawnDelegate.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "SpawnDelegate.h"

@interface SpawnDelegate()
@property ViewController* game;
@end

@implementation SpawnDelegate

- (id) initWithGame:(ViewController*)game
{
    self = [super init];
    _game = game;
    return self;
}

- (void) tick:(float*)interval
{
    if(_game.gameState != gamePlaying) return;
 
    *interval -= 0.05f;
    
    *interval = *interval < 0.25f ? 0.25f : *interval;
    
    Creep* enemy = [[Creep alloc] init];
    [_game.enemies addObject:enemy];
    [_game.scene addObject:enemy];
    [_game.spawn play];
}

@end
