//
//  OLKSliderControl.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-27.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKScratchButton.h"

@implementation OLKScratchButton
{
    NSImage *_catcherOnImg;
    NSImage *_catcherOffImg;
    NSImage *_catcherHalfImg;
    NSImage *_switcherOnImg;
    NSImage *_switcherOffImg;
    NSImage *_switcherHalfImg;
    BOOL _requiresReset;
    BOOL _sliding;
    BOOL _halfway;
    NSDate *_activatedTime;
    NSTimer *_animateTimer;
    float _activateAlpha;
    float _pauseActivateFrames;
    BOOL _outerHotZoneSet;
    BOOL _innerHotZoneSet;
    BOOL _escapeZoneSet;
    BOOL _resetEscapeZoneSet;
}

@synthesize identifier = _identifier;
@synthesize active = _active;
@synthesize activated = _activated;
@synthesize visible = _visible;
@synthesize size = _size;
@synthesize alpha = _alpha;
@synthesize switcherPosition = _switcherPosition;
@synthesize target = _target;
@synthesize action = _action;
@synthesize parentView = _parentView;
@synthesize enable = _enable;
@synthesize label = _label;
@synthesize drawLocation = _drawLocation;
@synthesize outerHotZone = _outerHotZone;
@synthesize escapeZone = _escapeZone;
@synthesize innerHotZone = _innerHotZone;
@synthesize resetEscapeZone = _resetEscapeZone;

- (id)init
{
    if (self = [super init])
    {
        _pauseActivateFrames = 0;
        _activateAlpha = 0;
        _alpha = 1.0;
        _switcherPosition = 0;
        _visible = YES;
        _active = YES;
        _sliding = NO;
        _activated = NO;
        _halfway = NO;
        _requiresReset = NO;
        _outerHotZoneSet = NO;
        _innerHotZoneSet = NO;
        _resetEscapeZoneSet = NO;
        _escapeZoneSet = NO;
    }
    return self;
}

- (void)initAnimateOnActivate
{
    _pauseActivateFrames = 0;
    _activateAlpha = 1;
    _animateTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(animateActivate:) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    [runLoop addTimer:_animateTimer forMode:NSDefaultRunLoopMode];
}

- (void)animateActivate:(NSTimer *)timer
{
    if (_pauseActivateFrames>0)
        _pauseActivateFrames --;
    else
    {
        _activateAlpha -= 0.1;
        if (_activateAlpha <= 0)
        {
            _activated = NO;
            [timer invalidate];
        }
        
        if (_parentView)
            [_parentView setNeedsDisplay:YES];
    }
}

- (void)createButtonImages
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

- (void)setOuterHotZone:(NSSize)outerHotZone
{
    if (!_outerHotZoneSet)
        _outerHotZoneSet = YES;
    
    _outerHotZone = outerHotZone;
}

- (void)setInnerHotZone:(float)innerHotZone
{
    if (!_innerHotZoneSet)
        _innerHotZoneSet = YES;
    
    _innerHotZone = innerHotZone;
}

- (void)setResetEscapeZone:(NSSize)resetEscapeZone
{
    if (!_resetEscapeZoneSet)
        _resetEscapeZoneSet = YES;

    _resetEscapeZone = resetEscapeZone;
}

- (void)setEscapeZone:(NSSize)escapeZone
{
    if (!_escapeZoneSet)
        _escapeZoneSet = YES;
    
    _escapeZone = escapeZone;
}

