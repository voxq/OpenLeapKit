//
//  OLKScratchButtonShell.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-15.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenLeapKit/OLKNIControl.h>

@interface OLKScratchButtonShell : OLKNIControl

- (BOOL)escapeInY:(NSPoint)position;

// These methods are required to be implemented in subclasses
- (void)updateSwitcherPosition:(NSPoint)position;
- (BOOL)positionReachedHalfwayHotzone:(NSPoint)position;
- (BOOL)detectCompletion:(NSPoint)position;
- (BOOL)inSlideInitiateZone:(NSPoint)position;
- (NSPoint)containSwitcherMovementToHalfway:(NSPoint)position;
- (NSPoint)containSwitcherMovementToBegin:(NSPoint)position;
- (void)resetSwitcherToBeginPosition;
- (NSPoint)beginCatcherDrawPosition;
- (NSPoint)halfwayCatcherDrawPosition;
// end of requirement

- (void)clear;
- (void)reset;
- (NSPoint)halfwayCheckAndUpdate:(NSPoint)position;
- (BOOL)handleSliding:(NSPoint)position;
- (BOOL)detectSlideInitiate:(NSPoint)position;
- (BOOL)cursorMovedTo:(NSPoint)position;
- (BOOL)detectReset:(NSPoint)position;
- (BOOL)inHotZone:(NSPoint)position;
- (BOOL)escapedResetZone:(NSPoint)position;
- (BOOL)escapedHotZone:(NSPoint)position;
- (void)triggerCompleted;
- (NSPoint)switcherDrawPosition;
- (BOOL)shouldDrawBeginCatcher;
- (BOOL)shouldDrawHalfwayCatcher;
- (NSRect)beginCatcherRect;
- (NSRect)halfwayCatcherRect;
- (NSRect)beginSwitcherRect;
- (NSRect)halfwaySwitcherRect;
- (NSRect)halfwayCatcherDrawRect;
- (NSRect)beginCatcherDrawRect;

@property (nonatomic, readonly) NSImage *beginCatcher; // The catcher image for initiation based on state of "togglesState" and "on" property
@property (nonatomic, readonly) NSImage *endCatcher; // The catcher image for completing based on state of "togglesState" and "on" property
@property (nonatomic) NSImage *catcherOnImg;
@property (nonatomic) NSImage *catcherOffImg;
@property (nonatomic) NSImage *catcherHalfImg;
@property (nonatomic) NSImage *switcherOnImg;
@property (nonatomic) NSImage *switcherOffImg;
@property (nonatomic) NSImage *switcherHalfImg;
@property (nonatomic) BOOL sliding;
@property (nonatomic) BOOL halfway;
@property (nonatomic) BOOL requiresReset;

@property (nonatomic) NSView <OLKHandContainer> *controllingHandView;
@property (nonatomic) BOOL activated;
@property (nonatomic) float alpha;
@property (nonatomic) NSPoint switcherPosition;
@property (nonatomic) NSSize escapeZone;
@property (nonatomic) NSSize outerHotZone;
@property (nonatomic) NSSize resetEscapeZone;
@property (nonatomic) float innerHotZone;
@property (nonatomic) NSColor *onColor;
@property (nonatomic) NSColor *offColor;
@property (nonatomic) NSColor *halfColor;
@property (nonatomic) BOOL useResetEscape;
@property (nonatomic) BOOL togglesState;
@property (nonatomic) BOOL on;

@end
