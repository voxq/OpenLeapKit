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
    int _prevIndexFingerId;
    int _prevMainTool;
}

@synthesize leapHand = _leapHand;
@synthesize leapFrame = _leapFrame;
@synthesize thumb = _thumb;
@synthesize handedness = _handedness;
@synthesize numFramesExist = _numFramesExist;
@synthesize simHandedness = _simHandedness;
@synthesize handednessAlgorithm = _handednessAlgorithm;
@synthesize usesStabilized = _usesStabilized;
@synthesize directionFactor = _directionFactor;
@synthesize directionFactorOffsetPalm = _directionFactorOffsetPalm;
@synthesize offsetYForAim = _offsetYForAim;
@synthesize pointableFactorOffsetPalm = _pointableFactorOffsetPalm;
@synthesize toolFactorOffsetPalm = _toolFactorOffsetPalm;
@synthesize fingerFactorOffsetPalm = _fingerFactorOffsetPalm;
@synthesize pointableFactorPosRelPalm = _pointableFactorPosRelPalm;
@synthesize toolFactorPosRelPalm = _toolFactorPosRelPalm;
@synthesize fingerFactorPosRelPalm = _fingerFactorPosRelPalm;

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

+ (LeapMatrix *)transformForNormalizedHandReference:(LeapHand *)hand
{
    LeapVector *handXBasis =  [[[hand palmNormal] cross:[hand direction] ] normalized];
    LeapVector *handYBasis = [[hand palmNormal] negate];
    LeapVector *handZBasis = [[hand direction] negate];
    LeapVector *handOrigin =  [LeapVector zero];
    LeapMatrix *handTransform = [[LeapMatrix alloc] initWithXBasis:handXBasis yBasis:handYBasis zBasis:handZBasis origin:handOrigin];
    return [handTransform rigidInverse];
}

+ (BOOL)isLeapHandPointing:(LeapHand *)leapHand
{
#ifdef __LEAP_RIGGED__
    if (leapHand.fingers.extended.count > 3)
        return FALSE;
    
    if ([[leapHand.fingers objectAtIndex:1] isExtended] || [[leapHand.fingers objectAtIndex:2] isExtended])
        return TRUE;
#endif
    return FALSE;
}

+ (BOOL)isLeapHandFingersMissingOrPinch:(LeapHand *)leapHand
{
#ifdef __LEAP_RIGGED__
    if (!leapHand.fingers.count && leapHand.pinchStrength > 0.8)
        return YES;
#else
    return NO;
#endif
}

+ (BOOL)isLeapHandFist:(LeapHand *)leapHand
{
    if (leapHand.fingers.count > 1)
        return NO;
 
#ifdef __LEAP_RIGGED__
    if (leapHand.grabStrength < 0.8)
        return NO;
    return YES;
#else
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
#endif
}

+ (LeapPointable *)furthestFingerOrPointableTipFromPalm:(LeapHand *)hand
{
    return [self furthestPointableTip:hand.pointables fromPalm:hand];
}

+ (LeapFinger *)furthestFingerTipFromPalm:(LeapHand *)hand
{
    return (LeapFinger *)[self furthestPointableTip:hand.fingers fromPalm:hand];
}

+ (LeapPointable *)furthestPointableTip:(NSArray *)pointables fromPalm:(LeapHand *)hand
{
    if (!pointables.count)
        return nil;
    
    float furthestTipDist = 0;
    LeapPointable *furthestPointable;
    for (LeapPointable *pointable in pointables)
    {
        float dist = [pointable.tipPosition distanceTo:hand.palmPosition];
        if (dist > furthestTipDist)
        {
            furthestTipDist = dist;
            furthestPointable = pointable;
        }
    }
    return furthestPointable;
}

+ (LeapPointable *)deepestPointableTip:(NSArray *)pointables fromPalm:(LeapHand *)hand
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

