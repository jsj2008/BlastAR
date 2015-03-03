//
//  Shootable.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Shootable <NSObject>

@property GLKVector3 lastHitPoint;

- (BOOL) fireAt:(ray3)projectile withIntersection:(vec3)hitPoint;
- (BOOL) fireAt:(ray3)projectile withIntersection:(vec3)hitPoint andSolutionLessThan:(float)t withDamage:(float)dmg;

@end
