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
//  OLKHand.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-16.
//

#import "OLKHand.h"

static OLKHand *gPrevHand=nil;

@implementation OLKHand
{
    NSUInteger _numLeftHandedness, _numRightHandedness;
}

@synthesize leapHand = _leapHand;
@synthesize leapFrame = _leapFrame;
@synthesize thumb = _thumb;
@synthesize handedness = _handedness;
@synthesize numFramesExist = _numFramesExist;
@synthesize simHandedness = _simHandedness;

+ (void)initialize
{
    if (!gPrevHand)
        gPrevHand = [[OLKHand alloc] init];
}

+ (LeapPointable *)furthestFingerOrPointableTipFromPalm:(LeapHand *)hand
{
    NSArray *pointables = [hand pointables];
    if ([pointables count] == 0)
        return nil;
    
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [hand palmPosition];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    handTransform = [handTransform rigidInverse];
    float furthestTipDist = 0;
    LeapPointable *furthestPointable;
    for (LeapPointable *pointable in pointables)
    {
        LeapVector *transformedPosition = [handTransform transformPoint:[pointable tipPosition]];
        float dist = handOrigin.z - transformedPosition.z;
        if (dist > furthestTipDist)
        {
            furthestTipDist = dist;
            furthestPointable = pointable;
        }
    }
    return furthestPointable;
}

+ (OLKHandedness)handednessByThumbTipDistFromPalm:(LeapHand *)hand
{
    if ([[hand fingers] count] == 0)
        return OLKHandednessUnknown;
    
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [hand palmPosition];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    handTransform = [handTransform rigidInverse];
    float avgDist = 0;
    NSUInteger fingerCount = 0;
    
    NSMutableArray *transformedFingers = [[NSMutableArray alloc] init];
    
    for( LeapFinger *finger in [hand fingers])
    {
        LeapVector *transformedPosition = [handTransform transformPoint:[finger tipPosition]];
    
        [transformedFingers addObject:transformedPosition];
        avgDist -= transformedPosition.z;
        fingerCount ++;
    }
    
    fingerCount = 0;

    LeapVector *leftMostFingerVector=nil;
    LeapVector *rightMostFingerVector=nil;
    
    for (LeapFinger *finger in [hand fingers])
    {
        LeapVector *transformedPos = [transformedFingers objectAtIndex:fingerCount];
        
        if (leftMostFingerVector == nil || transformedPos.x < leftMostFingerVector.x)
            leftMostFingerVector = transformedPos;
        if (rightMostFingerVector == nil || transformedPos.x > rightMostFingerVector.x)
            rightMostFingerVector = transformedPos;
        fingerCount ++;
    }

    if (leftMostFingerVector.z > rightMostFingerVector.z)
        avgDist += leftMostFingerVector.z;
    else if (leftMostFingerVector.z < rightMostFingerVector.z)
        avgDist += rightMostFingerVector.z;
    else
        return OLKHandednessUnknown;
    
    avgDist /= fingerCount-1;
    
    //    NSLog(@"avg: %f, leftmost finger: %f, rightmostfinger: %f, ratio left: %f, ratio right: %f", avgDist, leftMostFingerVector.z, rightMostFingerVector.z, -leftMostFingerVector.z/avgDist, -rightMostFingerVector.z/avgDist);
    if (-leftMostFingerVector.z > avgDist*0.55 && -rightMostFingerVector.z > avgDist*0.55)
        return OLKHandednessUnknown;
    
    
    if (leftMostFingerVector.z > rightMostFingerVector.z)
        return OLKRightHand;
    else
        return OLKLeftHand;
}

+ (OLKHandedness)handednessByThumbBasePosToPalm:(LeapHand *)hand thumbId:(int *)pThumbId
{
    if ([[hand fingers] count] == 0)
        return OLKHandednessUnknown;
    
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [hand palmPosition];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    handTransform = [handTransform rigidInverse];
    LeapFinger *finger;
    BOOL foundThumb = false;
    LeapVector *transformedPosition;
    LeapVector *transformedDirection;
    
    for( finger in [hand fingers])
    {
        transformedPosition = [handTransform transformPoint:[finger tipPosition]];
        transformedDirection = [handTransform transformDirection:[finger direction]];
        float fingerBaseZ = transformedPosition.z - transformedDirection.z*[finger length];

        if (fingerBaseZ > 0)
        {
            if (pThumbId)
                *pThumbId = [finger identifier];
            foundThumb = TRUE;
            break;
        }
    }
    
    if (!foundThumb)
        return OLKHandednessUnknown;
    
    float fingerBaseX = transformedPosition.x - transformedDirection.x*[finger length];
    if (fingerBaseX == 0)
        return OLKHandednessUnknown;
    
    if (fingerBaseX < 0)
        return OLKRightHand;
    else
        return OLKLeftHand;
}

