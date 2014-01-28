//
//  OLKScratchButtonShell.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-15.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKScratchButtonShell.h"

static float const OLKScratchButtonDefaultAlphaFadeOutAmtPerCycle = 0.1;

@implementation OLKScratchButtonShell
{
    NSDate *_activatedTime;
    NSTimer *_animateTimer;
    float _activateAlpha;
    BOOL _activated;
    float _pauseActivateFrames;
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
@synthesize on = _on;
@synthesize togglesState = _togglesState;
@synthesize catcherOnImg = _catcherOnImg;
@synthesize catcherOffImg = _catcherOffImg;
@synthesize catcherHalfImg = _catcherHalfImg;
@synthesize switcherOnImg = _switcherOnImg;
@synthesize switcherOffImg = _switcherOffImg;
@synthesize switcherHalfImg = _switcherHalfImg;
@synthesize sliding = _sliding;
@synthesize halfway = _halfway;
@synthesize requiresReset = _requiresReset;
@synthesize useResetEscape = _useResetEscape;

- (id)init
{
    if (self = [super init])
    {
        _offColor = [NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.4 alpha:1];
        _onColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1];
        _halfColor = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.4 alpha:1];
        
        _alpha = 1.0;
        _sliding = NO;
        _activated = NO;
        _halfway = NO;
        _requiresReset = NO;
        _activateAlpha = 0;
        _activated = NO;
        _useResetEscape = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OLKScratchButtonShell *copyOfSelf = [super copyWithZone:zone];
    copyOfSelf.catcherOnImg = _catcherOnImg;
    copyOfSelf.catcherOffImg = _catcherOffImg;
    copyOfSelf.catcherHalfImg = _catcherHalfImg;
    copyOfSelf.switcherOnImg = _switcherOnImg;
    copyOfSelf.switcherOffImg = _switcherOffImg;
    copyOfSelf.switcherHalfImg = _switcherHalfImg;
    copyOfSelf.requiresReset = _requiresReset;
    copyOfSelf.alpha = _alpha;
    copyOfSelf.escapeZone = _escapeZone;
    copyOfSelf.outerHotZone = _outerHotZone;
    copyOfSelf.resetEscapeZone = _resetEscapeZone;
    copyOfSelf.innerHotZone = _innerHotZone;
    copyOfSelf.onColor = _onColor;
    copyOfSelf.offColor = _offColor;
    copyOfSelf.halfColor = _halfColor;
    copyOfSelf.useResetEscape = _useResetEscape;
    copyOfSelf.togglesState = _togglesState;
    copyOfSelf.on = _on;
    return copyOfSelf;
}

- (void)initAnimateOnActivate
{
    _pauseActivateFrames = 15;
    _activated = YES;
    _activatedTime = [NSDate date];
    _activateAlpha = 1;
    _animateTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(animateActivate:) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    [runLoop addTimer:_animateTimer forMode:NSDefaultRunLoopMode];
}

- (void)animateActivate:(NSTimer *)timer
{
    if (_pauseActivateFrames>0)
    {
        _pauseActivateFrames --;
        return;
    }
    _activateAlpha -= OLKScratchButtonDefaultAlphaFadeOutAmtPerCycle;
    if (_activateAlpha <= 0)
    {
        _activated = NO;
        [timer invalidate];
    }
    
    if (self.parentView)
    {
        NSRect redrawRect;
        redrawRect.size = _catcherOnImg.size;
        redrawRect.origin = [self beginCatcherDrawPosition];
        
        [self.parentView setNeedsDisplayInRect:redrawRect];
    }
}

- (NSPoint)beginCatcherDrawPosition
{
    return NSZeroPoint;
}

- (NSPoint)halfwayCatcherDrawPosition
{
    return NSZeroPoint;
}

- (NSRect)halfwayCatcherDrawRect
{
    NSRect halfwayDrawRect = self.halfwayCatcherRect;
    NSPoint halfwayPos = self.halfwayCatcherDrawPosition;
    halfwayDrawRect.origin.x += halfwayPos.x;
    halfwayDrawRect.origin.y += halfwayPos.y;
    
    return halfwayDrawRect;
}

- (NSRect)beginCatcherDrawRect
{
    NSRect beginDrawRect = self.beginCatcherRect;
    NSPoint beginPos = self.beginCatcherDrawPosition;
    beginDrawRect.origin.x += beginPos.x;
    beginDrawRect.origin.y += beginPos.y;
    
    return beginDrawRect;
}

