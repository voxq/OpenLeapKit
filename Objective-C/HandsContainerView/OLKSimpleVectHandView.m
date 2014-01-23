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

@implementation OLKSimpleVectHandView
{
    NSMutableArray *_fingerBases;
    NSPoint _centerPoint;
}

@synthesize enabled = _enabled;

@synthesize hand = _hand;
@synthesize spaceView = _spaceView;
@synthesize simpleFingerTipSize = _simpleFingerTipSize;
@synthesize fitHandFact = _fitHandFact;
@synthesize enableAutoFitHand = _enableAutoFitHand;
@synthesize enableDrawHandBoundingCircle = _enableDrawHandBoundingCircle;
@synthesize enableDrawPalm = _enableDrawPalm;
@synthesize enableDrawFingers = _enableDrawFingers;
@synthesize enableDrawFingerTips = _enableDrawFingerTips;
@synthesize enableScreenYAxisUsesZAxis = _enableScreenYAxisUsesZAxis;
@synthesize enable3DHand = _enable3DHand;
@synthesize enableStable = _enableStable;
@synthesize palmColor = _palmColor;
@synthesize enableSphere = _enableSphere;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _fitHandFact = defaultFitHandFact;
        _simpleFingerTipSize.width = _bounds.size.width/10;
        _simpleFingerTipSize.height = _bounds.size.height/10;
        _enableAutoFitHand = YES;
        _enableDrawHandBoundingCircle = YES;
        _enableDrawFingers = YES;
        _enableDrawFingerTips = YES;
        _enableDrawPalm = YES;
        _enableScreenYAxisUsesZAxis = NO;
        _enable3DHand = NO;
        _enableStable = YES;
        _enabled = YES;
        _enableSphere = YES;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSUInteger)hash
{
    return (NSUInteger)[[_hand leapHand] id];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!_hand || ![[_hand leapHand] isValid] || !object)
        return NO;
    
    if (![object isKindOfClass:[OLKSimpleVectHandView class]])
        return NO;
    
    LeapHand *otherHand = [[(OLKSimpleVectHandView *)object hand] leapHand];
    if ([otherHand isValid] && [[_hand leapHand] id] == [otherHand id])
        return YES;
    
    return NO;
}


- (void)setHand:(OLKHand *)hand
{
    _hand = hand;
    [self setNeedsDisplay:YES];
}

- (void)insertIntoOrderedFingers:(NSPoint)insertFingerBase
{
    for (NSValue *fingerBaseValue in _fingerBases)
    {
//        NSPoint *fingerBase = (NSPoint*)[fingerBaseValue objCType];
//        if
    }
}

