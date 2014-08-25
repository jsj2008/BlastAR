//
//  SoundFactory.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/24/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"

@interface SoundFactory : NSObject

+ (Sound*) createSpawn;
+ (Sound*) createShoot;
+ (Sound*) createProximity;

@end
