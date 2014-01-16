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
    CalibratorController *_calibratorController;
    NSView *_displayingView;
    NSView *_handsView;
    BOOL _fullScreenMode;
    NSView *_fullOverlayView;
    OLKCircleMenuMultiCursorView *_optionsView;
    OLKCircleOptionMultiCursorInput *_optionsModel;
    BOOL _showingOptions;
    BOOL _showingCalibrate;
    OLKFullScreenOverlayWindow *_fullScreenOverlayWindow;
    OLKRangeCalibratorView *_calibratorView;
    OLKRangeCalibrator *_calibrator;
    ConfigMenuView *_menuView;
    NSView <OLKHandContainer> *_trackingHandView;
    BOOL _returnToFullScreen;
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

- (void)dealloc
{
    _controller = nil;
    _handsOverlayController = nil;
}

-(void)run:(NSView *)handsView;
{
    _handsOverlayController = [[OLKDemoHandsOverlayViewController alloc] init];
    [_handsOverlayController setHandsSpaceView:handsView];
    [_handsOverlayController setOverrideSpaceViews:YES];
    _controller = [[LeapController alloc] init];
    [_controller addListener:self];
    _handsView = handsView;
    NSLog(@"running");
    
    [self initCalibratorController];
    [_calibratorController loadFromDefaults];
    [_calibratorController changeToScreen:[[_displayingView window] screen]];

    _handCursorResponderController = [[OLKHandCursorResponderController alloc] init];
    [_handCursorResponderController addHandCursorResponder:_displayingView];
}

- (void)initCalibratorController
{
    _calibratorController = [[CalibratorController alloc] init];
    [_calibratorController setMenuParentView:_displayingView];
    [_calibratorController setHandsOverlayController:_handsOverlayController];
    [_calibratorController setDelegate:self];
}


#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification
{
    _menuView = [[ConfigMenuView alloc] initWithFrame:[_handsView bounds]];
    [_handsView addSubview:_menuView];
    [_menuView setDelegate:self];

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
        [_handsView addSubview:_menuView];
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
    
    _fullOverlayView = [[NSView alloc] initWithFrame:containerViewRect];
    _displayingView = _fullOverlayView;
	[_fullScreenOverlayWindow setContentView:_fullOverlayView];

	// Show the window
    [_menuView removeFromSuperview];
    [_fullOverlayView addSubview:_menuView];
	[_fullScreenOverlayWindow makeFirstResponder:_fullOverlayView];
    [_handsOverlayController setHandsSpaceView:_fullOverlayView];
    [_handsOverlayController updateHandsAndPointablesViews];
    if (_showingOptions)
        [self showOptionsViewLayout];
    [_fullScreenOverlayWindow makeKeyAndOrderFront:self];
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
    [self typingPointableToScreenPos];
    [_handsOverlayController onFrame:notification];
    return;
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
        [_handsOverlayController setEnableStablePalms:YES];
    else
        [_handsOverlayController setEnableStablePalms:NO];
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
    [_menuView setActive:NO];
    NSView *mainView;
    if (_fullScreenMode)
        mainView = _fullOverlayView;
    else
        mainView = _handsView;
    
    NSRect optionsViewRect = [mainView bounds];
    if (!_optionsView)
    {
        _optionsView = [[OLKCircleMenuView alloc] initWithFrame:optionsViewRect];
        
        _optionsModel = [[OLKCircleOptionInput alloc] init];
        [_optionsModel setDelegate:self];
        [_optionsModel setOptionObjects:[NSArray arrayWithObjects:@"2 Point Calibrate", @"3 Point Calibrate", @"exit", nil]];
        [_optionsView setCircleOptionInput:_optionsModel];
    }
    [_optionsModel setRequiresMoveToInner:YES];
    optionsViewRect.size.width /= 1.5;
    optionsViewRect.size.height /= 1.5;
    if (optionsViewRect.size.width < optionsViewRect.size.height)
        [_optionsModel setRadius:optionsViewRect.size.width/2.0];
    else
        [_optionsModel setRadius:optionsViewRect.size.height/2.0];

    [_optionsView setFrame:NSMakeRect(optionsViewRect.origin.x+optionsViewRect.size.width/6, optionsViewRect.origin.y+optionsViewRect.size.height/6, optionsViewRect.size.width, optionsViewRect.size.height)];
    
    [mainView addSubview:_optionsView];
    [_optionsView setActive:YES];
    [_optionsView setNeedsDisplay:YES];
    _showingOptions = YES;
}

- (void)exitOptionsView
{
    _showingOptions = NO;
    [_optionsView removeFromSuperview];
    [_optionsModel reset];
    [_menuView setActive:YES];
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
        propertyKey = WLHandsDrawFingerTips;
        resetPropertyKey = @"enableDrawFingerTips";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.fingerLinesButton)
    {
        _enableDrawFingers = enabled;
        propertyKey = WLHandsDrawFingers;
        resetPropertyKey = @"enableDrawFingers";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.boundedHandButton)
    {
        _enableDrawHandsBoundingCircle = enabled;
        propertyKey = WLHandsDrawBoundingCircle;
        resetPropertyKey = @"enableDrawHandsBoundingCircle";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.palmButton)
    {
        _enableDrawPalms = enabled;
        propertyKey = WLHandsDrawPalms;
        resetPropertyKey = @"enableDrawPalms";
    }
    else if (control == (OLKNIControl *)_handsConfigMenu.useSimpleCursorButton)
    {
        _usingSimpleCursor = enabled;
        propertyKey = WLHandsUseSimpleCursor;
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
            propertyKey = WLHandsUseZForY;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.hand3DButton)
        {
            _enable3DHand = enabled;
            propertyKey = WLHands3DPerspective;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.autoSizeButton)
        {
            _enableAutoFitHands = enabled;
            propertyKey = WLHandsAutoSizeHand;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.interactionBoxButton)
        {
            [self setUseInteractionBox:enabled];
            propertyKey = WLHandsUseInteractionBox;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.stablePalmsButton)
        {
            [self setUseStabilized:enabled];
            propertyKey = WLHandsUseStabilizedPos;
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.useOnlySimpleCursorButton)
        {
            _usingOnlySimpleCursor = enabled;
            propertyKey = WLHandsUseOnlySimpleCursor;
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
            [WordLeapHandsOverlayViewController resetDefaults];
        }
        else if (control == (OLKNIControl *)_handsConfigMenu.exitButton)
        {
            if ([_handsOverlayControllerDelegate respondsToSelector:@selector(exitedWordLeapHandsConfigMenu)])
                [_handsOverlayControllerDelegate exitedWordLeapHandsConfigMenu];
        }
    }
    if (propertyKey)
    {
        if (enabled)
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:propertyKey];
        else
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:propertyKey];
    }
}

