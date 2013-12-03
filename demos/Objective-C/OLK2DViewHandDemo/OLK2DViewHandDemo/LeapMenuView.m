//
//  LeapMenuView.m
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "LeapMenuView.h"
#import <OpenLeapKit/OLKToggleButton.h>
#import <OpenLeapKit/OLKScratchButton.h>

@implementation LeapMenuView
{
    OLKScratchButton *_calibrateButton;
    OLKScratchButton *_goFullScreenButton;
    OLKToggleButton *_boundedHandButton;
    OLKToggleButton *_fingerTipsButton;
    OLKToggleButton *_fingerLinesButton;
    OLKToggleButton *_fingerDepthYButton;
    OLKToggleButton *_palmButton;
    OLKToggleButton *_hand3DButton;
    OLKToggleButton *_autoSizeButton;
    OLKToggleButton *_stablePalmsButton;
    OLKToggleButton *_interactionBoxButton;
    BOOL _changeInMenu;
    NSImage *_menuImage;
}

@synthesize delegate = _delegate;
@synthesize active = _active;
@synthesize cursorRects = _cursorRects;
@synthesize enableCursor = _enableCursor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self defaultConfig];
}

- (void)setCursorPos:(NSPoint)cursorPos cursorObject:(id)cursorObject
{
    _changeInMenu = TRUE;
    if ([_boundedHandButton handMovedTo:cursorPos])
        return;
    
    if ([_fingerLinesButton handMovedTo:cursorPos])
        return;
    
    if ([_fingerTipsButton handMovedTo:cursorPos])
        return;
    
    if ([_calibrateButton handMovedTo:cursorPos])
        return;
    
    if ([_autoSizeButton handMovedTo:cursorPos])
        return;
    
    if ([_interactionBoxButton handMovedTo:cursorPos])
        return;
    
    if ([_stablePalmsButton handMovedTo:cursorPos])
        return;
    
    if ([_hand3DButton handMovedTo:cursorPos])
        return;
    
    if ([_goFullScreenButton handMovedTo:cursorPos])
        return;
    
    if ([_fingerDepthYButton handMovedTo:cursorPos])
        return;
    
    if ([_palmButton handMovedTo:cursorPos])
        return;
    
    _changeInMenu = FALSE;
}

- (void)defaultConfig
{
    _changeInMenu = TRUE;
    _active = NO;
    _enableCursor = TRUE;
    
    _calibrateButton = [[OLKScratchButton alloc] init];
    [_calibrateButton setSize:NSMakeSize(240, 50)];
    [_calibrateButton setTarget:self];
    [_calibrateButton setAction:@selector(calibrateOptionChanged:)];
    [_calibrateButton setParentView:self];
    
    _goFullScreenButton = [[OLKScratchButton alloc] init];
    [_goFullScreenButton setSize:NSMakeSize(240, 50)];
    [_goFullScreenButton setTarget:self];
    [_goFullScreenButton setAction:@selector(goFullScreenOptionChanged:)];
    [_goFullScreenButton setParentView:self];
    
    _boundedHandButton = [[OLKToggleButton alloc] init];
    [_boundedHandButton setSize:NSMakeSize(120, 50)];
    [_boundedHandButton setTarget:self];
    [_boundedHandButton setAction:@selector(boundedHandOptionChanged:)];
    [_boundedHandButton setEnable:YES];
    
    _fingerTipsButton = [[OLKToggleButton alloc] init];
    [_fingerTipsButton setSize:NSMakeSize(120, 50)];
    [_fingerTipsButton setTarget:self];
    [_fingerTipsButton setAction:@selector(fingerTipsOptionChanged:)];
    [_fingerTipsButton setEnable:YES];

    _fingerLinesButton = [[OLKToggleButton alloc] init];
    [_fingerLinesButton setSize:NSMakeSize(120, 50)];
    [_fingerLinesButton setTarget:self];
    [_fingerLinesButton setAction:@selector(fingerLinesOptionChanged:)];
    [_fingerLinesButton setEnable:YES];

    _palmButton = [[OLKToggleButton alloc] init];
    [_palmButton setSize:NSMakeSize(120, 50)];
    [_palmButton setTarget:self];
    [_palmButton setAction:@selector(drawPalmOptionChanged:)];
    [_palmButton setEnable:YES];

    _hand3DButton = [[OLKToggleButton alloc] init];
    [_hand3DButton setSize:NSMakeSize(120, 50)];
    [_hand3DButton setTarget:self];
    [_hand3DButton setAction:@selector(hand3DOptionChanged:)];
    [_hand3DButton setEnable:YES];

    _autoSizeButton = [[OLKToggleButton alloc] init];
    [_autoSizeButton setSize:NSMakeSize(120, 50)];
    [_autoSizeButton setTarget:self];
    [_autoSizeButton setAction:@selector(autoSizeOptionChanged:)];
    [_autoSizeButton setEnable:YES];
    
    _stablePalmsButton = [[OLKToggleButton alloc] init];
    [_stablePalmsButton setSize:NSMakeSize(120, 50)];
    [_stablePalmsButton setTarget:self];
    [_stablePalmsButton setAction:@selector(stablePalmOptionChanged:)];
    [_stablePalmsButton setEnable:YES];
    
    _interactionBoxButton = [[OLKToggleButton alloc] init];
    [_interactionBoxButton setSize:NSMakeSize(120, 50)];
    [_interactionBoxButton setTarget:self];
    [_interactionBoxButton setAction:@selector(interactionBoxOptionChanged:)];
    [_interactionBoxButton setEnable:YES];

    _fingerDepthYButton = [[OLKToggleButton alloc] init];
    [_fingerDepthYButton setSize:NSMakeSize(120, 50)];
    [_fingerDepthYButton setTarget:self];
    [_fingerDepthYButton setAction:@selector(fingerDepthOptionChanged:)];
    [_fingerDepthYButton setEnable:YES];
}

