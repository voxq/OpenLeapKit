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
#import <OpenLeapKit/OLKContextHand.h>
#import <OpenLeapKit/OLKHorizScratchButton.h>


@implementation OLKDemoHandsOverlayViewController
{
    NSSize _handsOverlaySize;
    OLKRangeCalibrator *_savedCalibrator;
}

@synthesize enableAutoFitHands = _enableAutoFitHands;
@synthesize enableDrawHandsBoundingCircle = _enableDrawHandsBoundingCircle;
@synthesize enableDrawPalms = _enableDrawPalms;
@synthesize enableDrawFingers = _enableDrawFingers;
@synthesize enableDrawFingerTips = _enableDrawFingerTips;
@synthesize enableDrawSphere = _enableDrawSphere;
@synthesize enableScreenYAxisUsesZAxis = _enableScreenYAxisUsesZAxis;
@synthesize enable3DHand = _enable3DHand;
@synthesize handFactory = _handFactory;
@synthesize handsConfigMenu = _handsConfigMenu;
@synthesize handsOverlayControllerDelegate = _handsOverlayControllerDelegate;
@synthesize fitHandFactor = _fitHandFactor;
@synthesize usingSimpleCursor = _usingSimpleCursor;
@synthesize usingOnlySimpleCursor = _usingOnlySimpleCursor;

+ (NSDictionary *)defaultProperties
{
    return [[NSDictionary alloc] initWithObjectsAndKeys:@"250", OLKDemoHandsViewsHeight, @"250", OLKDemoHandsViewsWidth, @"YES", OLKDemoHandsDrawPalms, @"YES", OLKDemoHandsDrawFingers, @"YES", OLKDemoHandsDrawFingerTips, @"NO", OLKDemoHandsDrawBoundingCircle, @"NO", OLKDemoHandsUseZForY, @"YES", OLKDemoHands3DPerspective, @"NO", OLKDemoHandsUseStabilizedPos, @"NO", OLKDemoHandsUseInteractionBox, @"YES", OLKDemoHandsAutoSizeHand, @"1.4", OLKDemoHandsFitFactorWidth, @"1.4", OLKDemoHandsFitFactorHeight, @"YES", OLKDemoHandsUseSimpleCursor, @"NO", OLKDemoHandsUseOnlySimpleCursor, @"YES", OLKDemoHandsUseCalibration, @"YES", OLKDemoHandsDrawSphere, nil];
}

+ (void)resetDefaults
{
    [[OLKDemoHandsOverlayViewController defaultProperties] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    }];
}

- (BOOL)displayingHandInSomeForm
{
    return _usingSimpleCursor | _usingOnlySimpleCursor | _enableDrawFingers | _enableDrawFingerTips | _enableDrawHandsBoundingCircle | _enableDrawPalms | _enableDrawSphere;
}

- (void)loadDefaults
{
    _handsOverlaySize.width = [[NSUserDefaults standardUserDefaults] floatForKey:OLKDemoHandsViewsWidth];
    _handsOverlaySize.height = [[NSUserDefaults standardUserDefaults] floatForKey:OLKDemoHandsViewsHeight];
    _enableAutoFitHands = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsAutoSizeHand];
    _enableDrawFingers = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawFingers];
    _enableDrawFingerTips = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawFingerTips];
    _enableDrawHandsBoundingCircle = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawBoundingCircle];
    _enableDrawPalms = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawPalms];
    _enableScreenYAxisUsesZAxis = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseZForY];
    _enable3DHand = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHands3DPerspective];
    [self setUseInteractionBox:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseInteractionBox]];
    [self setUseStabilized:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseStabilizedPos]];
    _fitHandFactor = NSMakeSize([[NSUserDefaults standardUserDefaults] floatForKey:OLKDemoHandsFitFactorWidth], [[NSUserDefaults standardUserDefaults] floatForKey:OLKDemoHandsFitFactorHeight]);
    _usingOnlySimpleCursor = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseOnlySimpleCursor];
    _usingSimpleCursor = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseSimpleCursor];
    _useCalibrator = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseCalibration];
    _enableDrawSphere = [[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawSphere];
    
    if (![self displayingHandInSomeForm])
    {
        _usingOnlySimpleCursor = TRUE;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:OLKDemoHandsUseOnlySimpleCursor];
    }
    if (_usingOnlySimpleCursor)
        [super setDrawHands:NO];
}

