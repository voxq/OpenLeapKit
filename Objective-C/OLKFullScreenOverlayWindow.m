//
//  WordLeapOverlayWindow.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKFullScreenOverlayWindow.h"

@implementation OLKFullScreenOverlayWindow

- (id)init
{
    if (self = [super init])
    {
        [self resetToDefaultConfig];
    }
    return self;
}

- (void)awakeFromNib
{
    [self resetToDefaultConfig];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)resetToDefaultConfig
{
	[self setStyleMask:NSUtilityWindowMask | NSNonactivatingPanelMask];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0]];
    [self setLevel:CGShieldingWindowLevel()+1];
    [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    [self setCanHide:NO];
}

- (void)moveToScreen:(NSScreen *)screen
{
    [self setFrame:[screen frame] display:YES];
}

@end
