//
//  GameModel.m
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel

- (NSMutableArray*)allWeapons
{
    return _allWeapons ? _allWeapons : (_allWeapons = [[NSMutableArray alloc] init]);
}

- (OrderedScene*) scene{
    if(!_scene){
        _scene = [[OrderedScene alloc] init];
    }
    
    return _scene;
}

@end