- (id)init
{
    if (self = [super init])
    {
        [self setDataSource:self];
        _handFactory = self;
        [self loadDefaults];
    }
    return self;
}

- (NSView <OLKHandContainer>*)handViewForHand:(OLKHand *)hand
{
    NSRect handRect = NSMakeRect(0, 0, _handsOverlaySize.width, _handsOverlaySize.height);
    OLKSimpleVectHandView *handView = [[OLKSimpleVectHandView alloc] initWithFrame:handRect];
    [handView setHand:hand];
    
    [self configHandView:handView];
    [[self handsSpaceView] addHandView:handView];
    
    return handView;
}

- (void)configHandView:(OLKSimpleVectHandView *)handView
{
    [handView setEnableScreenYAxisUsesZAxis:_enableScreenYAxisUsesZAxis];
    [handView setEnableDrawPalm:_enableDrawPalms];
    [handView setEnableDrawHandBoundingCircle:_enableDrawHandsBoundingCircle];
    [handView setEnableDrawFingerTips:_enableDrawFingerTips];
    [handView setEnableDrawFingers:_enableDrawFingers];
    [handView setEnableAutoFitHand:_enableAutoFitHands];
    [handView setFitHandFact:_fitHandFactor];
    [handView setEnable3DHand:_enable3DHand];
    [handView setEnableStable:self.useStabilized];
    [handView setEnableSphere:_enableDrawSphere];
}

- (void)configHandViews
{
    for (OLKSimpleVectHandView *handView in self.handsViews)
    {
        [self configHandView:handView];
    }
}

- (void)setUseCalibrator:(BOOL)enable
{
    if (_useCalibrator != enable)
    {
        if (enable)
            super.calibrator = _savedCalibrator;
        else
            super.calibrator = nil;
    }
    _useCalibrator = enable;
}

- (void)setCalibrator:(OLKRangeCalibrator *)calibrator
{
    _savedCalibrator = calibrator;
    [super setCalibrator:calibrator];
}

- (OLKHand *)manufactureHand:(LeapHand *)leapHand
{
    OLKContextHand *hand = [[OLKContextHand alloc] init];
    [hand setPalmDownThreshold:0.8];
    return hand;
}

