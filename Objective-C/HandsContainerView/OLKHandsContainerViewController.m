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
#import "OLKGestureRecognizer.h"
#import "OLKGestureRecognizerDispatcher.h"

static const float gHandViewDimX=250;
static const float gHandViewDimY=250;
static const NSSize gTrimInteractionBox={0.05,0.05};
static const NSUInteger gConfirmHandednessFrameThreshold=1500;

@implementation OLKHandsContainerViewController
{
    LeapFrame *_leapFrame;
    LeapInteractionBox *_interactionBox;
    LeapDevice *_leapDevice;
    LeapHand *_prevHand;
    float _longestTimeHandVis;
}

@synthesize handsSpaceView = _handsSpaceView;
@synthesize overrideSpaceViews = _overrideSpaceViews;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
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

- (id)init
{
    if (self = [super init])
    {
        _resetAutoFitOnNewHand = FALSE;
        _overrideSpaceViews = FALSE;
        _longestTimeHandVis = 0;
        _fitHandFact = defaultFitHandFact;
        _trimInteraction = gTrimInteractionBox;
        _gestureContext = [[NSMutableArray alloc] init];
        _useStabilized = TRUE;
        _useInteractionBox = TRUE;
        _allowAllHands = TRUE;
        _showPointables = TRUE;
        _rangeOffset = -80;
        _proximityOffset = 0;
        _percentRangeOfMaxWidth = 0.6;
        _handednessAlgorithm = OLKHandednessAlgorithmThumbTipAndBase;
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

- (OLKHand *)handFromLeapHand:(LeapHand *)leapHand
{
    if ([_leftHand isLeapHand:leapHand])
        return _leftHand;
    else if ([_rightHand isLeapHand:leapHand])
        return _rightHand;
    
    return nil;
}

- (void)setHandsSpaceView:(NSView *)handsSpaceView
{
    _handsSpaceView = handsSpaceView;
}

- (void)setOverrideSpaceViews:(BOOL)overrideSpaceViews
{
    _overrideSpaceViews = overrideSpaceViews;
    if (overrideSpaceViews)
        [self updateHandsAndPointablesViews];
}

- (NSMutableArray *)createHandViews:(NSArray *)hands
{
    if (!hands || ![hands count])
        return nil;
    
    NSMutableArray *handsViews = [[NSMutableArray alloc] init];
    NSMutableArray *newHands = [[NSMutableArray alloc] init];
    for (OLKHand *hand in hands)
    {
        NSView <OLKHandContainer> *handView = [self viewForHand:hand];
        if (!handView)
        {
            [newHands addObject:hand];
            [hand setUsesStabilized:_useStabilized];
            handView = [_dataSource handViewForHand:hand];
            NSLog(@"Creating Hand View!");
        }
        [handsViews addObject:handView];
        if ([hand isEqual:_leftHand])
            _leftHandView = handView;
        if ([hand isEqual:_rightHand])
            _rightHandView = handView;
    }
    if (_hands)
        [newHands addObjectsFromArray:_hands];
    _hands = [NSArray arrayWithArray:newHands];
    
    return handsViews;
}

- (void)assignHands
{
    NSMutableSet *ignoreHands=[[NSMutableSet alloc] init];
    
    if (_leftHand)
        [ignoreHands addObject:[_leftHand leapHand]];
    
    if (_rightHand)
        [ignoreHands addObject:[_rightHand leapHand]];
    
    NSDictionary *handsHandednessDict = [OLKHand leftRightHandSearch:[_leapFrame hands] ignoreHands:ignoreHands handednessAlgorithm:_handednessAlgorithm];
    NSView *prevLeftHandView = _leftHandView;
    NSView *prevRightHandView = _rightHandView;
    
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
    NSMutableArray *hands = [handsHandednessDict objectForKey:OLKHandLeftHandsKey];
    if (hands)
        [allHands addObjectsFromArray:hands];
    hands = [handsHandednessDict objectForKey:OLKHandRightHandsKey];
    if (hands)
        [allHands addObjectsFromArray:hands];
    hands = [handsHandednessDict objectForKey:OLKHandUnknownHandednessKey];
    if (hands)
        [allHands addObjectsFromArray:hands];
    
    NSMutableArray *handsViews = [self createHandViews:allHands];
    if (!handsViews)
        handsViews = [[NSMutableArray alloc] init];
    if (prevLeftHandView)
        [handsViews addObject:prevLeftHandView];
    if (prevRightHandView)
        [handsViews addObject:prevRightHandView];

    if (![handsViews count])
        handsViews = nil;
    _handsViews = [NSArray arrayWithArray:handsViews];

    return;
//    NSArray *leftRightHands = [OLKHand simpleLeftRightHandSearch:hands];
//    OLKHand *leftHand = [handsHandednessDict objectForKey:OLKHandLeftHandsKey];
//    OLKHand *rightHand = [handsHandednessDict objectForKey:OLKHandRightHandsKey];
//    LeapHand *bestLeftOption=leftHand;
//    LeapHand *bestRightOption=rightHand;
//    
//    if (_leftHand == nil && bestLeftOption != nil && bestLeftOption != (LeapHand*)[NSNull null])
//    {
//        OLKHandedness handedness;
//        if ([hands count] == 1 && [_leftHand handedness] == OLKHandednessUnknown)
//            handedness = OLKHandednessUnknown;
//        else
//            handedness = OLKLeftHand;
//        
//        NSLog(@"New Left Hand!");
//        LeapVector *palmPosition;
//        if (_useStabilized)
//            palmPosition = [bestLeftOption stabilizedPalmPosition];
//        else
//            palmPosition = [bestLeftOption palmPosition];
//        _leftHandView = [_dataSource handView:NSMakeRect(palmPosition.x-gHandViewDimX/2, palmPosition.y-gHandViewDimY/2, gHandViewDimX, gHandViewDimY) withHandedness:handedness];
//        _leftHand = [[OLKHand alloc] init];
//        if (!_resetAutoFitOnNewHand)
//            [(OLKSimpleVectHandView *)_leftHandView setFitHandFact:_fitHandFact];
//        [_leftHandView setHand:_leftHand];
//        [_leftHandView setEnableStable:_useStabilized];
//        
//        [_leftHand setLeapHand:bestLeftOption];
//        [_leftHand setHandedness:handedness];
//        if (handedness == OLKHandednessUnknown)
//            [_leftHand setSimHandedness:OLKLeftHand];
//        
//        if (_delegate)
//            [_delegate willAddHand:_leftHand withHandView:_leftHandView];
//        [_handsSpaceView addSubview:_leftHandView];
//    }
//    
//    if (_rightHand == nil && bestRightOption != nil && bestRightOption != (LeapHand*)[NSNull null])
//    {
//        OLKHandedness handedness;
//        if ([hands count] == 1 && [_leftHand handedness] == OLKHandednessUnknown)
//            handedness = OLKHandednessUnknown;
//        else
//            handedness = OLKLeftHand;
//        
//        NSLog(@"New Right Hand!");
//        LeapVector *palmPosition;
//        if (_useStabilized)
//            palmPosition = [bestRightOption stabilizedPalmPosition];
//        else
//            palmPosition = [bestRightOption palmPosition];
//        _rightHandView = [_dataSource handView:NSMakeRect(palmPosition.x-gHandViewDimX/2, palmPosition.y-gHandViewDimY/2, gHandViewDimX, gHandViewDimY) withHandedness:OLKRightHand];
//        if (!_resetAutoFitOnNewHand)
//            [(OLKSimpleVectHandView *)_rightHandView setFitHandFact:_fitHandFact];
//        _rightHand = [[OLKHand alloc] init];
//        [_rightHandView setHand:_rightHand];
//        [_rightHandView setEnableStable:_useStabilized];
//        
//        [_rightHand setLeapHand:bestRightOption];
//        [_rightHand setHandedness:handedness];
//        if (handedness == OLKHandednessUnknown)
//            [_rightHand setSimHandedness:OLKRightHand];
//        
//        if (_delegate)
//            [_delegate willAddHand:_rightHand withHandView:_rightHandView];
//
//        [_handsSpaceView addSubview:_rightHandView];
//    }
}

- (void)removeMissingHands
{
    NSMutableSet *foundHands = [[NSMutableSet alloc] init];
    
    for (OLKHand *hand in _hands)
    {
        LeapHand *leapHand = [_leapFrame hand:[[hand leapHand] id]];
        if ([leapHand isValid])
        {
            [hand setLeapHand:leapHand];
            [foundHands addObject:hand];
        }
    }
    
    NSMutableSet *missingHands = [NSMutableSet setWithArray:_hands];
    [missingHands minusSet:foundHands];
    
    for (OLKHand *hand in missingHands)
    {
        if ([hand isEqual:_leftHand])
            _leftHand = nil;
        if ([hand isEqual:_rightHand])
            _rightHand = nil;
        NSView *handView = [self viewForHand:hand];
        if (_delegate)
            [_delegate willRemoveHand:hand withHandView:handView];
        
        if (handView)
        {
            NSLog(@"Removing Hand View!");
            
            [handView removeFromSuperview];
            if (handView == _leftHandView)
                _leftHandView = nil;
            if (handView == _rightHandView)
                _rightHandView = nil;
        }
    }
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
                if (_delegate)
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
                if (_delegate)
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
        if (_delegate)
            [_delegate handChangedHandedness:_leftHand withHandView:_leftHandView];
    }
    
    if (_rightHand != nil)
    {
        NSLog(@"Left became right!");
        if (_delegate)
            [_delegate handChangedHandedness:_rightHand withHandView:_rightHandView];
    }
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
    LeapHand *leapHand = [hand leapHand];
    LeapVector *palmPosition;
    if (_useStabilized)
        palmPosition = [leapHand stabilizedPalmPosition];
    else
        palmPosition = [leapHand palmPosition];
    
    NSView *spaceView;
    if (_overrideSpaceViews)
    {
        spaceView = _handsSpaceView;
        NSLog(@"Error: space view not assigned!");
    }
    else
    {
        spaceView = [handView spaceView];
    
        if (!spaceView)
            spaceView = _handsSpaceView;
    }
    if (_useInteractionBox)
        oldRect.origin = [OLKHelpers convertInteractionBoxLeapPos:palmPosition toConfinedView:spaceView forFrame:[leapHand frame] trim:_trimInteraction];
    else
        oldRect.origin = [OLKHelpers convertLeapPos:palmPosition toConfinedView:spaceView proximityOffset:_proximityOffset rangeOffset:_rangeOffset percentRangeOfMaxWidth:_percentRangeOfMaxWidth forLeapDevice:_leapDevice];

    oldRect.origin.x -= [handView frame].size.width/2;
    oldRect.origin.y -= [handView frame].size.height/2;
    
    [handView setFrame:oldRect];
//    NSLog(@"hand x=%f, y=%f", [handView frame].origin.x, [handView frame].origin.y);
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

- (void)onFrame:(NSNotification *)notification
{
    LeapController *leapController = (LeapController *)[notification object];
    _leapDevice = [[leapController devices] objectAtIndex:0];
    
    // Get the most recent frame and report some basic information
    _leapFrame = [leapController frame:0];
    
//    OLKGestureRecognizerDispatcher *dispatcher = [OLKGestureRecognizerDispatcher sharedDispatcher];
    for (OLKGestureRecognizer *recognizer in _gestureContext)
         [recognizer updateWithFrame:_leapFrame controller:leapController];
//        [dispatcher dispatchGestureRecognizer:recognizer frame:_leapFrame controller:leapController];
    
    if (_interactionBox == nil)
        _interactionBox = [_leapFrame interactionBox];
    
    [self removeMissingHands];
    
    if ([[_leapFrame hands] count])
    {
        [self updateHandedness];
        [self assignHands];
        [self updateHandsAndPointablesViews];
    }
}


@end