- (BOOL)enabledMenuItem:(LeapMenuItem)item
{
    switch (item) {
        case LeapMenuItem3DHand:
            return [_hand3DButton enable];
            break;
            
        case LeapMenuItemAutoSizeHandToBounds:
            return [_autoSizeButton enable];
            break;
            
        case LeapMenuItemFingerDepthY:
            return [_fingerDepthYButton enable];
            break;
            
        case LeapMenuItemBoundedHand:
            return [_boundedHandButton enable];
            break;
            
        case LeapMenuItemUseInteractionBox:
            return [_interactionBoxButton enable];
            break;
            
        case LeapMenuItemFingerLines:
            return [_fingerLinesButton enable];
            break;
            
        case LeapMenuItemFingerTips:
            return [_fingerTipsButton enable];
            break;
            
        case LeapMenuItemPalm:
            return [_palmButton enable];
            break;
            
        case LeapMenuItemUseStablePalm:
            return [_stablePalmsButton enable];
            break;
            
        default:
            break;
    }
    return FALSE;
}

- (void)fingerDepthOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemFingerDepthY enabled:[_fingerDepthYButton enable]];
}

- (void)hand3DOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItem3DHand enabled:[_hand3DButton enable]];
}

- (void)drawPalmOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemPalm enabled:[_palmButton enable]];
}

- (void)goFullScreenOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemGoFullScreen enabled:[_goFullScreenButton enable]];
}

- (void)autoSizeOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemAutoSizeHandToBounds enabled:[_autoSizeButton enable]];
}

- (void)stablePalmOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemUseStablePalm enabled:[_stablePalmsButton enable]];
}

- (void)interactionBoxOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemUseInteractionBox enabled:[_interactionBoxButton enable]];
}

- (void)boundedHandOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemBoundedHand enabled:[_boundedHandButton enable]];
}

- (void)fingerLinesOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemFingerLines enabled:[_fingerLinesButton enable]];
}

- (void)calibrateOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemCalibrate enabled:[_calibrateButton enable]];
}

- (void)fingerTipsOptionChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemFingerTips enabled:[_fingerTipsButton enable]];
}

- (void)drawMenuInImage
{
    NSRect bounds = [self bounds];
    _menuImage = [[NSImage alloc] initWithSize:[self bounds].size];
    [_menuImage lockFocus];
    
    [_boundedHandButton setLabel:@"Bounded Hand"];
    [_boundedHandButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16))];
    [_boundedHandButton draw];
    
    [_fingerLinesButton setLabel:@"Finger Lines"];
    [_fingerLinesButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-70)];
    [_fingerLinesButton draw];
    
    [_fingerTipsButton setLabel:@"Finger Tips"];
    [_fingerTipsButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-140)];
    [_fingerTipsButton draw];
    
    [_palmButton setLabel:@"Draw Palms"];
    [_palmButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-210)];
    [_palmButton draw];
    
    [_fingerDepthYButton setLabel:@"Finger Depth on Y Axis"];
    [_fingerDepthYButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-280)];
    [_fingerDepthYButton draw];

    [_hand3DButton setLabel:@"Use 3D Perspective Hand"];
    [_hand3DButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-350)];
    [_hand3DButton draw];

    [_autoSizeButton setLabel:@"Auto Size Hand to Bounds"];
    [_autoSizeButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-420)];
    [_autoSizeButton draw];
    
    [_stablePalmsButton setLabel:@"Use Stabilized Palms"];
    [_stablePalmsButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-490)];
    [_stablePalmsButton draw];
    
    [_interactionBoxButton setLabel:@"Use Interaction Box"];
    [_interactionBoxButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-560)];
    [_interactionBoxButton draw];

    [_calibrateButton setLabel:@"Screen Calibrate"];
    [_calibrateButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-700)];
    [_calibrateButton draw];

    [_goFullScreenButton setLabel:@"Full Screen"];
    [_goFullScreenButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-800)];
    [_goFullScreenButton draw];
    [_menuImage unlockFocus];
}

- (void)drawMenu
{
    if (_changeInMenu)
    {
        [self drawMenuInImage];
        _changeInMenu = FALSE;
    }
    else
    {
         if ([_calibrateButton activated] || [_goFullScreenButton activated])
         {
            [_menuImage lockFocus];
            if ([_calibrateButton activated])
            {
                [_calibrateButton clear];
                [_calibrateButton draw];
            }
            if ([_goFullScreenButton activated])
            {
                [_goFullScreenButton clear];
                [_goFullScreenButton draw];
            }
            [_menuImage unlockFocus];
         }
    }
    
    NSRect menuRect;
    menuRect.origin = NSMakePoint(0, 0);
    menuRect.size = [self bounds].size;
    
    float currentAlpha;
    if (_active)
        currentAlpha = 1;
    else
        currentAlpha = 0.3;
    [_menuImage drawAtPoint:[self bounds].origin fromRect:menuRect operation:NSCompositeSourceOver fraction:currentAlpha];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawMenu];
    // Drawing code here.
}

@end
