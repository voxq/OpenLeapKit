//
//  OLKLineOptionMultiCursorInput.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-10.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import "OLKLineOptionMultiCursorInput.h"
#import <OpenLeapKit/OLKGeometryHelper.h>

@interface OLKLineOptionCursorTracking : NSObject

@property (nonatomic, weak) id cursorContext;

@property (nonatomic) BOOL requiresMoveToStrictResetZone;
@property (nonatomic) BOOL requiresMoveToPrepRestrikeZone;

@property (nonatomic) float lastUpdateCursorDistance;
@property (nonatomic) NSPoint cursorPos;

@property (nonatomic) int prevSelectedIndex;
@property (nonatomic) int selectedIndex;
@property (nonatomic) int prevHoverIndex;
@property (nonatomic) int hoverIndex;

@property (nonatomic) OLKRepeatTracker *repeatTracker;

@property (nonatomic) BOOL enableRepeatTracking;

@end


@implementation OLKLineOptionCursorTracking

@synthesize cursorPos;
@synthesize cursorContext;
@synthesize requiresMoveToStrictResetZone = _requiresMoveToStrictResetZone;
@synthesize requiresMoveToPrepRestrikeZone = _requiresMoveToPrepRestrikeZone;
@synthesize selectedIndex = _selectedIndex;
@synthesize hoverIndex = _hoverIndex;
@synthesize prevSelectedIndex = _prevSelectedIndex;
@synthesize prevHoverIndex = _prevHoverIndex;
@synthesize repeatTracker = _repeatTracker;
@synthesize enableRepeatTracking = _enableRepeatTracking;
@synthesize lastUpdateCursorDistance = _lastUpdateCursorDistance;

- (id)init
{
    if (self = [super init])
    {
        _requiresMoveToPrepRestrikeZone = YES;
        _hoverIndex = OLKOptionMultiInputInvalidSelection;
        _selectedIndex = OLKOptionMultiInputInvalidSelection;
        _prevHoverIndex = OLKOptionMultiInputInvalidSelection;
        _prevSelectedIndex = OLKOptionMultiInputInvalidSelection;
    }
    return self;
}

- (void)setEnableRepeatTracking:(BOOL)enableRepeatTracking
{
    _enableRepeatTracking = enableRepeatTracking;
    if (enableRepeatTracking && !_repeatTracker)
        _repeatTracker = [[OLKRepeatTracker alloc] init];
}

@end

@implementation OLKLineOptionMultiCursorInput
{
    NSDictionary *_cursorTrackings;
    NSBezierPath *_rectPath;
}

@synthesize delegate = _delegate;
@synthesize datasource = _datasource;

@synthesize superHandCursorResponder = _superHandCursorResponder;

@synthesize thresholdForPrepRestrike = _thresholdForPrepRestrike;
@synthesize thresholdForStrike = _thresholdForStrike;
@synthesize thresholdForRepeat = _thresholdForRepeat;
@synthesize thresholdForStrictReset = _thresholdForStrictReset;
@synthesize applyThresholdsAsFactors = _applyThresholdsAsFactors;

@synthesize enableRepeatTracking = _enableRepeatTracking;

@synthesize optionObjects = _optionObjects;
@synthesize size = _size;
@synthesize active = _active;
@synthesize strikeSide = _strikeSide;

- (id)init
{
    if (self = [super init])
    {
        [self resetToDefaults];
        _enableRepeatTracking = FALSE;
        _cursorTrackings = [[NSDictionary alloc] init];
    }
    return self;
}

- (void)resetToDefaults
{
    _active = YES;
    _applyThresholdsAsFactors = YES;
    _thresholdForStrike = 2;
    _thresholdForRepeat = 5;
    _thresholdForStrictReset = 50;
    _thresholdForPrepRestrike = 15;
}

- (void)setRequiresMoveToPrepRestrikeZone:(BOOL)requiresMoveToPrepRestrikeZone cursorContext:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToPrepRestrikeZone:requiresMoveToPrepRestrikeZone];
}

- (void)setRequiresMoveToStrictResetZone:(BOOL)requiresMoveToStrictResetZone cursorContext:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToStrictResetZone:requiresMoveToStrictResetZone];
}

- (int)selectedIndex:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking selectedIndex];
}

- (int)prevSelectedIndex:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking prevSelectedIndex];
}

- (int)hoverIndex:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking hoverIndex];
}

