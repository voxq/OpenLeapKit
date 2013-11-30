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
    OLKToggleButton *_typeModeButton;
    OLKScratchButton *_optionsButton;
    OLKToggleButton *_charSetsButton;
    OLKToggleButton *_layoutButton;
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
    if ([_typeModeButton handMovedTo:cursorPos])
        return;
    
    if ([_layoutButton handMovedTo:cursorPos])
        return;
    
    if ([_charSetsButton handMovedTo:cursorPos])
        return;
    
    if ([_optionsButton handMovedTo:cursorPos])
        return;

    _changeInMenu = FALSE;
}

- (void)defaultConfig
{
    _changeInMenu = TRUE;
    _active = NO;
    _enableCursor = TRUE;
    _optionsButton = [[OLKScratchButton alloc] init];
    [_optionsButton setSize:NSMakeSize(240, 50)];
    _typeModeButton = [[OLKToggleButton alloc] init];
    [_typeModeButton setSize:NSMakeSize(120, 50)];
    _charSetsButton = [[OLKToggleButton alloc] init];
    [_charSetsButton setSize:NSMakeSize(120, 50)];
    _layoutButton = [[OLKToggleButton alloc] init];
    [_layoutButton setSize:NSMakeSize(120, 50)];
    [_typeModeButton setTarget:self];
    [_typeModeButton setAction:@selector(typeModeChanged:)];
    [_layoutButton setTarget:self];
    [_layoutButton setAction:@selector(layoutChanged:)];
    [_optionsButton setTarget:self];
    [_optionsButton setAction:@selector(optionsChanged:)];
    [_optionsButton setParentView:self];
    [_charSetsButton setTarget:self];
    [_charSetsButton setAction:@selector(charSetsChanged:)];
}

- (void)typeModeChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemTypingMode];
}

- (void)layoutChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemLayout];
}

- (void)optionsChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemOptions];
}

- (void)charSetsChanged:(id)sender
{
    if (_delegate)
        [_delegate menuItemChangedValue:LeapMenuItemCharSets];
}

- (void)drawMenuInImage
{
    NSRect bounds = [self bounds];
    _menuImage = [[NSImage alloc] initWithSize:[self bounds].size];
    [_menuImage lockFocus];
    [_charSetsButton draw:@"Show Other Characters" at:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/4))];
    [_typeModeButton draw:@"Finger Mode" at:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/4)-100)];
    [_layoutButton draw:@"Split Mode" at:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/4)-200)];
    [_optionsButton draw:@"Options" at:NSMakePoint(bounds.origin.x+bounds.size.width/2 - [_optionsButton size].width/2, bounds.size.height-(bounds.size.width/4)-300)];
    [_menuImage unlockFocus];
}

- (void)drawMenu
{
    if (_changeInMenu)
    {
        [self drawMenuInImage];
        _changeInMenu = FALSE;
    }
    else if ([_optionsButton activated])
    {
        [_menuImage lockFocus];
        [[NSColor clearColor] set];
        NSRect bounds = [self bounds];
        NSRect clearAreaRect;
        clearAreaRect.origin = NSMakePoint(0, bounds.size.height-(bounds.size.width/4)-300);
        clearAreaRect.size.width = 320;
        clearAreaRect.size.height = 50;
        NSRectFill(clearAreaRect);
        [_optionsButton draw:@"Options" at:NSMakePoint(bounds.origin.x+bounds.size.width/2 - [_optionsButton size].width/2, bounds.size.height-(bounds.size.width/4)-300)];
        [_menuImage unlockFocus];
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
