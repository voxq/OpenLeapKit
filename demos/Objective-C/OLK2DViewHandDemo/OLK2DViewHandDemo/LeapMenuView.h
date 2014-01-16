//
//  LeapMenuView.h
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenLeapKit/OLKNIControlsContainerView.h>

@class OLKHorizScratchButton;
@class OLKToggleButton;

@interface LeapMenuView : OLKNIControlsContainerView

@property (nonatomic) OLKHorizScratchButton *calibrateButton;
@property (nonatomic) OLKHorizScratchButton *goFullScreenButton;
@property (nonatomic) OLKToggleButton *boundedHandButton;
@property (nonatomic) OLKToggleButton *fingerTipsButton;
@property (nonatomic) OLKToggleButton *fingerLinesButton;
@property (nonatomic) OLKToggleButton *fingerDepthYButton;
@property (nonatomic) OLKToggleButton *palmButton;
@property (nonatomic) OLKToggleButton *hand3DButton;
@property (nonatomic) OLKToggleButton *autoSizeButton;
@property (nonatomic) OLKToggleButton *stablePalmsButton;
@property (nonatomic) OLKToggleButton *interactionBoxButton;

@end
