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
//  OLKHand.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-16.
//

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

@class OLKHand;

@protocol OLKHandFactory <NSObject>
- (OLKHand *)manufactureHand:(LeapHand *)leapHand;
@end

typedef enum
{
    OLKHandCursorPosTypePalm,
    OLKHandCursorPosTypePointingFingerTip,
    OLKHandCursorPosTypePointingFingerTipOrPalm,
    OLKHandCursorPosTypePointingFingerTipRelativePalm,
    OLKHandCursorPosTypeLongFingerTip,
    OLKHandCursorPosTypeLongFingerTipOrPalm,
    OLKHandCursorPosTypeLongFingerTipRelativePalm,
    OLKHandCursorPosTypeIndexFingerTip,
    OLKHandCursorPosTypeIndexFingerTipOrPalm,
    OLKHandCursorPosTypeIndexFingerTipRelativePalm,
    OLKHandCursorPosTypePalmHandAimOffset,
    OLKHandCursorPosTypeHandAim,
    OLKHandCursorPosTypeMainToolTip,
    OLKHandCursorPosTypeMainToolTipOrPalm,
    OLKHandCursorPosTypeMainToolTipRelativePalm
}
OLKHandCursorPosType;

@protocol OLKHandContainer <NSObject, NSCopying>

@property (nonatomic) OLKHand *hand;
@property (nonatomic) NSView *spaceView;
@property (nonatomic) BOOL enabled;
@property (nonatomic) OLKHandCursorPosType cursorType;
@property (nonatomic) NSPoint activePoint;
@property (nonatomic) NSPoint centerPoint;


@end

static NSString * const OLKHandBestLeftGuessKey = @"BestLeftGuess";
static NSString * const OLKHandBestRightGuessKey = @"BestRightGuess";
static NSString * const OLKHandLeftHandsKey = @"LeftHands";
static NSString * const OLKHandRightHandsKey = @"RightHands";
static NSString * const OLKHandUnknownHandednessKey = @"UnknownHandednessHands";


typedef enum {
    OLKHandednessAlgorithmHandPos = 1,
    OLKHandednessAlgorithmThumbBasePos = 2,
    OLKHandednessAlgorithmThumbTipAndBase = 3,
    OLKHandednessAlgorithmThumbShortest = 4
}OLKHandednessAlgorithm;

typedef enum {
    OLKHandednessUnknown=0,
    OLKLeftHand=1,
    OLKRightHand=2
}OLKHandedness;

@interface LeapFingerAsLeapHand : LeapHand
@property (nonatomic) LeapFinger *fingerToMapToHand;
@property BOOL isTouching;
@property NSInteger tapCount;
@property NSDate *lastTapTime;

@end

@interface OLKHand : NSObject <NSCopying>

+ (BOOL)isLeapHandFingersMissingOrPinch:(LeapHand *)leapHand;
- (BOOL)fingersMissingOrPinch;
+ (BOOL)isLeapHandFist:(LeapHand *)leapHand;
+ (BOOL)isLeapHandPointing:(LeapHand *)leapHand;
- (BOOL)isPointing;
+ (LeapMatrix *)transformForNormalizedHandReference:(LeapHand *)hand;
+ (LeapMatrix *)transformForHandReference:(LeapHand *)hand;
+ (NSArray *)transFingerTipPositionsSortedForHand:(LeapHand *)hand;
+ (NSArray *)transFingerTipDirectionsSortedForHand:(LeapHand *)hand;
+ (NSArray *)transFingerTipDirectionsAndPositionsSortedForHand:(LeapHand *)hand;

+ (LeapPointable *)furthestFingerOrPointableTipFromPalm:(LeapHand *)hand;
+ (NSDictionary *)leftRightHandSearch:(NSArray *)hands ignoreHands:(NSSet *)ignoreHands handednessAlgorithm:(OLKHandednessAlgorithm)handednesAlgorithm factory:(NSObject<OLKHandFactory>*)factory;
+ (NSArray *)simpleLeftRightHandSearch:(NSArray *)hands;

