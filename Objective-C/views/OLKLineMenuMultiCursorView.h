//
//  OLKLineMenuMultiCursorView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-10.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKLineOptionMultiCursorInput.h"
#import "OLKMenuMultiCursorView.h"
#import "OLKHandCursorResponder.h"

@interface OLKLineMenuMultiCursorView : NSView <OLKHandCursorResponderParent, OLKOptionMultiCursorInputDatasource, OLKColorThemeableMenuMultiCursorView, OLKImageThemeableMenuMultiCursorView, OLKTextMenuMultiCursorView>

- (void)redraw;
- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (NSPoint)convertToInputCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView;
- (void)removeFromSuperHandCursorResponder;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;

- (void)addHandCursorResponder:(id)handCursorResponder;
- (void)removeHandCursorResponder:(id)handCursorResponder;

@property (nonatomic, readonly) NSArray *subHandCursorResponders;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@property (nonatomic) OLKLineOptionMultiCursorInput *optionInput;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL maintainProportion;

@property (nonatomic) NSImage *baseImage;
@property (nonatomic) NSImage *hoverImage;
@property (nonatomic) NSImage *selectedImage;

@property (nonatomic) float currentAlpha;
@property (nonatomic) float inactiveAlphaMultiplier;
@property (nonatomic) float textFontSize;
@property (nonatomic) NSFont *textFont;

@property (nonatomic) NSColor *optionBackgroundColor;
@property (nonatomic) NSColor *optionSeparatorColor;
@property (nonatomic) NSColor *optionHoverColor;
@property (nonatomic) NSColor *optionHighlightColor;
@property (nonatomic) NSColor *optionSelectColor;

@end
