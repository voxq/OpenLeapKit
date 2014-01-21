/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Sample.h"
#import "OLKDemoHandsOverlayViewController.h"
#import <OpenLeapKit/OLKHandCursorResponderController.h>
#import <OpenLeapKit/OLKCircleMultiCursorInputMultiTap.h>
#import <OpenLeapKit/OLKCircleMenuMultiCursorView.h>
#import <OpenLeapKit/OLKRangeCalibratorView.h>
#import <OpenLeapKit/OLKFullScreenOverlayWindow.h>
#import <OpenLeapKit/OLKHorizScratchButton.h>
#import "LeapMenuView.h"
#import "ConfigMenuView.h"

@implementation Sample
{
    LeapController *_controller;
    OLKDemoHandsOverlayViewController *_handsOverlayController;
    OLKHandCursorResponderController *_handCursorResponderController;
    MainOverlayView *_displayingView;
    MainOverlayView *_handsView;
    BOOL _fullScreenMode;
    MainOverlayView *_fullOverlayView;
    OLKCircleMenuMultiCursorView *_optionsView;
    OLKCircleOptionMultiCursorInput *_optionsModel;
    BOOL _showingOptions;
    BOOL _showingCalibrate;
    OLKFullScreenOverlayWindow *_fullScreenOverlayWindow;
    OLKFullScreenOverlayWindow *_fullScreenCalibrateOverlayWindow;
    OLKRangeCalibratorView *_calibratorView;
    OLKRangeCalibrator *_calibrator;
    LeapMenuView *_mainMenuView;
    NSView *_compoundMenu;
    NSView <OLKHandContainer> *_trackingHandView;
    BOOL _returnToFullScreen;
    BOOL _isFist;
    BOOL _prevNoHands;
}

@synthesize handBoundsButton = _handBoundsButton;
@synthesize fingerLinesButton = _fingerLinesButton;
@synthesize fingerTipsButton = _fingerTipsButton;
@synthesize fingerDepthYButton = _fingerDepthYButton;
@synthesize palmButton = _palmButton;
@synthesize hand3DButton = _hand3DButton;
@synthesize autoSizeButton = _autoSizeButton;
@synthesize stablePalmsButton = _stablePalmsButton;
@synthesize interactionBoxButton = _interactionBoxButton;

- (void)terminate
{
    [_controller removeListener:self];
}


- (void)dealloc
{
    _controller = nil;
    _handsOverlayController = nil;
}

-(void)run:(MainOverlayView *)handsView;
{
    _handsOverlayController = [[OLKDemoHandsOverlayViewController alloc] init];
    [_handsOverlayController setHandsSpaceView:handsView];
    [_handsOverlayController setOverrideSpaceViews:YES];
    _handsOverlayController.delegate = self;
    _handsOverlayController.handsOverlayControllerDelegate = self;
    _controller = [[LeapController alloc] init];
    [_controller addListener:self];
    _handsView = handsView;
    _prevNoHands = YES;
    
    _displayingView = _handsView;
    NSLog(@"running");
    
    _handCursorResponderController = [[OLKHandCursorResponderController alloc] init];
    [_handCursorResponderController addHandCursorResponder:_displayingView];

    _mainMenuView = [[LeapMenuView alloc] initWithFrame:[_handsView bounds]];
    _handsView.menuView = _mainMenuView;
    _mainMenuView.frame = _displayingView.frame;
    [_mainMenuView setDelegate:self];

    [_displayingView addSubview:_handsOverlayController.handsConfigMenu];
    _handsOverlayController.handsConfigMenu.frame = _displayingView.frame;
}


