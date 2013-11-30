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
//  OLKDemoHandsOberlayViewController.mm
//  OLK2DViewHandDemo
//
//  Created by Tyler Zetterstrom on 2013-08-29.
//

#import <OpenLeapKit/OLKHand.h>
#import "OLKDemoHandsOverlayViewController.h"
#import "LeapObjectiveC.h"


@implementation OLKDemoHandsOverlayViewController
{
    NSSize _handsOverlaySize;
}

@synthesize enableAutoFitHands = _enableAutoFitHands;
@synthesize enableDrawHandsBoundingCircle = _enableDrawHandsBoundingCircle;
@synthesize enableDrawPalms = _enableDrawPalms;
@synthesize enableDrawFingers = _enableDrawFingers;
@synthesize enableDrawFingerTips = _enableDrawFingerTips;
@synthesize enableScreenYAxisUsesZAxis = _enableScreenYAxisUsesZAxis;
@synthesize enable3DHand = _enable3DHand;
@synthesize enableStablePalms = _enableStablePalms;

- (id)init
{
    if (self = [super init])
    {
        [self setDataSource:self];
        _handsOverlaySize.width=250;
        _handsOverlaySize.height=250;
        _enableAutoFitHands = YES;
        _enableDrawFingers = YES;
        _enableDrawFingerTips = YES;
        _enableDrawHandsBoundingCircle = YES;
        _enableDrawPalms = YES;
        _enableScreenYAxisUsesZAxis = YES;
        _enable3DHand = YES;
        _enableStablePalms = YES;
    }
    return self;
}

- (NSView <OLKHandContainer>*)handViewForHand:(OLKHand *)hand;
{
    NSRect handRect = NSMakeRect(0, 0, _handsOverlaySize.width, _handsOverlaySize.height);
    OLKSimpleVectHandView *handView = [[OLKSimpleVectHandView alloc] initWithFrame:handRect];
    
    [handView setEnableScreenYAxisUsesZAxis:_enableScreenYAxisUsesZAxis];
    [handView setEnableDrawPalm:_enableDrawPalms];
    [handView setEnableDrawHandBoundingCircle:_enableDrawHandsBoundingCircle];
    [handView setEnableDrawFingerTips:_enableDrawFingerTips];
    [handView setEnableDrawFingers:_enableDrawFingers];
    [handView setEnableAutoFitHand:_enableAutoFitHands];
    [handView setEnable3DHand:_enable3DHand];
    [handView setHand:hand];
    [[self handsSpaceView] addSubview:handView];
    
    return handView;
}

- (void) setEnableScreenYAxisUsesZAxis:(BOOL)enableScreenYAxisUsesZAxis
{
    _enableScreenYAxisUsesZAxis = enableScreenYAxisUsesZAxis;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableScreenYAxisUsesZAxis:enableScreenYAxisUsesZAxis];
    if (rightHandView)
        [rightHandView setEnableScreenYAxisUsesZAxis:enableScreenYAxisUsesZAxis];
}

- (void) setEnableAutoFitHands:(BOOL)enableAutoFitHands
{
    _enableAutoFitHands = enableAutoFitHands;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableAutoFitHand:enableAutoFitHands];
    if (rightHandView)
        [rightHandView setEnableAutoFitHand:enableAutoFitHands];
}

- (void)setEnableDrawFingers:(BOOL)enableDrawFingers
{
    _enableDrawFingers = enableDrawFingers;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableDrawFingers:enableDrawFingers];
    if (rightHandView)
        [rightHandView setEnableDrawFingers:enableDrawFingers];
}

- (void)setEnableDrawFingerTips:(BOOL)enableDrawFingerTips
{
    _enableDrawFingerTips = enableDrawFingerTips;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableDrawFingerTips:enableDrawFingerTips];
    if (rightHandView)
        [rightHandView setEnableDrawFingerTips:enableDrawFingerTips];
}

- (void)setEnableDrawHandsBoundingCircle:(BOOL)enableDrawHandsBoundingCircle
{
    _enableDrawHandsBoundingCircle = enableDrawHandsBoundingCircle;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableDrawHandBoundingCircle:enableDrawHandsBoundingCircle];
    if (rightHandView)
        [rightHandView setEnableDrawHandBoundingCircle:enableDrawHandsBoundingCircle];
}

-(void)setEnableDrawPalms:(BOOL)enableDrawPalms
{
    _enableDrawPalms = enableDrawPalms;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableDrawPalm:enableDrawPalms];
    if (rightHandView)
        [rightHandView setEnableDrawPalm:enableDrawPalms];
}

-(void)setEnable3DHand:(BOOL)enable3DHand
{
    _enable3DHand = enable3DHand;
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnable3DHand:enable3DHand];
    if (rightHandView)
        [rightHandView setEnable3DHand:enable3DHand];
}

-(void)setEnableStablePalms:(BOOL)enableStablePalms
{
    _enableStablePalms = enableStablePalms;
    [super setUseStabilized:enableStablePalms];
    OLKSimpleVectHandView *leftHandView = (OLKSimpleVectHandView *)[self leftHandView];
    OLKSimpleVectHandView *rightHandView = (OLKSimpleVectHandView *)[self rightHandView];
    if (leftHandView)
        [leftHandView setEnableStable:enableStablePalms];
    if (rightHandView)
        [rightHandView setEnableStable:enableStablePalms];
}


@end
