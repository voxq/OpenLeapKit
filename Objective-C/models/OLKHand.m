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

+ (LeapMatrix *)transformForHandReference:(LeapHand *)hand
{
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [hand palmPosition];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    return [handTransform rigidInverse];
}

+ (BOOL)isLeapHandPointing:(LeapHand *)leapHand
{
    if ([leapHand.fingers respondsToSelector:@selector(extended)])
    {
        if (leapHand.fingers.extended.count > 3)
            return FALSE;
        
        if ([[leapHand.fingers objectAtIndex:1] isExtended] || [[leapHand.fingers objectAtIndex:2] isExtended])
            return TRUE;
        return FALSE;
    }
    return FALSE;
}

+ (BOOL)isLeapHandFingersMissingOrPinch:(LeapHand *)leapHand
{
    if (!leapHand.fingers.count || ([leapHand respondsToSelector:@selector(pinchStrength)] && leapHand.pinchStrength > 0.8))
        return YES;
    return NO;
}

+ (BOOL)isLeapHandFist:(LeapHand *)leapHand
{
    if (leapHand.fingers.count > 1)
        return NO;
 
    if ([leapHand respondsToSelector:@selector(grabStrength)])
    {
        if (leapHand.grabStrength < 0.8)
            return NO;
        return YES;
    }
    
    LeapMatrix *handTransform = [OLKHand transformForHandReference:leapHand];
    LeapVector *transformedPosition = [handTransform transformPoint:leapHand.sphereCenter];
 
    float sphereCenterOffset = transformedPosition.z;
    if (sphereCenterOffset > 0 || (leapHand.sphereRadius < 90 && sphereCenterOffset > -26 && sphereCenterOffset <= -21) || (leapHand.sphereRadius < 75 && sphereCenterOffset > -21 && sphereCenterOffset <= -15) || (leapHand.sphereRadius < 87 && sphereCenterOffset > -15 && sphereCenterOffset <= -10) || (leapHand.sphereRadius < 110 && sphereCenterOffset > -10))
    {
        //        NSLog(@"Closed Fist - sphereOffset=%f - sphereRadius=%f", sphereCenterOffset, leapHand.sphereRadius);
        return YES;
    }
//    else
//        NSLog(@"Open Hand - sphereOffset=%f - sphereRadius=%f", sphereCenterOffset, leapHand.sphereRadius);
    return NO;
}

+ (LeapPointable *)furthestFingerOrPointableTipFromPalm:(LeapHand *)hand
{
    return [self furthestPointableTip:hand.pointables fromPalm:hand];
}

+ (LeapPointable *)furthestFingerTipFromPalm:(LeapHand *)hand
{
    return [self furthestPointableTip:hand.fingers fromPalm:hand];
}

+ (LeapPointable *)furthestPointableTip:(NSArray *)pointables fromPalm:(LeapHand *)hand
{
    if (!pointables.count)
        return nil;
    
    LeapMatrix *handTransform = [self transformForHandReference:hand];
    float furthestTipDist = 0;
    LeapPointable *furthestPointable;
    for (LeapPointable *pointable in pointables)
    {
        LeapVector *transformedPosition = [handTransform transformPoint:[pointable tipPosition]];
        if (transformedPosition.z < furthestTipDist)
        {
            furthestTipDist = transformedPosition.z;
            furthestPointable = pointable;
        }
    }
    return furthestPointable;
}

+ (NSArray *)pointablesFurthestToClosestFromPalm:(LeapHand *)hand pointables:(NSArray *)pointables
{
    if (!pointables.count)
        return nil;
    
    NSMutableArray *fingersTransformedPosEntries = [[NSMutableArray alloc] initWithCapacity:pointables.count];
    LeapMatrix *handTransform = [self transformForHandReference:hand];
    for (LeapPointable *pointable in pointables)
    {
        LeapVector *transformedPosition = [handTransform transformPoint:[pointable tipPosition]];
        NSArray *fingerEntry = [NSArray arrayWithObjects:pointable, transformedPosition, nil];
        int i = 0;
        BOOL inserted = NO;
        NSArray *checkFingerEntry;
        for (checkFingerEntry in [fingersTransformedPosEntries copy])
        {
            LeapVector *otherTransformedPos = [checkFingerEntry objectAtIndex:1];
            if (transformedPosition.z < otherTransformedPos.z)
            {
                [fingersTransformedPosEntries insertObject:fingerEntry atIndex:i];
                inserted = YES;
            }
            i ++;
        }
        if (!inserted)
            [fingersTransformedPosEntries addObject:fingerEntry];
    }
    return [fingersTransformedPosEntries copy];
}

+ (NSArray *)fingerTipsFurthestToClosestFromPalm:(LeapHand *)hand
{
    return [self pointablesFurthestToClosestFromPalm:hand pointables:hand.fingers];
}

+ (OLKHandedness)handednessByThumbTipDistFromPalm:(LeapHand *)hand thumb:(LeapFinger **)pThumb
{
    if ([[hand fingers] count] == 0)
        return OLKHandednessUnknown;
    
    LeapMatrix *handTransform = [self transformForHandReference:hand];
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
    
    LeapMatrix *handTransform = [self transformForHandReference:hand];
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
    
    LeapMatrix *handTransform = [self transformForHandReference:hand];
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
    LeapMatrix *handTransform = [self transformForHandReference:hand];
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

+ (NSDictionary *)leftRightHandSearch:(NSArray *)hands ignoreHands:(NSSet *)ignoreHands handednessAlgorithm:(OLKHandednessAlgorithm)handednessAlgorithm factory:(NSObject<OLKHandFactory>*)factory
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
        
        OLKHand *hand;
        if (factory)
            hand = [factory manufactureHand:leapHand];
        else
            hand = [[OLKHand alloc] init];
        
        [hand setHandednessAlgorithm:handednessAlgorithm];
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

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSUInteger)hash
{
    return [_leapHand id];
}

