//
//  CircleTextInput.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKCircleOptionInput.h"

@implementation OLKCircleOptionInput

@synthesize delegate = _delegate;

@synthesize selectedIndex = _selectedIndex;
@synthesize hoverIndex = _hoverIndex;
@synthesize radius = _radius;
@synthesize lastUpdateCursorDistance = _lastUpdateCursorDistance;
@synthesize thresholdForHit = _thresholdForHit;
@synthesize thresholdForRepeat = _thresholdForRepeat;
@synthesize thresholdForCenter = _thresholdForCenter;

@synthesize repeatTracker = _repeatTracker;
@synthesize enableRepeatTracking = _enableRepeatTracking;

@synthesize cursorPos = _cursorPos;
@synthesize optionObjects = _optionObjects;

@synthesize requiresMoveToCenter = _requiresMoveToCenter;
@synthesize requiresMoveToInner = _requiresMoveToInner;


- (id)init
{
    if (self = [super init])
    {
        [self resetToDefaults];
        [self reset];
        _enableRepeatTracking = FALSE;
    }
    return self;
}

- (void)resetToDefaults
{
    _thresholdForRepeat = 1;
    _thresholdForHit = 6.0/7.0;
    _thresholdForCenter = 1.0/3.0;
    _radius = 1;
}

- (void)reset
{
    _requiresMoveToCenter = TRUE;
    _requiresMoveToInner = TRUE;
    _selectedIndex = OLKCircleOptionInputInvalidSelection;
    _hoverIndex = OLKCircleOptionInputInvalidSelection;
}

- (void)setEnableRepeatTracking:(BOOL)enableRepeatTracking
{
    _enableRepeatTracking = enableRepeatTracking;
    if (enableRepeatTracking && !_repeatTracker)
        _repeatTracker = [[OLKRepeatTracker alloc] init];
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

- (void)update
{
    float oOverA = (_cursorPos.y)/(_cursorPos.x);
    float degree = atan(oOverA) + M_PI_2;
    degree *= (180/M_PI_2);
    degree /= 2;
    if (_cursorPos.x < 0)
        degree = 180-degree;
    else
        degree = 360 - degree;
    
    degree += 180;
    if (degree >=360)
        degree -= 360;

    int index = [self indexAtAngle:degree];
    
    _lastUpdateCursorDistance = sqrtf(_cursorPos.x*_cursorPos.x + _cursorPos.y*_cursorPos.y);
    
    if (_lastUpdateCursorDistance < _thresholdForHit*_radius)
    {
        if (_requiresMoveToInner)
        {
            _requiresMoveToInner = FALSE;
            if ([_delegate respondsToSelector:@selector(cursorMovedToInner:)])
                [_delegate cursorMovedToInner:self];
        }
        
        if (_requiresMoveToCenter && _lastUpdateCursorDistance < _thresholdForCenter * _radius)
        {
            _requiresMoveToCenter = FALSE;
            if ([_delegate respondsToSelector:@selector(cursorMovedToCenter:)])
                [_delegate cursorMovedToCenter:self];
        }

        if (_hoverIndex != index)
        {
            _hoverIndex = index;
            if ([_delegate respondsToSelector:@selector(hoverIndexChanged:sender:)])
                [_delegate hoverIndexChanged:index sender:self];
        }
        if (_selectedIndex != OLKCircleOptionInputInvalidSelection)
        {
            _selectedIndex = OLKCircleOptionInputInvalidSelection;
            if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:)])
                [_delegate selectedIndexChanged:_selectedIndex sender:self];
        }
        
        return;
    }
    
    if (_repeatTracker && [_repeatTracker isRepeating])
    {
        if (_lastUpdateCursorDistance <= _thresholdForRepeat * _radius)
        {
            
            if (_lastUpdateCursorDistance >= _thresholdForHit * _radius)
            {
                if (![_repeatTracker detectRepeatOfObject:[NSNumber numberWithInt:index]])
                    return;
                
                if ([_delegate respondsToSelector:@selector(repeatTriggered:)])
                    [_delegate repeatTriggered:self];
            }
        }
        else
        {
            [_repeatTracker setIsRepeating:NO];
            if ([_delegate respondsToSelector:@selector(repeatEnded:)])
                [_delegate repeatEnded:self];
        }
    }
    
    if (_requiresMoveToInner)
        return;
    
    _requiresMoveToInner = YES;
    _selectedIndex = index;
    
    if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:)])
        [_delegate selectedIndexChanged:index sender:self];
    
    if (_repeatTracker)
        [_repeatTracker initRepeatWithObject:[NSNumber numberWithInt:index]];
}

- (void)setCursorPos:(NSPoint)cursorPos
{
    _cursorPos = cursorPos;
    [self update];
}

@end
