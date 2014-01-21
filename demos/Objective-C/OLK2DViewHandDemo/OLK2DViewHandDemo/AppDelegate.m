/******************************************************************************\
 * Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
 * Leap Motion proprietary and confidential. Not for distribution.              *
 * Use subject to the terms of the Leap Motion SDK Agreement available at       *
 * https://developer.leapmotion.com/sdk_agreement, or another agreement         *
 * between Leap Motion and you, your company or other organization.             *
 \******************************************************************************/

#import "AppDelegate.h"
#import "Sample.h"
#import "OLKDemoHandsOverlayViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize sample = _sample; // must retain for notifications
@synthesize handView = _handView;

+ (void)initialize
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSDictionary *tmpProperties = [OLKDemoHandsOverlayViewController defaultProperties];
    [properties addEntriesFromDictionary:tmpProperties];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults registerDefaults:properties];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [_sample terminate];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_sample run:_handView];
}

@end
