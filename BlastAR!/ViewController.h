//
//  ViewController.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Enemy/Creep.h"
#import "CreepRenderGroup.h"
#import "OPjective.h"

enum GameState{
    gameMainMenu,
    gamePlaying,
    gameOver
};

@interface ViewController : GLKViewController

@property (nonatomic) OrderedScene *scene;
@property (nonatomic) NSMutableArray *enemies;
@property (nonatomic) Creep* nearestEnemy;
@property (nonatomic) CreepRenderGroup* creeps;


@property (nonatomic) float viewRedness;

@property (strong, nonatomic) NSDate* lastTime;
@property (nonatomic) Sound* pewPew;
@property (nonatomic) Sound* spawn;
@property (nonatomic) Sound* proximityWarning;

@property (nonatomic) enum GameState gameState;

@end
