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
//  OLKDemoHandsOberlayViewController.h
//  OLK2DViewHandDemo
//
//  Created by Tyler Zetterstrom on 2013-08-29.
//


#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"
#import <OpenLeapKit/OLKHandsContainerViewController.h>
#import <OpenLeapKit/OLKNIControlsContainerView.h>
#import "ConfigMenuView.h"

static NSString * const OLKDemoHandsViewsWidth = @"HandsViewsWidth";
static NSString * const OLKDemoHandsViewsHeight = @"HandsViewsHeight";
static NSString * const OLKDemoHandsDrawFingers = @"Draw Fingers";
static NSString * const OLKDemoHandsDrawFingerTips = @"Draw Finger Tips";
static NSString * const OLKDemoHandsDrawPalms = @"Draw Palms";
static NSString * const OLKDemoHandsDrawBoundingCircle = @"Draw Bounding Circle";
static NSString * const OLKDemoHandsUseZForY = @"Use Z for Y";
static NSString * const OLKDemoHands3DPerspective = @"3D Hand";
static NSString * const OLKDemoHandsUseStabilizedPos = @"Use Stabilized Positions";
static NSString * const OLKDemoHandsUseInteractionBox = @"Use Interaction Box";
static NSString * const OLKDemoHandsAutoSizeHand = @"Auto Fit Hand to Bounds";
static NSString * const OLKDemoHandsFitFactorWidth = @"Fit Hand to Bounds Factor Width";
static NSString * const OLKDemoHandsFitFactorHeight = @"Fit Hand to Bounds Factor Height";
static NSString * const OLKDemoHandsUseSimpleCursor = @"Use Simple Hand Cursor";
static NSString * const OLKDemoHandsUseOnlySimpleCursor = @"Use Only Simple Hand Cursor";
static NSString * const OLKDemoHandsUseCalibration = @"Use Screen Calibrations";
static NSString * const OLKDemoHandsDrawSphere = @"Draw Sphere Data";


@protocol OLKDemoHandsOverlayViewControllerDelegate <NSObject>

@optional

- (void)exitedOLKDemoHandsConfigMenu;
- (void)simpleCursorNeedsShowing;

@end

@interface OLKDemoHandsOverlayViewController : OLKHandsContainerViewController <OLKHandsContainerViewControllerDataSource, OLKHandFactory, OLKNIControlsContainerViewDelegate>

+ (NSDictionary *)defaultProperties;

@property (nonatomic, readonly) ConfigMenuView *handsConfigMenu;
@property (nonatomic) NSObject <OLKDemoHandsOverlayViewControllerDelegate> *handsOverlayControllerDelegate;
@property (nonatomic) BOOL enableAutoFitHands;
@property (nonatomic) BOOL enableDrawHandsBoundingCircle;
@property (nonatomic) BOOL enableDrawPalms;
@property (nonatomic) BOOL enableDrawFingers;
@property (nonatomic) BOOL enableDrawFingerTips;
@property (nonatomic) BOOL enableScreenYAxisUsesZAxis;
@property (nonatomic) BOOL enable3DHand;
@property (nonatomic) NSSize fitHandFactor;
@property (nonatomic) NSObject <OLKHandFactory> *handFactory;
@property (nonatomic) BOOL usingSimpleCursor;
@property (nonatomic) BOOL usingOnlySimpleCursor;
@property (nonatomic) BOOL useCalibrator;
@property (nonatomic) BOOL enableDrawSphere;

@end