+ (NSArray *)transFingerTipPositionsSortedForHand:(LeapHand *)hand
{
    NSMutableArray *fingersTransformedPosEntries = [[NSMutableArray alloc] initWithCapacity:hand.fingers.count];
    LeapMatrix *handTransform = [self transformForHandReference:hand];
    for (LeapFinger *finger in hand.fingers)
    {
        LeapVector *transformedPosition = [handTransform transformPoint:finger.tipPosition];
        NSArray *fingerEntry = [NSArray arrayWithObjects:finger, transformedPosition, nil];
#ifdef __LEAP_RIGGED__
        [fingersTransformedPosEntries addObject:fingerEntry];
#else
        int i = 0;
        BOOL inserted = NO;
        NSArray *checkFingerEntry;
        for (checkFingerEntry in [fingersTransformedPosEntries copy])
        {
            LeapVector *otherTransformedPos = [checkFingerEntry objectAtIndex:1];
            if (transformedPosition.x < otherTransformedPos.x)
            {
                [fingersTransformedPosEntries insertObject:fingerEntry atIndex:i];
                inserted = YES;
                break;
            }
            i ++;
        }
        if (!inserted)
            [fingersTransformedPosEntries addObject:fingerEntry];
#endif
    }
    return [fingersTransformedPosEntries copy];
}

+ (NSArray *)transFingerTipDirectionsAndPositionsSortedForHand:(LeapHand *)hand
{
    NSMutableArray *fingersTransformedPosEntries = [[NSMutableArray alloc] initWithCapacity:hand.fingers.count];
    LeapMatrix *handTransform = [self transformForHandReference:hand];
    LeapMatrix *handNormalizedTransform = [self transformForNormalizedHandReference:hand];
    for (LeapFinger *finger in hand.fingers)
    {
        LeapVector *transformedPosition = [handTransform transformPoint:finger.tipPosition];
        LeapVector *transformedDirection = [handNormalizedTransform transformPoint:finger.direction];
        NSArray *fingerEntry = [NSArray arrayWithObjects:finger, transformedPosition, transformedDirection, nil];
#ifdef __LEAP_RIGGED__
        [fingersTransformedPosEntries addObject:fingerEntry];
#else
        int i = 0;
        BOOL inserted = NO;
        NSArray *checkFingerEntry;
        for (checkFingerEntry in [fingersTransformedPosEntries copy])
        {
            LeapVector *otherTransformedPos = [checkFingerEntry objectAtIndex:1];
            if (transformedPosition.x < otherTransformedPos.x)
            {
                [fingersTransformedPosEntries insertObject:fingerEntry atIndex:i];
                inserted = YES;
                break;
            }
            i ++;
        }
        if (!inserted)
            [fingersTransformedPosEntries addObject:fingerEntry];
#endif
    }
    return [fingersTransformedPosEntries copy];
}

+ (NSArray *)transFingerTipDirectionsSortedForHand:(LeapHand *)hand
{
#ifndef __LEAP_RIGGED__
    return [self transFingerTipDirectionsAndPositionsSortedForHand:hand];
#else
    NSMutableArray *fingersTransformedPosEntries = [[NSMutableArray alloc] initWithCapacity:hand.fingers.count];
    LeapMatrix *handNormalizedTransform = [self transformForNormalizedHandReference:hand];
    for (LeapFinger *finger in hand.fingers)
    {
        LeapVector *transformedDirection = [handNormalizedTransform transformPoint:finger.direction];
        NSArray *fingerEntry = [NSArray arrayWithObjects:finger, transformedDirection, nil];
        [fingersTransformedPosEntries addObject:fingerEntry];
    }
    return [fingersTransformedPosEntries copy];
#endif
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
                break;
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
        _directionFactor = NSMakeSize(300, 300);
        _prevIndexFingerId = 0;
        _prevMainTool = 0;
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
    _leapFrame = [leapHand frame];
    if ([leapHand isKindOfClass:[LeapFingerAsLeapHand class]])
    {
        ((LeapFingerAsLeapHand *)_leapHand).fingerToMapToHand = ((LeapFingerAsLeapHand *)leapHand).fingerToMapToHand;
        ((LeapFingerAsLeapHand *)_leapHand).isTouching = ((LeapFingerAsLeapHand *)leapHand).isTouching;
        return;
    }
    _leapHand = leapHand;
}

- (BOOL)isFist
{
    return [OLKHand isLeapHandFist:_leapHand];
}

- (BOOL)isLeftHand
{
#ifdef __LEAP_RIGGED__
    return [_leapHand isLeft];
#else
    return [self updateHandedness] == OLKLeftHand;
#endif
}

