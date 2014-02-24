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
    NSImage *_intButtonHoverImg;
    NSImage *_intButtonOffImg;
    NSImage *_intButtonOnImg;
    NSImage *_intButtonActivatedImg;
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
@synthesize showBorder = _showBorder;
@synthesize borderColor = _borderColor;

- (id)init
{
    if (self = [super init])
    {
        _offColor = [NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.4 alpha:1];
        _onColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1];
        _hoverColor = [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.8 alpha:1];
        _borderColor = [NSColor blackColor];
        
        _alpha = 1.0;
        _activated = NO;
        _requiresReset = NO;
        _activateAlpha = 0;
        _activated = NO;
        _useResetEscape = NO;
        _showBorder = NO;
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
    copyOfSelf.borderColor = _borderColor;
    copyOfSelf.showBorder = _showBorder;
    copyOfSelf.useResetEscape = _useResetEscape;
    copyOfSelf.togglesState = _togglesState;
    copyOfSelf.on = _on;
    copyOfSelf.buttonActivatedImg = _buttonActivatedImg;
    copyOfSelf.buttonHoverImg = _buttonHoverImg;
    copyOfSelf.buttonOffImg = _buttonOffImg;
    copyOfSelf.buttonOnImg = _buttonOnImg;
    [copyOfSelf createButtonImages];
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
    if (_buttonHoverImg)
    {
        _intButtonHoverImg = [[NSImage alloc] initWithSize:size];
        [_intButtonHoverImg lockFocus];
        NSRect sourceRect;
        sourceRect.origin = NSZeroPoint;
        sourceRect.size = _buttonHoverImg.size;
        NSRect destRect;
        destRect.size = size;
        destRect.origin = NSZeroPoint;
        [_buttonHoverImg drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
        [_intButtonHoverImg unlockFocus];
    }
    else
        _intButtonHoverImg = nil;

    if (_buttonActivatedImg)
    {
        _intButtonActivatedImg = [[NSImage alloc] initWithSize:size];
        [_intButtonActivatedImg lockFocus];
        NSRect sourceRect;
        sourceRect.origin = NSZeroPoint;
        sourceRect.size = _buttonActivatedImg.size;
        NSRect destRect;
        destRect.size = size;
        destRect.origin = NSZeroPoint;
        [_buttonActivatedImg drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
        [_intButtonActivatedImg unlockFocus];
    }
    else
        _intButtonActivatedImg = nil;
    
    if (_buttonOnImg)
    {
        _intButtonOnImg = [[NSImage alloc] initWithSize:size];
        [_intButtonOnImg lockFocus];
        NSRect sourceRect;
        sourceRect.origin = NSZeroPoint;
        sourceRect.size = _buttonOnImg.size;
        NSRect destRect;
        destRect.size = size;
        destRect.origin = NSZeroPoint;
        [_buttonOnImg drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
        [_intButtonOnImg unlockFocus];
    }
    else
        _intButtonOnImg = nil;
    
    if (_buttonOffImg)
    {
        _intButtonOffImg = [[NSImage alloc] initWithSize:size];
        [_intButtonOffImg lockFocus];
        NSRect sourceRect;
        sourceRect.origin = NSZeroPoint;
        sourceRect.size = _buttonOffImg.size;
        NSRect destRect;
        destRect.size = size;
        destRect.origin = NSZeroPoint;
        [_buttonOffImg drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
        [_intButtonOffImg unlockFocus];
    }
    else
        _intButtonOffImg = nil;
}

- (void)setSize:(NSSize)size
{
    if (NSEqualSizes(size, self.size))
        return;
    
    [super setSize:size];
    
    [self createButtonImages];
    [self softReset];
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
        currentAlpha *= 2.0/3.0;
   
    NSImage *bottomImg = nil;
    if (_on || (_hovering && !_hoverTimeToActivate))
    {
        bottomImg = _intButtonOnImg;
        curColor = _onColor;
    }
    else if (_hovering)
    {
        bottomImg = _intButtonHoverImg;
        curColor = _hoverColor;
    }
    else
    {
        bottomImg = _intButtonOffImg;
        curColor = _offColor;
    }

    NSRect buttonRect;
    buttonRect.origin = self.drawLocation;
    buttonRect.size = self.size;
    
    if (bottomImg)
    {
        NSRect sourceRect;
        sourceRect.origin = NSZeroPoint;
        sourceRect.size = bottomImg.size;
        [bottomImg drawInRect:buttonRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:currentAlpha];
    }
    else
    {
        if (curColor)
        {
            [[curColor colorWithAlphaComponent:currentAlpha] set];
            NSRectFill(buttonRect);
        }
        if (_showBorder && _borderColor)
        {
            NSBezierPath *buttonPath = [[NSBezierPath alloc] init];
            [buttonPath appendBezierPathWithRect:buttonRect];
            [[_borderColor colorWithAlphaComponent:currentAlpha] set];
            [buttonPath stroke];
        }
    }
    
    if (_activated && !_togglesState)
    {
        if (_intButtonActivatedImg)
        {
            NSRect sourceRect;
            sourceRect.origin = NSZeroPoint;
            sourceRect.size = _intButtonActivatedImg.size;
            [_intButtonActivatedImg drawInRect:buttonRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:currentAlpha];
        }
        else
        {
            [[_onColor colorWithAlphaComponent:_activateAlpha] set];
            NSRectFillUsingOperation(buttonRect, NSCompositeSourceOver);
        }
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

- (void)softReset
{
    if (_useResetEscape)
        _requiresReset = YES;
    else
        _requiresReset = NO;
    _hovering = NO;
    _hoveringSince = nil;
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

    [self softReset];
    
    if (!_togglesState)
        [self initAnimateOnActivate];
    if (self.target)
        [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
}

- (BOOL)detectCompletion:(NSPoint)position
{
    if (_requiresReset)
        return NO;
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
    {
        if (_requiresReset)
            return TRUE;
        return FALSE;
    }
    
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
        {
            _requiresReset = NO;
            return FALSE;
        }
        return TRUE;
    }
    _hovering = [self detectHoverInitiate:position];
    
    if (_hovering)
        return [self handleHovering:position];
    
    return _hovering;
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    if (_controllingHandView && _controllingHandView != handView)
        return;
    
    cursorPos = [self convertCusorPos:cursorPos fromHandView:handView];

    // Check whether the button was just added and a cursor is already in it, so we do not want to trigger
    OLKCursorTracking *cursorTracking = [self.cursorTrackings objectForKey:handView];
    if (!cursorTracking)
    {
        if ([self inHotZone:cursorPos])
            return;
        [super setCursorTracking:cursorPos withHandView:handView];
    }
    
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
    [super removeCursorTracking:handView];
    if (_controllingHandView && _controllingHandView == handView)
        [self reset];
}

- (void)removeAllCursorTracking
{
    [super removeAllCursorTracking];
    [self reset];
}

@end
