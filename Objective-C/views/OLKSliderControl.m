//
//  OLKSliderControl.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-28.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKSliderControl.h"

@implementation OLKSliderControl
{
    NSImage *_catcherOnImg;
    NSImage *_catcherOffImg;
    NSImage *_catcherHalfImg;
    NSImage *_switcherOnImg;
    NSImage *_switcherOffImg;
    NSImage *_switcherHalfImg;
    NSPoint _location;
}

@synthesize identifier = _identifier;
@synthesize active = _active;
@synthesize visible = _visible;
@synthesize size = _size;
@synthesize alpha = _alpha;
@synthesize position = _position;
@synthesize target = _target;
@synthesize action = _action;
@synthesize parentView = _parentView;
@synthesize orientation = _orientation;

- (id)init
{
    if (self = [super init])
    {
        _alpha = 1.0;
        _position = 1;
        _visible = YES;
        _active = YES;
    }
    return self;
}

- (void)createControlImages
{
    NSColor *offColor = [NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.4 alpha:1];
    NSColor *onColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1];
    NSColor *halfColor = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.4 alpha:1];
    NSBezierPath *switcher = [[NSBezierPath alloc] init];
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);
    switcherRect.size.height = _size.height/1.4;
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
    
    _switcherHalfImg = [[NSImage alloc] initWithSize:switcherRect.size];
    [_switcherHalfImg lockFocus];
    
    [halfColor set] ;
    [switcher fill];
    [_switcherHalfImg unlockFocus];
    
    NSSize catcherSize;
    catcherSize.height = _size.height;
    catcherSize.width = _size.height;
    
    _catcherOnImg = [[NSImage alloc] initWithSize:catcherSize];
    [_catcherOnImg lockFocus];
    
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
    [_catcherOnImg unlockFocus];
    
    _catcherOffImg = [[NSImage alloc] initWithSize:catcherSize];
    [_catcherOffImg lockFocus];
    
    [offColor set] ;
    [path stroke];
    [_catcherOffImg unlockFocus];
    
    _catcherHalfImg = [[NSImage alloc] initWithSize:catcherSize];
    [_catcherHalfImg lockFocus];
    
    [halfColor set] ;
    [path stroke];
    [_catcherHalfImg unlockFocus];
}

- (void)setSize:(NSSize)size
{
    _size = size;
    [self createControlImages];
}

- (void)onFrame:(NSNotification *)notification
{
    
}

- (float)switcherOnRestOffsetXPos
{
    return ([_catcherOnImg size].width - [_switcherOnImg size].width)/2;
}

- (float)switcherOffRestOffsetXPos
{
    return _size.width - _size.width/4;
}

- (float)switcherRestYOffsetPos
{
    return _size.height*0.15;
}

