//
//  OLKVertScratchButton.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-16.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKVertScratchButton.h"

static float const OLKVertScratchButtonDefaultOuterHotZoneWidth = 15;
static float const OLKVertScratchButtonDefaultOuterHotZoneHeight = 30;
static float const OLKVertScratchButtonDefaultEscapeZoneWidth = 60;
static float const OLKVertScratchButtonDefaultEscapeZoneHeight = 100;
static float const OLKVertScratchButtonDefaultResetEscapeZoneWidth = 40;
static float const OLKVertScratchButtonDefaultResetEscapeZoneHeight = 100;
static float const OLKVertScratchButtonDefaultAlphaFadeOutAmtPerCycle = 0.1;


@implementation OLKVertScratchButton
{
    BOOL _innerHotZoneSet;
}

@synthesize topInit = _topInit;
@synthesize expandsOnInit = _expandsOnInit;
@synthesize expandsOutEdgePercent = _expandsOutEdgePercent;
@synthesize nonExpandedRect = _nonExpandedRect;

- (id)init
{
    if (self=[super init])
    {
        [self initControlZones];
        _expandsOutEdgePercent = 1;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OLKVertScratchButton *copyOfSelf = [super copyWithZone:zone];
    copyOfSelf.topInit = _topInit;
    copyOfSelf.expandsOnInit = _expandsOnInit;
    copyOfSelf.expandsOutEdgePercent = _expandsOutEdgePercent;
    copyOfSelf.nonExpandedRect = _nonExpandedRect;
    
    return copyOfSelf;
}

- (void)initControlZones
{
    self.outerHotZone = NSMakeSize(OLKVertScratchButtonDefaultOuterHotZoneWidth, OLKVertScratchButtonDefaultOuterHotZoneHeight);
    self.escapeZone = NSMakeSize(OLKVertScratchButtonDefaultEscapeZoneWidth, OLKVertScratchButtonDefaultEscapeZoneHeight);
    self.resetEscapeZone = NSMakeSize(OLKVertScratchButtonDefaultResetEscapeZoneWidth, OLKVertScratchButtonDefaultResetEscapeZoneHeight);
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
        self.innerHotZone = [self switcherOffsetYFromCatcher] + self.switcherOnImg.size.height*2;
    [self prepareLabelImage];
}

- (void)setTopInit:(BOOL)topInit
{
    _topInit = topInit;
    [self resetSwitcherToBeginPosition];
    if (self.autoCalcLabelRect)
        [self autoCalculateLabelRectBounds];
}

- (NSPoint)catcherTopPosition
{
    NSPoint offsetPoint;
    offsetPoint.x = 0;
    offsetPoint.y = self.size.height - self.catcherOnImg.size.height;
    return offsetPoint;
}

- (NSPoint)catcherDrawTopPosition
{
    NSPoint drawPoint = self.catcherTopPosition;
    drawPoint.x += self.drawLocation.x;
    drawPoint.y += self.drawLocation.y;
    return drawPoint;
}

- (NSPoint)catcherBottomPosition
{
    NSPoint offsetPoint;
    offsetPoint.x = 0;
    offsetPoint.y = 0;
    return offsetPoint;
}

- (NSPoint)catcherDrawBottomPosition
{
    return self.drawLocation;
}

- (NSRect)beginSwitcherRect
{
    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
        return [super beginSwitcherRect];
    
    NSRect buttonRect = [self beginCatcherRect];
    if (_topInit)
        buttonRect.size.height -= [self switcherOffsetYFromCatcher];
    else
        buttonRect.origin.y -= [self switcherOffsetYFromCatcher];

    return buttonRect;
}

- (NSRect)nonExpandedRect
{
    NSRect buttonRect;
    buttonRect.size.width = self.catcherOnImg.size.width;
    buttonRect.origin.x = 0;
    buttonRect.size.height = self.catcherOnImg.size.height*_expandsOutEdgePercent;
    if (_topInit)
        buttonRect.origin.y = 0;
    else
        buttonRect.origin.y = self.catcherOnImg.size.height - buttonRect.size.height;
    
    return buttonRect;
}

- (NSRect)beginCatcherRect
{
    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
        return [super beginCatcherRect];

    return self.nonExpandedRect;
}

- (NSPoint)beginCatcherPosition
{
    if (_topInit)
    {
        NSPoint catcherPos = self.catcherTopPosition;
        if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
            return catcherPos;
            
        catcherPos.y += self.catcherOnImg.size.height - self.catcherOnImg.size.height*_expandsOutEdgePercent;
        return catcherPos;
    }
    return self.catcherBottomPosition;
}

- (NSPoint)beginCatcherDrawPosition
{
    NSPoint catcherPos = [self beginCatcherPosition];
    catcherPos.x += self.drawLocation.x;
    catcherPos.y += self.drawLocation.y;
    return catcherPos;
}

- (NSPoint)halfwayCatcherDrawPosition
{
    if (_topInit)
        return [self catcherDrawBottomPosition];
    else
        return [self catcherDrawTopPosition];
}

- (NSPoint)switcherDrawPosition
{
    NSPoint switcherPos = [super switcherDrawPosition];
    if (!_expandsOnInit || _expandsOutEdgePercent == 1 || self.sliding)
        return switcherPos;

    if (_topInit)
        switcherPos.y += self.catcherOnImg.size.height - self.catcherOnImg.size.height*_expandsOutEdgePercent;
    else
        switcherPos.y = self.drawLocation.y;

    return switcherPos;
}

- (void)resetSwitcherToBeginPosition
{
    NSRect switcherDrawRect;
    switcherDrawRect.origin = self.switcherDrawPosition;
    switcherDrawRect.size = self.switcherOnImg.size;
    [self.parentView setNeedsDisplayInRect:switcherDrawRect];
    self.switcherPosition = NSMakePoint([self switcherXPos], [self switcherBeginYPos]);
    [self.parentView setNeedsDisplayInRect:self.halfwayCatcherDrawRect];
    [self.parentView setNeedsDisplayInRect:self.beginCatcherDrawRect];
    self.sliding = FALSE;
}

- (float)switcherOffsetYFromCatcher
{
    return ([self.catcherOnImg size].height - self.switcherOnImg.size.height)/2;
}

- (float)topSideSwitcherYPos
{
    return self.size.height - self.catcherOnImg.size.height + [self switcherOffsetYFromCatcher];
}

- (float)bottomSideSwitcherYPos
{
    return [self switcherOffsetYFromCatcher];
}

- (float)switcherHalfYPos
{
    if (_topInit)
        return [self bottomSideSwitcherYPos];
    else
        return [self topSideSwitcherYPos];
}

- (float)switcherBeginYPos
{
    if (_topInit)
        return [self topSideSwitcherYPos];
    else
        return [self bottomSideSwitcherYPos];
}

- (float)switcherXPos
{
    return (self.catcherOnImg.size.width - self.switcherOnImg.size.width)/2;
}

- (float)topSideCursorSwitcherYPos
{
    return [self topSideSwitcherYPos] +  self.switcherOnImg.size.height/2;
}

- (float)bottomSideCursorSwitcherYPos
{
    return [self bottomSideSwitcherYPos] + self.switcherOnImg.size.height/2;
}

- (float)cursorSwitcherBeginYPos
{
    if (_topInit)
        return [self topSideCursorSwitcherYPos];
    else
        return [self bottomSideCursorSwitcherYPos];
}

- (float)cursorSwitcherHalfwayYPos
{
    if (_topInit)
        return [self bottomSideCursorSwitcherYPos];
    else
        return [self topSideCursorSwitcherYPos];
}

- (BOOL)inHotZoneX:(NSPoint)position
{
    if (position.x < -self.outerHotZone.width)
        return NO;
    
    if (position.x > self.size.width+self.outerHotZone.width)
        return NO;
    
    return YES;
}

- (BOOL)inSlideInitiateZone:(NSPoint)position
{
    if (![self inHotZoneX:position])
        return NO;
    
    if (_topInit)
    {
        if (position.y < [self switcherBeginYPos] - self.outerHotZone.height)
            return NO;
        if (position.y > self.size.height + self.outerHotZone.height)
            return NO;
    }
    else
    {
        if (position.y > [self switcherBeginYPos] + self.switcherOnImg.size.height + self.outerHotZone.height)
            return NO;
        if (position.y < - self.outerHotZone.height)
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
    if (_topInit)
    {
        float bottomMaxYPos = [self bottomSideCursorSwitcherYPos];
        if (position.y < bottomMaxYPos)
            position.y = bottomMaxYPos;
    }
    else
    {
        float topMaxYPos = [self topSideCursorSwitcherYPos];
        if (position.y > topMaxYPos)
            position.y = topMaxYPos;
    }
    return position;
}

- (NSPoint)containSwitcherMovementToBegin:(NSPoint)position
{
    if (_topInit)
    {
        float topMaxYPos = [self topSideCursorSwitcherYPos];
        if (position.y > topMaxYPos)
            position.y = topMaxYPos;
    }
    else
    {
        float bottomMaxYPos = [self bottomSideCursorSwitcherYPos];
        if (position.y < bottomMaxYPos)
            position.y = bottomMaxYPos;
    }
    
    return position;
}

- (void)updateSwitcherPosition:(NSPoint)position
{
    self.switcherPosition = NSMakePoint(self.switcherXPos, position.y - self.switcherOnImg.size.height/2);
}

- (BOOL)positionReachedHalfwayHotzone:(NSPoint)position
{
    if (_topInit)
    {
        if (position.y < self.innerHotZone)
            return YES;
    }
    else
    {
        if (position.y > self.size.height - self.innerHotZone)
            return YES;
    }
    
    return NO;
}

- (BOOL)detectCompletion:(NSPoint)position
{
    if (_topInit)
    {
        if (position.y <= self.size.height-self.innerHotZone)
            return FALSE;
    }
    else if (position.y >= self.innerHotZone)
        return FALSE;
    
    [self triggerCompleted];

    return TRUE;
}

- (BOOL)shouldDrawHalfwayCatcher
{
    if (self.expandsOnInit && !self.sliding)
        return NO;
    return YES;
}

- (void)autoCalculateLabelRectBounds
{
    if (NSEqualSizes(NSZeroSize, self.size) || !self.label || ![self.label length])
        return;
    
    NSRect labelRectBounds;
    labelRectBounds.size.height = self.size.height - (self.catcherOnImg.size.height*2 + self.labelFontSize*2);
    labelRectBounds.size = [self.label boundingRectWithSize:NSMakeSize(10000, labelRectBounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.labelBackAttributes].size;

    if (_topInit)
        labelRectBounds.origin.y = self.beginCatcherPosition.y - labelRectBounds.size.height - self.labelFontSize/2;
    else
        labelRectBounds.origin.y = self.beginCatcherPosition.y + self.beginCatcherRect.size.height + self.labelFontSize/2;
    
    labelRectBounds.origin.x = self.size.width/2 - labelRectBounds.size.width/2;
    self.labelRectBounds = labelRectBounds;
}


@end
