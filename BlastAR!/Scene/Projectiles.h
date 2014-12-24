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
    vec3 position;
    vec3 velocity;
    float lived;
    enum ProjectileType type;
};

@interface Projectiles : ShadedMesh <Drawable, Updateable, Ranked>

- (void)fireWithRay:(ray3)originVelocity andType:(enum ProjectileType)type;

@end