- (void)draw:(NSString *)label at:(NSPoint)drawLocation
{
    _location = drawLocation;
    
    if (!_visible)
        return;
    
    float currentAlpha = _alpha;
    
    if (!_active)
        currentAlpha /= 2;
    
    NSRect buttonRect;
    buttonRect.origin = NSMakePoint(0, 0);
    buttonRect.size = [_catcherOnImg size];
    [_catcherHalfImg drawAtPoint:drawLocation fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
    
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);
    
    if (_halfway)
    {
        NSPoint drawPoint;
        switcherRect.size = [_switcherOnImg size];
        if (_sliding)
            drawPoint.x = _switcherPosition;
        else
            drawPoint.x = drawLocation.x + [self switcherOnRestOffsetXPos];
        
        drawPoint.y = drawLocation.y + [self switcherRestYOffsetPos];
        [_switcherHalfImg drawAtPoint:drawPoint fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }
    
    drawLocation.x += [self switcherOffRestOffsetXPos];
    NSPoint savePos = drawLocation;
    drawLocation.y += [self switcherRestYOffsetPos];
    
    if (!_halfway)
    {
        NSPoint adjPos;
        if (_sliding)
            adjPos.x = _switcherPosition;
        else
            adjPos.x = drawLocation.x;
        adjPos.y = drawLocation.y;
        switcherRect.size = [_switcherOffImg size];
        if (_sliding)
            [_switcherOffImg drawAtPoint:adjPos fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
        else
        {
            if (!_activated || !_pauseActivateFrames)
                [_switcherOffImg drawAtPoint:adjPos fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
            if (_activated)
                [_switcherOnImg drawAtPoint:adjPos fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha*_activateAlpha];
        }
    }
    
    if (!_halfway && !_activated)
        buttonRect.size = [_catcherOffImg size];
    else
        buttonRect.size = [_catcherOnImg size];
    
    savePos.x -= (buttonRect.size.width - switcherRect.size.width)/2;
    if (!_halfway && !_activated)
        [_catcherOffImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
    else
    {
        if (!_activated || !_pauseActivateFrames)
            [_catcherOffImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
        if (_activated)
            [_catcherOnImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha*_activateAlpha];
        else if (_halfway)
            [_catcherOnImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }
    
    
    drawLocation.x += switcherRect.origin.x + switcherRect.size.width + switcherRect.size.width/4;
    drawLocation.y += _size.height/25;
    
    NSRect labelRect;
    labelRect.size.width = 500;
    labelRect.size.height = 35;
    labelRect.origin.x = _location.x - 20 - labelRect.size.width;
    labelRect.origin.y = drawLocation.y;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSRightTextAlignment];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:25], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    [label drawInRect:labelRect withAttributes:attributes];
    //    [label drawAtPoint:drawLocation withAttributes:attributes];
}

- (BOOL)detectReset:(NSPoint)position
{
    if (position.x > _location.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width + 40)
        return TRUE;
    if (position.x < _location.x - 40)
        return TRUE;
    if ([self escapeInY:position])
        return TRUE;
    
    return FALSE;
}

- (BOOL)escapeInY:(NSPoint)position
{
    if (position.y < _location.y-_size.height*0.35 || position.y > _location.y+_size.height+_size.height*0.35)
        return TRUE;
    
    return FALSE;
}

- (BOOL)handMovedTo:(NSPoint)position
{
    
    if (!_sliding && !_requiresReset && (position.x < _location.x || position.x > _size.width+_location.x || position.y < _location.y || position.y > _location.y + _size.height))
    {
        _sliding = NO;
        _requiresReset = NO;
        return FALSE;
    }
    
    if (_sliding)
    {
        if (_halfway)
        {
            if ([self escapeInY:position])
            {
                if (_parentView)
                    [_parentView setNeedsDisplay:YES];
                _sliding = NO;
            }
            else if (position.x > _location.x + _size.width*0.75)
            {
                _requiresReset = YES;
                _halfway = NO;
                _activated = YES;
                _activatedTime = [NSDate date];
                [self initAnimateOnActivate];
                if (_target)
                    [[NSApplication sharedApplication] sendAction:_action to:_target from:self];
                _sliding = NO;
            }
            else if (position.x < _location.x+[self switcherOnRestOffsetXPos])
            {
                if (position.x < _location.x - _size.width*0.25)
                {
                    if (_parentView)
                        [_parentView setNeedsDisplay:YES];
                    _sliding = NO;
                }
                position.x = _location.x + [self switcherOnRestOffsetXPos];
            }
        }
        else
        {
            if ([self escapeInY:position])
            {
                if (_parentView)
                    [_parentView setNeedsDisplay:YES];
                _sliding = NO;
            }
            else if (position.x < _location.x + [_catcherHalfImg size].width)
            {
                _requiresReset = YES;
                _halfway = YES;
            }
            else if (position.x > _location.x + [self switcherOffRestOffsetXPos])
            {
                if (position.x > _location.x+_size.width+_size.width*0.25)
                {
                    if (_parentView)
                        [_parentView setNeedsDisplay:YES];
                    _sliding = NO;
                }
                position.x = _location.x + [self switcherOffRestOffsetXPos];
            }
        }
    }
    else if (_requiresReset)
    {
        if ([self detectReset:position])
            _requiresReset = NO;
    }
    else if (position.x < _location.x + _size.width + 20 && position.x > _location.x + [self switcherOffRestOffsetXPos] - 20)
    {
        _sliding = YES;
        if (position.x > _location.x + [self switcherOffRestOffsetXPos])
            position.x = _location.x + [self switcherOffRestOffsetXPos];
    }
    if (!_sliding)
    {
        _halfway = NO;
    }
    _switcherPosition = position.x;
    
    return TRUE;
}


@end
