//
//  OLKHoverButton.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-15.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenLeapKit/OLKNIControl.h>

@interface OLKHoverButton : OLKNIControl

- (void)clear;
- (void)reset;
- (BOOL)handleHovering:(NSPoint)position;
- (BOOL)detectHoverInitiate:(NSPoint)position;
- (BOOL)cursorMovedTo:(NSPoint)position;
- (BOOL)inHotZone:(NSPoint)position;
- (BOOL)escapedResetZone:(NSPoint)position;
- (BOOL)escapedHotZone:(NSPoint)position;
- (void)triggerCompleted;
- (BOOL)detectCompletion:(NSPoint)position;
- (void)createButtonImages;

@property (nonatomic) NSImage *buttonHoverImg;
@property (nonatomic) NSImage *buttonOffImg;
@property (nonatomic) NSImage *buttonOnImg;
@property (nonatomic) NSImage *buttonActivatedImg;
@property (nonatomic) BOOL requiresReset;

@property (nonatomic) NSView <OLKHandContainer> *controllingHandView;
@property (nonatomic) BOOL hovering;
@property (nonatomic) BOOL activated;
@property (nonatomic) float alpha;
@property (nonatomic) NSTimeInterval hoverTimeToActivate;
@property (nonatomic) NSDate *hoveringSince;
@property (nonatomic) NSSize escapeZone;
@property (nonatomic) NSSize outerHotZone;
@property (nonatomic) NSSize resetEscapeZone;
@property (nonatomic) NSColor *onColor;
@property (nonatomic) NSColor *offColor;
@property (nonatomic) NSColor *hoverColor;
@property (nonatomic) NSColor *borderColor;
@property (nonatomic) BOOL useResetEscape;
@property (nonatomic) BOOL togglesState;
@property (nonatomic) BOOL on;
@property (nonatomic) BOOL showBorder;

@end
