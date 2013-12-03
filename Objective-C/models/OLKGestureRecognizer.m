//
//  OLKGestureRecognizer.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-09-26.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKGestureRecognizer.h"

@implementation OLKGestureRecognizer

@synthesize gestureRecognizerDelegate = _gestureRecognizerDelegate;
@synthesize enabled = _enabled;
@synthesize status = _status;
@synthesize duration = _duration;
@synthesize identifier = _identifier;
@synthesize gestureComponents = _gestureComponents;

- (id)init
{
    if (self = [super init])
    {
        _identifier = 0;
        _status = OLK_GESTURE_DETECT;
        _duration = 0;
        _enabled = YES;
        _gestureRecognizerDelegate = nil;
        _gestureComponents = nil;
    }
    return self;
}

- (void)updateWithFrame:(LeapFrame*)frame controller:(LeapController *)leapController
{
}


@end



@implementation OLKPressGestureRecognizer

- (void)updateWithFrame:(LeapFrame*)frame controller:(LeapController *)leapController
{
}


@end

@implementation OLKPointingDepthThresholdRecognizer
{
    int _handId;
}

@synthesize threshold = _threshold;
@synthesize inDirMinus = _inDirMinus;

- (id)init
{
    if (self = [super init])
    {
        _inDirMinus = YES;
    }
    return self;
}

- (BOOL)notInRecognizingState
{
    if (![self enabled])
        return YES;
    
    if ([self status] != OLK_GESTURE_DETECT)
        return YES;
    
    return NO;
}

- (BOOL)handBeyondThreshold:(LeapFrame *)frame
{
    LeapHand *deepHand = [[frame hands] frontmost];
    
    if (deepHand == nil)
        return NO;
    
    return [[self gestureComponents] handBeyondThreshold:_threshold inDirMinus:_inDirMinus hand:deepHand];
}

- (void)updateWithFrame:(LeapFrame *)frame controller:(LeapController *)leapController
{
    if ([self notInRecognizingState])
        return;

    if (![self handBeyondThreshold:frame])
        return;
    
    [self setStatus:OLK_GESTURE_COMPLETED];
}

@end


@implementation OLKPointingPenetrateThresholdRecognizer
{
    int _handId;
}

@synthesize threshold = _threshold;
@synthesize inDirMinus = _inDirMinus;

- (id)init
{
    if (self = [super init])
    {
        _inDirMinus = YES;
    }
    return self;
}

- (BOOL)notInRecognizingState
{
    if (![self enabled])
        return YES;
    
    if ([self status] != OLK_GESTURE_DETECT)
        return YES;
    
    return NO;
}

- (BOOL)handBeyondThreshold:(LeapFrame *)frame
{
    LeapHand *deepHand = [[frame hands] frontmost];
    
    if (deepHand == nil)
        return NO;
    
    return [[self gestureComponents] handBeyondThreshold:_threshold inDirMinus:_inDirMinus hand:deepHand];
}


- (void)updateWithFrame:(LeapFrame *)frame controller:(LeapController *)leapController
{
    if ([self notInRecognizingState])
        return;

    if (_handId == 0)
        
    if (![self handBeyondThreshold:frame])
        return;

    LeapHand *deepHand = [[frame hands] frontmost];
    
    if (deepHand == nil)
        return;
    
    LeapInteractionBox *interactionBox = [frame interactionBox];
    LeapVector *stabilPalmPos = [deepHand stabilizedPalmPosition];
    LeapVector *hand = [interactionBox normalizePoint:stabilPalmPos clamp:YES];
    
    if (hand.z > 0.25 || [deepHand palmNormal].y > -0.8 || [deepHand palmNormal].z > 0.2 || [deepHand palmNormal].z < -0.2 || [deepHand palmNormal].x > 0.2 || [deepHand palmNormal].x < -0.2 )
    {
        return;
    }
    
    LeapHand *prevFrameHand = [frame hand:[deepHand id]];
    if (![prevFrameHand isValid])
        return;
    
//    LeapVector *stabilPalmPosPrev = [prevFrameHand stabilizedPalmPosition];
    
    if (hand.z < 0.25 && [[deepHand fingers] count] > 3)
    {
//        _selectingCursorPos = NO;
        return;
    }
//    else if (!_selectingCursorPos && [[deepHand fingers] count] > 2)
//        return;
    

    [self setStatus:OLK_GESTURE_COMPLETED];

}

@end