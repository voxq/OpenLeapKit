//
//  OLKLineOptionMultiCursorInput.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-10.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKOptionMultiCursorInput.h"
#import "OLKHandCursorResponder.h"
#import "OLKRepeatTracker.h"

@interface OLKLineOptionMultiCursorInput : NSObject <OLKOptionMultiCursorInput>

- (NSDictionary *)objectCoordinates;
- (void)resetCurrentCursorTracking;
- (void)removeAllCursorTracking;
- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (id)objectAtPosition:(NSPoint)position;
- (int)indexAtPosition:(NSPoint)position;
- (id)objectAtIndex:(int)index;
- (void)setRequiresMoveToPrepRestrikeZone:(BOOL)requiresMoveToInner cursorContext:(id)cursorContext;
- (void)setRequiresMoveToStrictResetZone:(BOOL)requiresMoveToCenter cursorContext:(id)cursorContext;
- (int)selectedIndex:(id)cursorContext;
- (int)hoverIndex:(id)cursorContext;
- (int)prevSelectedIndex:(id)cursorContext;
- (int)prevHoverIndex:(id)cursorContext;
- (OLKRepeatTracker *)repeatTrackerFor:(id)cursorContext;
- (NSDictionary *)selectedIndexes;
- (NSDictionary *)hoverIndexes;
- (void)resetCurrentCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (NSArray *)cursorPositions;

- (NSRect)optionRectAtPosition:(NSPoint)position;
- (NSRect)optionRectForIndex:(int)index;


@property (nonatomic) NSObject <OLKOptionMultiCursorInputDelegate> *delegate;
@property (nonatomic) NSObject <OLKOptionMultiCursorInputDatasource> *datasource;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@property (nonatomic) NSArray *optionObjects;

@property (nonatomic) NSSize size;
@property (nonatomic) float thresholdForPrepRestrike;
@property (nonatomic) float thresholdForStrike;
@property (nonatomic) float thresholdForRepeat;
@property (nonatomic) float thresholdForStrictReset;
@property (nonatomic) BOOL applyThresholdsAsFactors;
@property (nonatomic) BOOL enableRepeatTracking;
@property (nonatomic) BOOL vertical;
@property (nonatomic) BOOL active;

@end
