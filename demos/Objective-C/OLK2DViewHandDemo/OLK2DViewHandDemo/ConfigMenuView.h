//
//  ConfigMenuView.h
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenLeapKit/OLKNIControlsContainerView.h>


@class OLKHorizScratchButton;

@interface ConfigMenuView : OLKNIControlsContainerView

- (void)reset;
- (void)setOnlySimpleCursor:(BOOL)enable;

@property (nonatomic) BOOL dontdraw;

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
@property (nonatomic) OLKHorizScratchButton *useCalibrationButton;
@property (nonatomic) OLKHorizScratchButton *sphereButton;

@end
