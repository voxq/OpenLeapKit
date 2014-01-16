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
@synthesize exitButton = _exitButton;
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
    _exitButton = [[OLKHorizScratchButton alloc] init];
    _exitButton.expandsOnInit = TRUE;
    _exitButton.togglesState = YES;
    [_exitButton setSize:NSMakeSize(180, 50)];
    [self addControl:_exitButton];
    
    _resetToDefaultsButton = [[OLKHorizScratchButton alloc] init];
    _resetToDefaultsButton.expandsOnInit = TRUE;
    _resetToDefaultsButton.togglesState = YES;
    [_resetToDefaultsButton setSize:NSMakeSize(240, 50)];
    [self addControl:_resetToDefaultsButton];
    
    _resetFitFactButton = [[OLKHorizScratchButton alloc] init];
    _resetFitFactButton.expandsOnInit = TRUE;
    _resetFitFactButton.rightInit = TRUE;
    _resetFitFactButton.togglesState = YES;
    [_resetFitFactButton setSize:NSMakeSize(240, 50)];
    [self addControl:_resetFitFactButton];
    
    _useSimpleCursorButton = [[OLKHorizScratchButton alloc] init];
    _useSimpleCursorButton.expandsOnInit = TRUE;
    _useSimpleCursorButton.rightInit = TRUE;
    _useSimpleCursorButton.togglesState = YES;
    [_useSimpleCursorButton setSize:NSMakeSize(180, 50)];
    [_useSimpleCursorButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsUseSimpleCursor]];
    [self addControl:_useSimpleCursorButton];
    
    _useOnlySimpleCursorButton = [[OLKHorizScratchButton alloc] init];
    _useOnlySimpleCursorButton.expandsOnInit = TRUE;
    _useOnlySimpleCursorButton.togglesState = YES;
    [_useOnlySimpleCursorButton setSize:NSMakeSize(180, 50)];
    [_useOnlySimpleCursorButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsUseOnlySimpleCursor]];
    [self addControl:_useOnlySimpleCursorButton];
    
    _boundedHandButton = [[OLKHorizScratchButton alloc] init];
    _boundedHandButton.expandsOnInit = TRUE;
    _boundedHandButton.togglesState = YES;
    [_boundedHandButton setSize:NSMakeSize(180, 50)];
    [_boundedHandButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsDrawBoundingCircle]];
    [self addControl:_boundedHandButton];
    
    _palmButton = [[OLKHorizScratchButton alloc] init];
    _palmButton.expandsOnInit = TRUE;
    _palmButton.rightInit = TRUE;
    _palmButton.togglesState = YES;
    [_palmButton setSize:NSMakeSize(180, 50)];
    [_palmButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsDrawPalms]];
    [self addControl:_palmButton];
    
    _fingerTipsButton = [[OLKHorizScratchButton alloc] init];
    _fingerTipsButton.expandsOnInit = TRUE;
    _fingerTipsButton.togglesState = YES;
    [_fingerTipsButton setSize:NSMakeSize(180, 50)];
    [_fingerTipsButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsDrawFingerTips]];
    [self addControl:_fingerTipsButton];

    _fingerLinesButton = [[OLKHorizScratchButton alloc] init];
    _fingerLinesButton.expandsOnInit = TRUE;
    _fingerLinesButton.rightInit = TRUE;
    _fingerLinesButton.togglesState = YES;
    [_fingerLinesButton setSize:NSMakeSize(180, 50)];
    [_fingerLinesButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsDrawFingers]];
    [self addControl:_fingerLinesButton];

    _hand3DButton = [[OLKHorizScratchButton alloc] init];
    _hand3DButton.expandsOnInit = TRUE;
    _hand3DButton.rightInit = TRUE;
    _hand3DButton.togglesState = YES;
    [_hand3DButton setSize:NSMakeSize(180, 50)];
    [_hand3DButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:Hands3DPerspective]];
    [self addControl:_hand3DButton];

    _fingerDepthYButton = [[OLKHorizScratchButton alloc] init];
    _fingerDepthYButton.expandsOnInit = TRUE;
    _fingerDepthYButton.togglesState = YES;
    [_fingerDepthYButton setSize:NSMakeSize(180, 50)];
    [_fingerDepthYButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsUseZForY]];
    [self addControl:_fingerDepthYButton];
    
    _autoSizeButton = [[OLKHorizScratchButton alloc] init];
    _autoSizeButton.expandsOnInit = TRUE;
    _autoSizeButton.rightInit = TRUE;
    _autoSizeButton.togglesState = YES;
    [_autoSizeButton setSize:NSMakeSize(180, 50)];
    [_autoSizeButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsAutoSizeHand]];
    [self addControl:_autoSizeButton];
    
    _stablePalmsButton = [[OLKHorizScratchButton alloc] init];
    _stablePalmsButton.expandsOnInit = TRUE;
    _stablePalmsButton.rightInit = TRUE;
    _stablePalmsButton.togglesState = YES;
    [_stablePalmsButton setSize:NSMakeSize(180, 50)];
    [_stablePalmsButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsUseStabilizedPos]];
    [self addControl:_stablePalmsButton];
    
    _interactionBoxButton = [[OLKHorizScratchButton alloc] init];
    _interactionBoxButton.expandsOnInit = TRUE;
    _interactionBoxButton.togglesState = YES;
    [_interactionBoxButton setSize:NSMakeSize(180, 50)];
    [_interactionBoxButton setOn:[[NSUserDefaults standardUserDefaults] boolForKey:HandsUseInteractionBox]];
    [self addControl:_interactionBoxButton];

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
    [_exitButton setLabel:@"Exit"];
    
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
}

- (void)layoutMenu
{
    NSRect bounds = [self bounds];
    float midPointXOffset = bounds.origin.x+bounds.size.width/2;
    float xOffsetLeft = midPointXOffset - _exitButton.size.width-20;
    float xOffsetRight = bounds.origin.x+midPointXOffset+20;
    float yOffsetFromTop = bounds.size.height-(bounds.size.width/16);
    [_boundedHandButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop)];
    [_palmButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop)];
    [_fingerLinesButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-100)];
    [_fingerTipsButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-100)];
    [_fingerDepthYButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-200)];
    [_hand3DButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-200)];
    [_stablePalmsButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-300)];
    [_interactionBoxButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-300)];
    [_autoSizeButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-400)];
    [_useSimpleCursorButton setDrawLocation:NSMakePoint(xOffsetLeft, yOffsetFromTop-500)];
    [_useOnlySimpleCursorButton setDrawLocation:NSMakePoint(xOffsetRight, yOffsetFromTop-500)];
    [_resetFitFactButton setDrawLocation:NSMakePoint(midPointXOffset - _resetFitFactButton.size.width-20, yOffsetFromTop-600)];
    [_resetToDefaultsButton setDrawLocation:NSMakePoint(midPointXOffset+20, yOffsetFromTop-600)];
    [_exitButton setDrawLocation:NSMakePoint(midPointXOffset - _exitButton.nonExpandedRect.size.width/2, yOffsetFromTop-750)];
}

@end
