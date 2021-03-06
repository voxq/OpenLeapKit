//
//  WordLeapOverlayWindow.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKFullScreenOverlayWindow.h"

static float const inchesToMM = 25.4;

@implementation OLKFullScreenOverlayWindow

@synthesize useFullScreenBounds = _useFullScreenBounds;

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
    [self moveToScreen:[self screen]];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)resetToDefaultConfig
{
    _useFullScreenBounds = NO;
    [self setBackingType:NSBackingStoreBuffered];
	[self setStyleMask:NSUtilityWindowMask | NSNonactivatingPanelMask];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0]];
    [self setLevel:CGShieldingWindowLevel()+1];
    [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    [self setCanHide:NO];
    [self setHasShadow:NO];
}

- (void)setUseFullScreenBounds:(BOOL)useFullScreenBounds
{
    _useFullScreenBounds = useFullScreenBounds;
    [self moveToScreen:self.screen];
}

- (void)moveToScreen:(NSScreen *)screen
{
    if (_useFullScreenBounds)
        [self setFrame:[screen frame] display:YES];
    else
        [self setFrame:[screen visibleFrame] display:YES];
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

- (void)moveToScreenNumber:(NSNumber *)screenNumber
{
    NSArray *screens=[NSScreen screens];
    if ([screens count] < 2)
        return;
    
    for (NSScreen *screen in screens)
    {
        NSNumber *foundScreenNumber = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
        if (foundScreenNumber == screenNumber)
        {
            [self moveToScreen:screen];
            return;
        }
    }
}

- (NSSize)screenPhysicalSize
{
    NSDictionary *description = [[self screen] deviceDescription];
    unsigned int screenNumber = [[description objectForKey:@"NSScreenNumber"] unsignedIntValue];
    NSSize physicalSize = CGDisplayScreenSize(screenNumber);
    if (physicalSize.width < 300)
    {
        NSSize resolution = [[description objectForKey:@"NSDeviceSize"] sizeValue];
        NSSize dpi = [[description objectForKey:@"NSDeviceResolution"] sizeValue];
        physicalSize = NSMakeSize(resolution.width/dpi.width*inchesToMM, resolution.height/dpi.height*inchesToMM);
    }
    return physicalSize;
}

- (NSSize)determinePointSizeFromDesiredPhysicalSize:(NSSize)desiredPhysicalSize
{
    NSSize pointSize;
    NSSize screenSize = [self screenPhysicalSize];
    NSSize screenPointSize = [[self screen] frame].size;
    pointSize.width = desiredPhysicalSize.width * (screenPointSize.width/screenSize.width);
    pointSize.height = desiredPhysicalSize.height * (screenPointSize.height/screenSize.height);
    return pointSize;
}

@end
