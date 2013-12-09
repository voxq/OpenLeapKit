//
//  OLKContextHand.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-04.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKContextHand.h"
#import "OLKGestureComponents.h"

@implementation OLKContextHand
{
    BOOL _palmUp;
    BOOL _palmDown;
    BOOL _palmAimingSideway;
    BOOL _palmAimingLeft;
    BOOL _palmAimingRight;
    BOOL _handPointingSideway;
    BOOL _handPointingLeft;
    BOOL _handPointingRight;
    BOOL _palmAimingInOut;
    BOOL _palmAimingIn;
    BOOL _palmAimingOut;
    
    OLKGestureComponents *_gestureComponents;
}

@synthesize previousLeapHand = _previousLeapHand;
@synthesize palmDownThreshold = _palmDownThreshold;
@synthesize palmUpThreshold = _palmUpThreshold;
@synthesize palmAimingInOutThreshold = _palmAimingInOutThreshold;
@synthesize handPointingSidewayThreshold = _handPointingSidewayThreshold;
@synthesize palmAimingSidewayThreshold = _palmAimingSidewayThreshold;

@synthesize resetThresholdBufferPercent = _resetThresholdBufferPercent;

@synthesize changedPalmDown = _changedPalmDown;
@synthesize changedPalmUp = _changedPalmUp;
@synthesize changedPalmAimingSideway = _changedPalmAimingSideway;
@synthesize changedPalmAimingLeft = _changedPalmAimingLeft;
@synthesize changedPalmAimingRight = _changedPalmAimingRight;
@synthesize changedHandPointingSideway = _changedHandPointingSideway;
@synthesize changedHandPointingLeft = _changedHandPointingLeft;
@synthesize changedHandPointingRight = _changedHandPointingRight;
@synthesize changedPalmAimingInOut = _changedPalmAimingInOut;
@synthesize changedPalmAimingIn = _changedPalmAimingIn;
@synthesize changedPalmAimingOut = _changedPalmAimingOut;

- (id)init
{
    if (self = [super init])
    {
        _palmDownThreshold = -0.8;
        _palmUpThreshold = -0.8;
        _palmAimingInOutThreshold = 0.6;
        _handPointingSidewayThreshold = 0.75;
        _palmAimingSidewayThreshold = 0.6;
        _resetThresholdBufferPercent = 0.25;
        _gestureComponents = [[OLKGestureComponents alloc] init];
    }
    return self;
}

- (void)updateLeapHand:(LeapHand *)leapHand
{
    _changedPalmUp = NO;
    _changedPalmDown = NO;
    _changedPalmAimingSideway = NO;
    _changedPalmAimingLeft = NO;
    _changedPalmAimingRight = NO;
    _changedHandPointingSideway = NO;
    _changedHandPointingLeft = NO;
    _changedHandPointingRight = NO;
    _changedPalmAimingInOut = NO;
    _changedPalmAimingIn = NO;
    _changedPalmAimingOut = NO;
    _previousLeapHand = [super leapHand];
    [super updateLeapHand:leapHand];
}

