//
//  OLKSliderButton.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-21.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKToggleButton.h"

@implementation OLKToggleButton
{
    NSImage *_onButtonImg;
    NSImage *_offButtonImg;
    NSImage *_switcherOnImg;
    NSImage *_switcherOffImg;
    BOOL _sliding;
    BOOL _requiresReset;
}

@synthesize on = _on;
@synthesize controllingHandView = _controllingHandView;
@synthesize alpha = _alpha;
@synthesize switcherPosition = _switcherPosition;

- (id)init
{
    if (self = [super init])
    {
        _alpha = 1.0;
        _switcherPosition = 1;
        _sliding = NO;
        _requiresReset = NO;
    }
    return self;
}

- (void)createButtonImages
{
    NSColor *offColor = [NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.4 alpha:1];
    NSColor *onColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1];
    NSBezierPath *switcher = [[NSBezierPath alloc] init];
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);
    switcherRect.size.height = self.size.height/1.4;
    switcherRect.size.width = switcherRect.size.height;
    
    _switcherOnImg = [[NSImage alloc] initWithSize:switcherRect.size];
    [_switcherOnImg lockFocus];
    
    [switcher appendBezierPathWithOvalInRect:switcherRect];
    [onColor set] ;
    [switcher fill];
    [_switcherOnImg unlockFocus];

    _switcherOffImg = [[NSImage alloc] initWithSize:switcherRect.size];
    [_switcherOffImg lockFocus];
    
    [offColor set] ;
    [switcher fill];
    [_switcherOffImg unlockFocus];

    NSSize catcherSize;
    catcherSize.height = self.size.height;
    catcherSize.width = self.size.height;
    
    _onButtonImg = [[NSImage alloc] initWithSize:catcherSize];
    [_onButtonImg lockFocus];
    
    NSBezierPath *path = [[NSBezierPath alloc] init];
    NSRect pathRect;
    pathRect.size = catcherSize;
    pathRect.size.width -=4;
    pathRect.size.height -=4;
    pathRect.origin.x = 2;
    pathRect.origin.y = 2;
    [path appendBezierPathWithOvalInRect:pathRect];
    [onColor set] ;
    [path setLineWidth:4];
    [path stroke];
    [_onButtonImg unlockFocus];    

    _offButtonImg = [[NSImage alloc] initWithSize:catcherSize];
    [_offButtonImg lockFocus];
    
    [offColor set] ;
    [path stroke];
    [_offButtonImg unlockFocus];
}

- (void)setSize:(NSSize)size
{
    [super setSize:size];
    [self createButtonImages];
}

- (float)switcherOnRestOffsetXPos
{
    return ([_onButtonImg size].width - [_switcherOnImg size].width)/2;
}

- (float)switcherOffRestOffsetXPos
{
    return self.size.width - _offButtonImg.size.width + [self switcherOnRestOffsetXPos];
}

- (float)switcherRestYOffsetPos
{
    return self.size.height*0.15;
}

- (void)draw
{
    NSPoint location = self.drawLocation;
    NSPoint drawLocation = self.drawLocation;
    
    if (!self.visible)
        return;
    
    float currentAlpha = _alpha;
    
    if (!self.active)
        currentAlpha /= 2;

    NSRect buttonRect;
    buttonRect.origin = NSMakePoint(0, 0);
    buttonRect.size = [_onButtonImg size];
    [_onButtonImg drawAtPoint:drawLocation fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
    
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);

    if (_on)
    {
        NSPoint drawPoint;
        switcherRect.size = [_switcherOnImg size];
        if (_sliding)
            drawPoint.x = _switcherPosition;
        else
            drawPoint.x = drawLocation.x + [self switcherOnRestOffsetXPos];
        
        drawPoint.y = drawLocation.y + [self switcherRestYOffsetPos];
        [_switcherOnImg drawAtPoint:drawPoint fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }

    drawLocation.x += [self switcherOffRestOffsetXPos];
    NSPoint savePos = drawLocation;
    drawLocation.y += [self switcherRestYOffsetPos];

    if (!_on)
    {
        NSPoint adjPos;
        if (_sliding)
            adjPos.x = _switcherPosition;
        else
            adjPos.x = drawLocation.x;
        adjPos.y = drawLocation.y;
        switcherRect.size = [_switcherOffImg size];
        [_switcherOffImg drawAtPoint:adjPos fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }

    buttonRect.size = [_offButtonImg size];
    savePos.x -= (buttonRect.size.width - switcherRect.size.width)/2;
    [_offButtonImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];

    drawLocation.x += switcherRect.origin.x + switcherRect.size.width + switcherRect.size.width/4;
    drawLocation.y += self.size.height/25;
    
    NSRect labelRect;
    labelRect.size.width = 500;
    labelRect.size.height = 35;
    labelRect.origin.x = location.x - 20 - labelRect.size.width;
    labelRect.origin.y = drawLocation.y;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSRightTextAlignment];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:25], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, [NSNumber numberWithFloat:-18.0], NSStrokeWidthAttributeName, [NSColor whiteColor], NSStrokeColorAttributeName, nil];
    [self.label drawInRect:labelRect withAttributes:attributes];
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:25], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    [self.label drawInRect:labelRect withAttributes:attributes];
//    [label drawAtPoint:drawLocation withAttributes:attributes];
    self.needsRedraw = NO;
}

