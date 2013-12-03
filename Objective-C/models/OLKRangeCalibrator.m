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
@synthesize leapPos1 = _leapPos1;
@synthesize leapPos2 = _leapPos2;
@synthesize screenFrame = _screenFrame;

- (void)configScreenPositionsFromWindow:(NSWindow *)window
{
    [self configScreenPositionsFromRect:[[window screen] frame]];
}

- (void)configScreenPositions
{
    [self configScreenPositionsFromRect:_screenFrame];
}

- (void)configScreenPositionsFromRect:(NSRect)screenRect
{
    _screenPos1 = screenRect.origin;
    _screenPos1.x += screenRect.size.width/4;
    _screenPos1.y += screenRect.size.height/4;
    _screenPos2 = screenRect.origin;
    _screenPos2.x += screenRect.size.width/4*3;
    _screenPos2.y += screenRect.size.height/4*3;
}

- (NSPoint)screenPosFromLeapPos:(LeapVector*)leapPos
{
    NSPoint screenPos;
    screenPos.x = leapPos.x*_widthFactor + _screenFrame.origin.x + _screenFrame.size.width/2;
    screenPos.y = (leapPos.y - _offsetToBase)*_heightFactor + _screenFrame.origin.y;
    return screenPos;
}


- (void)calibrate
{
    float screenDifX;
    float screenDifY;
    float leapDifX;
    float leapDifY;
    
    screenDifX = _screenPos1.x - _screenPos2.x;
    screenDifY = _screenPos1.y - _screenPos2.y;
    
    leapDifX = _leapPos1.x - _leapPos2.x;
    leapDifY = _leapPos1.y - _leapPos2.y;
    
    _heightFactor = screenDifY/leapDifY;
    _widthFactor = screenDifX/leapDifX;
    _offsetToBase = _leapPos1.y - ((_screenPos1.y-_screenFrame.origin.y)/_heightFactor);
}

- (void)calibrateWithScreenPos1:(NSPoint)screenPos1 andScreenPos2:(NSPoint)screenPos2 mappingLeapPos1:(LeapVector*)leapPos1 andLeapPos2:(LeapVector *)leapPos2
{
    _leapPos1 = leapPos1;
    _leapPos2 = leapPos2;
    _screenPos1 = screenPos1;
    _screenPos2 = screenPos2;
    
    [self calibrate];
}

@end
