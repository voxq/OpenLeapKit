//
//  LeapMenuView.m
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "LeapMenuView.h"
#import <OpenLeapKit/OLKToggleButton.h>
#import <OpenLeapKit/OLKHorizScratchButton.h>

@implementation LeapMenuView

@synthesize calibrateButton = _calibrateButton;
@synthesize goFullScreenButton = _goFullScreenButton;
@synthesize fistLabel = _fistLabel;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self defaultConfig];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self layoutMenu];
}

- (void)defaultConfig
{
    _fistLabel = [[OLKNIControl alloc] init];
    _fistLabel.size = NSMakeSize(340,50);
    _fistLabel.labelFontSize = 30;
    [self addControl:_fistLabel];
    
    _calibrateButton = [[OLKHorizScratchButton alloc] init];
    [_calibrateButton setSize:NSMakeSize(240, 50)];
    _calibrateButton.expandsOnInit = YES;
    [self addControl:_calibrateButton];
    
    _goFullScreenButton = [_calibrateButton copy];
    _goFullScreenButton.rightInit = YES;
    
    [_calibrateButton setLabel:@"Screen Calibrate"];
    [_goFullScreenButton setLabel:@"Full Screen"];
    _fistLabel.label = @"Fist State";
}


- (void)layoutMenu
{
    NSRect bounds = [self bounds];
    float midPointXOffset = bounds.origin.x+bounds.size.width/2;
    float xOffsetLeft = midPointXOffset - _calibrateButton.size.width-20;
    float xOffsetRight = bounds.origin.x+midPointXOffset+20;
    float yOffsetFromTop = bounds.size.height-(bounds.size.width/16);
    [_goFullScreenButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-600)];
    [_calibrateButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-600)];
    [_fistLabel setDrawLocation:NSMakePoint(midPointXOffset - _fistLabel.size.width, yOffsetFromTop-700)];
}

@end
