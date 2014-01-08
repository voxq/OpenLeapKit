//
//  OLKHorizScratchButton.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-15.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKHorizScratchButton.h"

static float const OLKHorizScratchButtonDefaultOuterHotZoneWidth = 30;
static float const OLKHorizScratchButtonDefaultOuterHotZoneHeight = 15;
static float const OLKHorizScratchButtonDefaultEscapeZoneWidth = 100;
static float const OLKHorizScratchButtonDefaultEscapeZoneHeight = 60;
static float const OLKHorizScratchButtonDefaultResetEscapeZoneWidth = 100;
static float const OLKHorizScratchButtonDefaultResetEscapeZoneHeight = 40;
static float const OLKHorizScratchButtonDefaultAlphaFadeOutAmtPerCycle = 0.1;


@implementation OLKHorizScratchButton
{
    BOOL _innerHotZoneSet;
}

@synthesize rightInit = _rightInit;
@synthesize expandsOnInit = _expandsOnInit;
@synthesize expandsOutEdgePercent = _expandsOutEdgePercent;
@synthesize nonExpandedRect = _nonExpandedRect;

- (id)init
{
    if (self=[super init])
    {
        _expandsOutEdgePercent = 1;
        [self initControlZones];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OLKHorizScratchButton *copyOfSelf = [super copyWithZone:zone];
    copyOfSelf.rightInit = _rightInit;
    copyOfSelf.expandsOnInit = _expandsOnInit;
    copyOfSelf.expandsOutEdgePercent = _expandsOutEdgePercent;
    copyOfSelf.nonExpandedRect = _nonExpandedRect;
    
    return copyOfSelf;
}

- (void)setInnerHotZone:(float)innerHotZone
{
    [super setInnerHotZone:innerHotZone];
    _innerHotZoneSet = TRUE;
}

- (void)setSize:(NSSize)size
{
    [super setSize:size];
    if (!_innerHotZoneSet)
        self.innerHotZone = [self switcherOffsetXFromCatcher] + self.switcherOnImg.size.width*2;
}

- (void)setRightInit:(BOOL)rightInit
{
    _rightInit = rightInit;
    [self resetSwitcherToBeginPosition];
    if (self.autoCalcLabelRect)
        [self autoCalculateLabelRectBounds];
}

- (void)initControlZones
{
    self.outerHotZone = NSMakeSize(OLKHorizScratchButtonDefaultOuterHotZoneWidth, OLKHorizScratchButtonDefaultOuterHotZoneHeight);
    self.escapeZone = NSMakeSize(OLKHorizScratchButtonDefaultEscapeZoneWidth, OLKHorizScratchButtonDefaultEscapeZoneHeight);
    self.resetEscapeZone = NSMakeSize(OLKHorizScratchButtonDefaultResetEscapeZoneWidth, OLKHorizScratchButtonDefaultResetEscapeZoneHeight);
}

- (NSPoint)catcherRightPosition
{
    NSPoint offsetPoint;
    offsetPoint.x = self.size.width - self.catcherOnImg.size.width;
    offsetPoint.y = 0;
    return offsetPoint;
}

- (NSPoint)catcherDrawRightPosition
{
    NSPoint drawPoint = self.catcherRightPosition;
    drawPoint.x += self.drawLocation.x;
    drawPoint.y += self.drawLocation.y;
    return drawPoint;
}

- (NSPoint)catcherLeftPosition
{
    return NSZeroPoint;
}

- (NSPoint)catcherDrawLeftPosition
{
    return self.drawLocation;
}

- (NSRect)beginSwitcherRect
{
    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
        return [super beginSwitcherRect];
    
    NSRect buttonRect = [self beginCatcherRect];
    if (_rightInit)
        buttonRect.size.width -= [self switcherOffsetXFromCatcher];
    else
        buttonRect.origin.x -= [self switcherOffsetXFromCatcher];
    
    return buttonRect;
}

- (NSRect)nonExpandedRect
{
    NSRect buttonRect;
    buttonRect.size.width = self.catcherOnImg.size.width*_expandsOutEdgePercent;
    buttonRect.size.height = self.catcherOnImg.size.height;
    buttonRect.origin.y = 0;
    if (_rightInit)
        buttonRect.origin.x = 0;
    else
        buttonRect.origin.x = self.catcherOnImg.size.width - buttonRect.size.width;
    
    return buttonRect;
}

- (NSRect)beginCatcherRect
{
    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
        return [super beginCatcherRect];

    return self.nonExpandedRect;
}

- (NSPoint)beginCatcherDrawPosition
{
    if (_rightInit)
    {
        NSPoint catcherPos = [self catcherDrawRightPosition];
        if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
            return catcherPos;
        catcherPos.y += self.catcherOnImg.size.height - self.catcherOnImg.size.height*_expandsOutEdgePercent;
        return catcherPos;
    }
    NSPoint catcherPos = [self catcherDrawLeftPosition];
//    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
//        return catcherPos;
//    catcherPos.y -= self.catcherOnImg.size.height - self.catcherOnImg.size.height*_expandsOutEdgePercent;
    return catcherPos;
}

- (NSPoint)halfwayCatcherDrawPosition
{
    if (_rightInit)
        return [self catcherDrawLeftPosition];
    else
        return [self catcherDrawRightPosition];
}

- (NSPoint)switcherDrawPosition
{
    NSPoint switcherPos = [super switcherDrawPosition];
    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
        return switcherPos;
    
    if (_rightInit)
        switcherPos.x += self.catcherOnImg.size.width - self.catcherOnImg.size.width*_expandsOutEdgePercent;
    else
        switcherPos.x = self.drawLocation.x;
    
    return switcherPos;
}

- (void)resetSwitcherToBeginPosition
{
    self.switcherPosition = NSMakePoint([self switcherBeginXPos], [self switcherYPos]);
    [self.parentView setNeedsDisplayInRect:self.halfwayCatcherDrawRect];
    self.sliding = TRUE;
    [self.parentView setNeedsDisplayInRect:self.beginCatcherDrawRect];
    self.sliding = FALSE;
}

- (float)switcherOffsetXFromCatcher
{
    return ([self.catcherOnImg size].width - [self.switcherOnImg size].width)/2;
}

- (float)rightSideSwitcherXPos
{
    return self.size.width - self.catcherOnImg.size.width + [self switcherOffsetXFromCatcher];
}

- (float)leftSideSwitcherXPos
{
    return [self switcherOffsetXFromCatcher];
}

- (float)switcherHalfXPos
{
    if (_rightInit)
        return [self leftSideSwitcherXPos];
    else
        return [self rightSideSwitcherXPos];
}

- (float)switcherBeginXPos
{
    if (_rightInit)
        return [self rightSideSwitcherXPos];
    else
        return [self leftSideSwitcherXPos];
}

- (float)switcherYPos
{
    return (self.catcherOnImg.size.height - self.switcherOnImg.size.height)/2;
}

- (float)rightSideCursorSwitcherXPos
{
    return [self rightSideSwitcherXPos] +  self.switcherOnImg.size.width/2;
}

- (float)leftSideCursorSwitcherXPos
{
    return [self leftSideSwitcherXPos] + self.switcherOnImg.size.width/2;
}

- (float)cursorSwitcherBeginXPos
{
    if (_rightInit)
        return [self rightSideCursorSwitcherXPos];
    else
        return [self leftSideCursorSwitcherXPos];
}

- (float)cursorSwitcherHalfwayXPos
{
    if (_rightInit)
        return [self leftSideCursorSwitcherXPos];
    else
        return [self rightSideCursorSwitcherXPos];
}

- (BOOL)inHotZoneY:(NSPoint)position
{
    if (position.y < -self.outerHotZone.height)
        return NO;
    
    if (position.y > self.size.height+self.outerHotZone.height)
        return NO;
    
    return YES;
}

- (BOOL)inSlideInitiateZone:(NSPoint)position
{
    if (![self inHotZoneY:position])
        return NO;
    
    if (_rightInit)
    {
        if (position.x < [self switcherBeginXPos] - self.outerHotZone.width)
            return NO;
        if (position.x > self.size.width + self.outerHotZone.width)
            return NO;
    }
    else
    {
        if (position.x > [self switcherBeginXPos] + self.switcherOnImg.size.width + self.outerHotZone.width)
            return NO;
        if (position.x < - self.outerHotZone.width)
            return NO;
    }
    return YES;
}

- (BOOL)detectSlideInitiate:(NSPoint)position
{
    if (![super detectSlideInitiate:position])
        return NO;
    
    if (_expandsOnInit)
    {
        [self.parentView setNeedsDisplayInRect:self.halfwayCatcherDrawRect];
        [self.parentView setNeedsDisplayInRect:self.beginCatcherDrawRect];
    }
    
    return YES;
}

- (NSPoint)containSwitcherMovementToHalfway:(NSPoint)position
{
    if (_rightInit)
    {
        float leftMaxXPos = [self leftSideCursorSwitcherXPos];
        if (position.x < leftMaxXPos)
            position.x = leftMaxXPos;
    }
    else
    {
        float rightMaxXPos = [self rightSideCursorSwitcherXPos];
        if (position.x > rightMaxXPos)
            position.x = rightMaxXPos;
    }
    return position;
}

- (NSPoint)containSwitcherMovementToBegin:(NSPoint)position
{
    if (_rightInit)
    {
        float rightMaxXPos = [self rightSideCursorSwitcherXPos];
        if (position.x > rightMaxXPos)
            position.x = rightMaxXPos;
    }
    else
    {
        float leftMaxXPos = [self leftSideCursorSwitcherXPos];
        if (position.x < leftMaxXPos)
            position.x = leftMaxXPos;
    }
    
    return position;
}

- (void)updateSwitcherPosition:(NSPoint)position
{
    self.switcherPosition = NSMakePoint(position.x - [self.switcherOnImg size].width/2, [self switcherYPos]);
}

- (BOOL)positionReachedHalfwayHotzone:(NSPoint)position
{
    if (_rightInit)
    {
        if (position.x < self.innerHotZone)
            return YES;
    }
    else
    {
        if (position.x > self.size.width - self.innerHotZone)
            return YES;
    }
    
    return NO;
}

- (BOOL)detectCompletion:(NSPoint)position
{
    if (_rightInit)
    {
        if (position.x <= self.size.width-self.innerHotZone)
            return FALSE;
    }
    else if (position.x >= self.innerHotZone)
        return FALSE;
    
    [self triggerCompleted];
    
    return TRUE;
}

- (BOOL)shouldDrawHalfwayCatcher
{
    if (!self.sliding && _expandsOnInit)
        return NO;
    return YES;
}

- (void)autoCalculateLabelRectBounds
{
    if (NSEqualSizes(NSZeroSize, self.size) || !self.label || ![self.label length])
        return;
    
    NSRect labelRectBounds;
    labelRectBounds.size.width = self.size.width - (self.catcherOnImg.size.width*2 + self.labelFontSize*2);
    labelRectBounds.size = [self.label boundingRectWithSize:NSMakeSize(labelRectBounds.size.width, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.labelBackAttributes].size;
    
    if (_rightInit)
        labelRectBounds.origin.x = self.catcherRightPosition.x - labelRectBounds.size.width - self.labelFontSize;
    else
        labelRectBounds.origin.x = self.catcherLeftPosition.x + self.catcherOnImg.size.width + self.labelFontSize;
    
    labelRectBounds.origin.y = self.size.height/2 - labelRectBounds.size.height/2;
    
    self.labelRectBounds = labelRectBounds;
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    if (_rightInit)
        [style setAlignment:NSRightTextAlignment];
    else
        [style setAlignment:NSLeftTextAlignment];
    
    NSMutableDictionary *modifyAttrs = [NSMutableDictionary dictionaryWithDictionary:self.labelAttributes];
    [modifyAttrs setObject:style forKey:NSParagraphStyleAttributeName];
    self.labelAttributes = [NSDictionary dictionaryWithDictionary:modifyAttrs];
    
    modifyAttrs = [NSMutableDictionary dictionaryWithDictionary:self.labelBackAttributes];
    [modifyAttrs setObject:style forKey:NSParagraphStyleAttributeName];
    self.labelBackAttributes = [NSDictionary dictionaryWithDictionary:modifyAttrs];
}


@end