+ (OLKHandedness)handednessByThumbTipAndBaseCombo:(LeapHand *)hand thumbId:(int *)pThumbId
{
    if ([[hand fingers] count] == 0)
        return OLKHandednessUnknown;
    
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [hand palmPosition];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    handTransform = [handTransform rigidInverse];
    LeapFinger *finger;
    BOOL foundThumb = false;
    LeapVector *transformedPosition;
    LeapVector *transformedDirection;
    float avgDist = 0;
    NSUInteger fingerCount = 0;
    
    NSMutableArray *transformedFingers = [[NSMutableArray alloc] init];
    
    for (finger in [hand fingers])
    {
        transformedPosition = [handTransform transformPoint:[finger tipPosition]];
        transformedDirection = [handTransform transformDirection:[finger direction]];
        
        [transformedFingers addObject:transformedPosition];
        float fingerBaseZ = transformedPosition.z - transformedDirection.z*[finger length];
        
        if (fingerBaseZ > 10)
        {
            if (pThumbId)
                *pThumbId = [finger identifier];
            foundThumb = TRUE;
            break;
        }
        
        avgDist -= transformedPosition.z;
        fingerCount ++;
    }
    
    if (foundThumb)
    {
        float fingerBaseX = transformedPosition.x - transformedDirection.x*[finger length];
        
        if (fingerBaseX < 0)
        {
//            NSLog(@"Right Handed detected by finger base");
            return OLKRightHand;
        }
        else
        {
//            NSLog(@"Left Handed detected by finger base");
            return OLKLeftHand;
        }
    }

    if ([[hand fingers] count] <= 1)
        return OLKHandednessUnknown;

    fingerCount = 0;
    
    LeapVector *leftMostFingerVector=nil;
    LeapVector *rightMostFingerVector=nil;
    
    for (LeapFinger *finger in [hand fingers])
    {
        LeapVector *transformedPos = [transformedFingers objectAtIndex:fingerCount];
        
        if (leftMostFingerVector == nil || transformedPos.x < leftMostFingerVector.x)
            leftMostFingerVector = transformedPos;
        if (rightMostFingerVector == nil || transformedPos.x > rightMostFingerVector.x)
            rightMostFingerVector = transformedPos;
        fingerCount ++;
    }
    
    if (leftMostFingerVector.z > rightMostFingerVector.z)
        avgDist += leftMostFingerVector.z;
    else if (leftMostFingerVector.z < rightMostFingerVector.z)
        avgDist += rightMostFingerVector.z;
    else
        return OLKHandednessUnknown;
    
    avgDist /= fingerCount-1;

    if (-leftMostFingerVector.z > avgDist*0.5 && -rightMostFingerVector.z > avgDist*0.5)
        return OLKHandednessUnknown;

//    NSLog(@"avg: %f, leftmost finger: %f, rightmostfinger: %f, ratio left: %f, ratio right: %f", avgDist, leftMostFingerVector.z, rightMostFingerVector.z, -leftMostFingerVector.z/avgDist, -rightMostFingerVector.z/avgDist);
    if (leftMostFingerVector.z > rightMostFingerVector.z)
    {
//        NSLog(@"Right Handed detected by finger length");
        return OLKRightHand;
    }
    else
    {
//        NSLog(@"Left Handed detected by finger length");
        return OLKLeftHand;
    }
}