- (void)setSize:(NSSize)size
{
    _size = size;
    [self createButtonImages];
    if (!_outerHotZoneSet)
    {
        _outerHotZone.width = 30;
        _outerHotZone.height = 15;
    }
    if (!_escapeZoneSet)
    {
        _escapeZone.width = 100;
        _escapeZone.height = 60;
    }
    if (!_resetEscapeZoneSet)
    {
        _resetEscapeZone.width = 100;
        _resetEscapeZone.height = 40;
    }
    if (!_innerHotZoneSet)
        _innerHotZone = [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width*2;

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

- (void)clear
{
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(_drawLocation.x, _drawLocation.y, _size.width, _size.height));
}

- (void)draw
{
    if (!_visible)
        return;
    
    float currentAlpha = _alpha;
    
    if (!_active)
        currentAlpha /= 2;
    
    NSRect buttonRect;
    buttonRect.origin = NSMakePoint(0, 0);
    buttonRect.size = [_catcherOnImg size];
    
    NSPoint elementDrawLocation = _drawLocation;
    [_catcherHalfImg drawAtPoint:elementDrawLocation fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
    
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);
    
    if (_halfway)
    {
        NSPoint drawPoint;
        switcherRect.size = [_switcherOnImg size];
        if (_sliding)
            drawPoint.x = _switcherPosition;
        else
            drawPoint.x = elementDrawLocation.x + [self switcherOnRestOffsetXPos];
        
        drawPoint.y = elementDrawLocation.y + [self switcherRestYOffsetPos];
         [_switcherHalfImg drawAtPoint:drawPoint fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }

    elementDrawLocation.x += [self switcherOffRestOffsetXPos];
    NSPoint savePos = elementDrawLocation;
    elementDrawLocation.y += [self switcherRestYOffsetPos];
    
    if (!_halfway)
    {
        NSPoint adjPos;
        if (_sliding)
            adjPos.x = _switcherPosition;
        else
            adjPos.x = elementDrawLocation.x;
        adjPos.y = elementDrawLocation.y;
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
        if (!_halfway || !_pauseActivateFrames)
            [_catcherOffImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
        if (_activated)
            [_catcherOnImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha*_activateAlpha];
        else if (_halfway)
            [_catcherOnImg drawAtPoint:savePos fromRect:buttonRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }

    
    elementDrawLocation.x += switcherRect.origin.x + switcherRect.size.width + switcherRect.size.width/4;
    elementDrawLocation.y += _size.height/25;
    
    NSRect labelRect;
    labelRect.size.width = 500;
    labelRect.size.height = 35;
    labelRect.origin.x = _drawLocation.x - 20 - labelRect.size.width;
    labelRect.origin.y = elementDrawLocation.y;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSRightTextAlignment];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:25], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    [_label drawInRect:labelRect withAttributes:attributes];
}

- (BOOL)detectReset:(NSPoint)position
{
    if (position.x > _drawLocation.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width + _resetEscapeZone.width)
        return TRUE;
    if (position.x < _drawLocation.x - _resetEscapeZone.width)
        return TRUE;
    if (position.y < _drawLocation.y-_resetEscapeZone.height || position.y > _drawLocation.y+_size.height+_resetEscapeZone.height)
        return TRUE;
    
    return FALSE;
}

- (BOOL)escapeInY:(NSPoint)position
{
    if (position.y < _drawLocation.y-_escapeZone.height || position.y > _drawLocation.y+_size.height+_escapeZone.height)
        return TRUE;
    
    return FALSE;
}

- (BOOL)inHotZoneX:(NSPoint)position
{
    if (position.x <= _drawLocation.x + _size.width + _outerHotZone.width && position.x > _drawLocation.x + [self switcherOffRestOffsetXPos] - _innerHotZone)
        return YES;
    return NO;
}

- (BOOL)inSlideInitiateZone:(NSPoint)position
{
    if (position.x < _drawLocation.x + [self switcherOffRestOffsetXPos] - _outerHotZone.width)
        return NO;
    if (position.x > _drawLocation.x + _size.width + _outerHotZone.width)
        return NO;
    
    return YES;
}

- (BOOL)inHotZone:(NSPoint)position
{
    if (position.x < _drawLocation.x - _outerHotZone.width)
        return NO;
    
    if (position.x > _size.width+_drawLocation.x+_outerHotZone.width)
        return NO;
    
    if (position.y < _drawLocation.y-_outerHotZone.height)
        return NO;
    
    if (position.y > _drawLocation.y + _size.height+_outerHotZone.height)
        return NO;
    
    return YES;
}

- (BOOL)escapedResetZone:(NSPoint)position
{
    if (position.x < _drawLocation.x - _resetEscapeZone.width)
        return YES;
    
    if (position.x > _size.width+_drawLocation.x+_resetEscapeZone.width)
        return YES;
    
    if (position.y < _drawLocation.y-_resetEscapeZone.height)
        return YES;
    
    if (position.y > _drawLocation.y + _size.height+_resetEscapeZone.height)
        return YES;
    
    return NO;
}

- (BOOL)escapedHotZone:(NSPoint)position
{
    if (position.x < _drawLocation.x - _escapeZone.width)
        return YES;
    
    if (position.x > _size.width+_drawLocation.x+_escapeZone.width)
        return YES;
    
    if (position.y < _drawLocation.y-_escapeZone.height)
        return YES;
    
    if (position.y > _drawLocation.y + _size.height+_escapeZone.height)
        return YES;
    
    return NO;
}

- (float)rightBoundForPos
{
    return _drawLocation.x + [self switcherOffRestOffsetXPos] + [_switcherOffImg size].width/2;
}

- (BOOL)handMovedTo:(NSPoint)position
{
    if (!_active)
        return FALSE;
    
    if (_requiresReset)
    {
        if ([self detectReset:position])
            _requiresReset = NO;
        
        return FALSE;
    }

    if (!_sliding && ![self inHotZone:position])
        return FALSE;
    
    if (_sliding)
    {
        if ([self escapedHotZone:position])
        {
            _switcherPosition = [self switcherOffRestOffsetXPos];
            _sliding = NO;
            _halfway = NO;
            if (_parentView)
                [_parentView setNeedsDisplay:YES];
            return TRUE;
        }
        if (_halfway)
        {
            if (position.x > _drawLocation.x + _size.width-_innerHotZone)
            {
                _requiresReset = YES;
                _halfway = NO;
                _activated = YES;
                _activatedTime = [NSDate date];
                _sliding = NO;
                _switcherPosition = [self switcherOffRestOffsetXPos];
                [self initAnimateOnActivate];
                if (_target)
                    [[NSApplication sharedApplication] sendAction:_action to:_target from:self];
                return TRUE;
            }
            else if (position.x < _drawLocation.x+[self switcherOnRestOffsetXPos] + [_switcherOnImg size].width/2)
                position.x = _drawLocation.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width/2;
        }
        else
        {
            if (position.x < _drawLocation.x + _innerHotZone)
            {
                _halfway = YES;
                if (_parentView)
                    [_parentView setNeedsDisplay:YES];
            }
            else if (position.x > [self rightBoundForPos])
                position.x = [self rightBoundForPos];
        }
    }
    else if ([self inSlideInitiateZone:position])
    {
        _sliding = YES;
        if (position.x > [self rightBoundForPos])
            position.x = [self rightBoundForPos];
    }

    _switcherPosition = position.x - [_switcherOffImg size].width/2;
    
    return TRUE;
}


@end
