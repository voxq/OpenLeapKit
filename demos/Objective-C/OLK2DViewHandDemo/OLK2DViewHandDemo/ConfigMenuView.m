//
//  ConfigMenuView.m
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <OpenLeapKit/OLKHorizScratchButton.h>
#import "ConfigMenuView.h"

@implementation ConfigMenuView

@synthesize dontdraw = _dontdraw;
@synthesize resetToDefaultsButton = _resetToDefaultsButton;
@synthesize resetFitFactButton = _resetFitFactButton;
@synthesize boundedHandButton = _boundedHandButton;
@synthesize fingerTipsButton = _fingerTipsButton;
@synthesize fingerLinesButton = _fingerLinesButton;
@synthesize fingerDepthYButton = _fingerDepthYButton;
@synthesize palmButton = _palmButton;
@synthesize hand3DButton = _hand3DButton;
@synthesize autoSizeButton = _autoSizeButton;
@synthesize stablePalmsButton = _stablePalmsButton;
@synthesize interactionBoxButton = _interactionBoxButton;
@synthesize useSimpleCursorButton = _useSimpleCursorButton;
@synthesize useOnlySimpleCursorButton = _useOnlySimpleCursorButton;
@synthesize sphereButton = _sphereButton;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self layoutMenu];
}

- (void)reset
{
    [self layoutMenu];
}

- (void)defaultConfig
{    
    _resetToDefaultsButton = [[OLKHorizScratchButton alloc] init];
    _resetToDefaultsButton.expandsOnInit = TRUE;
    _resetToDefaultsButton.togglesState = YES;
    [_resetToDefaultsButton setSize:NSMakeSize(240, 50)];
    [self addControl:_resetToDefaultsButton];
    
    _resetFitFactButton = [_resetToDefaultsButton copy];
    _resetFitFactButton.rightInit = TRUE;
    
    _useOnlySimpleCursorButton = [_resetToDefaultsButton copy];
    [_useOnlySimpleCursorButton setSize:NSMakeSize(180, 50)];
    
    _boundedHandButton = [_useOnlySimpleCursorButton copy];
    _fingerTipsButton = [_useOnlySimpleCursorButton copy];
    _fingerDepthYButton = [_useOnlySimpleCursorButton copy];
    _useCalibrationButton = [_fingerDepthYButton copy];
    _interactionBoxButton = [_useOnlySimpleCursorButton copy];
    

    _useSimpleCursorButton = [_useOnlySimpleCursorButton copy];
    _useSimpleCursorButton.rightInit = TRUE;
    
    _palmButton = [_useSimpleCursorButton copy];
    _fingerLinesButton = [_useSimpleCursorButton copy];
    _hand3DButton = [_useSimpleCursorButton copy];
    _autoSizeButton = [_useSimpleCursorButton copy];
    _stablePalmsButton = [_useSimpleCursorButton copy];
    _sphereButton = [_useSimpleCursorButton copy];
    
    [_boundedHandButton setLabel:@"Bounded Hand"];
    [_fingerLinesButton setLabel:@"Finger Lines"];
    [_fingerTipsButton setLabel:@"Finger Tips"];
    [_palmButton setLabel:@"Draw Palms"];
    [_fingerDepthYButton setLabel:@"Finger Depth on Y Axis"];
    [_hand3DButton setLabel:@"Use 3D Perspective Hand"];
    [_autoSizeButton setLabel:@"Auto Size Hand to Bounds"];
    [_stablePalmsButton setLabel:@"Use Stabilized Palms"];
    [_interactionBoxButton setLabel:@"Use Interaction Box"];
    [_useSimpleCursorButton setLabel:@"Use Simple Hand Cursor"];
    [_useOnlySimpleCursorButton setLabel:@"Use Only Simple Hand Cursor"];
    [_resetFitFactButton setLabel:@"Reset Fit Hands to Bounds"];
    [_resetToDefaultsButton setLabel:@"Reset to Defaults"];
    [_useCalibrationButton setLabel:@"Use Screen Calibrations"];
    _sphereButton.label = @"Show Sphere Data";

}

- (void)setOnlySimpleCursor:(BOOL)enable
{
    BOOL propertyEnable;
    if (enable)
        propertyEnable = NO;
    else
        propertyEnable = YES;
    
    [_fingerDepthYButton setActive:propertyEnable];
    [_boundedHandButton setActive:propertyEnable];
    [_useSimpleCursorButton setActive:propertyEnable];
    [_fingerLinesButton setActive:propertyEnable];
    [_fingerTipsButton setActive:propertyEnable];
    [_palmButton setActive:propertyEnable];
    [_sphereButton setActive:propertyEnable];
}

- (void)layoutMenu
{
    NSRect bounds = [self bounds];
    float midPointXOffset = bounds.origin.x+bounds.size.width/2;
    float xOffsetLeft = midPointXOffset - _boundedHandButton.size.width-20;
    float xOffsetRight = bounds.origin.x+midPointXOffset+20;
    float yOffsetFromTop = bounds.size.height-(bounds.size.width/16);
    [_resetFitFactButton setDrawLocation:NSMakePoint(midPointXOffset - _resetFitFactButton.size.width-20, yOffsetFromTop-500)];
    [_resetToDefaultsButton setDrawLocation:NSMakePoint(midPointXOffset+20, yOffsetFromTop-500)];

    midPointXOffset -= 200;
    xOffsetLeft = midPointXOffset - _boundedHandButton.size.width-20;
    xOffsetRight = bounds.origin.x+midPointXOffset+20;

    [_boundedHandButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop)];
    [_palmButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop)];
    [_fingerLinesButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-100)];
    [_fingerTipsButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-100)];
    [_fingerDepthYButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-200)];
    [_hand3DButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-200)];
    [_stablePalmsButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-300)];
    [_interactionBoxButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-300)];
    
    midPointXOffset += 400;
    xOffsetLeft = midPointXOffset - _boundedHandButton.size.width-20;
    xOffsetRight = bounds.origin.x+midPointXOffset+20;

    [_autoSizeButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop)];
    [_useCalibrationButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop)];
    [_useSimpleCursorButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-100)];
    [_useOnlySimpleCursorButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-100)];
    [_sphereButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-200)];
    
    
    self.needsDisplay = YES;
}

@end