- (BOOL)isEqual:(id)object
{
    if (![_leapHand isValid] || !object)
        return NO;
    
    if (![object isKindOfClass:[OLKHand class]])
        return NO;
    
    LeapHand *otherHand = (LeapHand *)[object leapHand];
    if ([otherHand isValid] && [_leapHand id] == [otherHand id])
        return YES;

    return NO;
}

- (BOOL)isLeapHand:(LeapHand *)leapHand
{
    if ([leapHand id] == [_leapHand id])
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

- (BOOL)isFist
{
    return [OLKHand isLeapHandFist:_leapHand];
}

- (BOOL)isLeftHand
{
    if ([_leapHand respondsToSelector:@selector(isLeft)])
        return [_leapHand isLeft];

    return [self updateHandedness] == OLKLeftHand;
}

- (BOOL)isRightHand
{
    if ([_leapHand respondsToSelector:@selector(isRight)])
        return [_leapHand isRight];
    
    return [self updateHandedness] == OLKRightHand;
}

- (LeapFinger *)thumb
{
    if ([_leapHand respondsToSelector:@selector(isLeft)])
        return [_leapHand.fingers objectAtIndex:0];

    if (_thumb)
        return _thumb;
    
    [self updateHandednessByThumbTipAndBaseCombo];
    return _thumb;
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

- (LeapVector *)longFingerTipPos
{
    LeapPointable *finger = [OLKHand furthestFingerOrPointableTipFromPalm:_leapHand];
    if (![finger isValid])
        return nil;
    
    if (_usesStabilized)
        return finger.stabilizedTipPosition;
    
    return finger.tipPosition;
}

- (LeapVector *)longFingerTipRelativePos
{
    LeapVector *tipPos = self.longFingerTipPos;
    if (!tipPos)
        return nil;

    return [tipPos minus:self.palmPosition];
}

- (NSArray *)extendedFingers
{
    NSMutableArray *extFingers = [[NSMutableArray alloc] init];
    for (LeapFinger *finger in _leapHand.fingers)
    {
        if (finger.direction.z > 0.8)
            [extFingers addObject:finger];
    }
    return [extFingers copy];
}

- (LeapFinger *)pointingFinger
{
    LeapFinger *pointFinger;
    if ([_leapHand.fingers respondsToSelector:@selector(extended)])
    {
//        if (_leapHand.fingers.extended.count > 3)
//            return nil;
        
        pointFinger = [_leapHand.fingers objectAtIndex:2];
        LeapFinger *finger3 = [_leapHand.fingers objectAtIndex:3];
        LeapFinger *finger4 = [_leapHand.fingers objectAtIndex:4];
        if (!pointFinger.isExtended && !finger3.isExtended && !finger4.isExtended)
        {
            pointFinger = [_leapHand.fingers objectAtIndex:1];
            if (!pointFinger.isExtended)
                return nil;
        }
        return pointFinger;
    }

    if (!_leapHand.fingers.count)
        return nil;

    NSArray *extFingers = [self extendedFingers];
    if (!extFingers.count || extFingers.count > 3)
        return nil;
    
    NSArray *fingers = [OLKHand pointablesFurthestToClosestFromPalm:_leapHand pointables:extFingers];
    NSArray *longFingerEntry = [fingers objectAtIndex:0];
    pointFinger = [longFingerEntry objectAtIndex:0];
    
    return pointFinger;
}

- (LeapVector *)longFingerTipPalmPosAdapt
{
    if (!_leapHand.fingers.count)
        return [_leapHand palmPosition];

    LeapFinger *pointingFinger = [self pointingFinger];
    
    if (!pointingFinger)
        return [_leapHand palmPosition];
    
    if (_usesStabilized)
        return pointingFinger.stabilizedTipPosition;
    
    return pointingFinger.tipPosition;
}

- (BOOL)fingersMissingOrPinch
{
    return [OLKHand isLeapHandFingersMissingOrPinch:_leapHand];
}

- (BOOL)isPointing
{
    return [OLKHand isLeapHandPointing:_leapHand];
}

- (LeapVector *)palmPosition
{
    if (_usesStabilized)
        return [_leapHand stabilizedPalmPosition];

    return [_leapHand palmPosition];
}

- (LeapVector *)direction
{
    return [_leapHand direction];
}

- (LeapVector *)palmNormal
{
    return [_leapHand palmNormal];
}

- (NSArray *)fingerPositionsTransformedToHand
{
    LeapMatrix *handTransform = [OLKHand transformForHandReference:_leapHand];
    NSMutableArray *transFingers = [[NSMutableArray alloc] initWithCapacity:_leapHand.fingers.count];
    for (LeapFinger *finger in _leapHand.fingers)
    {
        [transFingers addObject:[handTransform transformPoint:finger.tipPosition]];
    }
    return [transFingers copy];
}

@end
