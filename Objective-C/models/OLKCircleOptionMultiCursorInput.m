//
//  OLKCircleOptionMultiCursorInput.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKCircleOptionMultiCursorInput.h"
#import "OLKRepeatTracker.h"

@interface OLKCircleOptionCursorTracking : NSObject

@property (nonatomic, weak) id cursorContext;

@property (nonatomic) BOOL requiresMoveToCenter;
@property (nonatomic) BOOL requiresMoveToInner;

@property (nonatomic) float lastUpdateCursorDistance;
@property (nonatomic) NSPoint cursorPos;

@property (nonatomic) int prevSelectedIndex;
@property (nonatomic) int selectedIndex;
@property (nonatomic) int prevHoverIndex;
@property (nonatomic) int hoverIndex;

@property (nonatomic) OLKRepeatTracker *repeatTracker;

@property (nonatomic) BOOL enableRepeatTracking;

@end


@implementation OLKCircleOptionCursorTracking

@synthesize cursorPos;
@synthesize cursorContext;
@synthesize requiresMoveToCenter = _requiresMoveToCenter;
@synthesize requiresMoveToInner = _requiresMoveToInner;
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
        _requiresMoveToInner = YES;
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

@implementation OLKCircleOptionMultiCursorInput
{
    NSDictionary *_cursorTrackings;
}

@synthesize delegate = _delegate;
@synthesize datasource = _datasource;

@synthesize superHandCursorResponder = _superHandCursorResponder;

@synthesize size = _size;
@synthesize radius = _radius;
@synthesize thresholdForPrepRestrike = _thresholdForPrepRestrike;
@synthesize thresholdForStrike = _thresholdForStrike;
@synthesize thresholdForRepeat = _thresholdForRepeat;
@synthesize thresholdForStrictReset = _thresholdForStrictReset;
@synthesize applyThresholdsAsFactors = _applyThresholdsAsFactors;

@synthesize enableRepeatTracking = _enableRepeatTracking;

@synthesize optionObjects = _optionObjects;

@synthesize useInverse = _useInverse;
@synthesize active = _active;

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
    _applyThresholdsAsFactors = YES;
    _active = YES;

    if (_useInverse)
    {
        _thresholdForRepeat = 6.0/7.0;
        _thresholdForStrike = 1;
        _thresholdForStrictReset = 1+1.0/3.0;
    }
    else
    {
        _thresholdForStrike = 6.0/7.0;
        _thresholdForRepeat = 1;
        _thresholdForStrictReset = 1.0/3.0;
    }
    _thresholdForPrepRestrike = 15;
    _radius = 1;
}

- (void)setUseInverse:(BOOL)useInverse
{
    if (useInverse != _useInverse)
    {
        float oldValue = _thresholdForRepeat;
        _thresholdForRepeat = _thresholdForStrike;
        _thresholdForStrike = oldValue;
        if (_applyThresholdsAsFactors)
        {
            if (useInverse)
                _thresholdForStrictReset = 1+_thresholdForStrictReset;
            else
                _thresholdForStrictReset = _thresholdForStrictReset-1;
        }
    }
    _useInverse = useInverse;
}

- (void)setRequiresMoveToPrepRestrikeZone:(BOOL)requiresMoveToInner cursorContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToInner:requiresMoveToInner];
}

- (void)setRequiresMoveToStrictResetZone:(BOOL)requiresMoveToCenter cursorContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToCenter:requiresMoveToCenter];
}

- (int)selectedIndex:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking selectedIndex];
}

- (int)prevSelectedIndex:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking prevSelectedIndex];
}

- (int)hoverIndex:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking hoverIndex];
}

- (int)prevHoverIndex:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    return [cursorTracking prevHoverIndex];
}

- (OLKRepeatTracker *)repeatTrackerFor:(id)cursorContext;
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    if (!cursorTracking)
        return NO;
    return cursorTracking.repeatTracker;
}

- (NSDictionary *)selectedIndexes
{
    NSMutableDictionary *selected = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumer = [_cursorTrackings keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:key];
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
        OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:key];
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
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToInner:TRUE];
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
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    [cursorTracking setEnableRepeatTracking:enableRepeatTracking];
}

- (float)angleForPosition:(NSPoint)cursorPos
{
    float oOverA = (cursorPos.y)/(cursorPos.x);
    float degree = atan(oOverA) + M_PI_2;
    degree *= (180/M_PI);
    if (cursorPos.x < 0)
        degree = 180-degree;
    else
        degree = 360 - degree;
    
    degree += 180;
    if (degree >=360)
        degree -= 360;
    
    return degree;
}

