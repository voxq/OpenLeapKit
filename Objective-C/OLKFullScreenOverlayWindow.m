//
//  WordLeapOverlayWindow.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKFullScreenOverlayWindow.h"

@implementation OLKFullScreenOverlayWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    if (self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation])
    {
        [self resetToDefaultConfig];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation screen:(NSScreen *)screen
{
    if (self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation screen:screen])
    {
        [self resetToDefaultConfig];
    }
    return self;
}

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
    [self moveToScreen:[self screen]];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)resetToDefaultConfig
{
    [self setBackingType:NSBackingStoreBuffered];
	[self setStyleMask:NSUtilityWindowMask | NSNonactivatingPanelMask];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0]];
    [self setLevel:CGShieldingWindowLevel()+1];
    [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    [self setCanHide:NO];
    [self setHasShadow:NO];
}

- (void)moveToScreen:(NSScreen *)screen
{
    [self setFrame:[screen frame] display:YES];
}

- (void)moveToNextScreen
{
    NSArray *screens=[NSScreen screens];
    if ([screens count] < 2)
        return;
    
    BOOL grabNext = FALSE;
    NSScreen *foundScreen=nil;
    for (NSScreen *screen in screens)
    {
        if (grabNext)
        {
            foundScreen = screen;
            break;
        }
        if ([self screen] == screen)
        {
            grabNext = TRUE;
        }
    }
    if (!grabNext)
        return;
    
    if (!foundScreen)
        foundScreen = [screens objectAtIndex:0];
    
    [self moveToScreen:foundScreen];
}

@end
