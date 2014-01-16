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

@synthesize fingerTipsButton = _fingerTipsButton;
@synthesize fingerLinesButton = _fingerLinesButton;
@synthesize calibrateButton = _calibrateButton;
@synthesize boundedHandButton = _boundedHandButton;
@synthesize goFullScreenButton = _goFullScreenButton;
@synthesize fingerDepthYButton = _fingerDepthYButton;
@synthesize palmButton = _palmButton;
@synthesize hand3DButton = _hand3DButton;
@synthesize autoSizeButton = _autoSizeButton;
@synthesize stablePalmsButton = _stablePalmsButton;
@synthesize interactionBoxButton = _interactionBoxButton;

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
    _calibrateButton = [[OLKHorizScratchButton alloc] init];
    [_calibrateButton setSize:NSMakeSize(240, 50)];
    [self addControl:_calibrateButton];
    
    _goFullScreenButton = [_calibrateButton copy];
    
    _boundedHandButton = [[OLKToggleButton alloc] init];
    [_boundedHandButton setSize:NSMakeSize(120, 50)];
    [self addControl:_boundedHandButton];
    
    _fingerTipsButton = [_boundedHandButton copy];
    _fingerLinesButton = [_boundedHandButton copy];
    _fingerDepthYButton = [_boundedHandButton copy];
    _palmButton = [_boundedHandButton copy];
    _hand3DButton = [_boundedHandButton copy];
    _autoSizeButton = [_boundedHandButton copy];
    _stablePalmsButton = [_boundedHandButton copy];
    _interactionBoxButton = [_boundedHandButton copy];

    [_boundedHandButton setLabel:@"Bounded Hand"];
    [_fingerLinesButton setLabel:@"Finger Lines"];
    [_fingerTipsButton setLabel:@"Finger Tips"];
    [_palmButton setLabel:@"Draw Palms"];
    [_fingerDepthYButton setLabel:@"Finger Depth on Y Axis"];
    [_hand3DButton setLabel:@"Use 3D Perspective Hand"];
    [_autoSizeButton setLabel:@"Auto Size Hand to Bounds"];
    [_stablePalmsButton setLabel:@"Use Stabilized Palms"];
    [_interactionBoxButton setLabel:@"Use Interaction Box"];
    [_calibrateButton setLabel:@"Screen Calibrate"];
    [_goFullScreenButton setLabel:@"Full Screen"];
}


- (void)layoutMenu
{
    NSRect bounds = [self bounds];
    
    [_boundedHandButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16))];
    [_fingerLinesButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-70)];
    [_fingerTipsButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-140)];
    [_palmButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-210)];
    [_fingerDepthYButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-280)];
    [_hand3DButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-350)];
    [_autoSizeButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-420)];
    [_stablePalmsButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-490)];
    [_interactionBoxButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-560)];
    [_calibrateButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-700)];
    [_goFullScreenButton setDrawLocation:NSMakePoint(bounds.origin.x+bounds.size.width/2, bounds.size.height-(bounds.size.width/16)-800)];
}

@end
