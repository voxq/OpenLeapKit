/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Sample.h"
#import "OLKDemoHandsOverlayViewController.h"

@implementation Sample
{
    LeapController *_controller;
    OLKDemoHandsOverlayViewController *_handsOverlayController;
    NSView *_handsView;
    BOOL _fullScreenMode;
    NSView *_fullOverlayView;
    NSWindow *_fullOverlayWindow;
}

-(void)run:(NSView *)handsView;
{
    _handsOverlayController = [[OLKDemoHandsOverlayViewController alloc] init];
    [_handsOverlayController setHandsContainerView:handsView];
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
        [_handsOverlayController setHandsContainerView:_handsView];
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
    [_handsOverlayController setHandsContainerView:_fullOverlayView];
}


- (void)onFrame:(NSNotification *)notification
{
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

@end
