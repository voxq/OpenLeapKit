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

static const float gHandViewDimX=250;
static const float gHandViewDimY=250;
static const NSSize gTrimInteractionBox={0.05,0.05};
static const NSUInteger gConfirmHandednessFrameThreshold=1500;

@implementation OLKHandsContainerViewController
{
    LeapFrame *_leapFrame;
    LeapInteractionBox *_interactionBox;
    LeapHand *_prevHand;
}

@synthesize handsContainerView = _handsContainerView;
@synthesize dataSource = _dataSource;
@synthesize leftHand = _leftHand;
@synthesize rightHand = _rightHand;
@synthesize leftHandView = _leftHandView;
@synthesize rightHandView = _rightHandView;

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (NSView *)viewForHand:(OLKHand *)hand
{
    if (hand == _leftHand)
        return _leftHandView;
    
    if (hand == _rightHand)
        return _rightHandView;
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

- (void)assignHands:(NSArray *)hands
{
    NSArray *leftRightHands = [OLKHand simpleLeftRightHandSearch:hands];
    LeapHand *leftHand = [leftRightHands objectAtIndex:0];
    LeapHand *rightHand = [leftRightHands objectAtIndex:1];
    LeapHand *bestLeftOption=leftHand;
    LeapHand *bestRightOption=rightHand;
    if (bestLeftOption==(LeapHand*)[NSNull null])
        bestLeftOption = rightHand;
    if (bestRightOption==(LeapHand*)[NSNull null])
        bestRightOption = leftHand;
    
    if (_leftHand == nil && bestLeftOption != nil && bestLeftOption != (LeapHand*)[NSNull null])
    {
        NSLog(@"New Left Hand!");
        _leftHandView = [_dataSource handView:NSMakeRect([bestLeftOption palmPosition].x-gHandViewDimX/2, [bestLeftOption palmPosition].y-gHandViewDimY/2, gHandViewDimX, gHandViewDimY) withHandedness:OLKLeftHand];
        _leftHand = [[OLKHand alloc] init];
        [_leftHandView setHand:_leftHand];
        
        [_leftHand setLeapHand:bestLeftOption];
        [_leftHand setHandedness:OLKLeftHand];
        [_handsContainerView addSubview:_leftHandView];
    }
    
    if (_rightHand == nil && bestRightOption != nil && bestRightOption != (LeapHand*)[NSNull null])
    {
        NSLog(@"New Right Hand!");
        _rightHandView = [_dataSource handView:NSMakeRect([bestRightOption palmPosition].x-gHandViewDimX/2, [bestRightOption palmPosition].y-gHandViewDimY/2, gHandViewDimX, gHandViewDimY) withHandedness:OLKRightHand];
        _rightHand = [[OLKHand alloc] init];
        [_rightHandView setHand:_rightHand];
        
        [_rightHand setLeapHand:bestRightOption];
        [_rightHand setHandedness:OLKRightHand];
        
        [_handsContainerView addSubview:_rightHandView];
    }
}

- (void)removeMissingHands
{
    if (_leftHand != nil && [[_leftHand leapFrame] identifier] != [_leapFrame identifier])
    {
        NSLog(@"Removing Left Hand!");
        [_leftHandView removeFromSuperview];
        _leftHandView = nil;
        _leftHand = nil;
    }
    if (_rightHand != nil && [[_rightHand leapFrame] identifier] != [_leapFrame identifier])
    {
        NSLog(@"Removing Right Hand!");
        [_rightHandView removeFromSuperview];
        _rightHandView = nil;
        _rightHand = nil;
    }
}

- (void)updateHandedness
{
    if (_rightHand == nil && _leftHand==nil)
        return;
    
    OLKHandedness rightHandedness=OLKRightHand;
    if (_rightHand != nil)
    {
        if ([_rightHand numFramesExist] < gConfirmHandednessFrameThreshold)
            rightHandedness = [_rightHand updateHandedness];
    }
    OLKHandedness leftHandedness=OLKLeftHand;
    if (_leftHand != nil)
    {
        if ([_leftHand numFramesExist] < gConfirmHandednessFrameThreshold)
            leftHandedness = [_leftHand updateHandedness];
    }
    
    if (leftHandedness == OLKHandednessUnknown && rightHandedness == OLKHandednessUnknown)
        return;
    
    if (leftHandedness == OLKLeftHand && rightHandedness == OLKRightHand)
        return;
    
    if (_leftHand != nil && _rightHand != nil)
    {
        if (_rightHand != nil && [_rightHand numFramesExist] > [_leftHand numFramesExist] && rightHandedness == OLKRightHand)
        {
            if ([_leftHand handedness] == OLKRightHand)
                [_leftHand setSimHandedness:OLKLeftHand];
            else
                [_leftHand setSimHandedness:OLKHandednessUnknown];
            
            return;
        }
        if ([_leftHand numFramesExist] > [_rightHand numFramesExist] && leftHandedness == OLKLeftHand)
        {
            if ([_rightHand handedness] == OLKLeftHand)
                [_rightHand setSimHandedness:OLKRightHand];
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
    if (_leftHand != nil)
        NSLog(@"Left becoming right!");
    
    if (_rightHand != nil)
        NSLog(@"Right becoming left!");
    
    OLKHand *tmpHand = _leftHand;
    _leftHand = _rightHand;
    _rightHand = tmpHand;
    NSView *tmpView = _leftHandView;
    _leftHandView = _rightHandView;
    _rightHandView = (NSView<OLKHandContainer> *)tmpView;
}

- (void)updateHandViewForHand:(OLKHand *)hand
{
    NSView *handView = [self viewForHand:hand];
    if (!handView)
        return;
    
    NSRect oldRect = [handView frame];
    LeapHand *leapHand = [hand leapHand];
    oldRect.origin = [OLKHelpers convertLeapPos:[leapHand stabilizedPalmPosition] toConfinedView:_handsContainerView forFrame:[leapHand frame] trim:gTrimInteractionBox];
    oldRect.origin.x -= gHandViewDimX/2;
    oldRect.origin.y -= gHandViewDimY/2;
    
    [handView setFrame:oldRect];
    //    NSLog(@"hand x=%f, y=%f", [handView frame].origin.x, [handView frame].origin.y);
}

- (void)organizeHands
{
    LeapHand *leapHand;
    NSMutableArray *newHands = [[NSMutableArray alloc] init];
    LeapHand *_prevLeftHand=nil, *_prevRightHand=nil;
    for (leapHand in [_leapFrame hands])
    {
        OLKHand *hand = [self handFromLeapHand:leapHand];
        if (hand)
        {
            if (hand == _leftHand)
            {
                //                NSLog(@"existing left");
                _prevLeftHand = [hand leapHand];
            }
            else
            {
                //                NSLog(@"existing right");
                _prevRightHand = [hand leapHand];
            }
            
            [hand updateLeapHand:leapHand];
        }
        else
            [newHands addObject:leapHand];
    }
    
    [self updateHandedness];
    
    if ([newHands count] != 0)
        [self assignHands:newHands];
    
    [self updateHandViewForHand:_leftHand];
    [self updateHandViewForHand:_rightHand];
    
    [self removeMissingHands];
}

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];
    
    // Get the most recent frame and report some basic information
    _leapFrame = [aController frame:0];
    
    if (_interactionBox == nil)
        _interactionBox = [_leapFrame interactionBox];
    
    [self organizeHands];
}


@end
