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
@synthesize handednessAlgorithm = _handednessAlgorithm;
@synthesize usesStabilized = _usesStabilized;

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

+ (OLKHandedness)handednessByThumbTipDistFromPalm:(LeapHand *)hand thumb:(LeapFinger **)pThumb
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

+ (OLKHandedness)handednessByThumbBasePosToPalm:(LeapHand *)hand thumb:(LeapFinger **)pThumb
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
            if (pThumb)
                *pThumb = finger;
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

+ (OLKHandedness)handednessByThumbTipAndBaseCombo:(LeapHand *)hand thumb:(LeapFinger **)pThumb
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
            if (pThumb)
                *pThumb = finger;
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

+ (OLKHandedness)handednessByShortestFinger:(LeapHand *)hand thumb:(LeapFinger **)pThumb
{
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [hand palmPosition];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    handTransform = [handTransform rigidInverse];
    LeapFinger *finger;
    LeapVector *transformedPosition;
    LeapVector *rightmostTransformedPosition;
    LeapVector *leftmostTransformedPosition;
    LeapFinger *shortestFinger=nil;
    LeapFinger *rightMostFinger=nil, *secondRightMostFinger=nil;
    LeapFinger *leftMostFinger=nil, *secondLeftMostFinger=nil;
    
    for( finger in [hand fingers])
    {
        transformedPosition = [handTransform transformPoint:[finger tipPosition]];

        if (shortestFinger == nil || [finger length] < [shortestFinger length])
            shortestFinger = finger;
        if (rightMostFinger == nil || transformedPosition.x > rightmostTransformedPosition.x)
        {
            rightmostTransformedPosition = transformedPosition;
            secondRightMostFinger = rightMostFinger;
            rightMostFinger = finger;
        }
        if (leftMostFinger == nil || transformedPosition.x < leftmostTransformedPosition.x)
        {
            leftmostTransformedPosition = transformedPosition;
            secondLeftMostFinger = leftMostFinger;
            leftMostFinger = finger;
        }
    }
    if (rightMostFinger == shortestFinger || secondRightMostFinger == shortestFinger)
    {
        *pThumb = shortestFinger;
        //        NSLog(@"Left Hand Detected!");
        return OLKLeftHand;
    }
    if (leftMostFinger == shortestFinger || secondLeftMostFinger == shortestFinger)
    {
        *pThumb = shortestFinger;
        //        NSLog(@"Right Hand Detected!");
        return OLKRightHand;
    }
    return OLKHandednessUnknown;

}

+ (NSDictionary *)leftRightHandSearch:(NSArray *)hands ignoreHands:(NSSet *)ignoreHands handednessAlgorithm:(OLKHandednessAlgorithm)handednesAlgorithm
{
    if (!hands || ![hands count])
        return nil;
    
    NSMutableDictionary *handDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *leftHands = [[NSMutableArray alloc] init];
    NSMutableArray *rightHands = [[NSMutableArray alloc] init];
    NSMutableArray *unknownHands = [[NSMutableArray alloc] init];
    OLKHand *leftMostHand=nil;
    OLKHand *leftMostLeftHand = nil;
    OLKHand *rightMostHand=nil;
    OLKHand *rightMostRightHand = nil;
    LeapHand *leftMostLeapHand=nil;
    LeapHand *leftMostLeapLeftHand = nil;
    LeapHand *rightMostLeapHand=nil;
    LeapHand *rightMostLeapRightHand = nil;
    
    for (LeapHand *leapHand in hands)
    {
        if ([ignoreHands containsObject:leapHand])
            continue;
        
        OLKHand *hand = [[OLKHand alloc] init];
        [hand setHandednessAlgorithm:handednesAlgorithm];
        [hand setLeapHand:leapHand];
        
        OLKHandedness handedness = [hand updateHandedness];
        NSMutableArray *handednessHands;
        if (handedness == OLKLeftHand)
        {
            handednessHands = leftHands;
            if (leftMostLeapLeftHand == nil || [leapHand palmPosition].x < [leftMostLeapLeftHand palmPosition].x)
            {
                leftMostLeftHand = hand;
                leftMostLeapLeftHand = leapHand;
            }
        }
        else if (handedness == OLKRightHand)
        {
            handednessHands = rightHands;
            if (rightMostLeapRightHand == nil || [leapHand palmPosition].x > [rightMostLeapRightHand palmPosition].x)
            {
                rightMostRightHand = hand;
                rightMostLeapRightHand = leapHand;
            }
        }
        else
            handednessHands = unknownHands;

        [handednessHands addObject:hand];
        if (leftMostLeapHand == nil || [leapHand palmPosition].x < [leftMostLeapHand palmPosition].x)
        {
            leftMostHand = hand;
            leftMostLeapHand = leapHand;
        }
        if (rightMostLeapHand == nil || [leapHand palmPosition].x < [rightMostLeapHand palmPosition].x)
        {
            rightMostHand = hand;
            rightMostLeapHand = leapHand;
        }
    }
    
    OLKHand *leftSel = leftMostLeftHand;
    if (leftSel == nil && rightMostRightHand == nil)
        leftSel = leftMostHand;
    
    OLKHand *rightSel = rightMostRightHand;
    if (rightSel == nil && leftMostLeftHand == nil)
        rightSel = rightMostHand;
    
    if (leftSel != nil)
        [handDict setObject:leftSel forKey:OLKHandBestLeftGuessKey];
    if (rightSel != nil && leftSel == rightSel)
        [handDict setObject:rightSel forKey:OLKHandBestRightGuessKey];
    if ([leftHands count])
        [handDict setObject:[NSArray arrayWithArray:leftHands] forKey:OLKHandLeftHandsKey];
    if ([rightHands count])
        [handDict setObject:[NSArray arrayWithArray:rightHands] forKey:OLKHandRightHandsKey];
    if ([unknownHands count])
        [handDict setObject:[NSArray arrayWithArray:unknownHands] forKey:OLKHandUnknownHandednessKey];
    return [NSDictionary dictionaryWithDictionary:handDict];
 
}

