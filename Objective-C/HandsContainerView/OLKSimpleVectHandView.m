/*
 
 Copyright (c) 2013, Tyler Zetterstrom
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

//
//  OLKSimpleVectHandView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-15.
//


#import "OLKSimpleVectHandView.h"
#import "LeapObjectiveC.h"

static const NSSize defaultFitHandFact = {150, 150};

@implementation OLKSimpleVectHandView
{
    NSSize _fitHandFact;
    NSMutableArray *_fingerBases;
    NSPoint _centerPoint;
}


@synthesize hand = _hand;
@synthesize autoFitHand = _autoFitHand;
@synthesize simpleFingerTipSize = _simpleFingerTipSize;
@synthesize enableDrawHandBoundingCircle = _enableDrawHandBoundingCircle;
@synthesize enableDrawPalm = _enableDrawPalm;
@synthesize enableDrawFingers = _enableDrawFingers;
@synthesize enableDrawFingerTips = _enableDrawFingerTips;
@synthesize screenYAxisUsesZAxis = _screenYAxisUsesZAxis;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _fitHandFact = defaultFitHandFact;
        _simpleFingerTipSize.width = _bounds.size.width/10;
        _simpleFingerTipSize.height = _bounds.size.height/10;
        _autoFitHand = YES;
        _enableDrawHandBoundingCircle = YES;
        _enableDrawFingers = YES;
        _enableDrawFingerTips = YES;
        _enableDrawPalm = YES;
        _screenYAxisUsesZAxis = NO;
    }
    
    return self;
}

- (void)setHand:(OLKHand *)hand
{
    _hand = hand;
    [self display];
}

- (void)insertIntoOrderedFingers:(NSPoint)insertFingerBase
{
    for (NSValue *fingerBaseValue in _fingerBases)
    {
        NSPoint *fingerBase = (NSPoint*)[fingerBaseValue objCType];
//        if
    }
}

- (void)drawSimpleStickFinger:(LeapFinger *)finger fingersPath:(NSBezierPath *)theFingerPaths
{
    float palmY, fingerTipY, fingerDirY;
    
    if (_screenYAxisUsesZAxis)
    {
        palmY = [[_hand leapHand] palmPosition].z;
        fingerTipY = [finger tipPosition].z;
        fingerDirY = [finger direction].z;
    }
    else
    {
        palmY = -[[_hand leapHand] palmPosition].y;
        fingerTipY = -[finger tipPosition].y;
        fingerDirY = -[finger direction].y;
    }
    
    NSRect fingerTipRect;
    fingerTipRect.origin.x = _centerPoint.x + ([finger tipPosition].x - [[_hand leapHand] palmPosition].x)*_fitHandFact.width;
    fingerTipRect.origin.y = _centerPoint.y + (palmY - fingerTipY)*_fitHandFact.height;
    fingerTipRect.size = _simpleFingerTipSize;
    
    if (_autoFitHand)
    {
        if (fingerTipRect.origin.x - fingerTipRect.size.width < 0)
        {
            //              0 = centerPoint + (tipPos - palmPos)*fitHandFact - fingerTipRectSize
            //              Solve for fitHandFact
            //              fitHandFact = (fingerTipRectSize - centerPoint)/(tipPos - palmPos)
            _fitHandFact.width = (fingerTipRect.size.width-_centerPoint.x)/([finger tipPosition].x - [[_hand leapHand] palmPosition].x);
            fingerTipRect.origin.x = _centerPoint.x + ([finger tipPosition].x - [[_hand leapHand] palmPosition].x)*_fitHandFact.width;
        }
        else if (fingerTipRect.origin.x + fingerTipRect.size.width > _bounds.size.width)
        {
            //              boundsSize = centerPoint + (tipPos - palmPos)*fitHandFact + fingerTipRectSize
            //              Solve for fitHandFact
            //              fitHandFact = (boundsSize - fingerTipRectSize - centerPoint)/(tipPos - palmPos)
            _fitHandFact.width = (_bounds.size.width - fingerTipRect.size.width - _centerPoint.x)/([finger tipPosition].x - [[_hand leapHand] palmPosition].x);
            fingerTipRect.origin.x = _centerPoint.x + ([finger tipPosition].x - [[_hand leapHand] palmPosition].x)*_fitHandFact.width;
        }
        
        if (fingerTipRect.origin.y + fingerTipRect.size.height > _bounds.size.height)
        {
            //              boundsSize = centerpoint + (palmPos-tipPos)*fitHandFact + fingerTipRectSize
            //              Solve for fitHandFact
            //              fitHandFact = (boundsSize - fingerTipRectSize - centerPoint)/(palmPos - tipPos)
            _fitHandFact.height = (_bounds.size.height - fingerTipRect.size.height - _centerPoint.y)/(palmY - fingerTipY);
            fingerTipRect.origin.y = _centerPoint.y + (palmY - fingerTipY)*_fitHandFact.height;
        }
    }
    
    if (_enableDrawFingerTips)
        [theFingerPaths appendBezierPathWithOvalInRect:fingerTipRect];
    

    if (!_enableDrawFingers)
        return;
    
    NSPoint fingerTipBase;
    fingerTipBase.x = fingerTipRect.origin.x;
    // connect to a position on the fingerTip rect that automatically moves to a position that looks natural for the angle the line is coming into the fingerTip
    // currently calculated simply based on where the fingerTip is compared to the origin. Better results might be to use a comparison between the x and z components
    // of the direction vector.
    fingerTipBase.x -= (fingerTipRect.size.width / _bounds.size.width) * (fingerTipRect.origin.x - _bounds.size.width);
    fingerTipBase.y = fingerTipRect.origin.y;
    NSPoint fingerBase;
    fingerBase.x = fingerTipRect.origin.x - [finger direction].x * [finger length]*_fitHandFact.width;
    fingerBase.y = fingerTipRect.origin.y + fingerDirY * [finger length]*_fitHandFact.height;
    [theFingerPaths moveToPoint:fingerBase];
    
    [theFingerPaths lineToPoint:fingerTipBase];
}

- (void)drawFingers
{
    NSBezierPath* theFingerPaths = [NSBezierPath bezierPath];
    
    for (LeapFinger *finger in [[_hand leapHand] fingers])
    {
        [self drawSimpleStickFinger:finger fingersPath:theFingerPaths];
    }
    [[NSColor blackColor] setStroke];
    [theFingerPaths stroke];
}

- (void)drawPalm
{
    [[NSColor grayColor] setStroke];
    NSBezierPath* theHandPath = [NSBezierPath bezierPath];
    NSPoint thumbPoint;
    thumbPoint.y = _centerPoint.y;
    
    float handDirY;
    
    if (_screenYAxisUsesZAxis)
        handDirY = [[_hand leapHand] direction].z;
    else
        handDirY = -[[_hand leapHand] direction].y;
    

    NSBezierPath *palmDirectionPath = [NSBezierPath bezierPath];
    float palmCircleRadius = _bounds.size.width / 3;
    NSRect palmCircleBounds;
    palmCircleBounds.size.width = palmCircleRadius;
    palmCircleBounds.size.height = palmCircleRadius;
    palmCircleRadius /= 2;
    palmCircleBounds.origin = _centerPoint;
    palmCircleBounds.origin.x -= palmCircleRadius;
    palmCircleBounds.origin.y -= palmCircleRadius;
    [palmDirectionPath appendBezierPathWithOvalInRect:palmCircleBounds];
    NSPoint palmVector;
    palmVector.x = _centerPoint.x + [[_hand leapHand] direction].x*palmCircleRadius;
    palmVector.y = _centerPoint.y - handDirY*palmCircleRadius;
    [palmDirectionPath moveToPoint:_centerPoint];
    [palmDirectionPath lineToPoint:palmVector];
    [palmDirectionPath setLineWidth:3];
    [palmDirectionPath stroke];
    
    OLKHandedness handedness = [_hand simHandedness];
    if (handedness == OLKHandednessUnknown)
        handedness = [_hand handedness];
    
    if (handedness != OLKHandednessUnknown)
    {
        if (handedness == OLKRightHand)
            thumbPoint.x = _centerPoint.x-palmCircleRadius;
        else
            thumbPoint.x = _centerPoint.x+palmCircleRadius;
        
        [theHandPath moveToPoint:_centerPoint];
        [theHandPath lineToPoint:thumbPoint];
    }
    
    if (_enableDrawHandBoundingCircle)
        [theHandPath appendBezierPathWithOvalInRect:_bounds];
    
    [theHandPath stroke];
}

- (void)drawRect:(NSRect)dirtyRect
{
    _centerPoint.x = (_bounds.origin.x + _bounds.size.width)/2;
    _centerPoint.y = (_bounds.origin.y + _bounds.size.height)/2;

    if (_enableDrawPalm)
        [self drawPalm];
    
    if (_enableDrawFingers || _enableDrawFingerTips)
        [self drawFingers];
}

@end
