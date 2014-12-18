//
//  ProximityDelegate.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameModel.h"

@interface ProximityDelegate : NSObject

- (id) initWithGame:(GameModel*)model;
- (void) tick:(float*)interval;

@end