- (int)prevHoverIndex:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking prevHoverIndex];
}

- (OLKRepeatTracker *)repeatTrackerFor:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    if (!cursorTracking)
        return nil;
    return cursorTracking.repeatTracker;
}

- (NSDictionary *)selectedIndexes
{
    NSMutableDictionary *selected = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumer = [_cursorTrackings keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:key];
        [selected setObject:[NSNumber numberWithInt:[cursorTracking selectedIndex]] forKey:key];
        key = [enumer nextObject];
    }
    return [NSDictionary dictionaryWithDictionary:selected];
}

- (NSDictionary *)hoverIndexes
{
    NSMutableDictionary *hovers = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumer = [_cursorTrackings keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:key];
        [hovers setObject:[NSNumber numberWithInt:[cursorTracking hoverIndex]] forKey:key];
        key = [enumer nextObject];
    }
    return [NSDictionary dictionaryWithDictionary:hovers];
}

- (void)removeFromSuperHandCursorResponder
{
    if (_superHandCursorResponder)
        [_superHandCursorResponder removeHandCursorResponder:self];
}

- (void)removeCursorTracking:(id)cursorContext
{
    [self resetCurrentCursorTracking:cursorContext];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:_cursorTrackings];
    [newDict removeObjectForKey:cursorContext];
    if ([newDict count] < [_cursorTrackings count])
        _cursorTrackings = [NSDictionary dictionaryWithDictionary:newDict];
}

- (void)resetCurrentCursorTracking:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setPrevHoverIndex:cursorTracking.hoverIndex];
    if ([cursorTracking hoverIndex] != OLKOptionMultiInputInvalidSelection)
    {
        [cursorTracking setHoverIndex:OLKOptionMultiInputInvalidSelection];
        if ([_delegate respondsToSelector:@selector(hoverIndexChanged:sender:cursorContext:)])
            [_delegate hoverIndexChanged:OLKOptionMultiInputInvalidSelection sender:self cursorContext:cursorContext];
    }
    [cursorTracking setPrevSelectedIndex:cursorTracking.selectedIndex];
    if ([cursorTracking selectedIndex] != OLKOptionMultiInputInvalidSelection)
    {
        [cursorTracking setSelectedIndex:OLKOptionMultiInputInvalidSelection];
        if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:cursorContext:)])
            [_delegate selectedIndexChanged:OLKOptionMultiInputInvalidSelection sender:self cursorContext:cursorContext];
    }
}

- (void)setRectPath
{
    _rectPath = [[NSBezierPath alloc] init];
    [_rectPath appendBezierPathWithRect:NSMakeRect(0, 0, _size.width, _size.height)];
}

- (void)setSize:(NSSize)size
{
    _size = size;
    [self setRectPath];
}

- (void)setVertical:(BOOL)vertical
{
    _vertical = vertical;
    [self setRectPath];
}

- (void)resetCurrentCursorTracking
{
    for (id key in [_cursorTrackings keyEnumerator])
        [self resetCurrentCursorTracking:key];
}

- (void)removeAllCursorTracking
{
    [self resetCurrentCursorTracking];
    _cursorTrackings = nil;
}

- (void)setEnableRepeatTracking:(BOOL)enableRepeatTracking
{
    _enableRepeatTracking = enableRepeatTracking;
}

- (void)setEnableRepeatTracking:(BOOL)enableRepeatTracking cursorContext:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setEnableRepeatTracking:enableRepeatTracking];
}

- (NSRect)optionRectAtPosition:(NSPoint)position
{
    int index = [self indexAtPosition:position];
    return [self optionRectForIndex:index];
}

- (NSRect)optionRectForIndex:(int)index
{
    NSRect optionRect;
    float optionDimension;
    
    if (_vertical)
    {
        optionDimension = _size.height/_optionObjects.count;
        optionRect.origin = NSMakePoint(0, _size.height-index*optionDimension-optionDimension);
        optionRect.size = NSMakeSize(_size.width, optionDimension);
    }
    else
    {
        optionDimension = _size.width/_optionObjects.count;
        optionRect.origin = NSMakePoint(index*optionDimension,0);
        optionRect.size = NSMakeSize(optionDimension, _size.height);
    }
    return optionRect;
}

