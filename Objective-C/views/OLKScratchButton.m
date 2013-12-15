//
//  OLKSliderControl.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-27.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKScratchButton.h"

static float const OLKScratchButtonDefaultOuterHotZoneWidth = 30;
static float const OLKScratchButtonDefaultOuterHotZoneHeight = 15;
static float const OLKScratchButtonDefaultEscapeZoneWidth = 100;
static float const OLKScratchButtonDefaultEscapeZoneHeight = 60;
static float const OLKScratchButtonDefaultResetEscapeZoneWidth = 100;
static float const OLKScratchButtonDefaultResetEscapeZoneHeight = 40;
static float const OLKScratchButtonDefaultAlphaFadeOutAmtPerCycle = 0.1;

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

@synthesize controllingHandView = _controllingHandView;
@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize activated = _activated;
@synthesize alpha = _alpha;
@synthesize switcherPosition = _switcherPosition;
@synthesize outerHotZone = _outerHotZone;
@synthesize escapeZone = _escapeZone;
@synthesize innerHotZone = _innerHotZone;
@synthesize resetEscapeZone = _resetEscapeZone;
@synthesize onColor = _onColor;
@synthesize offColor = _offColor;
@synthesize halfColor = _halfColor;
@synthesize initiateBothSides = _initiateBothSides;
@synthesize verticalOrient = _verticalOrient;

- (id)init
{
    if (self = [super init])
    {
        _offColor = [NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.4 alpha:1];
        _onColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1];
        _halfColor = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.4 alpha:1];
        
        _pauseActivateFrames = 0;
        _activateAlpha = 0;
        _alpha = 1.0;
        _switcherPosition = 0;
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
        _activateAlpha -= OLKScratchButtonDefaultAlphaFadeOutAmtPerCycle;
        if (_activateAlpha <= 0)
        {
            _activated = NO;
            [timer invalidate];
        }
        
        if (self.parentView)
            [self.parentView setNeedsDisplay:YES];
    }
}

- (void)createButtonImages
{
    NSSize size = [self size];
    NSBezierPath *switcher = [[NSBezierPath alloc] init];
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);
    switcherRect.size.height = size.height/1.4;
    switcherRect.size.width = switcherRect.size.height;
    
    _switcherOnImg = [[NSImage alloc] initWithSize:switcherRect.size];
    [_switcherOnImg lockFocus];
    
    [switcher appendBezierPathWithOvalInRect:switcherRect];
    [_onColor set] ;
    [switcher fill];
    [_switcherOnImg unlockFocus];
    
    _switcherOffImg = [[NSImage alloc] initWithSize:switcherRect.size];
    [_switcherOffImg lockFocus];
    
    [_offColor set] ;
    [switcher fill];
    [_switcherOffImg unlockFocus];
    
    _switcherHalfImg = [[NSImage alloc] initWithSize:switcherRect.size];
    [_switcherHalfImg lockFocus];
    
    [_halfColor set] ;
    [switcher fill];
    [_switcherHalfImg unlockFocus];
    
    NSSize catcherSize;
    catcherSize.height = size.height;
    catcherSize.width = size.height;
    
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
    [_onColor set] ;
    [path setLineWidth:4];
    [path stroke];
    [_catcherOnImg unlockFocus];
    
    _catcherOffImg = [[NSImage alloc] initWithSize:catcherSize];
    [_catcherOffImg lockFocus];
    
    [_offColor set] ;
    [path stroke];
    [_catcherOffImg unlockFocus];
    
    _catcherHalfImg = [[NSImage alloc] initWithSize:catcherSize];
    [_catcherHalfImg lockFocus];
    
    [_halfColor set] ;
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
    [super setSize:size];
    
    [self createButtonImages];
    if (!_outerHotZoneSet)
    {
        _outerHotZone.width = OLKScratchButtonDefaultOuterHotZoneWidth;
        _outerHotZone.height = OLKScratchButtonDefaultOuterHotZoneHeight;
    }
    if (!_escapeZoneSet)
    {
        _escapeZone.width = OLKScratchButtonDefaultEscapeZoneWidth;
        _escapeZone.height = OLKScratchButtonDefaultEscapeZoneHeight;
    }
    if (!_resetEscapeZoneSet)
    {
        _resetEscapeZone.width = OLKScratchButtonDefaultResetEscapeZoneWidth;
        _resetEscapeZone.height = OLKScratchButtonDefaultResetEscapeZoneHeight;
    }
    if (!_innerHotZoneSet)
        _innerHotZone = [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width*2;

}

- (float)switcherOnRestOffsetXPos
{
    return ([_catcherOnImg size].width - [_switcherOnImg size].width)/2;
}

- (float)switcherOffRestOffsetXPos
{
    return self.size.width - self.size.width/4;
}

- (float)switcherRestYOffsetPos
{
    return self.size.height*0.15;
}

- (void)clear
{
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(self.drawLocation.x, self.drawLocation.y, self.size.width, self.size.height));
}

- (void)drawLabel
{
    
}

