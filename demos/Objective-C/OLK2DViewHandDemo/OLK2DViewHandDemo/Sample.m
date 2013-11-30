/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Sample.h"
#import "OLKDemoHandsOverlayViewController.h"
#import <OpenLeapKit/OLKCircleMenuView.h>
#import <OpenLeapKit/OLKCircleOptionInput.h>
#import "LeapMenuView.h"

@implementation Sample
{
    LeapController *_controller;
    OLKDemoHandsOverlayViewController *_handsOverlayController;
    NSView *_handsView;
    BOOL _fullScreenMode;
    NSView *_fullOverlayView;
    NSWindow *_fullOverlayWindow;
    OLKCircleMenuView *_optionsView;
    OLKCircleOptionInput *_optionsModel;
    BOOL _showingOptions;
    LeapMenuView *_menuView;
    NSView *_trackingHandView;
}

- (void)dealloc
{
    _controller = nil;
    _handsOverlayController = nil;
}

-(void)run:(NSView *)handsView;
{
    _handsOverlayController = [[OLKDemoHandsOverlayViewController alloc] init];
    [_handsOverlayController setHandsSpaceView:handsView];
    _controller = [[LeapController alloc] init];
    [_controller addListener:self];
    _handsView = handsView;
    NSLog(@"running");
}

#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification
{
    _menuView = [[LeapMenuView alloc] initWithFrame:[_handsView bounds]];
    [_handsView addSubview:_menuView];
    [_menuView setDelegate:self];
    [_menuView setActive:YES];

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
}

- (IBAction)goFullScreen:(id)sender
{
    if (_fullScreenMode)
    {
        [[_handsView window] orderFront:self];
        _fullOverlayView = nil;
        [_fullOverlayWindow orderOut:self];
        _fullOverlayWindow = nil;
        _fullScreenMode = NO;
        [_handsOverlayController setHandsSpaceView:_handsView];
        [_handsOverlayController updateHandsAndPointablesViews];
        if (_showingOptions)
            [self showOptionsViewLayout];
        [_handsView addSubview:_menuView];
        return;
    }
    _fullScreenMode = YES;
	NSRect mainDisplayRect;
	
    [[_handsView window] orderOut:self];
	// Create a screen-sized window on the display you want to take over
	// Note, mainDisplayRect has a non-zero origin if the key window is on a secondary display
	mainDisplayRect = [[NSScreen mainScreen] visibleFrame];
	_fullOverlayWindow = [[NSWindow alloc] initWithContentRect:mainDisplayRect styleMask:NSBorderlessWindowMask
                                                          backing:NSBackingStoreBuffered defer:YES];
	
	[_fullOverlayWindow setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0]];
	[_fullOverlayWindow setOpaque:NO];
	
	// Set the window level to be above the menu bar
    [_fullOverlayWindow setLevel:NSMainMenuWindowLevel+1];
	
	// Perform any other window configuration you desire

    NSRect containerViewRect;
    containerViewRect.origin = NSMakePoint(0, 0);
    containerViewRect.size = [_fullOverlayWindow frame].size;    
    
    _fullOverlayView = [[NSView alloc] initWithFrame:containerViewRect];
        
	[_fullOverlayWindow setContentView:_fullOverlayView];

	// Show the window
	[_fullOverlayWindow makeKeyAndOrderFront:_fullOverlayWindow];
    [_fullOverlayWindow setAcceptsMouseMovedEvents:YES];
	[_fullOverlayWindow makeFirstResponder:_fullOverlayView];
    [_handsOverlayController setHandsSpaceView:_fullOverlayView];
    [_handsOverlayController updateHandsAndPointablesViews];
    if (_showingOptions)
        [self showOptionsViewLayout];
    [_fullOverlayView addSubview:_menuView];
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

- (void)showOptionsViewLayout
{
    NSView *viewForMenu;
    if (_fullScreenMode)
        viewForMenu = _fullOverlayView;
    else
        viewForMenu = _handsView;
    
    if (!_optionsView)
    {
        NSRect optionsViewRect = [viewForMenu bounds];
        _optionsView = [[OLKCircleMenuView alloc] initWithFrame:optionsViewRect];
        [_optionsView setCellStrings:[NSArray arrayWithObjects:@"Option 1", @"Option 2", @"exit", nil]];
        
        _optionsModel = [[OLKCircleOptionInput alloc] init];
        [_optionsModel setDelegate:self];
        [_optionsModel setOptionObjects:[NSArray arrayWithObjects:@"Option 1", @"Option 2", @"exit", nil]];

        if (optionsViewRect.size.width < optionsViewRect.size.height)
            [_optionsModel setRadius:optionsViewRect.size.width/2.0];
        else
            [_optionsModel setRadius:optionsViewRect.size.height/2.0];
        [_optionsView setCircleOptionInput:_optionsModel];
    }
    
    NSRect keyViewRect = [viewForMenu bounds];
    [_optionsView setFrame:NSMakeRect(keyViewRect.origin.x+keyViewRect.size.width/6, keyViewRect.origin.y+keyViewRect.size.height/6, keyViewRect.size.width/1.5, keyViewRect.size.height/1.5)];
    
    [viewForMenu addSubview:_optionsView];
    [_optionsView setActive:YES];
    [_optionsView setNeedsDisplay:YES];
    _showingOptions = YES;
}

- (void)exitOptionsView
{
    _showingOptions = NO;
    [_optionsView removeFromSuperview];
    [_optionsModel reset];
}

- (void)menuItemChangedValue:(LeapMenuItem)menuItem
{
    switch (menuItem)
    {
        case LeapMenuItemTypingMode:
            break;
            
        case LeapMenuItemCharSets:
            
            break;
            
        case LeapMenuItemOptions:
            [self showOptionsViewLayout];
            break;
            
        case LeapMenuItemLayout:
            break;
            
        default:
            break;
    }
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
    [_menuView setCursorPos:cursorPos cursorObject:hand];
    if (_showingOptions)
    {
        [_optionsView setCursorPos:cursorPos];
        [_optionsModel setCursorPos:[self cursorPosRelativeToCenter]];
    }
}

- (void)cursorMovedToCenter:(id)sender
{
    NSLog(@"Moved To Center");
    
}

- (void)cursorMovedToInner:(id)sender
{
    NSLog(@"Moved To Inner");
}

- (void)selectedIndexChanged:(int)index sender:(id)sender
{
    if (index == OLKCircleOptionInputInvalidSelection)
        NSLog(@"Deselected Index");
    else
    {
        NSLog(@"Selected Index: %d", index);
        [_optionsModel setRequiresMoveToInner:TRUE];
    }
}

- (void)hoverIndexChanged:(int)index sender:(id)sender
{
    NSLog(@"Hover changed to Index: %d", index);
    
}

@end