- (int)indexAtPosition:(NSPoint)position
{
    float optionDimension;
    int index;
    if (_vertical)
    {
        optionDimension = _size.height/_optionObjects.count;
        index = position.y/optionDimension;
        index = _optionObjects.count - 1 - index;
    }
    else
    {
        optionDimension = _size.width/_optionObjects.count;
        index = position.x/optionDimension;
    }
    
    if (index < 0)
        index = 0;
    else if (index >= _optionObjects.count)
        index = _optionObjects.count-1;
    
    return index;
}

- (id)objectAtPosition:(NSPoint)position
{
    return [_optionObjects objectAtIndex:[self indexAtPosition:position]];
}

- (NSString *)objectAtIndex:(int)index
{
    return [_optionObjects objectAtIndex:index];
}

- (BOOL)inRepeatZone:(NSPoint)position index:(int)index
{
    NSRect optionRect = [self optionRectForIndex:index];
    if (position.x < optionRect.origin.x-_thresholdForRepeat || position.x > optionRect.size.width+_thresholdForRepeat)
        return FALSE;
    
    if (position.y < optionRect.origin.y-_thresholdForRepeat || position.y > optionRect.size.height+_thresholdForRepeat)
        return FALSE;
    
    return TRUE;
}

- (BOOL)inAnyRepeatZone:(NSPoint)position
{
    if (position.x < -_thresholdForStrike-_thresholdForRepeat || position.x > _size.width + _thresholdForStrike + _thresholdForRepeat)
        return FALSE;
    
    if (position.y < -_thresholdForStrike-_thresholdForRepeat || position.y > _size.height + _thresholdForStrike + _thresholdForRepeat)
        return FALSE;
    
    return TRUE;
}

- (BOOL)inPreparedToStrikeZone:(NSPoint)position
{
    if (position.x < -_thresholdForStrike || position.x > _size.width + _thresholdForStrike)
        return TRUE;

    if (position.y > _size.height+_thresholdForStrike || position.y < - _thresholdForStrike)
        return TRUE;

    return FALSE;
}

- (BOOL)reenteredPreparedToStrikeZone:(NSPoint)position
{
    if (position.x < -_thresholdForStrike-_thresholdForPrepRestrike || position.x > _size.width+_thresholdForStrike+_thresholdForPrepRestrike)
        return TRUE;
    
    if (position.y < -_thresholdForStrike-_thresholdForPrepRestrike || position.y > _size.height+_thresholdForStrike+_thresholdForPrepRestrike)
        return TRUE;
    
    return FALSE;
}

-(BOOL)inStrictResetZone:(NSPoint)position
{
    if (position.x < -_thresholdForStrictReset || position.x > _size.width+_thresholdForStrictReset)
        return TRUE;
    
    if (position.y < -_thresholdForStrictReset || position.y > _size.height+_thresholdForStrictReset)
        return TRUE;
    
    return FALSE;
}

- (NSDictionary *)objectCoordinates
{
    NSMutableDictionary *coordinateObjects = [[NSMutableDictionary alloc] initWithCapacity:[_optionObjects count]];

    int count=0;
    for (id object in _optionObjects)
    {
        NSRect optionRect = [self optionRectForIndex:count];
        NSPoint objectPos = optionRect.origin;
        objectPos.x += optionRect.size.width/2;
        objectPos.y += optionRect.size.height/2;
        [coordinateObjects setObject:[NSValue valueWithPoint:objectPos] forKey:object];
        count ++;
    }
    
    return [NSDictionary dictionaryWithDictionary:coordinateObjects];
}

- (NSPoint)convertToLocalCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView
{
    if (![_datasource respondsToSelector:@selector(convertToInputCursorPos:fromView:)])
        return cursorPos;
    return [_datasource convertToInputCursorPos:cursorPos fromView:handView];
}

- (OLKLineOptionCursorTracking *)createTracking:(NSPoint)cursorPos withContext:(id)cursorContext
{
    OLKLineOptionCursorTracking *cursorTracking = [[OLKLineOptionCursorTracking alloc] init];
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:cursorTracking forKey:cursorContext];
    [newDict addEntriesFromDictionary:_cursorTrackings];
    _cursorTrackings = [NSDictionary dictionaryWithDictionary:newDict];
    [cursorTracking setEnableRepeatTracking:[self enableRepeatTracking]];
    [cursorTracking setCursorPos:cursorPos];
    [cursorTracking setCursorContext:cursorContext];
    return cursorTracking;
}

