//
//  OLKCircleMenuMultiCursorView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKCircleOptionMultiCursorInput.h"
#import "OLKHandCursorResponder.h"

@interface OLKCircleMenuMultiCursorView : NSView <OLKHandCursorResponder>

- (void)redraw;
- (NSPoint)positionRelativeToCenter:(NSPoint)position convertFromView:(NSView *)view;
- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (void)removeFromSuperHandCursorResponder;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@property (nonatomic) OLKCircleOptionMultiCursorInput *circleInput;
@property (nonatomic) BOOL active;
@property (nonatomic) NSPoint center;
@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) NSImage *baseCircleImage;
@property (nonatomic) NSImage *hoverImage;

@property (nonatomic) float currentAlpha;
@property (nonatomic) float inactiveAlphaMultiplier;
@property (nonatomic) float textFontSize;
@property (nonatomic) NSFont *textFont;
@property (nonatomic) NSSet *highlightPositions;

@property (nonatomic) NSColor *optionRingColor;
@property (nonatomic) NSColor *optionSeparatorColor;
@property (nonatomic) NSColor *optionHoverColor;
@property (nonatomic) NSColor *optionHighlightColor;
@property (nonatomic) NSColor *optionInnerHighlightColor;
@property (nonatomic) NSColor *optionSelectColor;
@property (nonatomic) NSColor *fillCenterColor;

@end
