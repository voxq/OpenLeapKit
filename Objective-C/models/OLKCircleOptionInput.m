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

@synthesize cursorPos = _cursorPos;
@synthesize optionObjects = _optionObjects;

@synthesize requiresMoveToCenter = _requiresMoveToCenter;
@synthesize requiresMoveToInner = _requiresMoveToInner;

@synthesize repeating = _repeating;
@synthesize repeatIsKey = _repeatIsKey;
@synthesize repeatRate = _repeatRate;
@synthesize repeatCycles = _repeatCycles;
@synthesize repeatedChars = _repeatedChars;
@synthesize repeatAccelOnCycles = _repeatAccelOnCycles;
@synthesize repeatAccelAmt = _repeatAccelAmt;
@synthesize repeatAccel = _repeatAccel;
@synthesize repeatChar = _repeatChar;

- (id)init
{
    if (self = [super init])
    {
        [self resetToDefaults];
        [self reset];
    }
    return self;
}

- (void)resetToDefaults
{
    _repeatRate = 20;
    _repeatAccelOnCycles = 1;
    _repeatAccelAmt = 5;
    _repeatAccel = 1;
    _thresholdForRepeat = 1;
    _thresholdForHit = 6.0/7.0;
    _thresholdForCenter = 1.0/3.0;
    _radius = 1;
}

- (void)reset
{
    _repeatCycles = 0;
    _repeatedChars = 0;
    _repeating = FALSE;
    _repeatIsKey = NO;
    _requiresMoveToCenter = TRUE;
    _requiresMoveToInner = TRUE;
    _selectedIndex = OLKCircleOptionInputInvalidSelection;
    _hoverIndex = OLKCircleOptionInputInvalidSelection;
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
        
        if (_requiresMoveToCenter && _lastUpdateCursorDistance < _thresholdForCenter*_radius)
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
    
    if (_requiresMoveToInner)
        return;
    
    _selectedIndex = index;
    if ([_delegate respondsToSelector:@selector(selectedIndexChanged:sender:)])
        [_delegate selectedIndexChanged:index sender:self];
}


- (void)setCursorPos:(NSPoint)cursorPos
{
    _cursorPos = cursorPos;
    [self update];
}

@end