- (id)objectAtPosition:(NSPoint)position
{
    if (!_optionObjects || !_optionObjects.count)
        return nil;
    
    return [self objectAtAngle:[self angleForPosition:position]];
}

- (int)indexAtPosition:(NSPoint)position
{
    return [self indexAtAngle:[self angleForPosition:position]];
}

- (id)objectAtAngle:(float)degree
{
    int index = [self indexAtAngle:degree];
    return [self objectAtIndex:index];
}

- (int)indexAtAngle:(float)degree
{
    float arcAngleOffset = (360.0 / (float)[_optionObjects count]);
    float pos = degree + arcAngleOffset/2;
    if (pos > 359)
        pos -= 360;
    pos /= arcAngleOffset;
    return (int)pos;
}

- (NSString *)objectAtIndex:(int)index
{
    return [_optionObjects objectAtIndex:index];
}

- (BOOL)distanceInRepeatZone:(float)distance
{
    if (_applyThresholdsAsFactors)
    {
        if (_useInverse)
            return (distance <= _thresholdForStrike * _radius && distance >= _thresholdForRepeat * _radius);
        
        return (distance <= _thresholdForRepeat * _radius && distance >= _thresholdForStrike * _radius);
    }
    if (_useInverse)
        return (distance <= _thresholdForStrike && distance >= _thresholdForRepeat);
    
    return (distance <= _thresholdForRepeat && distance >= _thresholdForStrike);
}

- (BOOL)distanceInPreparedToStrikeZone:(float)distance
{
    if (_applyThresholdsAsFactors)
    {
        if (_useInverse)
            return (distance > _thresholdForStrike * _radius);
        
        return (distance < _thresholdForStrike*_radius);
    }
    if (_useInverse)
        return (distance > _thresholdForStrike);
    
    return (distance < _thresholdForStrike);
}

- (BOOL)distanceReenteredPreparedToStrikeZone:(float)distance
{
    if (_applyThresholdsAsFactors)
    {
        if (_useInverse)
            return (distance > _thresholdForStrike * _radius + _thresholdForPrepRestrike);
        
        return (distance < _thresholdForStrike*_radius - _thresholdForPrepRestrike);
    }
    if (_useInverse)
        return (distance > _thresholdForStrike + _thresholdForPrepRestrike);
    
    return (distance < _thresholdForStrike - _thresholdForPrepRestrike);
}

-(BOOL)distanceInCenterZone:(float)distance
{
    if (_applyThresholdsAsFactors)
    {
        if (_useInverse)
            return (distance > _thresholdForStrictReset * _radius);
        
        return (distance < _thresholdForStrictReset*_radius);
    }
    if (_useInverse)
        return (distance > _thresholdForStrictReset);
    
    return (distance < _thresholdForStrictReset);
}

- (NSDictionary *)objectCoordinates
{
    NSMutableDictionary *coordinateObjects = [[NSMutableDictionary alloc] initWithCapacity:[_optionObjects count]];
    float arcAngleOffset = (M_PI*2 / (float)[_optionObjects count]);
    float curAngle = M_PI_2;
    
    for (id object in _optionObjects)
    {
        NSPoint coordinate;
        
        coordinate.x = cos(curAngle)*_radius;
        coordinate.y = sin(curAngle)*_radius;
        [coordinateObjects setObject:[NSValue valueWithPoint:coordinate] forKey:object];
        curAngle -= arcAngleOffset;
        if (curAngle < 0)
            curAngle += M_PI*2;
    }
    
    return [NSDictionary dictionaryWithDictionary:coordinateObjects];
}

- (NSPoint)convertToLocalCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView
{
    if (![_datasource respondsToSelector:@selector(convertToInputCursorPos:fromView:)])
        return cursorPos;
    return [_datasource convertToInputCursorPos:cursorPos fromView:handView];
}

- (OLKCircleOptionCursorTracking *)createOrGetTracking:(NSPoint)cursorPos withContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorTrackings objectForKey:cursorContext];
    if (!cursorTracking)
    {
        cursorTracking = [[OLKCircleOptionCursorTracking alloc] init];
        [cursorTracking setCursorContext:cursorContext];
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict setObject:cursorTracking forKey:cursorContext];
        [newDict addEntriesFromDictionary:_cursorTrackings];
        _cursorTrackings = [NSDictionary dictionaryWithDictionary:newDict];
        [cursorTracking setEnableRepeatTracking:[self enableRepeatTracking]];
    }
    [cursorTracking setCursorPos:cursorPos];
    return cursorTracking;
}

