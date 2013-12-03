//
//  OLKRangeCalibrator.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-02.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKRangeCalibrator.h"

@implementation OLKRangeCalibrator

@synthesize heightFactor = _heightFactor;
@synthesize widthFactor = _widthFactor;
@synthesize screenPos1 = _screenPos1;
@synthesize screenPos2 = _screenPos2;
@synthesize screenPos3 = _screenPos3;
@synthesize leapPos1 = _leapPos1;
@synthesize leapPos2 = _leapPos2;
@synthesize leapPos3 = _leapPos3;
@synthesize screenFrame = _screenFrame;
@synthesize use3PointCalibration = _use3PointCalibration;
@synthesize offsetToBase = _offsetToBase;
@synthesize offsetFromHorizCenter = _offsetFromHorizCenter;

- (void)configScreenPositionsFromWindow:(NSWindow *)window
{
    _screenFrame = [[window screen] frame];
    [self configScreenPositions];
}

- (void)configScreenPositions
{
    if (_use3PointCalibration)
        [self config3PointScreenPositions];
    else
        [self config2PointScreenPositions];
}

- (void)config2PointScreenPositions
{
    _screenPos1 = _screenFrame.origin;
    _screenPos1.x += _screenFrame.size.width/4;
    _screenPos1.y += _screenFrame.size.height/4;
    _screenPos2 = _screenFrame.origin;
    _screenPos2.x += _screenFrame.size.width/4*3;
    _screenPos2.y += _screenFrame.size.height/4*3;
}

- (void)config3PointScreenPositions
{
    _screenPos1 = _screenFrame.origin;
    _screenPos1.x += _screenFrame.size.width/4;
    _screenPos1.y += _screenFrame.size.height/4*3;
    _screenPos2 = _screenFrame.origin;
    _screenPos2.x += _screenFrame.size.width/2;
    _screenPos2.y += _screenFrame.size.height/4;
    _screenPos3 = _screenFrame.origin;
    _screenPos3.x += _screenFrame.size.width/4*3;
    _screenPos3.y += _screenFrame.size.height/4*3;
}

- (NSPoint)screenPosFromLeapPos:(LeapVector*)leapPos
{
    NSPoint screenPos;
    screenPos.x = (leapPos.x - _offsetFromHorizCenter)*_widthFactor + _screenFrame.origin.x + _screenFrame.size.width/2;
    screenPos.y = (leapPos.y - _offsetToBase)*_heightFactor + _screenFrame.origin.y;
    return screenPos;
}


- (void)calibrate
{
    float screenDifX;
    float screenDifY;
    float leapDifX;
    float leapDifY;
    
    if (_use3PointCalibration)
    {
        screenDifX = _screenPos3.x - _screenPos1.x;
        screenDifY = _screenPos2.y - _screenPos1.y;
        leapDifX = _leapPos3.x - _leapPos1.x;
        leapDifY = _leapPos2.y - _leapPos1.y;
    }
    else
    {
        screenDifX = _screenPos2.x - _screenPos1.x;
        screenDifY = _screenPos2.y - _screenPos1.y;
        leapDifX = _leapPos2.x - _leapPos1.x;
        leapDifY = _leapPos2.y - _leapPos1.y;
    }
    
    _heightFactor = screenDifY/leapDifY;
    _widthFactor = screenDifX/leapDifX;
    if (_use3PointCalibration)
    {
        _offsetToBase = _leapPos2.y - ((_screenPos2.y-_screenFrame.origin.y)/_heightFactor);
        _offsetFromHorizCenter = _leapPos2.x;
    }
    else
    {
        _offsetToBase = _leapPos1.y - ((_screenPos1.y-_screenFrame.origin.y)/_heightFactor);
        _offsetFromHorizCenter = (_screenFrame.size.width/2-_screenPos1.x)/_widthFactor + _leapPos1.x;
    }
}

- (void)calibrate2PointWithScreenPos1:(NSPoint)screenPos1 screenPos2:(NSPoint)screenPos2 mappingLeapPos1:(LeapVector*)leapPos1 leapPos2:(LeapVector *)leapPos2
{
    _leapPos1 = leapPos1;
    _leapPos2 = leapPos2;
    _screenPos1 = screenPos1;
    _screenPos2 = screenPos2;
    
    [self calibrate];
}

- (void)calibrate3PointWithScreenPos1:(NSPoint)screenPos1 screenPos2:(NSPoint)screenPos2 screenPos3:(NSPoint)screenPos3 mappingLeapPos1:(LeapVector*)leapPos1 leapPos2:(LeapVector *)leapPos2 leapPos3:(LeapVector *)leapPos3
{
    _leapPos1 = leapPos1;
    _leapPos2 = leapPos2;
    _leapPos3 = leapPos3;
    _screenPos1 = screenPos1;
    _screenPos2 = screenPos2;
    _screenPos3 = screenPos3;
    
    [self calibrate];
}

@end
