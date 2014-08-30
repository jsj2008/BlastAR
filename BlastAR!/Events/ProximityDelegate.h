//
//  ProximityDelegate.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface ProximityDelegate : NSObject

- (id) initWithGame:(ViewController*)scene;
- (void) tick:(float*)interval;

@end
