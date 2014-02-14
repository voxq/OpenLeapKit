//
//  OLKRepeatTracker.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-01.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKRepeatTracker.h"

@implementation OLKRepeatTracker

@synthesize isRepeating = _isRepeating;
@synthesize repeatRate = _repeatRate;
@synthesize repeatCycles = _repeatCycles;
@synthesize repeatedCount = _repeatedCount;
@synthesize repeatedCountAtSpeed = _repeatedCountAtSpeed;
@synthesize repeatAccelOnCycles = _repeatAccelOnCycles;
@synthesize repeatAccelAmt = _repeatAccelAmt;
@synthesize repeatAccel = _repeatAccel;
@synthesize repeatObject = _repeatObject;


- (id)init
{
    if (self = [super init])
    {
        [self resetToDefaults];
        [self reset];
    }
    return self;
}
- (void)resetToDefaults
{
    _repeatRate = 20;
    _repeatAccelOnCycles = 1;
    _repeatAccelAmt = 5;
    _repeatAccel = 1;
}

- (void)reset
{
    _repeatCycles = 0;
    _repeatedCountAtSpeed = 0;
    _repeatedCount = 0;
    _isRepeating = FALSE;
}

- (void)initRepeatWithObject:(id)object
{
    _repeatAccel = 1;
    _repeatedCount = 0;
    _repeatedCountAtSpeed = 0;
    
    _isRepeating = YES;
    _repeatCycles = 0;
    _repeatObject = object;
}

- (void)stopRepeatIfObject:(id)object
{
    if (!_isRepeating)
        return;
    
    if ([object isEqual:_repeatObject])
        _isRepeating = NO;
}

- (BOOL)detectRepeatOfObject:(id)object
{
    if (!_isRepeating)
        return NO;

    if (![object isEqual:_repeatObject])
        return NO;
    
    _repeatCycles ++;

    if (_repeatCycles < _repeatRate-_repeatAccel)
        return NO;
    
    //            NSLog(@"Repeating!");
    _repeatedCount ++;
    _repeatedCountAtSpeed ++;
    if (_repeatAccel > 0 && _repeatedCountAtSpeed>_repeatAccelOnCycles*(_repeatAccel/_repeatAccelAmt))
    {
        //                NSLog(@"Accelerating repeat!");
        _repeatAccel += _repeatAccelAmt;
        _repeatedCountAtSpeed = 0;
    }
    _repeatCycles = 0;
    return YES;
}


@end
