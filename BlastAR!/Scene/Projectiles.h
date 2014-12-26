//
//  Projectiles.h
//  Projective
//
//  Created by Kirk Roerig on 12/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "OPjective.h"

enum ProjectileType{
    ProjectileSemi,
    ProjectileAuto,
    ProjectileScatter,
    ProjectileSeeking,
};

struct Projectile{
    ray3 positionVelocity;
    float lived;
    enum ProjectileType type;
};

@interface Projectiles : ShadedMesh <Drawable, Updateable, Ranked>

@property (nonatomic, readonly) struct Projectile* projectiles;
@property (nonatomic, readonly) unsigned int maxLiving;

- (void)fireWithRay:(ray3)originVelocity andType:(enum ProjectileType)type;

@end
