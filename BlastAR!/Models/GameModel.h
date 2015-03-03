//
//  GameModel.h
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"
#import "CameraEntity.h"
#import "./../Scene/Background.h"
#import "./../Scene/Starfield.h"
#import "./../Scene/Crosshair.h"
#import "./../Scene/Projectiles.h"
#import "./../Effects/SoundFactory.h"
#import "./../Effects/Particles.h"
#import "./../Effects/ParticleFactory.h"
#import "./../Enemy/Creep.h"
#import "./../CreepGroup.h"
#import "./../Weapons/Weapons.h"
//#import "./../Weapons/Weapons.h"

@interface GameModel : NSObject

@property (nonatomic) CameraEntity* camera;
@property (strong, nonatomic) id <Drawable, Ranked> crosshair;
@property (strong, nonatomic) Starfield* background;
@property (nonatomic) Projectiles* projectiles;

@property (nonatomic) OrderedScene *scene;
@property (nonatomic) Creep* nearestEnemy;
@property (nonatomic) CreepGroup* creeps;

@property (nonatomic) float viewRedness;

@property (strong, nonatomic) NSDate* lastTime;
@property (nonatomic) Sound* pewPew;
@property (nonatomic) Sound* spawn;
@property (nonatomic) Sound* proximityWarning;

@property (nonatomic) NSMutableArray* allWeapons;
@property (nonatomic) Weapon* selectedWeapon;

@end
