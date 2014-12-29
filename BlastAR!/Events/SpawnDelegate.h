//
//  SpawnDelegate.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameModel.h"
#import "OPjective.h"

@interface SpawnDelegate : NSObject <Drawable, Ranked>

@property (nonatomic) GLKVector3 spawnDirection;

- (id) initWithGame:(GameModel*)model;
- (void) tick:(float*)interval;

- (void)setSpawnFeild:(float)spawnFeild;

@end