- (NSRect)beginCatcherRect
{
    NSRect buttonRect;
    buttonRect.origin = NSMakePoint(0, 0);
    buttonRect.size = [self.catcherOnImg size];
    return buttonRect;
}

- (NSRect)halfwayCatcherRect
{
    NSRect buttonRect;
    buttonRect.origin = NSMakePoint(0, 0);
    buttonRect.size = [self.catcherHalfImg size];
    return buttonRect;
}

- (NSRect)beginSwitcherRect
{
    NSRect switcherRect;
    switcherRect.origin = NSZeroPoint;
    switcherRect.size = _switcherOnImg.size;
    return switcherRect;
}

- (NSRect)halfwaySwitcherRect
{
    NSRect switcherRect;
    switcherRect.origin = NSZeroPoint;
    switcherRect.size = _switcherHalfImg.size;
    return switcherRect;
}

- (void)createButtonImages
{
    NSSize size = [self size];
    NSBezierPath *switcher = [[NSBezierPath alloc] init];
    NSRect switcherRect;
    switcherRect.origin = NSMakePoint(0, 0);
    if (size.height > size.width)
    {
        switcherRect.size.width = size.width/1.4;
        switcherRect.size.height = switcherRect.size.width;
    }
    else
    {
        switcherRect.size.height = size.height/1.4;
        switcherRect.size.width = switcherRect.size.height;
    }
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
    if (size.height > size.width)
    {
        catcherSize.height = size.width;
        catcherSize.width = size.width;
    }
    else
    {
        catcherSize.height = size.height;
        catcherSize.width = size.height;
    }
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

- (void)setSize:(NSSize)size
{
    if (NSEqualSizes(size, self.size))
        return;
    
    [super setSize:size];
    
    [self createButtonImages];
    [self reset];
    [self prepareLabelImage];
}

- (void)clear
{
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(self.drawLocation.x, self.drawLocation.y, self.size.width, self.size.height));
}

- (NSPoint)switcherDrawPosition
{
    NSPoint switcherLocation = _switcherPosition;
    switcherLocation.x += self.drawLocation.x;
    switcherLocation.y += self.drawLocation.y;
    return switcherLocation;
}

