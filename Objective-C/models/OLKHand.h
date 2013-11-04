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

@protocol OLKHandContainer <NSObject>

@property (nonatomic) OLKHand *hand;
@property (nonatomic) BOOL enableStable;

@end


typedef enum {
    OLKHandednessUnknown=0,
    OLKLeftHand=1,
    OLKRightHand=2
}OLKHandedness;


@interface OLKHand : NSObject

+ (LeapPointable *)furthestFingerOrPointableTipFromPalm:(LeapHand *)hand;
+ (NSArray *)simpleLeftRightHandSearch:(NSArray *)hands;
+ (OLKHandedness)handednessByThumbBasePosToPalm:(LeapHand *)hand thumbId:(int *)pThumbId;
+ (OLKHandedness)handednessByThumbTipAndBaseCombo:(LeapHand *)hand thumbId:(int *)pThumbId;

- (BOOL)isLeapHand:(LeapHand *)leapHand;
- (void)updateLeapHand:(LeapHand *)leapHand;
- (OLKHandedness)updateHandedness;

@property (nonatomic) LeapHand *leapHand;
@property (nonatomic) LeapFrame *leapFrame;
@property (nonatomic, readonly) LeapFinger *thumb;
@property (nonatomic) OLKHandedness handedness;
@property (nonatomic, readonly) NSUInteger numFramesExist;
@property (nonatomic) OLKHandedness simHandedness;

@end
