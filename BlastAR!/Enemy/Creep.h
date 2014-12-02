//
//  Creep.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"
#import "Shootable.h"

@interface Creep : ShadedMesh <Drawable, Updateable, Ranked, Shootable>

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 velocity;
@property (nonatomic, readonly) int HP;

+ (Sound*) soundHit;

@end
