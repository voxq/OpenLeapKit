/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"
#import "LeapMenuView.h"
#import <OpenLeapKit/OLKNIControlsContainerView.h>
#import <OpenLeapKit/OLKCircleOptionMultiCursorInput.h>
#import <OpenLeapKit/OLKRangeCalibratorView.h>
#import "OLKDemoHandsOverlayViewController.h"
#import "MainOverlayView.h"

@interface Sample : NSObject<LeapListener, OLKDemoHandsOverlayViewControllerDelegate, OLKHandsContainerViewControllerDelegate, OLKCircleOptionMultiCursorInputDelegate, OLKRangeCalibratorViewDelegate, OLKNIControlsContainerViewDelegate, OLKNIControlsContainerViewDelegate>

- (void)terminate;
-(void)run:(MainOverlayView *)handView;

- (IBAction)goFullScreen:(id)sender;
- (IBAction)resetCalibration:(id)sender;

- (IBAction)enableInteractionBox:(id)sender;

@property (nonatomic) IBOutlet NSButton *interactionBoxButton;

@end