+ (NSArray *)simpleLeftRightHandSearch:(NSArray *)hands
{
    LeapHand *leftMostHand=nil;
    LeapHand *leftMostLeftHand = nil;
    LeapHand *rightMostHand=nil;
    LeapHand *rightMostRightHand = nil;
    
    for (LeapHand *hand in hands)
    {
        OLKHandedness handedness = [self handednessByThumbTipAndBaseCombo:hand thumb:nil];
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
        _handednessAlgorithm = OLKHandednessAlgorithmThumbTipAndBase;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![_leapHand isValid] || !object)
        return NO;
    
    if (![object isKindOfClass:[OLKHand class]])
        return NO;
    
    LeapHand *otherHand = (LeapHand *)[object leapHand];
    if ([otherHand isValid] && [_leapHand identifier] == [otherHand identifier])
        return YES;

    return NO;
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

- (OLKHandedness)updateHandednessByThumbTipDistFromPalm
{
    LeapFinger *thumb=nil;
    OLKHandedness handedness = [OLKHand handednessByThumbTipAndBaseCombo:_leapHand thumb:&thumb];
    if (thumb)
        _thumb = thumb;
    [self updateHandednessWithAverage:handedness];
    return _handedness;
}

- (OLKHandedness)updateHandednessByThumbBasePosToPalm
{
    LeapFinger *thumb=nil;
    OLKHandedness handedness = [OLKHand handednessByThumbBasePosToPalm:_leapHand thumb:&thumb];
    if (thumb)
        _thumb = thumb;
    [self updateHandednessWithAverage:handedness];
    return _handedness;
}

- (OLKHandedness)updateHandednessByShortestFinger
{
    LeapFinger *thumb=nil;
    OLKHandedness handedness = [OLKHand handednessByShortestFinger:_leapHand thumb:&thumb];
    if (thumb)
        _thumb = thumb;
    [self updateHandednessWithAverage:handedness];
    return _handedness;
}

- (OLKHandedness)updateHandednessByThumbTipAndBaseCombo
{
    LeapFinger *thumb=nil;
    OLKHandedness handedness = [OLKHand handednessByThumbTipAndBaseCombo:_leapHand thumb:&thumb];
    if (thumb)
        _thumb = thumb;
    [self updateHandednessWithAverage:handedness];
    
    return _handedness;
}

- (void)updateHandednessWithAverage:(OLKHandedness)handedness
{
    if (handedness == OLKLeftHand)
        _numLeftHandedness ++;
    else if (handedness == OLKRightHand)
        _numRightHandedness ++;
    else if (_handedness == OLKHandednessUnknown)
        return;
    
    if (_numLeftHandedness > _numRightHandedness)
        _handedness = OLKLeftHand;
    else if (_numRightHandedness > _numLeftHandedness)
        _handedness = OLKRightHand;
}

- (OLKHandedness)updateHandedness
{
//    NSLog(@"Left handedness count: %lu; Right handedness count: %lu!", (unsigned long)_numLeftHandedness, (unsigned long)_numRightHandedness);
    switch (_handednessAlgorithm)
    {
        case OLKHandednessAlgorithmThumbTipAndBase:
            [self updateHandednessByThumbTipAndBaseCombo];
            break;
        case OLKHandednessAlgorithmThumbBasePos:
            [self updateHandednessByThumbBasePosToPalm];
            break;
        case OLKHandednessAlgorithmThumbShortest:
            [self updateHandednessByShortestFinger];
            break;
        case OLKHandednessAlgorithmHandPos:
            return _handedness;
            break;
    }
    
    return _handedness;
}

@end