- (void)controlChangedValue:(id)sender control:(OLKNIControl *)control
{
    BOOL enabled;
    if ([control isKindOfClass:[OLKScratchButtonShell class]])
        enabled = [(OLKScratchButtonShell *)control on];
    
    NSString *propertyKey=nil;
    NSString *resetPropertyKey=nil;
    
    if (control == (OLKNIControl *)_handsConfigMenu.fingerTipsButton)
    {
        _enableDrawFingerTips = enabled;
        propertyKey = OLKDemoHandsDrawFingerTips;
        resetPropertyKey = @"enableDrawFingerTips";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.fingerLinesButton)
    {
        _enableDrawFingers = enabled;
        propertyKey = OLKDemoHandsDrawFingers;
        resetPropertyKey = @"enableDrawFingers";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.boundedHandButton)
    {
        _enableDrawHandsBoundingCircle = enabled;
        propertyKey = OLKDemoHandsDrawBoundingCircle;
        resetPropertyKey = @"enableDrawHandsBoundingCircle";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.palmButton)
    {
        _enableDrawPalms = enabled;
        propertyKey = OLKDemoHandsDrawPalms;
        resetPropertyKey = @"enableDrawPalms";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.sphereButton)
    {
        _enableDrawSphere = enabled;
        propertyKey = OLKDemoHandsDrawSphere;
        resetPropertyKey = @"enableDrawSphere";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.useSimpleCursorButton)
    {
        _usingSimpleCursor = enabled;
        propertyKey = OLKDemoHandsUseSimpleCursor;
        resetPropertyKey = @"usingSimpleCursor";
    }
    if (![self displayingHandInSomeForm] && resetPropertyKey)
    {
        [self setValue:@YES forKey:resetPropertyKey];
        [(OLKScratchButtonShell *)control setOn:YES];
        [_handsConfigMenu setNeedsDisplay:YES];
        return;
    }
    if (!resetPropertyKey)
    {
        if (control == (OLKNIControl *)_handsConfigMenu.fingerDepthYButton)
        {
            _enableScreenYAxisUsesZAxis = enabled;
            propertyKey = OLKDemoHandsUseZForY;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.hand3DButton)
        {
            _enable3DHand = enabled;
            propertyKey = OLKDemoHands3DPerspective;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.autoSizeButton)
        {
            _enableAutoFitHands = enabled;
            propertyKey = OLKDemoHandsAutoSizeHand;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.interactionBoxButton)
        {
            [self setUseInteractionBox:enabled];
            propertyKey = OLKDemoHandsUseInteractionBox;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.stablePalmsButton)
        {
            [self setUseStabilized:enabled];
            propertyKey = OLKDemoHandsUseStabilizedPos;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.useCalibrationButton)
        {
            [self setUseCalibrator:enabled];
            propertyKey = OLKDemoHandsUseCalibration;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.useOnlySimpleCursorButton)
        {
            _usingOnlySimpleCursor = enabled;
            propertyKey = OLKDemoHandsUseOnlySimpleCursor;
            [_handsConfigMenu setOnlySimpleCursor:enabled];
            if (enabled)
            {
                if (!_usingSimpleCursor && [_handsOverlayControllerDelegate respondsToSelector:@selector(simpleCursorNeedsShowing)])
                    [_handsOverlayControllerDelegate simpleCursorNeedsShowing];
                
                [super setDrawHands:NO];
            }
            else
                [super setDrawHands:YES];
            [_handsConfigMenu setNeedsDisplay:YES];
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.resetToDefaultsButton)
        {
            [OLKDemoHandsOverlayViewController resetDefaults];
        }
    }
    if (propertyKey)
    {
        if (enabled)
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:propertyKey];
        else
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:propertyKey];
        
        [self configHandViews];
    }
}

- (ConfigMenuView *)handsConfigMenu
{
    if (!_handsConfigMenu)
    {
        _handsConfigMenu = [[ConfigMenuView alloc] init];
        [_handsConfigMenu setDelegate:self];
        [_handsConfigMenu.interactionBoxButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseInteractionBox]];
        [_handsConfigMenu.stablePalmsButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseStabilizedPos]];
        [_handsConfigMenu.autoSizeButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsAutoSizeHand]];
        [_handsConfigMenu.useSimpleCursorButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseSimpleCursor]];
        [_handsConfigMenu.useOnlySimpleCursorButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseOnlySimpleCursor]];
        [_handsConfigMenu.boundedHandButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawBoundingCircle]];
        [_handsConfigMenu.palmButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawPalms]];
        [_handsConfigMenu.fingerTipsButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawFingerTips]];
        [_handsConfigMenu.fingerLinesButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawFingers]];
        [_handsConfigMenu.hand3DButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHands3DPerspective]];
        [_handsConfigMenu.fingerDepthYButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseZForY]];
        [_handsConfigMenu.useCalibrationButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsUseCalibration]];
        [_handsConfigMenu.sphereButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:OLKDemoHandsDrawSphere]];
    }
    return _handsConfigMenu;
}

@end