- (NSArray *)cursorPositions
{
    NSMutableArray *cursorPositions = [[NSMutableArray alloc] initWithCapacity:[_cursorTrackings count]];
    
    NSEnumerator *enumer = [_cursorTrackings objectEnumerator];
    OLKLineOptionCursorTracking *cursorTracking = [enumer nextObject];
    while (cursorTracking)
    {
        [cursorPositions addObject:[NSValue valueWithPoint:[cursorTracking cursorPos]]];
        cursorTracking = [enumer nextObject];
    }
    return [NSArray arrayWithArray:cursorPositions];
}

- (BOOL)checkAndHandleRepeatTracking:(OLKLineOptionCursorTracking *)cursorTracking
{
    OLKRepeatTracker *repeatTracker = cursorTracking.repeatTracker;
    
    if (!repeatTracker || ![repeatTracker isRepeating])
        return FALSE;

    int repeatingIndex = [[repeatTracker repeatObject] intValue];
    if ([self inAnyRepeatZone:cursorTracking.cursorPos])
    {
        if ([self inRepeatZone:cursorTracking.cursorPos index:repeatingIndex] && [repeatTracker detectRepeatOfObject:[NSNumber numberWithInt:repeatingIndex]])
        {
            if ([_delegate respondsToSelector:@selector(repeatTriggered:sender:cursorContext:)])
                [_delegate repeatTriggered:repeatingIndex sender:self cursorContext:cursorTracking.cursorContext];
        }
        return TRUE;
    }
    [repeatTracker setIsRepeating:NO];
    if ([_delegate respondsToSelector:@selector(repeatEnded:sender:cursorContext:)])
        [_delegate repeatEnded:repeatingIndex sender:self cursorContext:cursorTracking.cursorContext];

    return FALSE;
}

- (void)handlePreparedToStrike:(OLKLineOptionCursorTracking *)cursorTracking
{
    if (cursorTracking.requiresMoveToPrepRestrikeZone && [self reenteredPreparedToStrikeZone:cursorTracking.cursorPos])
    {
        [cursorTracking setRequiresMoveToPrepRestrikeZone:NO];
        if ([_delegate respondsToSelector:@selector(cursorMovedToPrepRestrikeZone:cursorContext:)])
            [_delegate cursorMovedToPrepRestrikeZone:self cursorContext:cursorTracking.cursorContext];
    }
    
    if (cursorTracking.requiresMoveToStrictResetZone && [self inStrictResetZone:cursorTracking.cursorPos])
    {
        [cursorTracking setRequiresMoveToStrictResetZone:NO];
        if ([_delegate respondsToSelector:@selector(cursorMovedToStrictResetZone:cursorContext:)])
            [_delegate cursorMovedToStrictResetZone:self cursorContext:cursorTracking.cursorContext];
    }
}

