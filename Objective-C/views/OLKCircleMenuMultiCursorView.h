//
//  OLKCircleMenuMultiCursorView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKMenuMultiCursorView.h"
#import "OLKCircleOptionMultiCursorInput.h"
#import "OLKHandCursorResponder.h"

@interface OLKCircleMenuMultiCursorView : NSView <OLKHandCursorResponderParent, OLKOptionMultiCursorInputDatasource, OLKColorThemeableMenuMultiCursorView, OLKImageThemeableMenuMultiCursorView, OLKTextMenuMultiCursorView>

- (NSPoint)positionRelativeToCenter:(NSPoint)position convertFromView:(NSView *)view;
- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (NSPoint)convertToInputCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView;
- (void)removeFromSuperHandCursorResponder;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;
- (void)subHandCursorResponderRemovedTracking:(id)handCursorResponder forCursorContext:(id)cursorContext;
- (void)addHandCursorResponder:(id)handCursorResponder;
- (void)removeHandCursorResponder:(id)handCursorResponder;

@property (nonatomic, readonly) NSArray *subHandCursorResponders;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@property (nonatomic) OLKCircleOptionMultiCursorInput *optionInput;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL maintainProportion;

@property (nonatomic) NSPoint center;
@property (nonatomic) CGFloat innerRadius;

@property (nonatomic) NSImage *baseImage;
@property (nonatomic) NSImage *hoverImage;
@property (nonatomic) NSImage *selectedImage;

@property (nonatomic) float currentAlpha;
@property (nonatomic) float inactiveAlphaMultiplier;
@property (nonatomic) float textFontSize;
@property (nonatomic) NSFont *textFont;

@property (nonatomic) NSColor *optionTextColor;
@property (nonatomic) NSColor *optionBackgroundColor;
@property (nonatomic) NSColor *optionSeparatorColor;
@property (nonatomic) NSColor *optionHoverColor;
@property (nonatomic) NSColor *optionHighlightColor;
@property (nonatomic) NSColor *optionInnerHighlightColor;
@property (nonatomic) NSColor *optionSelectColor;

@property (nonatomic) NSColor *fillCenterColor;

@property (nonatomic) NSSet *highlightPositions;

@end