- (void)menuItemChangedValue:(LeapMenuItem)menuItem enabled:(BOOL)enabled
{
    NSButton *button = nil;
    switch (menuItem)
    {
        case LeapMenuItemFingerTips:
            button = _fingerTipsButton;
            break;
            
        case LeapMenuItemFingerLines:
            button = _fingerLinesButton;
            break;
            
        case LeapMenuItemBoundedHand:
            button = _handBoundsButton;
            break;
            
        case LeapMenuItemPalm:
            button = _palmButton;
            break;
            
        case LeapMenuItemFingerDepthY:
            button = _fingerDepthYButton;
            break;
            
        case LeapMenuItem3DHand:
            button = _hand3DButton;
            break;
            
        case LeapMenuItemAutoSizeHandToBounds:
            button = _autoSizeButton;
            break;
            
        case LeapMenuItemUseInteractionBox:
            button = _interactionBoxButton;
            break;
            
        case LeapMenuItemUseStablePalm:
            button = _stablePalmsButton;
            break;
            
        case LeapMenuItemGoFullScreen:
            [self goFullScreen:self];
            return;
            break;
            
        case LeapMenuItemCalibrate:
            [_calibratorController showCalibrationMenu];
//            [self showOptionsViewLayout];
            return;
            break;
            

        default:
            return;
            break;
    }
    if (enabled)
        [button setState:NSOnState];
    else
        [button setState:NSOffState];
    [button sendAction:[button action] to:self];
}

- (void)updateWithHand:(NSView <OLKHandContainer> *)handView
{
    NSPoint cursorPos;
    OLKHand *hand = [handView hand];
    if (_typingMode == WLHandMode || [[[hand leapHand] fingers] count] > 2)
    {
        NSRect handRect = [handView frame];
        cursorPos.x = handRect.origin.x + handRect.size.width/2;
        cursorPos.y = handRect.origin.y + handRect.size.height/2;
    }
    [_handCursorResponderController setCursorTracking:cursorPos withHandView:handView];
    
    if ([_calibratorController showingCalibrationMenu])
        [_calibratorController setCursorPos:cursorPos cursorContext:handView];
}

- (void)willRemoveHand:(OLKHand *)hand withHandView:(NSView<OLKHandContainer> *)handView
{
    [_handCursorResponderController removeCursorTracking:handView];
    
    if ([_calibratorController showingCalibrationMenu])
        [_calibratorController removeCursorContext:handView];
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
        
        if ([_displayingView active])
            [_displayingView setActive:NO];
        
        return;
    }
    if (_prevNoHands)
    {
        _prevNoHands = NO;
        [_displayingView setActive:YES];
        if ([_handsOverlayController usingSimpleCursor] || [_handsOverlayController usingOnlySimpleCursor])
            [_displayingView setEnableCursor:YES];
        else if ([_displayingView enableCursor])
            [_displayingView setEnableCursor:NO];
    }
    
    NSView <OLKHandContainer>*handView;
    for (handView in [_handsOverlayController handsViews])
        [self updateWithHand:handView];
}


- (void)typingPointableToScreenPos
{
    NSPoint cursorPos;
    OLKHand *hand = [_handsOverlayController rightHand];
    if (hand)
    {
        _trackingHandView = [_handsOverlayController rightHandView];
    }
    else
    {
        hand = [_handsOverlayController leftHand];
        if (hand)
        {
            _trackingHandView = [_handsOverlayController leftHandView];
        }
        else
        {
            _trackingHandView = nil;
            return;
        }
    }
    NSRect handRect = [_trackingHandView frame];
    cursorPos.x = handRect.origin.x + handRect.size.width/2;
    cursorPos.y = handRect.origin.y + handRect.size.height/2;
    if (_showingOptions)
        [_optionsModel setCursorPos:[self cursorPosRelativeToCenter]];
    else
        [_menuView setCursorPos:cursorPos cursorObject:hand];

    if ([_calibratorController showingCalibrationMenu])
        [_calibratorController setCursorPos:cursorPos cursorContext:_trackingHandView];

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

- (void)selectedIndexChanged:(int)index sender:(id)sender
{
    if (index == OLKCircleOptionInputInvalidSelection)
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
        [_optionsModel setRequiresMoveToInner:TRUE];
        [_optionsModel setSelectedIndex:OLKCircleOptionInputInvalidSelection];
    }
    NSView *mainView;
    if (_fullScreenMode)
        mainView = _fullOverlayView;
    else
        mainView = _handsView;

    [mainView setNeedsDisplay:YES];
}

- (void)hoverIndexChanged:(int)index sender:(id)sender
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
