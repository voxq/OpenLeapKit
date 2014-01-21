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
//  OLKHandsContainerViewController.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-22.
//

#import <Foundation/Foundation.h>
#import "OLKSimpleVectHandView.h"
#import "OLKHand.h"
#import "OLKRangeCalibrator.h"

@protocol OLKHandsContainerView <NSObject>

- (void)addHandView:(NSView <OLKHandContainer> *)handView;

@end

@protocol OLKHandsContainerViewControllerDataSource <NSObject>

- (NSView <OLKHandContainer>*)handViewForHand:(OLKHand *)hand;

@property (nonatomic) NSObject <OLKHandFactory> *handFactory;

@end

@protocol OLKHandsContainerViewControllerDelegate <NSObject>
@optional
- (void)willAddHand:(OLKHand *)hand withHandView:(NSView <OLKHandContainer> *)handView;
- (void)willRemoveHand:(OLKHand *)hand withHandView:(NSView <OLKHandContainer> *)handView;
- (void)handChangedHandedness:(OLKHand *)hand withHandView:(NSView <OLKHandContainer> *)handView;
- (void)handWillSimulateHandedness:(OLKHand *)hand withHandView:(NSView <OLKHandContainer> *)handView;

@end

@interface OLKHandsContainerViewController : NSObject

- (void)onFrame:(NSNotification *)notification;
- (NSView <OLKHandContainer> *)viewForHand:(OLKHand *)hand;
- (void)updateHandsAndPointablesViews;
- (void)updateHandViewForHand:(OLKHand *)hand;
- (NSView <OLKHandContainer>*)viewForLeapHandId:(int)leapHandId;
- (OLKHand *)handFromLeapHand:(LeapHand *)leapHand;

@property (nonatomic) BOOL drawHands;
@property (nonatomic) NSView <OLKHandsContainerView> *handsSpaceView;
@property (nonatomic) BOOL overrideSpaceViews;
@property (nonatomic) NSObject <OLKHandsContainerViewControllerDataSource> *dataSource;
@property (nonatomic) NSObject <OLKHandsContainerViewControllerDelegate> *delegate;
@property (nonatomic, readonly) OLKHand *oldestHand;
@property (nonatomic, readonly) OLKHand *leftHand;
@property (nonatomic, readonly) OLKHand *rightHand;
@property (nonatomic, readonly) NSView <OLKHandContainer> *leftHandView;
@property (nonatomic, readonly) NSView <OLKHandContainer> *rightHandView;
@property (nonatomic, readonly) NSArray *pointableViews;
@property (nonatomic, readonly) NSArray *leftHands;
@property (nonatomic, readonly) NSArray *rightHands;
@property (nonatomic, readonly) NSArray *handsNoHandedness;
@property (nonatomic, readonly) NSArray *handsViews;
@property (nonatomic, readonly) NSArray *hands;
@property (nonatomic) BOOL resetAutoFitOnNewHand;
@property (nonatomic) NSSize trimInteraction;
@property (nonatomic) BOOL useStabilized;
@property (nonatomic) BOOL useInteractionBox;
@property (nonatomic) NSMutableArray *gestureContext;
@property (nonatomic) BOOL allowAllHands;
@property (nonatomic) BOOL findRightLeft;
@property (nonatomic) OLKHandednessAlgorithm handednessAlgorithm;
@property (nonatomic) BOOL showPointables;
@property (nonatomic) NSSize pointableScale;
@property (nonatomic) NSSize handScale;
@property (nonatomic) float rangeOffset;
@property (nonatomic) float proximityOffset;
@property (nonatomic) float percentRangeOfMaxWidth;
@property (nonatomic) NSSize fitHandFact;
@property (nonatomic) OLKRangeCalibrator *calibrator;

@end
