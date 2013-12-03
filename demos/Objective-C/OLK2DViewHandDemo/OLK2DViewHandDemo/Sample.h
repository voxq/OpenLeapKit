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
#import <OpenLeapKit/OLKCircleOptionInput.h>
#import <OpenLeapKit/OLKRangeCalibratorView.h>

@interface Sample : NSObject<LeapListener,LeapMenuDelegate, OLKCircleOptionInputDelegate, OLKRangeCalibratorViewDelegate>

-(void)run:(NSView *)handView;

- (IBAction)goFullScreen:(id)sender;
- (IBAction)resetCalibration:(id)sender;

- (IBAction)enableHandBounds:(id)sender;
- (IBAction)enableFingerLines:(id)sender;
- (IBAction)enableFingerTips:(id)sender;
- (IBAction)enableFingersZisY:(id)sender;
- (IBAction)enableDrawPalm:(id)sender;
- (IBAction)enableAutoHandSize:(id)sender;
- (IBAction)enable3DHand:(id)sender;
- (IBAction)enableStabilizedPalms:(id)sender;
- (IBAction)enableInteractionBox:(id)sender;

@property (nonatomic) IBOutlet NSButton *handBoundsButton;
@property (nonatomic) IBOutlet NSButton *fingerLinesButton;
@property (nonatomic) IBOutlet NSButton *fingerTipsButton;
@property (nonatomic) IBOutlet NSButton *fingerDepthYButton;
@property (nonatomic) IBOutlet NSButton *palmButton;
@property (nonatomic) IBOutlet NSButton *hand3DButton;
@property (nonatomic) IBOutlet NSButton *autoSizeButton;
@property (nonatomic) IBOutlet NSButton *stablePalmsButton;
@property (nonatomic) IBOutlet NSButton *interactionBoxButton;

@end
