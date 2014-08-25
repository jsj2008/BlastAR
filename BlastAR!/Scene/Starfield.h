//
//  Starfield.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"
#import "ShadedMesh.h"

@interface Starfield : ShadedMesh<Drawable>

- (id) initWithStars:(int)stars;

@end