#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification
{
    NSLog(@"Connected");
    LeapController *aController = (LeapController *)[notification object];
//    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
//    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
//    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
//    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification
{
    //Note: not dispatched when running in a debugger.
    NSLog(@"Disconnected");
}

- (void)onExit:(NSNotification *)notification
{
    NSLog(@"Exited");
    [_controller removeListener:self];
}

- (IBAction)goFullScreen:(id)sender
{
    [_handCursorResponderController removeHandCursorResponder:_displayingView];
    if (_fullScreenMode)
    {
        _displayingView = _handsView;
        [[_handsView window] orderFront:self];
        _fullOverlayView = nil;
        [_fullScreenOverlayWindow orderOut:self];
        _fullScreenOverlayWindow = nil;
        _fullScreenMode = NO;
        [_handsOverlayController setHandsSpaceView:_handsView];
        [_handsOverlayController updateHandsAndPointablesViews];
        if (_showingOptions)
            [self showOptionsViewLayout];
        [_handsView addSubview:_mainMenuView];
        [_handsView addSubview:_handsOverlayController.handsConfigMenu];
        [_handCursorResponderController addHandCursorResponder:_displayingView];
        return;
    }
    _fullScreenMode = YES;

    [[_handsView window] orderOut:self];
	// Create a screen-sized window on the display you want to take over
	// Note, mainDisplayRect has a non-zero origin if the key window is on a secondary display
	_fullScreenOverlayWindow = [[OLKFullScreenOverlayWindow alloc] initWithContentRect:[[[_handsView window] screen] frame] styleMask:0 backing:NSBackingStoreBuffered defer:YES];
    [_fullScreenOverlayWindow moveToScreen:[[_handsView window] screen]];

	// Perform any other window configuration you desire

    NSRect containerViewRect;
    containerViewRect.origin = NSMakePoint(0, 0);
    containerViewRect.size = [_fullScreenOverlayWindow frame].size;    
    
    _fullOverlayView = [[MainOverlayView alloc] initWithFrame:containerViewRect];
    _displayingView = _fullOverlayView;
	[_fullScreenOverlayWindow setContentView:_fullOverlayView];

	// Show the window
    [_mainMenuView removeFromSuperview];
    [_handsOverlayController.handsConfigMenu removeFromSuperview];
    [_fullOverlayView addSubview:_mainMenuView];
    [_fullOverlayView addSubview:_handsOverlayController.handsConfigMenu];
	[_fullScreenOverlayWindow makeFirstResponder:_fullOverlayView];
    [_handsOverlayController setHandsSpaceView:_fullOverlayView];
    [_handsOverlayController updateHandsAndPointablesViews];
    if (_showingOptions)
        [self showOptionsViewLayout];
    [_fullScreenOverlayWindow makeKeyAndOrderFront:self];
    [_handCursorResponderController addHandCursorResponder:_displayingView];
}

- (NSPoint)cursorPosRelativeToCenter
{
    NSPoint center = [_optionsView center];
    NSPoint handPos;
    NSRect handBounds = [_trackingHandView bounds];
    handPos = handBounds.origin;
    handPos.x += handBounds.size.width/2;
    handPos.y += handBounds.size.height/2;
    handPos = [_optionsView convertPoint:handPos fromView:_trackingHandView];
    
    handPos.x = handPos.x - center.x;
    handPos.y = handPos.y - center.y;
    return handPos;
}

- (void)onFrame:(NSNotification *)notification
{
    [_handsOverlayController onFrame:notification];
    if (!_showingCalibrate)
        [self updateWithHands];
}

- (void)onFocusGained:(NSNotification *)notification
{
    NSLog(@"Focus Gained");
}

- (void)onFocusLost:(NSNotification *)notification
{
    NSLog(@"Focus Lost");
}

+ (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}

- (IBAction)enableHandBounds:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnableDrawHandsBoundingCircle:YES];
    else
        [_handsOverlayController setEnableDrawHandsBoundingCircle:NO];
}

- (IBAction)enableFingerLines:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnableDrawFingers:YES];
    else
        [_handsOverlayController setEnableDrawFingers:NO];
}

- (IBAction)enableFingerTips:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnableDrawFingerTips:YES];
    else
        [_handsOverlayController setEnableDrawFingerTips:NO];
}

- (IBAction)enableFingersZisY:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnableScreenYAxisUsesZAxis:YES];
    else
        [_handsOverlayController setEnableScreenYAxisUsesZAxis:NO];
}

- (IBAction)enableDrawPalm:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnableDrawPalms:YES];
    else
        [_handsOverlayController setEnableDrawPalms:NO];
}

- (IBAction)enableAutoHandSize:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnableAutoFitHands:YES];
    else
        [_handsOverlayController setEnableAutoFitHands:NO];
}

- (IBAction)enable3DHand:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setEnable3DHand:YES];
    else
        [_handsOverlayController setEnable3DHand:NO];
}

- (IBAction)enableStabilizedPalms:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setUseStabilized:YES];
    else
        [_handsOverlayController setUseStabilized:NO];
}

- (IBAction)enableInteractionBox:(id)sender
{
    if ([(NSButton*)sender state] == NSOnState)
        [_handsOverlayController setUseInteractionBox:YES];
    else
        [_handsOverlayController setUseInteractionBox:NO];
}

- (IBAction)resetCalibration:(id)sender
{
    [_handsOverlayController setCalibrator:nil];
    [_handsOverlayController updateHandsAndPointablesViews];
}