- (void)draw
{
    if (!self.visible)
        return;
    
    float currentAlpha = _alpha;
    
    if (!self.active)
        currentAlpha /= 2;
    
    NSRect buttonRect;
    buttonRect.origin = NSMakePoint(0, 0);
    buttonRect.size = [_catcherOnImg size];
    
    NSPoint elementDrawLocation = self.drawLocation;
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
    elementDrawLocation.y += self.size.height/25;
    
    NSRect labelRect;
    labelRect.size.width = 500;
    labelRect.size.height = 35;
    labelRect.origin.x = self.drawLocation.x - 20 - labelRect.size.width;
    labelRect.origin.y = elementDrawLocation.y;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSRightTextAlignment];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:25], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, [NSNumber numberWithFloat:-18.0], NSStrokeWidthAttributeName, [NSColor whiteColor], NSStrokeColorAttributeName, nil];
    [self.label drawInRect:labelRect withAttributes:attributes];
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:25], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    [self.label drawInRect:labelRect withAttributes:attributes];
    self.needsRedraw = FALSE;
}

- (void)reset
{
    if (_activated)
    {
        _activated = NO;
        [_animateTimer invalidate];
        _animateTimer = nil;
    }
    _requiresReset = NO;
    _halfway = NO;
    _activated = NO;
    _activatedTime = nil;
    _sliding = NO;
    _switcherPosition = [self switcherOffRestOffsetXPos];
    _controllingHandView = nil;
}

- (BOOL)detectReset:(NSPoint)position
{
    if (position.x > self.drawLocation.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width + _resetEscapeZone.width)
        return TRUE;
    if (position.x < self.drawLocation.x - _resetEscapeZone.width)
        return TRUE;
    if (position.y < self.drawLocation.y-_resetEscapeZone.height || position.y > self.drawLocation.y+self.size.height+_resetEscapeZone.height)
        return TRUE;
    
    return FALSE;
}

- (BOOL)escapeInY:(NSPoint)position
{
    if (position.y < self.drawLocation.y-_escapeZone.height || position.y > self.drawLocation.y+self.size.height+_escapeZone.height)
        return TRUE;
    
    return FALSE;
}

- (BOOL)inHotZoneX:(NSPoint)position
{
    if (position.x <= self.drawLocation.x + self.size.width + _outerHotZone.width && position.x > self.drawLocation.x + [self switcherOffRestOffsetXPos] - _innerHotZone)
        return YES;
    return NO;
}

- (BOOL)inSlideInitiateZone:(NSPoint)position
{
    if (position.x < self.drawLocation.x + [self switcherOffRestOffsetXPos] - _outerHotZone.width)
        return NO;
    if (position.x > self.drawLocation.x + self.size.width + _outerHotZone.width)
        return NO;
    
    return YES;
}

- (BOOL)inHotZone:(NSPoint)position
{
    if (position.x < self.drawLocation.x - _outerHotZone.width)
        return NO;
    
    if (position.x > self.size.width+self.drawLocation.x+_outerHotZone.width)
        return NO;
    
    if (position.y < self.drawLocation.y-_outerHotZone.height)
        return NO;
    
    if (position.y > self.drawLocation.y + self.size.height+_outerHotZone.height)
        return NO;
    
    return YES;
}

- (BOOL)escapedResetZone:(NSPoint)position
{
    if (position.x < self.drawLocation.x - _resetEscapeZone.width)
        return YES;
    
    if (position.x > self.size.width+self.drawLocation.x+_resetEscapeZone.width)
        return YES;
    
    if (position.y < self.drawLocation.y-_resetEscapeZone.height)
        return YES;
    
    if (position.y > self.drawLocation.y + self.size.height+_resetEscapeZone.height)
        return YES;
    
    return NO;
}

- (BOOL)escapedHotZone:(NSPoint)position
{
    if (position.x < self.drawLocation.x - _escapeZone.width)
        return YES;
    
    if (position.x > self.size.width+self.drawLocation.x+_escapeZone.width)
        return YES;
    
    if (position.y < self.drawLocation.y-_escapeZone.height)
        return YES;
    
    if (position.y > self.drawLocation.y + self.size.height+_escapeZone.height)
        return YES;
    
    return NO;
}

- (float)rightBoundForPos
{
    return self.drawLocation.x + [self switcherOffRestOffsetXPos] + [_switcherOffImg size].width/2;
}

// Returns whether the hand context relating to the position is in control of the control, allowing us
// to stop other hands from affecting the control until it is otherwise so.
- (BOOL)handMovedTo:(NSPoint)position
{
    if (!self.active)
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
            if (self.parentView)
                [self.parentView setNeedsDisplay:YES];
            return TRUE;
        }
        if (_halfway)
        {
            if (position.x > self.drawLocation.x + self.size.width-_innerHotZone)
            {
                [self reset];
                _activated = YES;
                _activatedTime = [NSDate date];
                [self initAnimateOnActivate];
                if (self.target)
                    [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
                return FALSE;
            }
            else if (position.x < self.drawLocation.x+[self switcherOnRestOffsetXPos] + [_switcherOnImg size].width/2)
                position.x = self.drawLocation.x + [self switcherOnRestOffsetXPos] + [_switcherOnImg size].width/2;
        }
        else
        {
            if (position.x < self.drawLocation.x + _innerHotZone)
            {
                _halfway = YES;
                if (self.parentView)
                    [self.parentView setNeedsDisplay:YES];
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
        [self reset];
    }
}

- (void)removeAllCursorTracking
{
    _controllingHandView = nil;
    [self reset];
}

@end
