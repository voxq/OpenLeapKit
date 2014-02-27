//
//  OLKMenuMultiCursorView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-10.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKOptionMultiCursorInput.h"
#import "OLKHandCursorResponder.h"

@protocol OLKMenuMultiCursorView <OLKHandCursorResponder>

- (void)redraw;

@property (nonatomic) NSObject <OLKOptionMultiCursorInput> *optionInput;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL maintainProportion;
@property (nonatomic) BOOL showSelection;
@property (nonatomic) BOOL fastEdit; // suggests realtime editing required, ie. resizing/reposition with many calls to setFrame.

@end


@protocol OLKTextMenuMultiCursorView <OLKMenuMultiCursorView>

@property (nonatomic) float textFontSize;
@property (nonatomic) NSFont *textFont;

@end


@protocol OLKImageThemeableMenuMultiCursorView <OLKMenuMultiCursorView>

@property (nonatomic) float currentAlpha;
@property (nonatomic) float inactiveAlphaMultiplier;

@property (nonatomic) NSImage *baseImage;
@property (nonatomic) NSImage *hoverImage;
@property (nonatomic) NSImage *selectedImage;

@end


@protocol OLKColorThemeableMenuMultiCursorView <OLKMenuMultiCursorView>

@property (nonatomic) float currentAlpha;
@property (nonatomic) float inactiveAlphaMultiplier;

@property (nonatomic) NSColor *optionTextColor;
@property (nonatomic) NSColor *optionBackgroundColor;
@property (nonatomic) NSColor *optionSeparatorColor;
@property (nonatomic) NSColor *optionHoverColor;
@property (nonatomic) NSColor *optionHighlightColor;
@property (nonatomic) NSColor *optionSelectColor;

@end