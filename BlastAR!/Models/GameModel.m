//
//  GameModel.m
//  Projective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel

- (NSMutableArray*) enemies{
    if(!_enemies){
        _enemies = [[NSMutableArray alloc] init];
    }
    
    return _enemies;
}

- (OrderedScene*) scene{
    if(!_scene){
        _scene = [[OrderedScene alloc] init];
    }
    
    return _scene;
}


@end
