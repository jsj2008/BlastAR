//
//  Weapon.h
//  Projective
//
//  Created by Kirk Roerig on 12/25/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "OPjective.h"
#import "./../Scene/Projectiles.h"
#import "CameraEntity.h"

@interface Weapon : ShadedMesh <Drawable, Updateable, Ranked>

@property (nonatomic) Projectiles* projectiles;
@property (nonatomic) CameraEntity* cam;
@property (nonatomic) BOOL isTriggerHeld;
@property (nonatomic) enum ProjectileType type;
@property (nonatomic) float coolDown;
@property (nonatomic) float timeFiring;

- (instancetype)initWithProjectiles:(Projectiles*)projectiles andCamera:(CameraEntity*)cam;
- (void)beginFiring;
- (void)endFiring;
- (void)generateProjectiles:(ray3)projectile withOffset:(vec3)off;
- (GLKVector3)inaccuracyOffset:(float)inaccuracy;
- (int)damage;

@end
