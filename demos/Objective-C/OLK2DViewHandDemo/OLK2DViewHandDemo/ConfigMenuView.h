//
//  ConfigMenuView.h
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenLeapKit/OLKNIControlsContainerView.h>

static NSString * const HandsViewsWidth = @"HandsViewsWidth";
static NSString * const HandsViewsHeight = @"HandsViewsHeight";
static NSString * const HandsDrawFingers = @"Draw Fingers";
static NSString * const HandsDrawFingerTips = @"Draw Finger Tips";
static NSString * const HandsDrawPalms = @"Draw Palms";
static NSString * const HandsDrawBoundingCircle = @"Draw Bounding Circle";
static NSString * const HandsUseZForY = @"Use Z for Y";
static NSString * const Hands3DPerspective = @"3D Hand";
static NSString * const HandsUseStabilizedPos = @"Use Stabilized Positions";
static NSString * const HandsUseInteractionBox = @"Use Interaction Box";
static NSString * const HandsAutoSizeHand = @"Auto Fit Hand to Bounds";
static NSString * const HandsFitFactorWidth = @"Fit Hand to Bounds Factor Width";
static NSString * const HandsFitFactorHeight = @"Fit Hand to Bounds Factor Height";
static NSString * const HandsUseSimpleCursor = @"Use Simple Hand Cursor";
static NSString * const HandsUseOnlySimpleCursor = @"Use Only Simple Hand Cursor";


@class OLKHorizScratchButton;

@interface ConfigMenuView : OLKNIControlsContainerView

- (void)reset;
- (void)setOnlySimpleCursor:(BOOL)enable;

@property (nonatomic) BOOL dontdraw;

@property (nonatomic) OLKHorizScratchButton *exitButton;
@property (nonatomic) OLKHorizScratchButton *resetToDefaultsButton;
@property (nonatomic) OLKHorizScratchButton *resetFitFactButton;
@property (nonatomic) OLKHorizScratchButton *boundedHandButton;
@property (nonatomic) OLKHorizScratchButton *fingerTipsButton;
@property (nonatomic) OLKHorizScratchButton *fingerLinesButton;
@property (nonatomic) OLKHorizScratchButton *fingerDepthYButton;
@property (nonatomic) OLKHorizScratchButton *palmButton;
@property (nonatomic) OLKHorizScratchButton *hand3DButton;
@property (nonatomic) OLKHorizScratchButton *autoSizeButton;
@property (nonatomic) OLKHorizScratchButton *stablePalmsButton;
@property (nonatomic) OLKHorizScratchButton *interactionBoxButton;
@property (nonatomic) OLKHorizScratchButton *useSimpleCursorButton;
@property (nonatomic) OLKHorizScratchButton *useOnlySimpleCursorButton;

@end
