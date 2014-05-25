/*
 
 Copyright (c) 2013, Tyler Zetterstrom
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

//
//  OLKHandsContainerViewController.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-22.
//

#import "LeapObjectiveC.h"
#import "OLKHandsContainerViewController.h"
#import "OLKHand.h"
#import "OLKHelpers.h"
//#import "OLKGestureRecognizer.h"
//#import "OLKGestureRecognizerDispatcher.h"

typedef enum
{
    OLKFingerTapStateHovering,
    OLKFingerTapStateOrienting,
    OLKFingerTapStateLifting,
    OLKFingerTapStatePeaking,
    OLKFingerTapStateDropping,
    OLKFingerTapStateTapping,
    OLKFingerTapStateRedHerring
} OLKFingerTapState;

static NSString * const OLKKeyFingerTapStateStart = @"Finger State Start";
static NSString * const OLKKeyFingerTapState = @"Finger State";
static NSString * const OLKKeyFingerTapPosHistory = @"Finger Position History";
static NSString * const OLKKeyFingerTapCount = @"Finger Tap Count";
static NSString * const OLKKeyFingerTapPosOriginal = @"Finger Tap Original Position";

static const NSSize gTrimInteractionBox={0.05,0.05};
static const NSUInteger gConfirmHandednessFrameThreshold=1500;

@implementation OLKHandsContainerViewController
{
    LeapController *_leapController;
    LeapInteractionBox *_interactionBox;
    LeapDevice *_leapDevice;
    LeapHand *_prevHand;
    float _longestTimeHandVis;
    NSArray *_leapHandsThisFrame;
    long _leapHandsThisFrameId;
    NSMutableDictionary *_tapDetects;
}

@synthesize leapFrame = _leapFrame;
@synthesize drawHands = _drawHands;
@synthesize handsSpaceView = _handsSpaceView;
@synthesize overrideSpaceViews = _overrideSpaceViews;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize oldestHand = _oldestHand;
@synthesize leftHand = _leftHand;
@synthesize rightHand = _rightHand;
@synthesize leftHandView = _leftHandView;
@synthesize rightHandView = _rightHandView;
@synthesize handsViews = _handsViews;
@synthesize leftHands = _leftHands;
@synthesize rightHands = _rightHands;
@synthesize resetAutoFitOnNewHand = _resetAutoFitOnNewHand;
@synthesize trimInteraction = _trimInteraction;
@synthesize gestureContext = _gestureContext;
@synthesize useInteractionBox = _useInteractionBox;
@synthesize allowAllHands = _allowAllHands;
@synthesize showPointables = _showPointables;
@synthesize pointableViews = _pointableViews;
@synthesize rangeOffset = _rangeOffset;
@synthesize proximityOffset = _proximityOffset;
@synthesize percentRangeOfMaxWidth = _percentRangeOfMaxWidth;
@synthesize fitHandFact = _fitHandFact;
@synthesize calibrator = _calibrator;
@synthesize findRightLeft = _findRightLeft;
@synthesize constrainHandsToSpace = _constrainHandsToSpace;

- (id)init
{
    if (self = [super init])
    {
        _drawHands = TRUE;
        _resetAutoFitOnNewHand = FALSE;
        _overrideSpaceViews = FALSE;
        _longestTimeHandVis = 0;
        _fitHandFact = defaultFitHandFact;
        _trimInteraction = gTrimInteractionBox;
        _gestureContext = [[NSMutableArray alloc] init];
        _useStabilized = TRUE;
        _useInteractionBox = TRUE;
        _allowAllHands = TRUE;
        _constrainHandsToSpace = TRUE;
        _findRightLeft = YES;
        _showPointables = TRUE;
        _rangeOffset = -80;
        _proximityOffset = 0;
        _percentRangeOfMaxWidth = 0.6;
        _handednessAlgorithm = OLKHandednessAlgorithmThumbTipAndBase;
        _detectTouchMethod = OLKHandsDetectTouchEmulation;
    }
    return self;
}

- (NSView <OLKHandContainer>*)viewForHand:(OLKHand *)hand
{
    for (NSView <OLKHandContainer> *handView in _handsViews)
    {
        if ([[handView hand] isEqual:hand])
            return handView;
    }
    return nil;
}

- (NSView <OLKHandContainer>*)viewForLeapHandId:(int)leapHandId
{
    for (NSView <OLKHandContainer> *handView in _handsViews)
    {
        if ([[[handView hand] leapHand] id] == leapHandId)
            return handView;
    }
    return nil;
}

- (OLKHand *)handFromLeapHand:(LeapHand *)leapHand
{
    for (OLKHand *hand in _hands)
        if ([hand isLeapHand:leapHand])
            return hand;
    
    return nil;
}

- (void)setHandsSpaceView:(NSView <OLKHandsContainerView> *)handsSpaceView
{
    _handsSpaceView = handsSpaceView;
    for (NSView <OLKHandContainer> *handView in _handsViews)
    {
        if ([handView spaceView])
            continue;
        
        [handView removeFromSuperview];
        [_handsSpaceView addHandView:handView];
    }
}

- (void)setOverrideSpaceViews:(BOOL)overrideSpaceViews
{
    _overrideSpaceViews = overrideSpaceViews;
    if (overrideSpaceViews)
        [self updateHandsAndPointablesViews];
}

- (NSArray *)newLeapHands
{
    NSArray *leapHands = self.leapHands;
    NSMutableArray *newHands = [[NSMutableArray alloc] initWithCapacity:leapHands.count];
    for (LeapHand *leapHand in leapHands)
    {
        NSView <OLKHandContainer>*handView = [self viewForLeapHandId:[leapHand id]];
        if (!handView)
            [newHands addObject:leapHand];
    }
    return [NSArray arrayWithArray:newHands];
}

- (NSMutableArray *)createHandViews:(NSArray *)hands
{
    NSMutableArray *handsViews = [[NSMutableArray alloc] init];
    if (!hands || ![hands count])
        return handsViews;

    for (OLKHand *hand in hands)
    {
        NSView <OLKHandContainer> *handView = [self viewForHand:hand];
        if (!handView)
        {
            [hand setUsesStabilized:_useStabilized];
            handView = [_dataSource handViewForHand:hand];
            NSLog(@"Creating Hand View!");
        }
        [handsViews addObject:handView];
    }
    
    return handsViews;
}

- (OLKHand *)newHandFromLeapHand:(LeapHand *)leapHand withFactory:(NSObject <OLKHandFactory>*)factory
{
    OLKHand *hand;
    if (factory)
        hand = [factory manufactureHand:leapHand];
    else
        hand = [[OLKHand alloc] init];
    
    [hand setHandednessAlgorithm:_handednessAlgorithm];
    [hand setLeapHand:leapHand];
    return hand;
}

- (NSMutableArray *)assignLeftRightHands
{
    NSMutableSet *ignoreLeapHands=[[NSMutableSet alloc] init];
    NSMutableSet *ignoreHands=[[NSMutableSet alloc] init];
    
    if (_leftHand)
    {
        [ignoreLeapHands addObject:[_leftHand leapHand]];
        [ignoreHands addObject:_leftHand];
    }
    if (_rightHand)
    {
        [ignoreLeapHands addObject:[_rightHand leapHand]];
        [ignoreHands addObject:_rightHand];
    }
    NSObject <OLKHandFactory>*factory = nil;
    if (_dataSource && [_dataSource  respondsToSelector:@selector(handFactory)])
        factory = [_dataSource handFactory];
    
    NSDictionary *handsHandednessDict = [OLKHand leftRightHandSearch:self.leapHands ignoreHands:ignoreLeapHands handednessAlgorithm:_handednessAlgorithm factory:factory];
    
    OLKHand *bestGuessHand = [handsHandednessDict objectForKey:OLKHandBestLeftGuessKey];
    if (!_leftHand)
        _leftHand = bestGuessHand;
    else if ([_leftHand handedness] == OLKHandednessUnknown && [bestGuessHand handedness] == OLKLeftHand)
        _leftHand = bestGuessHand;
    
    bestGuessHand = [handsHandednessDict objectForKey:OLKHandBestRightGuessKey];
    if (bestGuessHand && ![_leftHand isEqual:bestGuessHand])
    {
        if (!_rightHand)
            _rightHand = bestGuessHand;
        if ([_rightHand handedness] == OLKHandednessUnknown && [bestGuessHand handedness] == OLKRightHand)
            _rightHand = bestGuessHand;
    }
    if ([_leftHand handedness] == OLKHandednessUnknown)
        [_leftHand setSimHandedness:OLKLeftHand];
    if ([_rightHand handedness] == OLKHandednessUnknown)
        [_rightHand setSimHandedness:OLKRightHand];
    
    NSMutableArray *allHands = [[NSMutableArray alloc] init];

    NSArray *hands = [handsHandednessDict objectForKey:OLKHandLeftHandsKey];
    if (hands)
        [allHands addObjectsFromArray:hands];
    
    hands = [handsHandednessDict objectForKey:OLKHandRightHandsKey];
    if (hands)
        [allHands addObjectsFromArray:hands];
    
    hands = [handsHandednessDict objectForKey:OLKHandUnknownHandednessKey];
    if (hands)
        [allHands addObjectsFromArray:hands];
    
    if ([ignoreLeapHands count])
        [allHands addObjectsFromArray:[ignoreHands allObjects]];
    
    NSMutableArray *handsViews = [self createHandViews:allHands];
    _hands = [NSArray arrayWithArray:allHands];

    if (_leftHandView)
        [handsViews addObject:_leftHandView];
    if (_rightHandView)
        [handsViews addObject:_rightHandView];
    
    return handsViews;
}

- (LeapHand *)leapHandWithId:(long)identifier
{
    for (LeapHand *leapHand in self.leapHands)
    {
        if (leapHand.id == identifier)
            return leapHand;
    }
    return nil;
}

- (void)addTapInit:(LeapFinger *)finger toArray:(NSMutableArray *)array
{
    NSMutableDictionary *tapDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:finger], OLKKeyFingerTapPosHistory,
                             OLKFingerTapStateOrienting, OLKKeyFingerTapState, [NSDate date], OLKKeyFingerTapStateStart,
                             [NSNumber numberWithInteger:0], OLKKeyFingerTapCount, finger.tipPosition, OLKKeyFingerTapPosOriginal, nil];
    if (!_tapDetects)
        _tapDetects = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    if (array)
        [array addObject:tapDict];
    else
    {
        array = [NSMutableArray arrayWithObject:tapDict];
        [_tapDetects setObject:array forKey:[NSNumber numberWithInteger:finger.id]];
    }
}

- (OLKFingerTapState)handleTapOrienting:(NSMutableDictionary *)tapDetectDict finger:(LeapFinger *)finger
{
//    NSLog(@"Finger touch dist: %f", finger.touchDistance);

    if (finger.touchZone == LEAP_POINTABLE_ZONE_HOVERING && finger.touchDistance > 0.01)
    {
//        if (finger.touchDistance < 0.03)
//        {
//    //        NSLog(@"Finger lifting");
//            return OLKFingerTapStateLifting;
//        }
//        NSLog(@"Finger peaking");
//        return OLKFingerTapStatePeaking;
        return OLKFingerTapStateDropping;
    }

    NSInteger tapCount = [[tapDetectDict objectForKey:OLKKeyFingerTapCount] integerValue];
    if (tapCount != 0)
    {
        NSDate *stateStart = [tapDetectDict objectForKey:OLKKeyFingerTapStateStart];
        if ([stateStart timeIntervalSinceNow] < -0.5)
            return OLKFingerTapStateRedHerring;
    }
    else
        [tapDetectDict setObject:finger.tipPosition forKey:OLKKeyFingerTapPosOriginal];
    
    return OLKFingerTapStateOrienting;
}

- (OLKFingerTapState)handleTapLifting:(NSMutableDictionary *)tapDetectDict finger:(LeapFinger *)finger
{
    NSDate *stateStart = [tapDetectDict objectForKey:OLKKeyFingerTapStateStart];
    if (finger.touchDistance >= 0.03)
        return OLKFingerTapStatePeaking;
    
    if ([stateStart timeIntervalSinceNow] < -0.5)
        return OLKFingerTapStateRedHerring;
    
    return OLKFingerTapStateLifting;
}

- (OLKFingerTapState)handleTapPeaking:(NSMutableDictionary *)tapDetectDict finger:(LeapFinger *)finger
{
    NSDate *stateStart = [tapDetectDict objectForKey:OLKKeyFingerTapStateStart];
    
    if (finger.touchDistance <= 0.04)
        return OLKFingerTapStateDropping;

    if ([stateStart timeIntervalSinceNow] < -0.5)
        return OLKFingerTapStateRedHerring;
    
    return OLKFingerTapStatePeaking;
}

- (OLKFingerTapState)handleTapDropping:(NSMutableDictionary *)tapDetectDict finger:(LeapFinger *)finger tapCountDetected:(NSInteger *)tapCountDetected
{
    NSDate *stateStart = [tapDetectDict objectForKey:OLKKeyFingerTapStateStart];
    
    if (finger.touchZone == LEAP_POINTABLE_ZONE_TOUCHING)
    {
        NSInteger tapCount = [[tapDetectDict objectForKey:OLKKeyFingerTapCount] integerValue];
        tapCount ++;
        *tapCountDetected = tapCount;
        [tapDetectDict setObject:[NSNumber numberWithInteger:tapCount] forKey:OLKKeyFingerTapCount];
        NSLog(@"Tap detected!");
        return OLKFingerTapStateOrienting;
    }

//    if (finger.touchDistance >= 0.05)
//        return OLKFingerTapStateRedHerring;

    if ([stateStart timeIntervalSinceNow] < -0.5)
        return OLKFingerTapStateRedHerring;

    return OLKFingerTapStateDropping;
}

- (BOOL)updateTapFinger:(LeapFinger *)finger tapCountDetected:(NSInteger *)tapCountDetected
{
//    if (finger.touchZone == LEAP_POINTABLE_ZONE_HOVERING && finger.touchDistance > 0.01)
//        NSLog(@"Finger id(%d) Hovering", finger.id);
//    else
//        NSLog(@"Finger id(%d) Not Hovering", finger.id);

    NSMutableArray *fingerTapDetects = [_tapDetects objectForKey:[NSNumber numberWithInteger:finger.id]];
    BOOL noneOrienting = TRUE;
    BOOL tapDetected = FALSE;
    NSUInteger i = 0;
    NSMutableIndexSet *removeDetects = [[NSMutableIndexSet alloc] init];
    NSMutableDictionary *tapDetectDict;
    for (tapDetectDict in fingerTapDetects)
    {
        NSInteger state = [[tapDetectDict objectForKey:OLKKeyFingerTapState] integerValue];
        NSInteger newState;
        switch (state)
        {
            case OLKFingerTapStateOrienting:
                newState = [self handleTapOrienting:tapDetectDict finger:finger];
                noneOrienting = FALSE;
                break;
            case OLKFingerTapStateLifting:
                newState = [self handleTapLifting:tapDetectDict finger:finger];
                break;
            case OLKFingerTapStatePeaking:
                newState = [self handleTapPeaking:tapDetectDict finger:finger];
                break;
            case OLKFingerTapStateDropping:
                newState = [self handleTapDropping:tapDetectDict finger:finger tapCountDetected:tapCountDetected];
                break;
        }
        if (newState == OLKFingerTapStateRedHerring)
        {
//            NSLog(@"Finger Id(%d) Red Herring!", finger.id);
            [removeDetects addIndex:i];
        }
        else if (newState != state)
        {
//            NSLog(@"Finger id(%d) State changed from %d to %d!", finger.id, state, newState);
            if (newState == OLKFingerTapStateOrienting)
            {
                noneOrienting = FALSE;
                if (state == OLKFingerTapStateDropping)
                    tapDetected = TRUE;
            }
            [tapDetectDict setObject:[NSDate date] forKey:OLKKeyFingerTapStateStart];
            [tapDetectDict setObject:[NSNumber numberWithInteger:newState] forKey:OLKKeyFingerTapState];
            if (tapDetected)
                break;
        }
        i ++;
    }

    if (tapDetected)
    {
        [fingerTapDetects removeAllObjects];
        [fingerTapDetects addObject:tapDetectDict];
    }
    else
        [fingerTapDetects removeObjectsAtIndexes:removeDetects];
    if (noneOrienting && finger.touchZone == LEAP_POINTABLE_ZONE_TOUCHING)
    {
        [self addTapInit:finger toArray:fingerTapDetects];
//        NSLog(@"Finger id(%d) Added tap Init!", finger.id);
    }
    return tapDetected;
}

- (NSArray *)leapHands
{
    if (_leapFrame.hands.count)
        return _leapFrame.hands;

    if (!_leapFrame.fingers.count)
        return _leapFrame.hands;

    if (_leapHandsThisFrameId == _leapFrame.id)
        return _leapHandsThisFrame;
    
    NSMutableArray *leapHands = [[NSMutableArray alloc] init];
    LeapFingerAsLeapHand *leapHand=nil;
    LeapFingerAsLeapHand *leapHandNeedingCtl=nil;
    BOOL prevLeapHandNeedsCtl=FALSE;
    BOOL newHandNeedingCtl;
    for (LeapFinger *finger in _leapFrame.fingers)
    {
        if (_detectTouchMethod == OLKHandsDetectTouchSecondTouch)
        {
            newHandNeedingCtl = FALSE;
            if (finger.touchZone == LEAP_POINTABLE_ZONE_TOUCHING)
            {
                if (prevLeapHandNeedsCtl)
                {
                    prevLeapHandNeedsCtl = FALSE;
                    leapHandNeedingCtl.isTouching = TRUE;
                    leapHandNeedingCtl = nil;
                }
                else
                {
                    prevLeapHandNeedsCtl = TRUE;
                    newHandNeedingCtl = TRUE;
                }
            }
        }
        leapHand = [[LeapFingerAsLeapHand alloc] init];
        leapHand.fingerToMapToHand = finger;
        NSInteger tapCountDetected = 0;
        [self updateTapFinger:leapHand.fingerToMapToHand tapCountDetected:&tapCountDetected];
        if (tapCountDetected)
        {
            leapHand.tapCount = tapCountDetected;
            leapHand.lastTapTime = [NSDate date];
        }
        if (_detectTouchMethod == OLKHandsDetectTouchSecondTouch)
        {
            leapHand.isTouching = FALSE;
            if (newHandNeedingCtl)
                leapHandNeedingCtl = leapHand;
        }
        else if (_detectTouchMethod == OLKHandsDetectTouchEmulation)
        {
            if (finger.touchZone == LEAP_POINTABLE_ZONE_TOUCHING)
                leapHand.isTouching = TRUE;
            else
                leapHand.isTouching = FALSE;
        }
        else if (_detectTouchMethod == OLKHandsDetectTouchDoubleTap || _detectTouchMethod == OLKHandsDetectTouchSingleTap)
        {
            if (((tapCountDetected == 1 && _detectTouchMethod == OLKHandsDetectTouchSingleTap) || (tapCountDetected > 1 && _detectTouchMethod == OLKHandsDetectTouchDoubleTap)) && !leapHand.isTouching)
            {
                leapHand.isTouching = TRUE;
//                    [_tapDetects removeObjectForKey:[NSNumber numberWithInteger:finger.id]];
            }
        }
        [leapHands addObject:leapHand];
    }
    _leapHandsThisFrame = [leapHands copy];
    _leapHandsThisFrameId = _leapFrame.id;
    return _leapHandsThisFrame;
}

- (void)assignHands
{
    if ([_hands count] == [self.leapHands count])
        return;
    
    NSMutableArray *handsViews;
    if (_findRightLeft)
        handsViews = [self assignLeftRightHands];
    else
        [self generateHands];
    if (_findRightLeft)
    {
        if (_leftHandView)
            [handsViews addObject:_leftHandView];
        if (_rightHandView)
            [handsViews addObject:_rightHandView];
        if ([handsViews count])
            _handsViews = [NSArray arrayWithArray:handsViews];
    }
}

- (void)removeMissingHandView:(NSView <OLKHandContainer> *)handView
{
    if (!handView)
        return;

    if ([handView.hand isKindOfClass:[LeapFingerAsLeapHand class]])
        [_tapDetects removeObjectForKey:[NSNumber numberWithInteger:((LeapFingerAsLeapHand *)handView.hand).fingerToMapToHand.id]];
    OLKHand *hand = [handView hand];
    if ([hand isEqual:_leftHand])
        _leftHand = nil;
    if ([hand isEqual:_rightHand])
        _rightHand = nil;
    if ([_delegate respondsToSelector:@selector(willRemoveHand:withHandView:)])
        [_delegate willRemoveHand:hand withHandView:handView];
    
//        NSLog(@"Removing Hand View!");
    
    [handView removeFromSuperview];
    if (handView == _leftHandView)
        _leftHandView = nil;
    if (handView == _rightHandView)
        _rightHandView = nil;
}

- (BOOL)invalidHandPosition:(LeapHand *)leapHand
{
    if ([leapHand isKindOfClass:[LeapFingerAsLeapHand class]])
        return NO;
    LeapVector *palmPosition;
    if (_useStabilized)
        palmPosition = [leapHand stabilizedPalmPosition];
    else
        palmPosition = [leapHand palmPosition];
    
    float distanceToBounds = [OLKHelpers distanceToWidthBoundary:palmPosition leapDevice:_leapDevice];
    if (distanceToBounds < 0)
        return YES;
    distanceToBounds = [OLKHelpers distanceToDepthBoundary:palmPosition leapDevice:_leapDevice];
    return distanceToBounds < 0;
}

- (void)generateHands
{
    NSObject <OLKHandFactory>*factory = nil;
    if (_dataSource && [_dataSource  respondsToSelector:@selector(handFactory)])
        factory = [_dataSource handFactory];
    
    NSArray *leapHands = self.leapHands;
    NSMutableArray *newHands = [[NSMutableArray alloc] initWithCapacity:leapHands.count];
    NSMutableArray *newHandsViews = [[NSMutableArray alloc] initWithCapacity:leapHands.count];
    for (LeapHand *leapHand in leapHands)
    {
        if ([self invalidHandPosition:leapHand] || [leapHand timeVisible] < 0.3)
            continue;
        
        NSView <OLKHandContainer>*handView = [self viewForLeapHandId:[leapHand id]];
        if (handView)
        {
            if ([handView.hand.leapHand isKindOfClass:[LeapFingerAsLeapHand class]])
            {
                LeapFingerAsLeapHand *existLeapFingerAsHand = (LeapFingerAsLeapHand *)handView.hand.leapHand;
                existLeapFingerAsHand.isTouching = ((LeapFingerAsLeapHand *)leapHand).isTouching;
            }
            continue;
        }
        
        OLKHand *hand = [self newHandFromLeapHand:leapHand withFactory:factory];
        [hand setUsesStabilized:_useStabilized];
        [newHands addObject:hand];
        
        [newHandsViews addObject:[_dataSource handViewForHand:hand]];
    }
    _hands = [newHands arrayByAddingObjectsFromArray:_hands];
    _handsViews = [newHandsViews arrayByAddingObjectsFromArray:_handsViews];
}

- (void)removeMissingHands
{
    if (![_hands count])
        return;
    NSMutableSet *foundHandsViews = [[NSMutableSet alloc] init];
    NSMutableSet *foundHands = [[NSMutableSet alloc] init];
    for (NSView <OLKHandContainer> *handView in _handsViews)
    {
        OLKHand *hand = [handView hand];
        LeapHand *leapHand = [self leapHandWithId:[[hand leapHand] id]];
        if ([leapHand isValid])
        {
            if ([self invalidHandPosition:leapHand])
            {
                [self removeMissingHandView:handView];
                continue;
            }
            if ((_detectTouchMethod == OLKHandsDetectTouchDoubleTap || _detectTouchMethod == OLKHandsDetectTouchSingleTap) && [leapHand isKindOfClass:[LeapFingerAsLeapHand class]])
            {
                LeapFingerAsLeapHand *updateHand = (LeapFingerAsLeapHand *)leapHand;
                LeapFingerAsLeapHand *existHand = (LeapFingerAsLeapHand *)hand.leapHand;
                if (existHand.isTouching && existHand.fingerToMapToHand.touchZone == LEAP_POINTABLE_ZONE_TOUCHING)
                    updateHand.isTouching = YES;
            }
                
            [hand updateLeapHand:leapHand];
            [foundHandsViews addObject:handView];
            [foundHands addObject:hand];
        }
        else
        {
            [self removeMissingHandView:handView];
//            NSLog(@"Removing Missing Hand");
        }
    }
    
    _handsViews = [foundHandsViews allObjects];
    _hands = [foundHands allObjects];
    if (![_hands count])
    {
        _leftHand = nil;
        _rightHand = nil;
    }
    
}

- (void)updateHandedness
{
    if (_rightHand == nil && _leftHand==nil)
        return;

    OLKHandedness rightHandedness=OLKHandednessUnknown;
    if (_rightHand != nil)
    {
        if ([_rightHand numFramesExist] < gConfirmHandednessFrameThreshold)
            rightHandedness = [_rightHand updateHandedness];
    }
    OLKHandedness leftHandedness=OLKHandednessUnknown;
    if (_leftHand != nil)
    {
        OLKHandedness leftHandDetected = [_leftHand handedness];
        
        if ([_leftHand numFramesExist] < gConfirmHandednessFrameThreshold)
        {
            leftHandedness = [_leftHand updateHandedness];
            if (leftHandDetected == OLKHandednessUnknown && leftHandedness == OLKLeftHand)
            {
                if ([_delegate respondsToSelector:@selector(handChangedHandedness:withHandView:)])
                    [_delegate handChangedHandedness:_leftHand withHandView:_leftHandView];
                return;
            }
        }
    }
    
    if (leftHandedness == OLKHandednessUnknown && rightHandedness == OLKHandednessUnknown)
        return;
    
    if (leftHandedness == OLKLeftHand || rightHandedness == OLKRightHand)
        return;
    
    // Only continue if there is a known handedness detected which is opposite to the hand's previous 
    
    if (_leftHand != nil && _rightHand != nil)
    {
        if ([_rightHand numFramesExist] > [_leftHand numFramesExist] && rightHandedness == OLKRightHand)
        {
            if ([_leftHand handedness] == OLKRightHand)
            {
                [_leftHand setSimHandedness:OLKLeftHand];
                if ([_delegate respondsToSelector:@selector(handWillSimulateHandedness:withHandView:)])
                    [_delegate handWillSimulateHandedness:_leftHand withHandView:_leftHandView];
            }
            else
                [_leftHand setSimHandedness:OLKHandednessUnknown];
            
            return;
        }
        if ([_leftHand numFramesExist] > [_rightHand numFramesExist] && leftHandedness == OLKLeftHand)
        {
            if ([_rightHand handedness] == OLKLeftHand)
            {
                [_rightHand setSimHandedness:OLKRightHand];
                if ([_delegate respondsToSelector:@selector(handWillSimulateHandedness:withHandView:)])
                    [_delegate handWillSimulateHandedness:_rightHand withHandView:_rightHandView];
            }
            else
                [_rightHand setSimHandedness:OLKHandednessUnknown];
            return;
        }
    }
    else if (_leftHand == nil)
        [_rightHand setSimHandedness:OLKHandednessUnknown];
    else
        [_leftHand setSimHandedness:OLKHandednessUnknown];
    
    NSLog(@"Switching handedness: numFrames Right=%ld, numFrames Left=%ld!", [_rightHand numFramesExist], [_leftHand numFramesExist]);
    OLKHand *tmpHand = _leftHand;
    NSView *tmpView = _leftHandView;

    _leftHand = _rightHand;
    _leftHandView = _rightHandView;
    _rightHand = tmpHand;
    _rightHandView = (NSView<OLKHandContainer> *)tmpView;

    if (_leftHand != nil)
    {
        NSLog(@"Right became left!");
        if ([_delegate respondsToSelector:@selector(handChangedHandedness:withHandView:)])
            [_delegate handChangedHandedness:_leftHand withHandView:_leftHandView];
    }
    
    if (_rightHand != nil)
    {
        NSLog(@"Left became right!");
        if ([_delegate respondsToSelector:@selector(handChangedHandedness:withHandView:)])
            [_delegate handChangedHandedness:_rightHand withHandView:_rightHandView];
    }
}

- (NSRect)constrainInputCompletelyInView:(NSRect)frameRect handSpaceView:(NSView *)handSpaceView
{
    if (frameRect.origin.x + frameRect.size.width/2 > handSpaceView.bounds.origin.x + handSpaceView.bounds.size.width)
        frameRect.origin.x = handSpaceView.bounds.origin.x + handSpaceView.bounds.size.width - frameRect.size.width/2;
    if (frameRect.origin.y + frameRect.size.height/2 > handSpaceView.bounds.origin.y + handSpaceView.bounds.size.height)
        frameRect.origin.y = handSpaceView.bounds.origin.y + handSpaceView.bounds.size.height - frameRect.size.height/2;
    if (frameRect.origin.x + frameRect.size.width/2 < handSpaceView.bounds.origin.x)
        frameRect.origin.x = handSpaceView.bounds.origin.x - frameRect.size.width/2;
    if (frameRect.origin.y + frameRect.size.height/2 < handSpaceView.bounds.origin.y)
        frameRect.origin.y = handSpaceView.bounds.origin.y - frameRect.size.height/2;
    return frameRect;
}

- (void)updateHandViewForHand:(OLKHand *)hand
{
    NSView <OLKHandContainer>*handView = [self viewForHand:hand];
    if (!handView)
        return;
    
    if (!_resetAutoFitOnNewHand && [[hand leapHand] timeVisible] > _longestTimeHandVis)
    {
        _fitHandFact = [(OLKSimpleVectHandView *)handView fitHandFact];
        _longestTimeHandVis = [[hand leapHand] timeVisible];
    }
    
    NSRect oldRect = [handView frame];

    LeapVector *position;

    if ([hand.leapHand isKindOfClass:[LeapFingerAsLeapHand class]])
    {
        handView.cursorType = OLKHandCursorPosTypePalm;
    }
    switch (handView.cursorType)
    {
        case OLKHandCursorPosTypePointingFingerTip:
            position = [hand pointingFingerTipPos];
            break;
            
        case OLKHandCursorPosTypePointingFingerTipOrPalm:
            position = [hand pointingFingerTipOrPalmPos];
            break;
            
        case OLKHandCursorPosTypePointingFingerTipRelativePalm:
            position = [hand pointingFingerTipPosRelativePalm];
            break;
            
        case OLKHandCursorPosTypeIndexFingerTip:
            position = [hand indexFingerTipPos];
            break;
            
        case OLKHandCursorPosTypeIndexFingerTipOrPalm:
            position = [hand indexFingerTipOrPalmPos];
            break;
            
        case OLKHandCursorPosTypeIndexFingerTipRelativePalm:
            position = [hand indexFingerTipPosRelativePalm];
            break;
            
        case OLKHandCursorPosTypePalmHandAimOffset:
            position = [hand palmPosPlusAimOffset];
            break;

#ifndef __LEAP_RIGGED__

        case OLKHandCursorPosTypeMainToolTip:
            position = [hand mainToolTipPos];
            break;
            
        case OLKHandCursorPosTypeMainToolTipOrPalm:
            position = [hand mainToolTipOrPalmPos];
            break;
            
        case OLKHandCursorPosTypeMainToolTipRelativePalm:
            position = [hand mainToolTipPosRelativePalm];
            break;

#endif
            
        case OLKHandCursorPosTypeHandAim:
            position = [hand posFromAim];
            break;
            
        case OLKHandCursorPosTypeLongFingerTip:
            position = [hand longFingerTipPos];
            break;
            
        case OLKHandCursorPosTypeLongFingerTipOrPalm:
            position = [hand longFingerTipOrPalmPos];
            break;
            
        case OLKHandCursorPosTypeLongFingerTipRelativePalm:
            position = [hand longFingerTipRelativePos];
            break;
            
        case OLKHandCursorPosTypePalm:
        default:
            position = [hand palmPosition];
            break;
    }
    
    NSView *spaceView;
    if (_overrideSpaceViews)
    {
        spaceView = _handsSpaceView;
        if (!spaceView)
            NSLog(@"Error: space view not assigned!");
    }
    else
    {
        spaceView = [handView spaceView];
    
        if (!spaceView)
            spaceView = _handsSpaceView;
    }
    if (_confineCursor)
        oldRect.origin = [OLKHelpers convertLeapPos:position toConfinedBounds:_confineCursorRect fromConfinedBounds:_confineCursorFromRect];
    else if (_calibrator)
    {
        NSRect convertRect;
        convertRect.origin = [_calibrator screenPosFromLeapPos:position];
        convertRect.size = oldRect.size;
        oldRect = [[spaceView window] convertRectFromScreen:convertRect];
    }
    else if (_useInteractionBox)
        oldRect.origin = [OLKHelpers convertInteractionBoxLeapPos:position toConfinedView:spaceView forFrame:[[hand leapHand] frame] trim:_trimInteraction];
    else
        oldRect.origin = [OLKHelpers convertLeapPos:position toConfinedBounds:spaceView.bounds proximityOffset:_proximityOffset rangeOffset:_rangeOffset percentRangeOfMaxWidth:_percentRangeOfMaxWidth forLeapDevice:_leapDevice];

    oldRect.origin.x -= [handView frame].size.width/2;
    oldRect.origin.y -= [handView frame].size.height/2;

    if (_constrainHandsToSpace)
        oldRect = [self constrainInputCompletelyInView:oldRect handSpaceView:spaceView];

    if (_drawHands)
    {
        if (![handView enabled])
            [handView setEnabled:YES];
    }
    else if ([handView enabled])
        [handView setEnabled:NO];
    
    [handView setFrame:oldRect];
//    NSLog(@"hand x=%f, y=%f, width=%f, height=%f", [handView frame].origin.x, [handView frame].origin.y,[handView frame].size.width, [handView frame].size.height);
}

- (void)updateHandsAndPointablesViews
{
    for (OLKHand *hand in _hands)
        [self updateHandViewForHand:hand];
/*
    for (LeapPointable *pointable in [_leapFrame pointables])
    {
        NSView *pointableView = [_dataSource pointableView:(NSRect)frame withHandedness:(OLKHandedness)handedness;

    }
 */
}

- (void)onFrame:(LeapFrame *)leapFrame controller:(LeapController *)leapController
{
    _leapController = leapController;
    NSArray *devices = [leapController devices];
    if (devices && [devices count] > 0)
        _leapDevice = [devices objectAtIndex:0];
    else
        _leapDevice = nil;
    
    // Get the most recent frame and report some basic information
    _leapFrame = leapFrame;
    
//    OLKGestureRecognizerDispatcher *dispatcher = [OLKGestureRecognizerDispatcher sharedDispatcher];
//    for (OLKGestureRecognizer *recognizer in _gestureContext)
//         [recognizer updateWithFrame:_leapFrame controller:leapController];
//        [dispatcher dispatchGestureRecognizer:recognizer frame:_leapFrame controller:leapController];
    
    if (_interactionBox == nil)
        _interactionBox = [_leapFrame interactionBox];
    
    [self removeMissingHands];
    
    if ([self.leapHands count])
    {
        if (_findRightLeft)
            [self updateHandedness];
        [self assignHands];
        [self updateHandsAndPointablesViews];
    }
}


@end