- (void)draw
{
    if (!self.visible)
        return;
    
    float currentAlpha = _alpha;
    
    if (!self.active)
        currentAlpha /= 2;
    
    if ([self shouldDrawHalfwayCatcher])
        [_catcherHalfImg drawAtPoint:[self halfwayCatcherDrawPosition] fromRect:[self halfwayCatcherRect] operation:NSCompositeSourceOver fraction:1];
    
    BOOL drawCatcher = [self shouldDrawBeginCatcher];
    NSRect buttonRect = [self beginCatcherRect];

    NSRect switcherRect = [self beginSwitcherRect];

    NSPoint switcherLocation = [self switcherDrawPosition];
    
    
    if (_halfway)
    {
        if (drawCatcher)
        {
            if (!_togglesState || !_on)
                [_catcherOnImg drawAtPoint:[self beginCatcherDrawPosition] fromRect:buttonRect operation:NSCompositeSourceOver fraction:1];
            else
                [_catcherOffImg drawAtPoint:[self beginCatcherDrawPosition] fromRect:buttonRect operation:NSCompositeSourceOver fraction:1];
        }
        [_switcherHalfImg drawAtPoint:switcherLocation fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }
    else if (_togglesState && _on)
    {
        if (drawCatcher)
            [_catcherOnImg drawAtPoint:[self beginCatcherDrawPosition] fromRect:buttonRect operation:NSCompositeSourceOver fraction:1];
        [_switcherOnImg drawAtPoint:switcherLocation fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }
    else
    {
        if (drawCatcher)
            [_catcherOffImg drawAtPoint:[self beginCatcherDrawPosition] fromRect:buttonRect operation:NSCompositeSourceOver fraction:1];
        [_switcherOffImg drawAtPoint:switcherLocation fromRect:switcherRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }
    if (_activated && !_togglesState)
    {
        if (drawCatcher)
            [_catcherOnImg drawAtPoint:[self beginCatcherDrawPosition] fromRect:buttonRect operation:NSCompositeSourceOver fraction:_activateAlpha];
        [_switcherOnImg drawAtPoint:switcherLocation fromRect:switcherRect operation:NSCompositeSourceOver fraction:_activateAlpha];
    }
    [super draw];
    self.needsRedraw=NO;
}

- (BOOL)shouldDrawBeginCatcher
{
    return YES;
}

- (BOOL)shouldDrawHalfwayCatcher
{
    return YES;
}

- (void)resetSwitcherToBeginPosition
{
    
}

- (void)reset
{
    _requiresReset = NO;
    _halfway = NO;
    _sliding = NO;
    _controllingHandView = nil;
    [self resetSwitcherToBeginPosition];
}

- (BOOL)inSlideInitiateZone:(NSPoint)position
{
    return NO;
}

- (BOOL)inHotZone:(NSPoint)position
{
    if (position.x < - _outerHotZone.width)
        return NO;
    
    if (position.x > self.size.width+_outerHotZone.width)
        return NO;
    
    if (position.y < -_outerHotZone.height)
        return NO;
    
    if (position.y > self.size.height+_outerHotZone.height)
        return NO;
    
    return YES;
}

- (BOOL)escapedResetZone:(NSPoint)position
{
    if (position.x < - _resetEscapeZone.width)
        return YES;
    
    if (position.x > self.size.width+_resetEscapeZone.width)
        return YES;
    
    if (position.y < -_resetEscapeZone.height)
        return YES;
    
    if (position.y > self.size.height+_resetEscapeZone.height)
        return YES;
    
    return NO;
}

- (BOOL)escapedHotZone:(NSPoint)position
{
    if (position.x < - _escapeZone.width)
        return YES;
    
    if (position.x > self.size.width+_escapeZone.width)
        return YES;
    
    if (position.y < -_escapeZone.height)
        return YES;
    
    if (position.y > + self.size.height+_escapeZone.height)
        return YES;
    
    return NO;
}

- (NSPoint)containSwitcherMovementToHalfway:(NSPoint)position
{
    return position;
}

- (NSPoint)containSwitcherMovementToBegin:(NSPoint)position
{
    return position;
}

- (NSImage *)beginCatcher
{
    if (!_togglesState || !_on)
        return _catcherOffImg;
    return _catcherOnImg;
}

- (NSImage *)endCatcher
{
    if (!_togglesState || !_on)
        return _catcherOnImg;
    return _catcherOffImg;
}

- (void)triggerCompleted
{
    if (_togglesState)
        _on = !_on;

    [self reset];
    if (_useResetEscape)
        _requiresReset = TRUE;
    
    if (!_togglesState)
        [self initAnimateOnActivate];
    if (self.target)
        [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
}

- (BOOL)detectCompletion:(NSPoint)position
{
    return FALSE;
}

- (void)updateSwitcherPosition:(NSPoint)position
{
}

- (BOOL)positionReachedHalfwayHotzone:(NSPoint)position
{
    return NO;
}

- (NSPoint)halfwayCheckAndUpdate:(NSPoint)position
{
    if ([self positionReachedHalfwayHotzone:position])
        _halfway = YES;
    position = [self containSwitcherMovementToBegin:position];
    
    return position;
}

- (BOOL)handleSliding:(NSPoint)position
{
    if ([self escapedHotZone:position])
    {
        [self reset];
        [self requestRedraw];
        return FALSE;
    }
    if (_halfway)
    {
        if  ([self detectCompletion:position])
             return FALSE;
        
        position = [self containSwitcherMovementToHalfway:position];
    }
    else
        position = [self halfwayCheckAndUpdate:position];
    
    [self updateSwitcherPosition:position];
    
    return TRUE;
}

- (BOOL)detectSlideInitiate:(NSPoint)position
{
    if (![self inSlideInitiateZone:position])
        return NO;
    
    _sliding = YES;
    position = [self containSwitcherMovementToBegin:position];
    [self updateSwitcherPosition:position];
    return YES;
}

// Returns whether the hand context relating to the position is in control of the control, allowing us
// to stop other hands from affecting the control until it is otherwise so.
- (BOOL)cursorMovedTo:(NSPoint)position
{
    if (!self.active)
        return FALSE;
    
    if (_requiresReset)
    {
        if ([self escapedResetZone:position])
        {
            _requiresReset = NO;
            return FALSE;
        }
        
        return TRUE;
    }
    
    if (_sliding)
        return [self handleSliding:position];
    
    return [self detectSlideInitiate:position];
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    if (_controllingHandView && _controllingHandView != handView)
        return;
    
    cursorPos = [self convertCusorPos:cursorPos fromHandView:handView];
    
    if (![self cursorMovedTo:cursorPos])
    {
        if (_controllingHandView)
            _controllingHandView = nil;
        return;
    }
    
    if (!_controllingHandView)
        _controllingHandView = handView;
    
    [self requestRedraw];
}

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView
{
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