- (BOOL)resetFromEnable:(NSPoint)position
{
    if (position.x > self.drawLocation.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width + 40)
        return TRUE;
    if (position.x < self.drawLocation.x - 40)
        return TRUE;
    if ([self escapeInY:position])
        return TRUE;

    return FALSE;
}

- (BOOL)resetFromDisable:(NSPoint)position
{
    if (position.x > self.drawLocation.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width + 40)
        return TRUE;
    if (position.x < self.drawLocation.x - 40)
        return TRUE;
    if ([self escapeInY:position])
        return TRUE;
    
    return FALSE;
}

- (BOOL)escapeInY:(NSPoint)position
{
    if (position.y < self.drawLocation.y-self.size.height*0.35 || position.y > self.drawLocation.y+self.size.height+self.size.height*0.35)
        return TRUE;
    
    return FALSE;
}

- (BOOL)handMovedTo:(NSPoint)position
{
    if (!self.active)
        return FALSE;
    NSPoint location = self.drawLocation;
    
    if (!_sliding && !_requiresReset && (position.x < location.x || position.x > self.size.width+location.x || position.y < location.y || position.y > location.y + self.size.height))
    {
        _sliding = NO;
        _requiresReset = NO;
        return FALSE;
    }
    
    if (_sliding)
    {
        if (_on)
        {
            if ([self escapeInY:position])
                _sliding = NO;
            else if (position.x > location.x + self.size.width*0.75)
            {
                _requiresReset = YES;
                _on = FALSE;
                if (self.target)
                    [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
                _sliding = NO;
            }
            else if (position.x < location.x+[self switcherOnRestOffsetXPos])
            {
                if (position.x < location.x - self.size.width*0.35)
                    _sliding = NO;
                position.x = location.x + [self switcherOnRestOffsetXPos];
            }
        }
        else
        {
            if ([self escapeInY:position])
                _sliding = NO;
            else if (position.x < location.x + self.size.width*0.25)
            {
                _requiresReset = YES;
                _on = TRUE;
                if (self.target)
                    [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
                _sliding = NO;
            }
            else if (position.x > location.x + [self switcherOffRestOffsetXPos])
            {
                if (position.x > location.x+self.size.width+self.size.width*0.35)
                    _sliding = NO;
                position.x = location.x + [self switcherOffRestOffsetXPos];
            }
        }
    }
    else if (_on)
    {
        if (_requiresReset)
        {
            if ([self resetFromEnable:position])
                _requiresReset = NO;
        }
        else if (position.x < location.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width + 20 && position.x > location.x - 20)
        {
            if (position.x < location.x + [self switcherOnRestOffsetXPos])
                position.x = location.x + [self switcherOnRestOffsetXPos];
            _sliding = YES;
        }
    }
    else
    {
        if (_requiresReset)
        {
            if ([self resetFromDisable:position])
                _requiresReset = NO;
        }
        else if (position.x < location.x + self.size.width + 20 && position.x > location.x + [self switcherOffRestOffsetXPos] - 20)
        {
            _sliding = YES;
            if (position.x > location.x + [self switcherOffRestOffsetXPos])
                position.x = location.x + [self switcherOffRestOffsetXPos];
        }
    }
    _switcherPosition = position.x;
    
    return TRUE;
}


- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    [super setCursorTracking:cursorPos withHandView:handView];
    
    if (_controllingHandView && _controllingHandView != handView)
        return;
    
    if (![self handMovedTo:cursorPos])
    {
        if (_controllingHandView)
            _controllingHandView = nil;
        return;
    }
    if (!_controllingHandView)
        _controllingHandView = handView;
    
    self.needsRedraw = TRUE;
    NSRect buttonRect;
    buttonRect.size = [self size];
    buttonRect.origin = cursorPos;
    [self.parentView setNeedsDisplayInRect:buttonRect];
}

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView
{
    [super removeCursorTracking:handView];
    
    if (_controllingHandView && _controllingHandView == handView)
    {
        _controllingHandView = nil;
    }
}

- (void)removeAllCursorTracking
{
    _controllingHandView = nil;
}

@end