- (BOOL)isRightHand
{
#ifdef __LEAP_RIGGED__
    return [_leapHand isRight];
#else
    return [self updateHandedness] == OLKRightHand;
#endif
}

- (LeapFinger *)thumb
{
#ifdef __LEAP_RIGGED__
    return [_leapHand.fingers objectAtIndex:0];
#else
    if (_thumb)
        return _thumb;
    
    [self updateHandednessByThumbTipAndBaseCombo];
    return _thumb;
#endif
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
    LeapPointable *finger;
    return [self longFingerTipPos:&finger];
}

- (LeapVector *)longFingerTipPos:(LeapFinger **)pFinger
{
    LeapFinger *finger = [OLKHand furthestFingerTipFromPalm:_leapHand];
    if (![finger isValid])
        return nil;
    
    *pFinger = finger;
    return [self factorPointableOffsetRelativePalm:[self tipPosition:finger] factor:_fingerFactorOffsetPalm];
}

- (LeapVector *)longFingerTipRelativePos
{
    LeapFinger *finger = [OLKHand furthestFingerTipFromPalm:_leapHand];
    if (![finger isValid])
        return nil;
    
    return [self factorPointablePosRelativePalm:[self tipPosition:finger] factor:_fingerFactorPosRelPalm];
}

- (NSArray *)extendedFingers
{
    NSMutableArray *extFingers = [[NSMutableArray alloc] init];
    NSArray *fingerDirections = [self fingersTransformedToHand];
#ifdef __LEAP_RIGGED__
    int i=0;
    for (LeapFinger *finger in _leapHand.fingers)
    {
        LeapVector *dir = [fingerDirections objectAtIndex:i];
        i++;
#else
    for (NSArray *fingerDirEntry in  fingerDirections)
    {
        LeapVector *dir = [fingerDirEntry objectAtIndex:2];
        LeapFinger *finger = [fingerDirEntry objectAtIndex:0];
#endif
        if (dir.z < -0.3 && dir.x > -0.35 && dir.x < 0.35)
            [extFingers addObject:finger];
    }
    return [extFingers copy];
}

- (NSArray *)extendedFingersTransformed
{
    NSMutableArray *extFingers = [[NSMutableArray alloc] init];
#ifdef __LEAP_RIGGED__
    LeapMatrix *handTransform = [OLKHand transformForHandReference:_leapHand];
    LeapMatrix *handNormalizedTransform = [OLKHand transformForNormalizedHandReference:_leapHand];
    for (LeapFinger *finger in _leapHand.fingers)
    {
        if (!finger.isExtended)
              continue;
        LeapVector *transformedPosition = [handTransform transformPoint:[finger tipPosition]];
        LeapVector *transformedDirection = [handNormalizedTransform transformPoint:[finger direction]];
        [extFingers addObject:[NSArray arrayWithObjects:finger, transformedPosition, transformedDirection, nil]];

#else
        NSArray *fingerDirections = [self fingersTransformedToHand];
        for (NSArray *fingerDirEntry in  fingerDirections)
        {
            LeapVector *pos = [fingerDirEntry objectAtIndex:1];
            LeapVector *dir = [fingerDirEntry objectAtIndex:2];
            if (pos.magnitude > 80)
//        if (dir.z < -0.3 && dir.x > -0.35 && dir.x < 0.35)
            [extFingers addObject:fingerDirEntry];
#endif
    }
    return [extFingers copy];
}

- (LeapFinger *)pointingFinger
{
    LeapFinger *pointFinger;
#ifdef __LEAP_RIGGED__
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
#else
    if (!_leapHand.fingers.count)
        return nil;
    
    NSArray *extFingers = [self extendedFingersTransformed];
    if (!extFingers.count || extFingers.count > 2)
        return nil;
    
    if (extFingers.count == 2)
    {
        float finger1Mag = [[[extFingers objectAtIndex:0] objectAtIndex:1] magnitude];
        float finger2Mag = [[[extFingers objectAtIndex:1] objectAtIndex:1] magnitude];
        if (finger1Mag > finger2Mag)
        {
            if (finger1Mag/finger2Mag > 0.55)
                return nil;
        }
        else if (finger2Mag/finger1Mag > 0.55)
            return nil;
    }
//    NSArray *fingers = [OLKHand pointablesFurthestToClosestFromPalm:_leapHand pointables:extFingers];
//    NSArray *longFingerEntry = [fingers objectAtIndex:0];
//    pointFinger = [longFingerEntry objectAtIndex:0];
    pointFinger = [[extFingers objectAtIndex:0] objectAtIndex:0];
    
    return pointFinger;
#endif
}

- (LeapFinger *)indexFinger
{
#ifdef __LEAP_RIGGED__
    
    return [_leapHand.fingers objectAtIndex:1];
#else

    if (!_leapHand.fingers.count)
        return nil;

    LeapFinger *finger;
    if (_prevIndexFingerId)
    {
        finger = [_leapHand finger:_prevIndexFingerId];
        if (finger && finger.isValid)
            return finger;
        _prevIndexFingerId = 0;
    }
    
    if (abs((int)_numLeftHandedness - (int)_numRightHandedness) <= 150)
        [self updateHandedness];
    if (_leapHand.fingers.count == 5)
    {
        NSArray *orderedFingers = [OLKHand transFingerTipPositionsSortedForHand:_leapHand];
        
        int indexFingerPos;
        
        if (self.handedness == OLKLeftHand)
            indexFingerPos = 3;
        else
            indexFingerPos = 1;
        finger = [[orderedFingers objectAtIndex:indexFingerPos] objectAtIndex:0];
        if (abs((int)_numLeftHandedness - (int)_numRightHandedness) > 150)
            _prevIndexFingerId = finger.id;
        return finger;
    }
    
    NSArray *extFingers = [self extendedFingers];
    if (!extFingers.count || extFingers.count > 1)
        return nil;
    
    int indexFingerPos;
    if (self.handedness == OLKLeftHand)
        indexFingerPos = extFingers.count - 1;
    else
        indexFingerPos = 0;
    finger = [extFingers objectAtIndex:indexFingerPos];
    if (abs((int)_numLeftHandedness - (int)_numRightHandedness) > 150)
        _prevIndexFingerId = finger.id;
    return finger;
#endif
}

- (LeapVector *)indexFingerTipPosRelativePalm
{
    LeapFinger *finger=[self indexFinger];
    if (!finger || !finger.isValid)
        return [[LeapVector alloc] initWithX:0 y:_offsetYForAim z:0];

    return [self factorPointablePosRelativePalm:[self tipPosition:finger] factor:_fingerFactorPosRelPalm];
}

- (LeapVector *)indexFingerTipOrPalmPos
{
    LeapFinger *finger;
    LeapVector *position = [self indexFingerTipPos:&finger];
    if (finger)
        return position;
    
    return [self palmPosition];
}

- (LeapVector *)indexFingerTipPos
{
    LeapFinger *finger;
    return [self indexFingerTipPos:&finger];
}

- (LeapVector *)indexFingerTipPos:(LeapFinger **)pFinger
{
    LeapFinger *finger=nil;
    finger = [self indexFinger];
    if (finger)
    {
        *pFinger = finger;
        return [self factorPointableOffsetRelativePalm:[self tipPosition:finger] factor:_fingerFactorOffsetPalm];
    }
    
    *pFinger = nil;
    return nil;
}

- (LeapPointable *)mainTool
{
    if (!_leapHand.tools.count)
    {
        _prevMainTool = 0;
        return nil;
    }
    
    LeapPointable *pointable;
    if (_prevMainTool)
    {
        pointable = [_leapHand tool:_prevMainTool];
        if (pointable.isValid)
            return pointable;
    }
    pointable = [_leapHand.tools objectAtIndex:0];
    _prevMainTool = pointable.id;
    return pointable;
}

- (LeapVector *)mainToolTipPosRelativePalm
{
    LeapPointable *pointable=[self mainTool];
    
    if (!pointable)
        return [[LeapVector alloc] initWithX:0 y:_offsetYForAim z:0];
    
    return [self factorPointablePosRelativePalm:[self tipPosition:pointable] factor:_toolFactorOffsetPalm];
}

- (LeapVector *)mainToolTipPos
{
    LeapPointable *tool;
    return [self mainToolTipPos:&tool];
}

- (LeapVector *)mainToolTipPos:(LeapPointable **)pTool
{
    *pTool = [self mainTool];

    if (*pTool)
        return [self factorPointableOffsetRelativePalm:[self tipPosition:*pTool] factor:_toolFactorOffsetPalm];
    
    return nil;
}

- (LeapVector *)mainToolTipOrPalmPos
{
    LeapVector *position = [self mainToolTipPos];
    if (position)
        return position;
    
    return [self palmPosition];
}

- (LeapVector *)longFingerTipOrPalmPos
{
    if (!_leapHand.fingers.count)
        return self.palmPosition;
    
    LeapVector *tipPosition = self.longFingerTipPos;
    
    if (!tipPosition)
        return self.palmPosition;
    
    return tipPosition;
}

- (LeapVector *)pointingFingerTipPos
{
    if (!_leapHand.fingers.count)
        return nil;
    
    LeapFinger *pointingFinger = [self pointingFinger];
    
    if (!pointingFinger)
        return nil;
    
    return [self factorPointableOffsetRelativePalm:[self tipPosition:pointingFinger] factor:_fingerFactorOffsetPalm];
}

- (LeapVector *)pointingFingerTipOrPalmPos
{
    if (!_leapHand.fingers.count)
        return self.palmPosition;
    
    LeapFinger *pointingFinger = [self pointingFinger];
    
    if (!pointingFinger)
        return self.palmPosition;
    
    return [self factorPointableOffsetRelativePalm:[self tipPosition:pointingFinger] factor:_fingerFactorOffsetPalm];
}

- (LeapVector *)pointingFingerTipPosRelativePalm
{
    LeapPointable *pointable=[self pointingFinger];
    
    if (!pointable)
        return [[LeapVector alloc] initWithX:0 y:_offsetYForAim z:0];
    
    return [self factorPointablePosRelativePalm:[self tipPosition:pointable] factor:_fingerFactorPosRelPalm];
}

- (LeapVector *)tipPosition:(LeapPointable *)pointable
{
    LeapVector *tipPosition;
    
    if (_usesStabilized)
        tipPosition = pointable.stabilizedTipPosition;
    else
        tipPosition = pointable.tipPosition;
    
    return tipPosition;
}

- (LeapVector *)factorPointableOffsetRelativePalm:(LeapVector *)position factor:(NSSize)factor
{
    return [[LeapVector alloc] initWithX:[self palmPosition].x + (position.x - [self palmPosition].x)*factor.width y:[self palmPosition].y + (position.y - [self palmPosition].y)*factor.height z:position.z];
}

- (LeapVector *)factorPointablePosRelativePalm:(LeapVector *)position factor:(NSSize)factor
{
    return [[LeapVector alloc] initWithX:(position.x - [self palmPosition].x)*factor.width y:_offsetYForAim+(position.y - [self palmPosition].y)*factor.height z:position.z];
}

- (LeapVector *)posFromAim
{
    return [[LeapVector alloc] initWithX:_leapHand.direction.x*_directionFactor.width y:_offsetYForAim + _leapHand.direction.y*_directionFactor.height z:0];
}

- (LeapVector *)palmPosPlusAimOffset
{
    LeapVector *palmPosition = [self palmPosition];
    return [[LeapVector alloc] initWithX:palmPosition.x+_leapHand.direction.x*_directionFactorOffsetPalm.width y:palmPosition.y+_leapHand.direction.y*_directionFactorOffsetPalm.height z:palmPosition.z];
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
    return [OLKHand transFingerTipPositionsSortedForHand:_leapHand];
}

- (NSArray *)fingerDirectionsTransformedToHand
{
    return [OLKHand transFingerTipDirectionsSortedForHand:_leapHand];
}

- (NSArray *)fingersTransformedToHand
{
    return [OLKHand transFingerTipDirectionsAndPositionsSortedForHand:_leapHand];
}


@end

//////////////////////////////////////////////////////////////////////////
//HAND
@implementation LeapFingerAsLeapHand
{
    NSMutableArray *_prevTipPositions;
}

@synthesize frame = _frame;

- (id)init
{
    if (self = [super init])
    {
        _prevTipPositions = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}
    
- (NSString *)description
{
    if (![self isValid]) {
        return @"Invalid Hand";
    }
    return [NSString stringWithFormat:@"Hand Id:%d", [self id]];
}

- (int32_t)id
{
    return _fingerToMapToHand.id + 1000000;
}
    
- (void)setFingerToMapToHand:(LeapFinger *)fingerToMapToHand
{
    _fingerToMapToHand = fingerToMapToHand;
    _frame = _fingerToMapToHand.frame;
}

- (NSArray *)pointables
{
    return nil;
}

- (NSArray *)fingers
{
    return nil;
}

- (NSArray *)tools
{
    return nil;
}

- (LeapPointable *)pointable:(int32_t)pointableId
{
    return nil;
}

- (LeapFinger *)finger:(int32_t)fingerId
{
    return nil;
}

- (LeapTool *)tool:(int32_t)toolId
{
    return nil;
}

- (LeapVector *)palmPosition
{
//    NSLog(@"Finger Id: %d; tip pos: %@", self.id, _fingerToMapToHand.tipPosition);
    if (_fingerToMapToHand.touchZone == LEAP_POINTABLE_ZONE_TOUCHING)
        return _fingerToMapToHand.tipPosition;
    LeapVector *prevTipPosition = _prevTipPositions.lastObject;
    LeapVector *distance = [prevTipPosition minus:_fingerToMapToHand.tipPosition];
//    NSLog(@"Finger Id: %d; filtered count: %d; magnitude: %f", self.id, _prevTipPositions.count, distance.magnitude);
    if (distance.magnitude > 5)
    {
        [_prevTipPositions removeAllObjects];
        [_prevTipPositions addObject:_fingerToMapToHand.tipPosition];
        return _fingerToMapToHand.tipPosition;
    }
    if (_prevTipPositions.count > 10)
        [_prevTipPositions removeObjectAtIndex:0];
    [_prevTipPositions addObject:_fingerToMapToHand.tipPosition];
    LeapVector *averagePos = [[LeapVector alloc] initWithX:0 y:0 z:0];
    for (LeapVector *tipPosition in _prevTipPositions)
    {
        averagePos = [averagePos plus:tipPosition];
    }
    averagePos = [averagePos divide:_prevTipPositions.count];
//    NSLog(@"Finger Id: %d; filtered count: %d; average pos: %@", self.id, _prevTipPositions.count, averagePos);
    return averagePos;
}

- (LeapVector *)stabilizedPalmPosition
{
    return _fingerToMapToHand.stabilizedTipPosition;
}

- (LeapVector *)palmVelocity
{
    return _fingerToMapToHand.tipVelocity;
}

- (LeapVector *)palmNormal
{
    return [[LeapVector alloc] initWithX:0 y:-1 z:0];
}

- (LeapVector *)direction
{
    return _fingerToMapToHand.direction;
}

- (LeapVector *)sphereCenter
{
    return _fingerToMapToHand.tipPosition;
}

- (float)sphereRadius
{
    return 1;
}

- (BOOL)isValid
{
    return [_fingerToMapToHand isValid];
}

- (LeapFrame *)frame
{
    NSAssert(_frame != nil, @"Hand's frame has been deallocated due to weak ARC reference. Retain a strong pointer to this frame if you wish to access it later.");
    return _frame;
}

- (void)dealloc
{
}

- (LeapVector *)translation:(const LeapFrame *)sinceFrame
{
    return [[LeapVector alloc] initWithX:0 y:0 z:0];
}

- (float)translationProbability:(const LeapFrame *)sinceFrame
{
    return 1;
}

- (LeapVector *)rotationAxis:(const LeapFrame *)sinceFrame
{
    return [[LeapVector alloc] initWithX:0 y:0 z:0];
}

- (float)rotationAngle:(const LeapFrame *)sinceFrame
{
    return 0;
}

- (float)rotationAngle:(const LeapFrame *)sinceFrame axis:(const LeapVector *)axis
{
    return 0;
}

- (LeapMatrix *)rotationMatrix:(const LeapFrame *)sinceFrame
{
    return [LeapMatrix identity];
}

- (float)rotationProbability:(const LeapFrame *)sinceFrame
{
    return 1;
}

- (float)scaleFactor:(const LeapFrame *)sinceFrame
{
    return 1;
}

- (float)scaleProbability:(const LeapFrame *)sinceFrame
{
    return 1;
}

- (float)timeVisible
{
    return _fingerToMapToHand.timeVisible;
}

@end;