- (BOOL)handleRepeatTracking:(OLKCircleOptionCursorTracking *)cursorTracking index:(int)index withCursorContext:(id)cursorContext
{
    OLKRepeatTracker *repeatTracker = cursorTracking.repeatTracker;
    
    if (!repeatTracker || ![repeatTracker isRepeating])
        return FALSE;
    
    if ([self distanceInRepeatZone:cursorTracking.lastUpdateCursorDistance])
    {
        if ([repeatTracker detectRepeatOfObject:[NSNumber numberWithInt:index]])
        {
            if ([_delegate respondsToSelector:@selector(repeatTriggered:sender:cursorContext:)])
                [_delegate repeatTriggered:index sender:self cursorContext:cursorContext];
        }
        return TRUE;
    }

    [repeatTracker setIsRepeating:NO];
    if ([_delegate respondsToSelector:@selector(repeatEnded:sender:cursorContext:)])
        [_delegate repeatEnded:index sender:self cursorContext:cursorContext];

    return FALSE;
}

- (void)handlePreparedToStrike:(OLKCircleOptionCursorTracking *)cursorTracking index:(int)index cursorContext:(id)cursorContext
{
    if (cursorTracking.requiresMoveToInner && [self distanceReenteredPreparedToStrikeZone:cursorTracking.lastUpdateCursorDistance])
    {
        [cursorTracking setRequiresMoveToInner:NO];
        if ([_delegate respondsToSelector:@selector(cursorMovedToPrepRestrikeZone:cursorContext:)])
            [_delegate cursorMovedToPrepRestrikeZone:self cursorContext:cursorContext];
    }
    
    if (cursorTracking.requiresMoveToCenter && [self distanceInCenterZone:cursorTracking.lastUpdateCursorDistance])
    {
        [cursorTracking setRequiresMoveToCenter:NO];
        if ([_delegate respondsToSelector:@selector(cursorMovedToStrictResetZone:cursorContext:)])
            [_delegate cursorMovedToStrictResetZone:self cursorContext:cursorContext];
    }
    
    if ([cursorTracking hoverIndex] != index)
    {
        [cursorTracking setPrevHoverIndex:cursorTracking.hoverIndex];
        [cursorTracking setHoverIndex:index];
        if ([_delegate respondsToSelector:@selector(hoverIndexChanged:sender:cursorContext:)])
            [_delegate hoverIndexChanged:index sender:self cursorContext:cursorContext];
    }
    if ([cursorTracking selectedIndex] != OLKOptionMultiInputInvalidSelection)
    {
        [cursorTracking setPrevSelectedIndex:cursorTracking.selectedIndex];
        [cursorTracking setSelectedIndex:OLKOptionMultiInputInvalidSelection];
        if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:cursorContext:)])
            [_delegate selectedIndexChanged:OLKOptionMultiInputInvalidSelection sender:self cursorContext:cursorContext];
    }
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [self createOrGetTracking:cursorPos withContext:cursorContext];
    
    int index = [self indexAtPosition:cursorPos];
    
    [cursorTracking setLastUpdateCursorDistance:sqrtf(cursorPos.x*cursorPos.x + cursorPos.y*cursorPos.y)];

    if ([self handleRepeatTracking:cursorTracking index:index withCursorContext:cursorContext])
        return;
    
    if ([self distanceInPreparedToStrikeZone:cursorTracking.lastUpdateCursorDistance])
    {
        [self handlePreparedToStrike:cursorTracking index:index cursorContext:cursorContext];
        return;
    }
    
    if (cursorTracking.requiresMoveToInner)
        return;
    
    [cursorTracking setRequiresMoveToInner:YES];
    [cursorTracking setPrevSelectedIndex:cursorTracking.selectedIndex];
    [cursorTracking setSelectedIndex:index];
    
    if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:cursorContext:)])
        [_delegate selectedIndexChanged:index sender:self cursorContext:cursorContext];
    
    if (cursorTracking.repeatTracker)
        [cursorTracking.repeatTracker initRepeatWithObject:[NSNumber numberWithInt:index]];
}

- (NSArray *)cursorPositions
{
    NSMutableArray *cursorPositions = [[NSMutableArray alloc] initWithCapacity:[_cursorTrackings count]];

    NSEnumerator *enumer = [_cursorTrackings objectEnumerator];
    OLKCircleOptionCursorTracking *cursorTracking = [enumer nextObject];
    while (cursorTracking)
    {
        [cursorPositions addObject:[NSValue valueWithPoint:[cursorTracking cursorPos]]];
        cursorTracking = [enumer nextObject];
    }
    return [NSArray arrayWithArray:cursorPositions];
}

@end