- (void)calibratedPosition:(OLKRangePositionsCalibrated)positionCalibrated
{
    _trackingHandView = [[_handsOverlayController handsViews] objectAtIndex:0];
    switch (positionCalibrated)
    {
        case OLKRangeFirstPositionCalibrated:
            [_calibrator setLeapPos1:[[_trackingHandView hand] palmPosition]];
            break;
            
        case OLKRangeSecondPositionCalibrated:
            [_calibrator setLeapPos2:[[_trackingHandView hand] palmPosition]];
            break;

        case OLKRangeAllPositionsCalibrated:
            if ([_calibrator use3PointCalibration])
                [_calibrator setLeapPos3:[[_trackingHandView hand] palmPosition]];
            else
                [_calibrator setLeapPos2:[[_trackingHandView hand] palmPosition]];
            
            [_calibrator calibrate];
            [_handsOverlayController setCalibrator:_calibrator];
            [_handsOverlayController updateHandsAndPointablesViews];
            break;
    }
}

- (void)canceledCalibration
{
    _showingCalibrate = NO;
    _calibratorView = nil;
    _calibrator = nil;
    _fullScreenCalibrateOverlayWindow = nil;

    [_fullScreenCalibrateOverlayWindow orderOut:self];
    if (!_fullScreenMode)
    {
        [_handsOverlayController setHandsSpaceView:_handsView];
        [[_handsView window] orderFront:self];
    }
    else
    {
        [_handsOverlayController setHandsSpaceView:_fullOverlayView];
        [_fullScreenOverlayWindow orderFront:self];

        [_fullScreenOverlayWindow makeFirstResponder:_fullOverlayView];
        [_fullOverlayView setNeedsDisplay:YES];
     }
    _showingOptions = TRUE;
    [_handsOverlayController updateHandsAndPointablesViews];

}

- (void)showCalibrate:(BOOL)threePoint
{
    _showingCalibrate = YES;
    NSScreen *screen;
    
    if (!_fullScreenMode)
    {
        screen = [[_handsView window] screen];
        [[_handsView window] orderOut:self];
    }
    else
    {
        screen = [_fullScreenOverlayWindow screen];
        [_fullScreenOverlayWindow orderOut:self];
    }
    
    _fullScreenCalibrateOverlayWindow = [[OLKFullScreenOverlayWindow alloc] init];
    [_fullScreenCalibrateOverlayWindow setFrame:[screen frame] display:YES];
    
    _calibrator = [[OLKRangeCalibrator alloc] init];
    [_calibrator setUse3PointCalibration:threePoint];
    
    [_calibrator setScreenFrame:[screen frame]];
    [_calibrator configScreenPositions];
    
    _calibratorView = [[OLKRangeCalibratorView alloc] initWithFrame:[screen frame]];
    [_calibratorView setRangeCalibrator:_calibrator];
    [_calibratorView setDelegate:self];
    [_handsOverlayController setHandsSpaceView:_calibratorView];
    [_handsOverlayController updateHandsAndPointablesViews];
    [_fullScreenCalibrateOverlayWindow setContentView:_calibratorView];
    [_fullScreenCalibrateOverlayWindow makeKeyAndOrderFront:self];
    [_fullScreenCalibrateOverlayWindow makeFirstResponder:_calibratorView];
}

- (void)showOptionsViewLayout
{
    [_mainMenuView setActive:NO];
    [_handsOverlayController.handsConfigMenu setActive:NO];
    
    NSRect optionsViewRect = [_displayingView bounds];
    if (!_optionsView)
    {
        _optionsView = [[OLKCircleMenuMultiCursorView alloc] initWithFrame:optionsViewRect];
        
        _optionsModel = [[OLKCircleOptionMultiCursorInput alloc] init];
        [_optionsModel setDelegate:self];
        [_optionsModel setOptionObjects:[NSArray arrayWithObjects:@"2 Point Calibrate", @"3 Point Calibrate", @"exit", nil]];
        [_optionsView setCircleInput:_optionsModel];
    }
    optionsViewRect.size.width /= 1.5;
    optionsViewRect.size.height /= 1.5;
    if (optionsViewRect.size.width < optionsViewRect.size.height)
        [_optionsModel setRadius:optionsViewRect.size.width/2.0];
    else
        [_optionsModel setRadius:optionsViewRect.size.height/2.0];

    [_optionsView setFrame:NSMakeRect(optionsViewRect.origin.x+optionsViewRect.size.width/6, optionsViewRect.origin.y+optionsViewRect.size.height/6, optionsViewRect.size.width, optionsViewRect.size.height)];
    
    [_displayingView addSubview:_optionsView];
    [_optionsView setActive:YES];
    [_optionsView setNeedsDisplay:YES];
    _showingOptions = YES;
}