- (void)drawSimpleStickFinger:(LeapFinger *)finger fingersPath:(NSBezierPath *)theFingerPaths
{
    float palmY, fingerTipY, fingerDirY;
    LeapVector *palmPosition;
    if (_enableStable)
        palmPosition = [[_hand leapHand] stabilizedPalmPosition];
    else
        palmPosition = [[_hand leapHand] palmPosition];
    
    if (_enableScreenYAxisUsesZAxis && !_enable3DHand)
    {
        palmY = palmPosition.z;
        fingerTipY = [finger tipPosition].z;
        fingerDirY = [finger direction].z;
    }
    else
    {
        palmY = -palmPosition.y;
        
        fingerTipY = -[finger tipPosition].y;
        fingerDirY = -[finger direction].y;
    }
    
    NSSize fitHandFact;
    if (_enableAutoFitHand)
        fitHandFact = _fitHandFact;
    else
        fitHandFact = NSMakeSize(1, 1);
    
    NSRect fingerTipRect;
    fingerTipRect.origin.x = ([finger tipPosition].x - palmPosition.x)*fitHandFact.width;
    fingerTipRect.origin.y = (palmY - fingerTipY)*fitHandFact.height;
    NSRect origFingerTipRect = fingerTipRect;
    if (_enable3DHand)
    {
        origFingerTipRect.origin.x += _centerPoint.x;
        origFingerTipRect.origin.y += _centerPoint.y;

        float difcalc = fabs([[_hand leapHand] palmPosition].z-[finger tipPosition].z);
        if (difcalc != 0)
        {
            if (difcalc>60)
            {
                fingerTipRect.origin.x /= difcalc/60;
                fingerTipRect.origin.y /= difcalc/60;
            }
            fingerTipRect.size.height = _simpleFingerTipSize.height/difcalc*20;
        }
        else
            fingerTipRect.size.height = 0.1;
        if (fingerTipRect.size.height > _simpleFingerTipSize.height)
            fingerTipRect.size.height = _simpleFingerTipSize.height;

        fingerTipRect.size.height *= fabs([[_hand leapHand] palmPosition].y-[finger tipPosition].y)/30;
        if (fingerTipRect.size.height > _simpleFingerTipSize.height)
            fingerTipRect.size.height = _simpleFingerTipSize.height;
        else if (fingerTipRect.size.height == 0)
            fingerTipRect.size.height = 0.1;
        
        if (difcalc != 0)
            fingerTipRect.size.width = _simpleFingerTipSize.width/difcalc*20;
        else
            fingerTipRect.size.width = 0.1;
        if (fingerTipRect.size.width > _simpleFingerTipSize.width)
            fingerTipRect.size.width = _simpleFingerTipSize.width;
        else if (fingerTipRect.size.width == 0)
            fingerTipRect.size.width = 0.1;
        fingerTipRect.size.width = _simpleFingerTipSize.width;
    }
    else
    {
        fingerTipRect.size = _simpleFingerTipSize;
    }

    origFingerTipRect.size = _simpleFingerTipSize;
    
    fingerTipRect.origin.x += _centerPoint.x;
    fingerTipRect.origin.y += _centerPoint.y;

//    if (_enableAutoFitHand)
//    {
        if (fingerTipRect.origin.x - fingerTipRect.size.width < 0)
        {
            //              0 = centerPoint + (tipPos - palmPos)*fitHandFact - fingerTipRectSize
            //              Solve for fitHandFact
            //              fitHandFact = (fingerTipRectSize - centerPoint)/(tipPos - palmPos)
            _fitHandFact.width = (fingerTipRect.size.width-_centerPoint.x)/([finger tipPosition].x - palmPosition.x);
            fingerTipRect.origin.x = _centerPoint.x + ([finger tipPosition].x - palmPosition.x)*fitHandFact.width;
        }
        else if (fingerTipRect.origin.x + fingerTipRect.size.width > _bounds.size.width)
        {
            //              boundsSize = centerPoint + (tipPos - palmPos)*fitHandFact + fingerTipRectSize
            //              Solve for fitHandFact
            //              fitHandFact = (boundsSize - fingerTipRectSize - centerPoint)/(tipPos - palmPos)
            _fitHandFact.width = (_bounds.size.width - fingerTipRect.size.width - _centerPoint.x)/([finger tipPosition].x - palmPosition.x);
            fingerTipRect.origin.x = _centerPoint.x + ([finger tipPosition].x - palmPosition.x)*fitHandFact.width;
        }
        
        if (fingerTipRect.origin.y + fingerTipRect.size.width > _bounds.size.height)
        {
            //              boundsSize = centerpoint + (palmPos-tipPos)*fitHandFact + fingerTipRectSize
            //              Solve for fitHandFact
            //              fitHandFact = (boundsSize - fingerTipRectSize - centerPoint)/(palmPos - tipPos)
            _fitHandFact.height = (_bounds.size.height - fingerTipRect.size.height - _centerPoint.y)/(palmY - fingerTipY);
            fingerTipRect.origin.y = _centerPoint.y + (palmY - fingerTipY)*fitHandFact.height;
        }
//    }
    
    if (_enableDrawFingerTips)
        [theFingerPaths appendBezierPathWithOvalInRect:fingerTipRect];
    

    if (!_enableDrawFingers)
        return;
    
    NSPoint fingerTipBase;
    NSPoint fingerTipBaseCalc;
    fingerTipBase.x = fingerTipRect.origin.x;
    // connect to a position on the fingerTip rect that automatically moves to a position that looks natural for the angle the line is coming into the fingerTip
    // currently calculated simply based on where the fingerTip is compared to the origin. Better results might be to use a comparison between the x and z components
    // of the direction vector.
    fingerTipBase.x -= (fingerTipRect.size.width / _bounds.size.width) * (fingerTipRect.origin.x - _bounds.size.width);
    fingerTipBase.y = fingerTipRect.origin.y;

    if (_enable3DHand)
    {
        fingerTipBaseCalc.x = origFingerTipRect.origin.x;
        // connect to a position on the fingerTip rect that automatically moves to a position that looks natural for the angle the line is coming into the fingerTip
        // currently calculated simply based on where the fingerTip is compared to the origin. Better results might be to use a comparison between the x and z components
        // of the direction vector.
        fingerTipBaseCalc.x -= (origFingerTipRect.size.width / _bounds.size.width) * (origFingerTipRect.origin.x - _bounds.size.width);
        fingerTipBaseCalc.y = origFingerTipRect.origin.y;
    }
    else
        fingerTipBaseCalc = fingerTipBase;
    
    NSPoint fingerBase;
    fingerBase.x = fingerTipBaseCalc.x - [finger direction].x * [finger length]*fitHandFact.width;
    fingerBase.y = fingerTipBaseCalc.y + fingerDirY * [finger length]*fitHandFact.height;
    
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
    if (_palmColor)
    {
        [_palmColor setStroke];
        [theFingerPaths setLineWidth:3];
        [theFingerPaths stroke];
    }
}