- (BOOL)palmDown
{
    if (_palmDown)
    {
        if (![_gestureComponents palmDown:[self leapHand] normalThreshold:_palmDownThreshold - (1-_palmDownThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmDown = YES;
            _palmDown = NO;
        }
    }
    else
    {
        if ([_gestureComponents palmDown:[self leapHand] normalThreshold:_palmDownThreshold])
        {
            _changedPalmDown = YES;
            _palmDown = YES;
        }
    }
    
    return _palmDown;
}

- (BOOL)palmUp
{
    if (_palmUp)
    {
        if (![_gestureComponents palmUp:[self leapHand] normalThreshold:_palmUpThreshold - (1-_palmUpThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmUp = YES;
            _palmUp = NO;
        }
    }
    else
    {
        if ([_gestureComponents palmUp:[self leapHand] normalThreshold:_palmUpThreshold])
        {
            _changedPalmUp = YES;
            _palmUp = YES;
        }
    }
    
    return _palmUp;
}

- (BOOL)palmAimingSideway
{
    if (_palmAimingSideway)
    {
        if (![_gestureComponents palmAimingSideway:[self leapHand] normalThreshold:_palmAimingSidewayThreshold - (1-_palmAimingSidewayThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmAimingSideway = YES;
            _palmAimingSideway = NO;
            if (_palmAimingRight == YES)
            {
                _changedPalmAimingRight = YES;
                _palmAimingRight = NO;
            }
            if (_palmAimingLeft == YES)
            {
                _changedPalmAimingLeft = YES;
                _palmAimingLeft = NO;
            }
        }
    }
    else
    {
        if ([_gestureComponents palmAimingSideway:[self leapHand] normalThreshold:_palmAimingSidewayThreshold])
        {
            _changedPalmAimingSideway = YES;
            _palmAimingSideway = YES;
        }
    }
    
    return _palmAimingSideway;
}

- (BOOL)palmAimingInOut
{
    if (_palmAimingInOut)
    {
        if (![_gestureComponents handPointingSideway:[self leapHand] directionThreshold:_palmAimingInOutThreshold - (1-_palmAimingInOutThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmAimingInOut = YES;
            _palmAimingInOut = NO;
        }
    }
    else
    {
        if ([_gestureComponents handPointingSideway:[self leapHand] directionThreshold:_palmAimingInOutThreshold])
        {
            _changedPalmAimingInOut = YES;
            _palmAimingInOut = YES;
        }
    }
    
    return _palmAimingInOut;
}

- (BOOL)handPointingSideway
{
    if (_handPointingSideway)
    {
        if (![_gestureComponents handPointingSideway:[self leapHand] directionThreshold:_handPointingSidewayThreshold - (1-_handPointingSidewayThreshold)*_resetThresholdBufferPercent])
        {
            _changedHandPointingSideway = YES;
            _handPointingSideway = NO;
            if (_handPointingRight == YES)
            {
                _changedHandPointingRight = YES;
                _handPointingRight = NO;
            }
            if (_handPointingLeft == YES)
            {
                _changedHandPointingLeft = YES;
                _handPointingLeft = NO;
            }
        }
    }
    else
    {
        if ([_gestureComponents handPointingSideway:[self leapHand] directionThreshold:_handPointingSidewayThreshold])
        {
            _changedHandPointingSideway = YES;
            _handPointingSideway = YES;
        }
    }
    
    return _handPointingSideway;
}

- (BOOL)palmAimingLeft
{
    if (_palmAimingLeft)
    {
        if (![_gestureComponents palmAimingLeft:[self leapHand] normalThreshold:_palmAimingSidewayThreshold - (1-_palmAimingSidewayThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmAimingLeft = YES;
            _palmAimingLeft = NO;
        }
    }
    else
    {
        if ([_gestureComponents palmAimingLeft:[self leapHand] normalThreshold:_palmAimingSidewayThreshold])
        {
            _changedPalmAimingLeft = YES;
            _palmAimingLeft = YES;
            if (_palmAimingRight == YES)
            {
                _changedPalmAimingRight = YES;
                _palmAimingRight = NO;
            }
            if (_palmAimingSideway == NO)
            {
                _changedPalmAimingSideway = YES;
                _palmAimingSideway = YES;
            }
        }
    }
    
    return _palmAimingLeft;
}

- (BOOL)palmAimingRight
{
    if (_palmAimingRight)
    {
        if (![_gestureComponents palmAimingRight:[self leapHand] normalThreshold:_palmAimingSidewayThreshold - (1-_palmAimingSidewayThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmAimingRight = YES;
            _palmAimingRight = NO;
        }
    }
    else
    {
        if ([_gestureComponents palmAimingRight:[self leapHand] normalThreshold:_palmAimingSidewayThreshold])
        {
            _changedPalmAimingRight = YES;
            _palmAimingRight = YES;
            if (_palmAimingLeft == YES)
            {
                _changedPalmAimingLeft = YES;
                _palmAimingLeft = NO;
            }
            if (_palmAimingSideway == NO)
            {
                _changedPalmAimingSideway = YES;
                _palmAimingSideway = YES;
            }
        }
    }
    
    return _palmAimingRight;
}

- (BOOL)handPointingLeft
{
    if (_handPointingLeft)
    {
        if (![_gestureComponents handPointingLeft:[self leapHand] directionThreshold:_handPointingSidewayThreshold - (1-_handPointingSidewayThreshold)*_resetThresholdBufferPercent])
        {
            _changedHandPointingLeft = YES;
            _handPointingLeft = NO;
        }
    }
    else
    {
        if ([_gestureComponents handPointingLeft:[self leapHand] directionThreshold:_handPointingSidewayThreshold])
        {
            _changedHandPointingLeft = YES;
            _handPointingLeft = YES;
            if (_handPointingRight == YES)
            {
                _changedHandPointingRight = YES;
                _handPointingRight = NO;
            }
            if (_handPointingSideway == NO)
            {
                _changedHandPointingSideway = YES;
                _handPointingSideway = YES;
            }
        }
    }
    
    return _handPointingLeft;
}

- (BOOL)handPointingRight
{
    if (_handPointingRight)
    {
        if ([_gestureComponents handPointingRight:[self leapHand] directionThreshold:_handPointingSidewayThreshold - (1-_handPointingSidewayThreshold)*_resetThresholdBufferPercent])
        {
            _changedHandPointingRight = YES;
            _handPointingRight = NO;
        }
    }
    else
    {
        if ([_gestureComponents handPointingRight:[self leapHand] directionThreshold:_handPointingSidewayThreshold])
        {
            _changedHandPointingRight = YES;
            _handPointingRight = YES;
            if (_handPointingLeft == YES)
            {
                _changedHandPointingLeft = YES;
                _handPointingLeft = NO;
            }
            if (_handPointingSideway == NO)
            {
                _changedHandPointingSideway = YES;
                _handPointingSideway = YES;
            }
        }
    }
    
    return _handPointingRight;
}

- (BOOL)palmAimingIn
{
    if (_palmAimingIn)
    {
        if (![_gestureComponents palmAimingIn:[self leapHand] normalThreshold:_palmAimingInOutThreshold - (1-_palmAimingInOutThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmAimingIn = YES;
            _palmAimingIn = NO;
        }
    }
    else
    {
        if ([_gestureComponents palmAimingIn:[self leapHand] normalThreshold:_palmAimingInOutThreshold])
        {
            _changedPalmAimingIn = YES;
            _palmAimingIn = YES;
            if (_palmAimingOut == YES)
            {
                _changedPalmAimingOut = YES;
                _palmAimingOut = NO;
            }
            if (_palmAimingInOut == NO)
            {
                _changedPalmAimingInOut = YES;
                _palmAimingInOut = YES;
            }
        }
    }
    
    return _palmAimingIn;
}

- (BOOL)palmAimingOut
{
    if (_palmAimingOut)
    {
        if (![_gestureComponents palmAimingOut:[self leapHand] normalThreshold:_palmAimingInOutThreshold - (1-_palmAimingInOutThreshold)*_resetThresholdBufferPercent])
        {
            _changedPalmAimingOut = YES;
            _palmAimingOut = NO;
        }
    }
    else
    {
        if ([_gestureComponents palmAimingOut:[self leapHand] normalThreshold:_palmAimingInOutThreshold])
        {
            _changedPalmAimingOut = YES;
            _palmAimingOut = YES;
            if (_palmAimingIn == YES)
            {
                _changedPalmAimingIn = YES;
                _palmAimingIn = NO;
            }
            if (_palmAimingInOut == NO)
            {
                _changedPalmAimingInOut = YES;
                _palmAimingInOut = YES;
            }
        }
    }
    
    return _palmAimingOut;
}

@end
