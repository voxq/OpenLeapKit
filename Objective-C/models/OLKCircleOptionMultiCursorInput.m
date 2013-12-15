//
//  OLKCircleOptionMultiCursorInput.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKCircleOptionMultiCursorInput.h"

@interface OLKCircleOptionCursorTracking : NSObject

@property (nonatomic, weak) id cursorContext;

@property (nonatomic) BOOL requiresMoveToCenter;
@property (nonatomic) BOOL requiresMoveToInner;

@property (nonatomic) float lastUpdateCursorDistance;
@property (nonatomic) NSPoint cursorPos;

@property (nonatomic) int selectedIndex;
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
@synthesize repeatTracker = _repeatTracker;
@synthesize enableRepeatTracking = _enableRepeatTracking;
@synthesize lastUpdateCursorDistance = _lastUpdateCursorDistance;

- (id)init
{
    if (self = [super init])
    {
        _requiresMoveToInner = YES;
        _hoverIndex = OLKCircleOptionMultiInputInvalidSelection;
        _selectedIndex = OLKCircleOptionMultiInputInvalidSelection;
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
    NSDictionary *_cursorContexts;
}

@synthesize delegate = _delegate;

@synthesize radius = _radius;
@synthesize thresholdForReenter = _thresholdForReenter;
@synthesize thresholdForHit = _thresholdForHit;
@synthesize thresholdForRepeat = _thresholdForRepeat;
@synthesize thresholdForCenter = _thresholdForCenter;

@synthesize enableRepeatTracking = _enableRepeatTracking;

@synthesize optionObjects = _optionObjects;

- (id)init
{
    if (self = [super init])
    {
        [self resetToDefaults];
        _enableRepeatTracking = FALSE;
        _cursorContexts = [[NSDictionary alloc] init];
    }
    return self;
}

- (void)resetToDefaults
{
    _thresholdForRepeat = 1;
    _thresholdForHit = 6.0/7.0;
    _thresholdForReenter = 15;
    _thresholdForCenter = 1.0/3.0;
    _radius = 1;
}

- (void)setRequiresMoveToInner:(BOOL)requiresMoveToInner cursorContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToInner:requiresMoveToInner];
}

- (void)setRequiresMoveToCenter:(BOOL)requiresMoveToCenter cursorContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:cursorContext];
    [cursorTracking setRequiresMoveToCenter:requiresMoveToCenter];
}

- (int)selectedIndex:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:cursorContext];
    return [cursorTracking selectedIndex];
}

- (int)hoverIndex:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:cursorContext];
    return [cursorTracking hoverIndex];
}

- (NSDictionary *)selectedIndexes
{
    NSMutableDictionary *selected = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumer = [_cursorContexts keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:key];
        [selected setObject:[NSNumber numberWithInt:[cursorTracking selectedIndex]] forKey:key];
        key = [enumer nextObject];
    }
    return [NSDictionary dictionaryWithDictionary:selected];
}

- (NSDictionary *)hoverIndexes
{
    NSMutableDictionary *hovers = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumer = [_cursorContexts keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:key];
        [hovers setObject:[NSNumber numberWithInt:[cursorTracking hoverIndex]] forKey:key];
        key = [enumer nextObject];
    }
    return [NSDictionary dictionaryWithDictionary:hovers];
}

- (void)removeCursorContext:(id)cursorContext
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:_cursorContexts];
    [newDict removeObjectForKey:cursorContext];
    if ([newDict count] < [_cursorContexts count])
        _cursorContexts = [NSDictionary dictionaryWithDictionary:newDict];
}

- (void)resetCurrentCursorTracking
{
    NSEnumerator *enumer = [_cursorContexts keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:key];
        [cursorTracking setRequiresMoveToInner:TRUE];
        [cursorTracking setHoverIndex:OLKCircleOptionMultiInputInvalidSelection];
        [cursorTracking setSelectedIndex:OLKCircleOptionMultiInputInvalidSelection];
        key = [enumer nextObject];
    }
}

- (void)removeAllCursorTracking
{
    _cursorContexts = nil;
}

- (void)setEnableRepeatTracking:(BOOL)enableRepeatTracking
{
    _enableRepeatTracking = enableRepeatTracking;
}

- (void)setEnableRepeatTracking:(BOOL)enableRepeatTracking cursorContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:cursorContext];
    [cursorTracking setEnableRepeatTracking:enableRepeatTracking];
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