+ (OLKHandedness)handednessByThumbTipDistFromPalm:(LeapHand *)hand thumb:(LeapFinger **)pThumb;
+ (OLKHandedness)handednessByThumbBasePosToPalm:(LeapHand *)hand thumb:(LeapFinger **)pThumb;
+ (OLKHandedness)handednessByThumbTipAndBaseCombo:(LeapHand *)hand thumb:(LeapFinger **)pThumb;
+ (OLKHandedness)handednessByShortestFinger:(LeapHand *)hand thumb:(LeapFinger **)pThumb;

- (BOOL)isLeapHand:(LeapHand *)leapHand;
- (void)updateLeapHand:(LeapHand *)leapHand;
- (OLKHandedness)updateHandedness;

- (BOOL)isFist;
- (BOOL)isLeftHand;
- (BOOL)isRightHand;

- (OLKHandedness)updateHandednessByThumbTipDistFromPalm;
- (OLKHandedness)updateHandednessByThumbBasePosToPalm;
- (OLKHandedness)updateHandednessByShortestFinger;
- (OLKHandedness)updateHandednessByThumbTipAndBaseCombo;

- (LeapVector *)palmPosition;
- (LeapVector *)direction;
- (LeapVector *)palmNormal;

- (NSArray *)extendedFingers;

- (LeapFinger *)indexFinger;
- (LeapVector *)tipPosition:(LeapPointable *)pointable;

- (LeapVector *)longFingerTipPos;
- (LeapVector *)longFingerTipPos:(LeapFinger **)pFinger;
- (LeapVector *)longFingerTipRelativePos;
- (LeapVector *)longFingerTipOrPalmPos;
- (LeapVector *)indexFingerTipPos;
- (LeapVector *)indexFingerTipPos:(LeapFinger **)pFinger;
- (LeapVector *)indexFingerTipOrPalmPos;
- (LeapVector *)indexFingerTipPosRelativePalm;
- (LeapVector *)mainToolTipPos;
- (LeapVector *)mainToolTipPos:(LeapPointable **)pTool;
- (LeapVector *)mainToolTipOrPalmPos;
- (LeapVector *)mainToolTipPosRelativePalm;
- (LeapFinger *)pointingFinger;
- (LeapVector *)pointingFingerTipOrPalmPos;
- (LeapVector *)pointingFingerTipPos;
- (LeapVector *)pointingFingerTipPosRelativePalm;
- (LeapVector *)palmPosPlusAimOffset;
- (LeapVector *)posFromAim;

- (LeapVector *)factorPointableOffsetRelativePalm:(LeapVector *)position factor:(NSSize)factor;
- (LeapVector *)factorPointablePosRelativePalm:(LeapVector *)position factor:(NSSize)factor;

- (NSArray *)fingersTransformedToHand;
- (NSArray *)fingerPositionsTransformedToHand;
- (NSArray *)fingerDirectionsTransformedToHand;

@property (nonatomic) LeapHand *leapHand;
@property (nonatomic) LeapFrame *leapFrame;
@property (nonatomic, readonly) LeapFinger *thumb;
@property (nonatomic) OLKHandedness handedness;
@property (nonatomic, readonly) NSUInteger numFramesExist;
@property (nonatomic) OLKHandedness simHandedness;
@property (nonatomic) OLKHandednessAlgorithm handednessAlgorithm;
@property (nonatomic) BOOL usesStabilized;
@property (nonatomic) NSSize directionFactor;
@property (nonatomic) NSSize directionFactorOffsetPalm;
@property (nonatomic) float offsetYForAim;
@property (nonatomic) NSSize pointableFactorOffsetPalm;
@property (nonatomic) NSSize toolFactorOffsetPalm;
@property (nonatomic) NSSize fingerFactorOffsetPalm;
@property (nonatomic) NSSize pointableFactorPosRelPalm;
@property (nonatomic) NSSize toolFactorPosRelPalm;
@property (nonatomic) NSSize fingerFactorPosRelPalm;

@end
