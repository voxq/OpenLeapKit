//
//  OLKNIControl.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKHandCursorResponder.h"
#import "OLKMultiCursorTrackingController.h"

@interface OLKNIControl : OLKMultiCursorTrackingController <NSCopying>

- (id)copyAddingToSuper;
- (void)prepareLabelImage; // If you don't want the standard label drawing, override this so the standard label NSImage is not prepared and cached.
- (void)drawLabel;
- (void)draw;
- (void)requestRedraw;
- (NSRect)frame; // includes label overflow from original size specification
- (NSRect)frameWithoutLabel;
- (NSRect)labelRectBoundsFrame;
- (NSPoint)convertToParentViewCusorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView;
- (void)recalculateFontSize;

// converts the cursorPos to a point relative to the controls origin (drawLocation).
- (NSPoint)convertCursorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView;

- (void)autoCalculateLabelRectBounds;

@property id <NSObject> context;
@property NSImage *labelImage;
@property NSDictionary *labelAttributes;
@property NSDictionary *labelBackAttributes;
@property NSSize size;
@property NSPoint drawLocation;
@property BOOL enable;
@property BOOL active;
@property BOOL visible;
@property (weak) id target;
@property SEL action;
@property NSString *label;
@property NSRect labelRectBounds;
@property float labelFontSize;
@property BOOL labelFontBold;
@property BOOL autoFontSize;
@property BOOL autoCalcLabelRect;
@property BOOL needsRedraw;
@property BOOL outlineLabel;
@property (weak) NSView *parentView;

@end
