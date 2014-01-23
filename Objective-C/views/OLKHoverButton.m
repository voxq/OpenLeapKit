//
//  OLKScratchButtonShell.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-15.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKHoverButton.h"

static float const OLKHoverButtonDefaultAlphaFadeOutAmtPerCycle = 0.1;

@implementation OLKHoverButton
{
    NSDate *_activatedTime;
    NSTimer *_animateTimer;
    float _activateAlpha;
    BOOL _activated;
    float _pauseActivateFrames;
}

@synthesize buttonHoverImg = _buttonHoverImg;
@synthesize buttonOffImg = _buttonOffImg;
@synthesize buttonOnImg = _buttonOnImg;
@synthesize buttonActivatedImg = _buttonActivatedImg;
@synthesize hoverTimeToActivate = _hoverTimeToActivate;
@synthesize hoveringSince = _hoveringSince;
@synthesize controllingHandView = _controllingHandView;
@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize activated = _activated;
@synthesize alpha = _alpha;
@synthesize outerHotZone = _outerHotZone;
@synthesize escapeZone = _escapeZone;
@synthesize resetEscapeZone = _resetEscapeZone;
@synthesize onColor = _onColor;
@synthesize offColor = _offColor;
@synthesize on = _on;
@synthesize togglesState = _togglesState;
@synthesize hovering = _hovering;
@synthesize requiresReset = _requiresReset;
@synthesize useResetEscape = _useResetEscape;

- (id)init
{
    if (self = [super init])
    {
        _offColor = [NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.4 alpha:1];
        _onColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1];
        _hoverColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.8 alpha:1];
        
        _alpha = 1.0;
        _activated = NO;
        _requiresReset = NO;
        _activateAlpha = 0;
        _activated = NO;
        _useResetEscape = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OLKHoverButton *copyOfSelf = [super copyWithZone:zone];
    copyOfSelf.requiresReset = _requiresReset;
    copyOfSelf.alpha = _alpha;
    copyOfSelf.escapeZone = _escapeZone;
    copyOfSelf.outerHotZone = _outerHotZone;
    copyOfSelf.resetEscapeZone = _resetEscapeZone;
    copyOfSelf.onColor = _onColor;
    copyOfSelf.offColor = _offColor;
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
    _activateAlpha -= OLKHoverButtonDefaultAlphaFadeOutAmtPerCycle;
    if (_activateAlpha <= 0)
    {
        _activated = NO;
        [timer invalidate];
    }
    
    if (self.parentView)
    {
        NSRect redrawRect;
        redrawRect.size = self.size;
        redrawRect.origin = self.drawLocation;
        
        [self.parentView setNeedsDisplayInRect:redrawRect];
    }
}

- (void)createButtonImages
{
    NSSize size = [self size];
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

- (void)draw
{
    if (!self.visible)
        return;
    
    float currentAlpha = _alpha;
    NSColor *curColor;
    
    if (!self.active)
        currentAlpha /= 2;
    if (_on || (_hovering && !_hoverTimeToActivate))
        curColor = _onColor;
    else if (_hovering)
        curColor = _hoverColor;
    else
        curColor = _offColor;

    [curColor set];
    NSRect buttonRect;
    buttonRect.origin = self.drawLocation;
    buttonRect.size = self.size;
    NSRectFill(buttonRect);
    if (_activated && !_togglesState)
    {
        [[_onColor colorWithAlphaComponent:_activateAlpha] set];
        NSRectFillUsingOperation(buttonRect, NSCompositeSourceOver);
    }
    
    [super draw];
    self.needsRedraw=NO;
}

- (void)reset
{
    _requiresReset = NO;
    _hovering = NO;
    _hoveringSince = nil;
    _controllingHandView = nil;
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
    if (!_hoveringSince)
        return YES;
    
    NSTimeInterval timeHovering = [_hoveringSince timeIntervalSinceNow];
    if (-timeHovering < _hoverTimeToActivate)
        return NO;
    
    [self triggerCompleted];
    return YES;
}

- (BOOL)handleHovering:(NSPoint)position
{
    if ([self escapedHotZone:position])
    {
        [self reset];
        [self requestRedraw];
        return FALSE;
    }

    if  ([self detectCompletion:position])
         return FALSE;
    
    return TRUE;
}

- (BOOL)detectHoverInitiate:(NSPoint)position
{
    if (![self inHotZone:position])
        return NO;
    
    _hovering = YES;
    _hoveringSince = [NSDate date];

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
            _requiresReset = NO;
        
        return FALSE;
    }
    
    if (_hovering)
        return [self handleHovering:position];
    
    return [self detectHoverInitiate:position];
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