- (void)setCursorPos:(NSPoint)cursorPos cursorContext:(id)cursorContext
{
    OLKCircleOptionCursorTracking *cursorTracking = [_cursorContexts objectForKey:cursorContext];
    if (!cursorTracking)
    {
        cursorTracking = [[OLKCircleOptionCursorTracking alloc] init];
        [cursorTracking setCursorContext:cursorContext];
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict setObject:cursorTracking forKey:cursorContext];
        [newDict addEntriesFromDictionary:_cursorContexts];
        _cursorContexts = [NSDictionary dictionaryWithDictionary:newDict];
        [cursorTracking setEnableRepeatTracking:[self enableRepeatTracking]];
    }
    [cursorTracking setCursorPos:cursorPos];

    float oOverA = (cursorPos.y)/(cursorPos.x);
    float degree = atan(oOverA) + M_PI_2;
    degree *= (180/M_PI_2);
    degree /= 2;
    if (cursorPos.x < 0)
        degree = 180-degree;
    else
        degree = 360 - degree;
    
    degree += 180;
    if (degree >=360)
        degree -= 360;
    
    int index = [self indexAtAngle:degree];
    
    [cursorTracking setLastUpdateCursorDistance:sqrtf(cursorPos.x*cursorPos.x + cursorPos.y*cursorPos.y)];
    float lastDist = [cursorTracking lastUpdateCursorDistance];
    OLKRepeatTracker *repeatTracker = [cursorTracking repeatTracker];
    
    if (repeatTracker && [repeatTracker isRepeating])
    {
        if (lastDist <= _thresholdForRepeat * _radius && lastDist >= _thresholdForHit * _radius)
        {
            if (![repeatTracker detectRepeatOfObject:[NSNumber numberWithInt:index]])
                return;
            
            if ([_delegate respondsToSelector:@selector(repeatTriggered:sender:cursorContext:)])
                [_delegate repeatTriggered:index sender:self cursorContext:cursorContext];
        }
        else
        {
            [repeatTracker setIsRepeating:NO];
            if ([_delegate respondsToSelector:@selector(repeatEnded:sender:cursorContext:)])
                [_delegate repeatEnded:index sender:self cursorContext:cursorContext];
        }
    }
    BOOL requiresMoveToInner = [cursorTracking requiresMoveToInner];
    BOOL requiresMoveToCenter = [cursorTracking requiresMoveToCenter];
    
    if (lastDist < _thresholdForHit*_radius)
    {
        if (requiresMoveToInner && lastDist <= _thresholdForHit*_radius - _thresholdForReenter)
        {
            [cursorTracking setRequiresMoveToInner:NO];
            if ([_delegate respondsToSelector:@selector(cursorMovedToInner:cursorContext:)])
                [_delegate cursorMovedToInner:self cursorContext:cursorContext];
        }
        
        if (requiresMoveToCenter && lastDist < _thresholdForCenter * _radius)
        {
            [cursorTracking setRequiresMoveToCenter:NO];
            if ([_delegate respondsToSelector:@selector(cursorMovedToCenter:cursorContext:)])
                [_delegate cursorMovedToCenter:self cursorContext:cursorContext];
        }
        
        if ([cursorTracking hoverIndex] != index)
        {
            [cursorTracking setHoverIndex:index];
            if ([_delegate respondsToSelector:@selector(hoverIndexChanged:sender:cursorContext:)])
                [_delegate hoverIndexChanged:index sender:self cursorContext:cursorContext];
        }
        if ([cursorTracking selectedIndex] != OLKCircleOptionMultiInputInvalidSelection)
        {
            [cursorTracking setSelectedIndex:OLKCircleOptionMultiInputInvalidSelection];
            if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:cursorContext:)])
                [_delegate selectedIndexChanged:OLKCircleOptionMultiInputInvalidSelection sender:self cursorContext:cursorContext];
        }
        
        return;
    }
    
    if (requiresMoveToInner)
        return;
    
    [cursorTracking setRequiresMoveToInner:YES];
    [cursorTracking setSelectedIndex:index];
    
    if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:cursorContext:)])
        [_delegate selectedIndexChanged:index sender:self cursorContext:cursorContext];
    
    if (repeatTracker)
        [repeatTracker initRepeatWithObject:[NSNumber numberWithInt:index]];
}

@end
