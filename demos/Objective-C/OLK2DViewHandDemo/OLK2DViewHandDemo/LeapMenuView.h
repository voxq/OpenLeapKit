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

typedef enum
{
    LeapMenuItemGoFullScreen,
    LeapMenuItemCalibrate
}LeapMenuItem;

@interface LeapMenuView : OLKNIControlsContainerView

@property (nonatomic) OLKHorizScratchButton *calibrateButton;
@property (nonatomic) OLKHorizScratchButton *goFullScreenButton;
@property (nonatomic) OLKNIControl *fistLabel;

@end
