//
//  CalibratorController.h
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-12-08.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenLeapKit/OLKFullScreenOverlayWindow.h>
#import <OpenLeapKit/OLKRangeCalibrator.h>
#import <OpenLeapKit/OLKRangeCalibratorView.h>
#import <OpenLeapKit/OLKCircleOptionMultiCursorInput.h>
#import <OpenLeapKit/OLKHandsContainerViewController.h>

static NSString * const WLCalibratorControllerKey = @"Calibrator Controller";
static NSString * const WLCalibratorMethod = @"Method";
static NSString * const WLCalibratorHeightFactor = @"Height Factor";
static NSString * const WLCalibratorWidthFactor = @"Width Factor";
static NSString * const WLCalibratorOffsetBase = @"Base Offset";
static NSString * const WLCalibratorOffsetCenter = @"Center Offset";
static NSString * const WLCalibratorLeapPos1 = @"Leap Position 1";
static NSString * const WLCalibratorLeapPos2 = @"Leap Position 2";
static NSString * const WLCalibratorLeapPos3 = @"Leap Position 3";
static NSString * const WLCalibratorScreenPos1 = @"Screen Position 1";
static NSString * const WLCalibratorScreenPos2 = @"Screen Position 2";
static NSString * const WLCalibratorScreenPos3 = @"Screen Position 3";

@protocol CalibratorControllerDelegate <NSObject>

@optional

- (void)canceledCalibration;
- (void)completedCalibration;
- (void)exitedCalibrationMenu;

@end

@interface CalibratorController : NSObject <OLKRangeCalibratorViewDelegate, OLKCircleOptionMultiCursorInputDelegate>

- (void)setCursorPos:(NSPoint)cursorPos cursorContext:(id)cursorContext;
- (void)showCalibrationMenu;
- (void)changeToScreen:(NSScreen *)screen;
- (OLKRangeCalibrator *)calibratorForScreen:(NSScreen *)screen;
- (void)loadFromDefaults;
- (void)removeCursorContext:(id)cursorContext;

@property (nonatomic) BOOL showingCalibrationMenu;
@property (nonatomic) OLKFullScreenOverlayWindow *fullScreenCalibrateOverlayWindow;
@property (nonatomic) OLKRangeCalibratorView *calibratorView;
@property (nonatomic) OLKRangeCalibrator *calibrator;
@property (nonatomic) NSMutableDictionary *screenCalibrators;

@property (nonatomic) OLKHandsContainerViewController *handsOverlayController;
@property (nonatomic) NSObject <CalibratorControllerDelegate> *delegate;
@property (nonatomic) NSView *menuParentView;

@end
