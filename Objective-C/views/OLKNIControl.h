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

- (void)prepareLabelImage; // If you don't want the standard label drawing, override this so the standard label NSImage is not prepared and cached.
- (void)drawLabel;
- (void)draw;
- (void)requestRedraw;
- (NSRect)frame;
- (NSPoint)convertToParentViewCusorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView;

// converts the cursorPos to a point relative to the controls origin (drawLocation).
- (NSPoint)convertCusorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView;

- (void)autoCalculateLabelRectBounds;

@property (nonatomic) NSImage *labelImage;
@property (nonatomic) NSDictionary *labelAttributes;
@property (nonatomic) NSDictionary *labelBackAttributes;
@property (nonatomic) NSSize size;
@property (nonatomic) NSPoint drawLocation;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL visible;
@property (weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic) NSString *label;
@property (nonatomic) NSRect labelRectBounds;
@property (nonatomic) float labelFontSize;
@property (nonatomic) BOOL autoFontSize;
@property (nonatomic) BOOL autoCalcLabelRect;
@property (nonatomic) BOOL needsRedraw;
@property (nonatomic, weak) NSView *parentView;

@end