+ (OLKHandedness)handednessByShortestFinger:(LeapHand *)hand
{
    LeapFinger *shortestFinger=nil;
    LeapFinger *rightMostFinger=nil, *secondRightMostFinger=nil;
    LeapFinger *leftMostFinger=nil, *secondLeftMostFinger=nil;
    for (LeapFinger *finger in [hand fingers])
    {
        if (shortestFinger == nil || [finger length] < [shortestFinger length])
            shortestFinger = finger;
        if (rightMostFinger == nil || [finger tipPosition].x > [rightMostFinger tipPosition].x)
        {
            secondRightMostFinger = rightMostFinger;
            rightMostFinger = finger;
        }
        if (leftMostFinger == nil || [finger tipPosition].x < [leftMostFinger tipPosition].x)
        {
            secondLeftMostFinger = leftMostFinger;
            leftMostFinger = finger;
        }
    }
    
    if (rightMostFinger == shortestFinger || secondRightMostFinger == shortestFinger)
    {
        //        NSLog(@"Left Hand Detected!");
        return OLKLeftHand;
    }
    if (leftMostFinger == shortestFinger || secondLeftMostFinger == shortestFinger)
    {
        //        NSLog(@"Right Hand Detected!");
        return OLKRightHand;
    }
    return OLKHandednessUnknown;

}

+ (NSArray *)simpleLeftRightHandSearch:(NSArray *)hands
{
    LeapHand *leftMostHand=nil;
    LeapHand *leftMostLeftHand = nil;
    LeapHand *rightMostHand=nil;
    LeapHand *rightMostRightHand = nil;
    
    for (LeapHand *hand in hands)
    {
        OLKHandedness handedness = [self handednessByThumbTipAndBaseCombo:hand thumbId:nil];
        if (handedness == OLKLeftHand)
        {
            if (leftMostLeftHand == nil || [hand palmPosition].x < [leftMostLeftHand palmPosition].x)
                leftMostLeftHand = hand;
        }
        else if (handedness == OLKRightHand)
        {
            if (rightMostRightHand == nil || [hand palmPosition].x > [rightMostRightHand palmPosition].x)
                rightMostRightHand = hand;
        }
        if (leftMostHand == nil || [hand palmPosition].x < [leftMostHand palmPosition].x)
            leftMostHand = hand;
        
        if (rightMostHand == nil || [hand palmPosition].x < [rightMostHand palmPosition].x)
            rightMostHand = hand;
    }
    
    LeapHand *leftSel = leftMostLeftHand;
    if (leftSel == nil && rightMostRightHand == nil)
        leftSel = leftMostHand;
    
    LeapHand *rightSel = rightMostRightHand;
    if (rightSel == nil && leftMostLeftHand == nil)
        rightSel = rightMostHand;
    
    if (leftSel == nil)
        leftSel = (LeapHand*)[NSNull null];
    if (rightSel == nil || leftSel == rightSel)
        rightSel = (LeapHand*)[NSNull null];
    
    return [NSArray arrayWithObjects:leftSel, rightSel, nil];
}

- (id)init
{
    if (self = [super init])
    {
        _simHandedness = OLKHandednessUnknown;
        _handedness = OLKHandednessUnknown;
    }
    return self;
}

- (BOOL)isLeapHand:(LeapHand *)leapHand
{
    if ([leapHand identifier] == [_leapHand identifier])
        return YES;
    
    return NO;
}

- (void)setLeapHand:(LeapHand *)leapHand
{
    _numFramesExist = 1;
    _leapHand = leapHand;
    _leapFrame = [leapHand frame];
}

- (void)updateLeapHand:(LeapHand *)leapHand
{
    _numFramesExist ++;
    _leapHand = leapHand;
    _leapFrame = [leapHand frame];
}

- (OLKHandedness)defaultHandednessAlgorithm
{
    int thumbId=0;
    OLKHandedness handedness = [OLKHand handednessByThumbTipAndBaseCombo:_leapHand thumbId:&thumbId];
    if (thumbId != 0)
        _thumb = [_leapHand finger:thumbId];
    return handedness;
}

- (OLKHandedness)updateHandedness
{
//    NSLog(@"Left handedness count: %lu; Right handedness count: %lu!", (unsigned long)_numLeftHandedness, (unsigned long)_numRightHandedness);

    OLKHandedness handedness = [self defaultHandednessAlgorithm];
    if (handedness == OLKLeftHand)
        _numLeftHandedness ++;
    else if (handedness == OLKRightHand)
        _numRightHandedness ++;
    else if (_handedness == OLKHandednessUnknown)
        return OLKHandednessUnknown;
    
    if (_numLeftHandedness > _numRightHandedness)
        _handedness = OLKLeftHand;
    else if (_numRightHandedness > _numLeftHandedness)
        _handedness = OLKRightHand;
    
    return _handedness;
}

@end
