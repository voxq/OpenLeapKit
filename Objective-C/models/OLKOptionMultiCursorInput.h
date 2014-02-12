//
//  OLKOptionMultiCursorInput.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-10.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKHandsContainerViewController.h"

static int const OLKOptionMultiInputInvalidSelection = -1;

@protocol OLKOptionMultiCursorInputDatasource <NSObject>

- (NSPoint)convertToInputCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView;

@end

@protocol OLKOptionMultiCursorInputDelegate <NSObject>

@optional
- (void)hoverIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)selectedIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)repeatTriggered:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)repeatEnded:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)cursorMovedToPrepRestrikeZone:(id)sender cursorContext:(id)cursorContext;
- (void)cursorMovedToStrictResetZone:(id)sender cursorContext:(id)cursorContext;

@end

@protocol OLKOptionMultiCursorInput <NSObject>

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
- (NSDictionary *)selectedIndexes;
- (NSDictionary *)hoverIndexes;
- (void)resetCurrentCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (NSArray *)cursorPositions;
@property (nonatomic) NSObject <OLKOptionMultiCursorInputDelegate> *delegate;

@property (nonatomic) NSArray *optionObjects;

@property (nonatomic) NSSize size;
@property (nonatomic) float thresholdForPrepRestrike;
@property (nonatomic) float thresholdForStrike;
@property (nonatomic) float thresholdForRepeat;
@property (nonatomic) float thresholdForStrictReset;
@property (nonatomic) BOOL applyThresholdsAsFactors;
@property (nonatomic) BOOL enableRepeatTracking;

@end