- (int)strikeFromValidSide:(OLKLineOptionCursorTracking *)cursorTracking prevPos:(NSPoint)prevPos
{
    if (![self inPreparedToStrikeZone:prevPos])
        return OLKOptionMultiInputInvalidSelection;

    NSPoint upperLeftCorner = NSMakePoint(-_thresholdForStrike, _size.height+_thresholdForStrike);
    NSPoint lowerLeftCorner = NSMakePoint(-_thresholdForStrike, -_thresholdForStrike);
    NSPoint upperRightCorner = NSMakePoint(_size.width+_thresholdForStrike, _size.height+_thresholdForStrike);
    NSPoint lowerRightCorner = NSMakePoint(_size.width+_thresholdForStrike, -_thresholdForStrike);
    
//    BOOL passedThrough = [self inPreparedToStrikeZone:cursorTracking.cursorPos];

    if (_vertical)
    {
        if (_strikeSide == OLKOptionStrikeSideAny || _strikeSide == OLKOptionStrikeSideStarboard)
        {
            NSPoint intersectRight = [OLKGeometryHelper intersectPoint:lowerRightCorner line1Point2:upperRightCorner line2Point1:prevPos line2Point2:cursorTracking.cursorPos];
            if ([OLKGeometryHelper pointOnSegment:lowerRightCorner linePoint2:upperRightCorner checkPoint:intersectRight])
            {
                BOOL wasLeft = [OLKGeometryHelper isLeftOfLine:upperRightCorner linePoint2:lowerRightCorner checkPoint:prevPos];
                if (wasLeft && ![OLKGeometryHelper isLeftOfLine:upperRightCorner linePoint2:lowerRightCorner checkPoint:cursorTracking.cursorPos])
                    return [self indexAtPosition:intersectRight];
            }
        }
        if (_strikeSide == OLKOptionStrikeSideAny || _strikeSide == OLKOptionStrikeSidePort)
        {
            NSPoint intersectLeft = [OLKGeometryHelper intersectPoint:lowerLeftCorner line1Point2:upperLeftCorner line2Point1:prevPos line2Point2:cursorTracking.cursorPos];
            if ([OLKGeometryHelper pointOnSegment:lowerLeftCorner linePoint2:upperLeftCorner checkPoint:intersectLeft])
            {
                BOOL wasLeft = [OLKGeometryHelper isLeftOfLine:lowerLeftCorner linePoint2:upperLeftCorner checkPoint:prevPos];
                if (wasLeft && ![OLKGeometryHelper isLeftOfLine:lowerLeftCorner linePoint2:upperLeftCorner checkPoint:cursorTracking.cursorPos])
                    return [self indexAtPosition:intersectLeft];
            }
        }
    }
    else
    {
        if (_strikeSide == OLKOptionStrikeSideAny || _strikeSide == OLKOptionStrikeSideStarboard)
        {
            NSPoint intersectBottom = [OLKGeometryHelper intersectPoint:lowerLeftCorner line1Point2:lowerRightCorner line2Point1:prevPos line2Point2:cursorTracking.cursorPos];
            if ([OLKGeometryHelper pointOnSegment:lowerLeftCorner linePoint2:lowerRightCorner checkPoint:intersectBottom])
            {
                BOOL wasLeft = [OLKGeometryHelper isLeftOfLine:lowerRightCorner linePoint2:lowerLeftCorner checkPoint:prevPos];
                if (wasLeft && ![OLKGeometryHelper isLeftOfLine:lowerRightCorner linePoint2:lowerLeftCorner checkPoint:cursorTracking.cursorPos])
                    return [self indexAtPosition:intersectBottom];
            }
        }
        if (_strikeSide == OLKOptionStrikeSideAny || _strikeSide == OLKOptionStrikeSidePort)
        {
            NSPoint intersectTop = [OLKGeometryHelper intersectPoint:upperLeftCorner line1Point2:upperRightCorner line2Point1:prevPos line2Point2:cursorTracking.cursorPos];
            if ([OLKGeometryHelper pointOnSegment:upperLeftCorner linePoint2:upperRightCorner checkPoint:intersectTop])
            {
                BOOL wasLeft = [OLKGeometryHelper isLeftOfLine:upperLeftCorner linePoint2:upperRightCorner checkPoint:prevPos];
                if (wasLeft && ![OLKGeometryHelper isLeftOfLine:upperLeftCorner linePoint2:upperRightCorner checkPoint:cursorTracking.cursorPos])
                    return [self indexAtPosition:intersectTop];
            }
        }
    }
    return OLKOptionMultiInputInvalidSelection;
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)cursorContext
{
    // Check whether the button was just added and a cursor is already in it, so we do not want to trigger
    OLKLineOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    
    if (!cursorTracking)
    {
        if (![self inPreparedToStrikeZone:cursorPos])
            return;

        cursorTracking = [self createTracking:cursorPos withContext:cursorContext];
        return;
    }
    
    NSPoint prevPos = cursorTracking.cursorPos;
    
    cursorTracking.cursorPos = cursorPos;
    
    if ([self checkAndHandleRepeatTracking:cursorTracking])
        return;
    
    if (cursorTracking.requiresMoveToPrepRestrikeZone || cursorTracking.requiresMoveToStrictResetZone)
    {
        [self handlePreparedToStrike:cursorTracking];
        return;
    }
    
    int index = [self strikeFromValidSide:cursorTracking prevPos:prevPos];
    if (index == OLKOptionMultiInputInvalidSelection)
        return;
    
    cursorTracking.requiresMoveToPrepRestrikeZone = YES;
    cursorTracking.prevSelectedIndex = cursorTracking.selectedIndex;
    cursorTracking.selectedIndex = index;
    
    if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:cursorContext:)])
        [_delegate selectedIndexChanged:index sender:self cursorContext:cursorContext];
    
    if (cursorTracking.repeatTracker)
        [cursorTracking.repeatTracker initRepeatWithObject:[NSNumber numberWithInt:index]];
}



@end