- (void)exitOptionsView
{
    _showingOptions = NO;
    [_optionsView removeFromSuperview];
    [_optionsModel removeAllCursorTracking];
    [_handsOverlayController.handsConfigMenu setActive:YES];
    [_mainMenuView setActive:YES];
}

- (void)controlChangedValue:(id)sender control:(OLKNIControl *)control
{
    if (control == _mainMenuView.goFullScreenButton)
        [self goFullScreen:self];
    else if (control == _mainMenuView.calibrateButton)
        [self showOptionsViewLayout];
}


- (void)updateWithHand:(NSView <OLKHandContainer> *)handView
{
    NSPoint cursorPos;
    NSRect handRect = [handView frame];
    cursorPos.x = handRect.origin.x + handRect.size.width/2;
    cursorPos.y = handRect.origin.y + handRect.size.height/2;

    [_handCursorResponderController setCursorTracking:cursorPos withHandView:handView];
}

- (void)willRemoveHand:(OLKHand *)hand withHandView:(NSView<OLKHandContainer> *)handView
{
    [_handCursorResponderController removeCursorTracking:handView];
    
}

- (void)simpleCursorNeedsShowing
{
    [_displayingView setEnableCursor:YES];
    [_displayingView setNeedsDisplay:YES];
}

- (void)updateWithHands
{
    NSArray *handsViews = [_handsOverlayController handsViews];
    if (![handsViews count])
    {
        if (_prevNoHands)
            return;
        
        _prevNoHands = YES;
        if ([_displayingView enableCursor])
            [_displayingView setEnableCursor:NO];
        
        return;
    }
    if (_prevNoHands)
    {
        _prevNoHands = NO;
        if ([_handsOverlayController usingSimpleCursor] || [_handsOverlayController usingOnlySimpleCursor])
            [_displayingView setEnableCursor:YES];
        else if ([_displayingView enableCursor])
            [_displayingView setEnableCursor:NO];
    }
    
    NSView <OLKHandContainer>*handView;
    for (handView in handsViews)
        [self updateWithHand:handView];
    
    if ([[(OLKSimpleVectHandView *)[handsViews objectAtIndex:0] hand] isFist] && !_isFist)
    {
        _isFist = YES;
        _mainMenuView.fistLabel.label = @"Hand is Fist";
        [_mainMenuView setNeedsDisplayInRect:_mainMenuView.fistLabel.frame];
    }
    else if (![[(OLKSimpleVectHandView *)[handsViews objectAtIndex:0] hand] isFist] && _isFist)
    {
        _isFist = NO;
        _mainMenuView.fistLabel.label = @"Hand is Open";
        [_mainMenuView setNeedsDisplayInRect:_mainMenuView.fistLabel.frame];
    }
}


- (void)cursorMovedToCenter:(id)sender
{
    NSLog(@"Moved To Center");
    
    NSView *mainView;
    if (_fullScreenMode)
        mainView = _fullOverlayView;
    else
        mainView = _handsView;
    
    [mainView setNeedsDisplay:YES];
}

- (void)cursorMovedToInner:(id)sender
{
    NSLog(@"Moved To Inner");
    NSView *mainView;
    if (_fullScreenMode)
        mainView = _fullOverlayView;
    else
        mainView = _handsView;
    
    [mainView setNeedsDisplay:YES];
}

- (void)selectedIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext
{
    if (index == OLKCircleOptionMultiInputInvalidSelection)
        NSLog(@"Deselected Index");
    else
    {
        if (index == 0)
        {
            [self showCalibrate:NO];
            _showingOptions = FALSE;
        }
        else if (index == 1)
        {
            [self showCalibrate:YES];
            _showingOptions = FALSE;
        }
        else if (index == 2)
            [self exitOptionsView];
        NSLog(@"Selected Index: %d", index);
    }
    [_displayingView setNeedsDisplay:YES];
}

- (void)hoverIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext
{
    NSLog(@"Hover changed to Index: %d", index);
    
    NSView *mainView;
    if (_fullScreenMode)
        mainView = _fullOverlayView;
    else
        mainView = _handsView;
    
    [mainView setNeedsDisplay:YES];
}

@end
