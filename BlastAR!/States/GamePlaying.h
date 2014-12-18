//
//  Game.h
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "OPjective.h"
#import "ViewController.h"
#import "./../Models/GameModel.h"

@interface GamePlaying : GameState

- (instancetype)initWithGameModel:(GameModel*)model andViewController:(ViewController*)view;

@end