- (void)drawSphereData
{
    float palmCircleRadius = _bounds.size.width / 3;
    NSRect palmCircleBounds;
    palmCircleBounds.size.width = palmCircleRadius;
    palmCircleBounds.size.height = palmCircleRadius;
    palmCircleRadius /= 2;
    palmCircleBounds.origin = _centerPoint;
    palmCircleBounds.origin.x -= palmCircleRadius;
    palmCircleBounds.origin.y -= palmCircleRadius;

    LeapHand *leapHand = [_hand leapHand];
    LeapVector *palmPosition;
    if (_enableStable)
        palmPosition = [leapHand stabilizedPalmPosition];
    else
        palmPosition = [leapHand palmPosition];
    
    LeapMatrix *handTransform = [OLKHand transformForHandReference:leapHand];
    LeapVector *transformedPosition = [handTransform transformPoint:leapHand.sphereCenter];

    NSBezierPath *sphereCenter = [NSBezierPath bezierPath];
    float lineWidthHalf = palmCircleBounds.size.width*(leapHand.sphereRadius/150)/2;
    
    float sphereCenterOffset = transformedPosition.z;
    [sphereCenter moveToPoint:NSMakePoint(palmCircleBounds.origin.x + lineWidthHalf, palmCircleBounds.origin.y + palmCircleBounds.size.height/2 - sphereCenterOffset*_fitHandFact.height)];
    
//        NSLog(@"%f,%f,%f", sphereCenterOffset, transformedPosition.y, leapHand.sphereRadius);
//    if ([_hand isFist])
//        NSLog(@"Closed Fist - sphereOffset=%f - sphereRadius=%f", sphereCenterOffset, leapHand.sphereRadius);
//    else
//        NSLog(@"Open Hand - sphereOffset=%f - sphereRadius=%f", sphereCenterOffset, leapHand.sphereRadius);
//    NSLog(@"difference between palm center (%@) and sphere center (%@) differences(%f, %f, %f) transformed (%@) radius(%f) = %f", palmPosition, leapHand.sphereCenter, palmPosition.x - leapHand.sphereCenter.x, palmPosition.y - leapHand.sphereCenter.y, palmPosition.z - leapHand.sphereCenter.z, transformedPosition, leapHand.sphereRadius, sphereCenterOffset);
    [sphereCenter lineToPoint:NSMakePoint(palmCircleBounds.origin.x+palmCircleBounds.size.width - lineWidthHalf, palmCircleBounds.origin.y + palmCircleBounds.size.height/2 - sphereCenterOffset*_fitHandFact.height)];
    [sphereCenter setLineWidth:3];
    [sphereCenter stroke];
}

- (void)drawPalm
{
    [[NSColor grayColor] setStroke];
    NSBezierPath* theHandPath = [NSBezierPath bezierPath];

    
    if (_enableDrawHandBoundingCircle)
        [theHandPath appendBezierPathWithOvalInRect:_bounds];

    if (!_enableDrawPalm)
    {
        [theHandPath stroke];
        if (_palmColor)
        {
            [_palmColor setStroke];
            [theHandPath setLineWidth:3];
            [theHandPath stroke];
        }
        return;
    }

    NSPoint thumbPoint;
    thumbPoint.y = _centerPoint.y;
    
    float handDirY;
    
    if (_enableScreenYAxisUsesZAxis && !_enable3DHand)
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
    if (_enable3DHand)
    {
        palmCircleBounds.size.height *= fabs([[_hand leapHand] palmNormal].z);
        if (palmCircleBounds.size.height == 0)
            palmCircleBounds.size.height = 0.1;
        palmCircleBounds.origin.y += (1-fabs([[_hand leapHand] palmNormal].z))*40;
    }

    [palmDirectionPath appendBezierPathWithOvalInRect:palmCircleBounds];
    NSPoint palmVector;
    palmVector.x = _centerPoint.x + [[_hand leapHand] direction].x*palmCircleRadius;
    palmVector.y = _centerPoint.y - handDirY*palmCircleRadius;
    if (_enable3DHand)
    {
        palmVector.y = _centerPoint.y - handDirY*palmCircleRadius* fabs([[_hand leapHand] palmNormal].z);
    }
    else
        palmVector.y = _centerPoint.y - handDirY*palmCircleRadius;

    [palmDirectionPath moveToPoint:_centerPoint];
    [palmDirectionPath lineToPoint:palmVector];
    [palmDirectionPath setLineWidth:3];
    [palmDirectionPath stroke];
    if (_palmColor)
    {
        [_palmColor setStroke];
        [palmDirectionPath setLineWidth:3];
        [palmDirectionPath stroke];
    }

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
    
    [[NSColor grayColor] setStroke];
    [theHandPath stroke];
    if (_palmColor)
    {
        [_palmColor setStroke];
        [theHandPath setLineWidth:3];
        [theHandPath stroke];
    }
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    _centerPoint.x = (_bounds.origin.x + _bounds.size.width)/2;
    _centerPoint.y = (_bounds.origin.y + _bounds.size.height)/2;

    if (!_enabled)
        return;
    
    if (_enableDrawPalm || _enableDrawHandBoundingCircle)
        [self drawPalm];
    
    if ( _enableSphere)
        [self drawSphereData];
    
    if (_enableDrawFingers || _enableDrawFingerTips)
        [self drawFingers];
}

@end
