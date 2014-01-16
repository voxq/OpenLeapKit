//
//  OLKRangeCalibratorView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-02.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKRangeCalibratorView.h"

@implementation OLKRangeCalibratorView
{
    NSImage *_selectPointUncalibratedImg;
    NSImage *_selectPointCalibratedImg;
}

@synthesize rangeCalibrator = _rangeCalibrator;
@synthesize selectPointSize = _selectPointSize;
@synthesize delegate = _delegate;
@synthesize positionsCalibrated = _positionsCalibrated;

- (id)initWithFrame:(NSRect)rect
{
    if (self = [super initWithFrame:rect])
    {
        _selectPointSize = NSMakeSize(50, 50);
        [self reset];
    }
    return self;
}

- (void)reset
{
//    if (!_rangeCalibrator)
//    {
//        _rangeCalibrator = [[OLKRangeCalibrator alloc] init];
//    }
//    NSRect frame = [self convertRect:[self frame] toView:nil];
//    [self ]
//    [[self window] convertRectToScreen:<#(NSRect)#>]
    _positionsCalibrated = OLKRangeNoPositionsCalibrated;
     [self drawIntoImage];
}

- (void)addHandView:(NSView <OLKHandContainer> *)handView
{
    [self addSubview:handView];
}


- (void)setSelectPointSize:(NSSize)selectPointSize
{
    _selectPointSize = selectPointSize;
    [self drawIntoImage];
}

- (void)drawIntoImage
{
    NSBezierPath *selectPoint = [[NSBezierPath alloc] init];
    NSRect selectPointRect;
    selectPointRect.origin = NSMakePoint(0, 0);
    selectPointRect.size = _selectPointSize;
    _selectPointUncalibratedImg = [[NSImage alloc] initWithSize:selectPointRect.size];
    [_selectPointUncalibratedImg lockFocus];
    
    [selectPoint appendBezierPathWithOvalInRect:selectPointRect];
    [[NSColor colorWithCalibratedRed:1 green:0.2 blue:0.2 alpha:1] set] ;
    [selectPoint fill];
    [_selectPointUncalibratedImg unlockFocus];

    _selectPointCalibratedImg = [[NSImage alloc] initWithSize:selectPointRect.size];
    [_selectPointCalibratedImg lockFocus];
    
    [selectPoint appendBezierPathWithOvalInRect:selectPointRect];
    [[NSColor colorWithCalibratedRed:0.2 green:1 blue:0.2 alpha:1] set] ;
    [selectPoint fill];
    [_selectPointCalibratedImg unlockFocus];
}


- (void)drawRect:(NSRect)dirtyRect
{
    if (!_rangeCalibrator)
        return;

    NSPoint drawLocation;
    NSRect convertRect;
    convertRect.origin = [_rangeCalibrator screenPos1];
    convertRect.size = NSMakeSize(0, 0);
    convertRect = [[self window] convertRectFromScreen:convertRect];

    drawLocation = convertRect.origin;
    
    NSRect selectPointRect;
    selectPointRect.origin = NSMakePoint(0, 0);
    drawLocation.x -= _selectPointSize.width/2;
    drawLocation.y -= _selectPointSize.height/2;
    selectPointRect.size = _selectPointSize;
    if (_positionsCalibrated == OLKRangeNoPositionsCalibrated)
        [_selectPointUncalibratedImg drawAtPoint:drawLocation fromRect:selectPointRect operation:NSCompositeSourceOver fraction:1];
    else
        [_selectPointCalibratedImg drawAtPoint:drawLocation fromRect:selectPointRect operation:NSCompositeSourceOver fraction:1];
    
    convertRect.origin = [_rangeCalibrator screenPos2];
    convertRect.size = NSMakeSize(0, 0);
    convertRect = [[self window] convertRectFromScreen:convertRect];
    
    drawLocation = convertRect.origin;
    
    drawLocation.x -= _selectPointSize.width/2;
    drawLocation.y -= _selectPointSize.height/2;
    if (_positionsCalibrated == OLKRangeFirstPositionCalibrated)
        [_selectPointUncalibratedImg drawAtPoint:drawLocation fromRect:selectPointRect operation:NSCompositeSourceOver fraction:1];
    else if (_positionsCalibrated != OLKRangeNoPositionsCalibrated)
        [_selectPointCalibratedImg drawAtPoint:drawLocation fromRect:selectPointRect operation:NSCompositeSourceOver fraction:1];

    if (![_rangeCalibrator use3PointCalibration])
        return;
    
    convertRect.origin = [_rangeCalibrator screenPos3];
    convertRect.size = NSMakeSize(0, 0);
    convertRect = [[self window] convertRectFromScreen:convertRect];
    
    drawLocation = convertRect.origin;
    
    drawLocation.x -= _selectPointSize.width/2;
    drawLocation.y -= _selectPointSize.height/2;
    if (_positionsCalibrated == OLKRangeSecondPositionCalibrated)
        [_selectPointUncalibratedImg drawAtPoint:drawLocation fromRect:selectPointRect operation:NSCompositeSourceOver fraction:1];
    else if (_positionsCalibrated == OLKRangeAllPositionsCalibrated)
        [_selectPointCalibratedImg drawAtPoint:drawLocation fromRect:selectPointRect operation:NSCompositeSourceOver fraction:1];
}

- (void)keyDown:(NSEvent *)event
{
    unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
    switch (c) {
			
        case NSLeftArrowFunctionKey:
            
            break;
            
        case NSRightArrowFunctionKey:
            break;
            
        case NSUpArrowFunctionKey:
            break;
            
        case NSDownArrowFunctionKey:
            break;

			// [Esc] exits full-screen mode
        case 27:
            [_delegate canceledCalibration];
            break;
            
        default:
            if (_positionsCalibrated == OLKRangeAllPositionsCalibrated)
                break;
            if (_positionsCalibrated == OLKRangeNoPositionsCalibrated)
                _positionsCalibrated = OLKRangeFirstPositionCalibrated;
            else if ([_rangeCalibrator use3PointCalibration])
            {
                if (_positionsCalibrated == OLKRangeFirstPositionCalibrated)
                    _positionsCalibrated = OLKRangeSecondPositionCalibrated;
                else
                    _positionsCalibrated = OLKRangeAllPositionsCalibrated;
            }
            else if (_positionsCalibrated == OLKRangeFirstPositionCalibrated)
                _positionsCalibrated = OLKRangeAllPositionsCalibrated;

            [self setNeedsDisplay:YES];
            [_delegate calibratedPosition:_positionsCalibrated];
            break;
    }

}
@end
