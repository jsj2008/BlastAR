//
//  SoundFactory.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/24/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "SoundFactory.h"

@implementation SoundFactory

+ (Sound*) createSpawn
{
    static short spawnData[11050];
    for (int i = 11050; i--;) {
        float f = i / 11050.0f;
        short sample = (short)(sin((f * 400 * M_PI_2) * (1.0f - f)) * SHRT_MAX);
        spawnData[i] = sample;
    }
    return [[Sound alloc] initWithData:spawnData ofLength:sizeof(spawnData) asStereo:NO withSoundCount:10];
}

+ (Sound*) createShoot
{
    // Create the shooting sound using some random samples that taper
    // off in amplitude as the sound nears the end;
    static short pewData[5525];
    for (int i = 5525; i--;) {
        float f = 1.0f - (i / 5525.0f);
        short sample = (short)(((rand() % (SHRT_MAX << 1)) - SHRT_MAX) * f);
        pewData[i] = sample;
    }
    return [[Sound alloc] initWithData:pewData ofLength:sizeof(pewData) asStereo:NO withSoundCount:5];
}

+ (Sound*) createProximity
{
    static short beep[5525];
    
    for (int i = 5525; i--;) {
        float f = (i / 5525.0f);
        short sample = (short)(f * cos(f * 1000) * sin(f * M_PI) * SHRT_MAX);
        beep[i] = sample;
    }
    
    return [[Sound alloc] initWithData:beep ofLength:sizeof(beep) asStereo:NO withSoundCount:5];
}

@end
