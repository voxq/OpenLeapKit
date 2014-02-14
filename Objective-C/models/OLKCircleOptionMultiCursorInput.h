//
//  OLKCircleOptionMultiCursorInput.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKOptionMultiCursorInput.h"
#import "OLKHandCursorResponder.h"
#import "OLKRepeatTracker.h"

@interface OLKCircleOptionMultiCursorInput : NSObject <OLKOptionMultiCursorInput>

- (NSDictionary *)objectCoordinates;
- (void)resetCurrentCursorTracking;
- (void)removeAllCursorTracking;
- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (NSPoint)convertToLocalCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView;
- (id)objectAtPosition:(NSPoint)position;
- (int)indexAtPosition:(NSPoint)position;
- (id)objectAtAngle:(float)degree;
- (int)indexAtAngle:(float)degree;
- (id)objectAtIndex:(int)index;
- (void)setRequiresMoveToPrepRestrikeZone:(BOOL)requiresMoveToInner cursorContext:(id)cursorContext;
- (void)setRequiresMoveToStrictResetZone:(BOOL)requiresMoveToCenter cursorContext:(id)cursorContext;
- (int)selectedIndex:(id)cursorContext;
- (OLKRepeatTracker *)repeatTrackerFor:(id)cursorContext;
- (int)hoverIndex:(id)cursorContext;
- (int)prevSelectedIndex:(id)cursorContext;
- (int)prevHoverIndex:(id)cursorContext;
- (NSDictionary *)selectedIndexes;
- (NSDictionary *)hoverIndexes;
- (void)resetCurrentCursorTracking:(id)cursorContext;
- (void)removeCursorTracking:(id)cursorContext;
- (NSArray *)cursorPositions;

@property (nonatomic) NSObject <OLKOptionMultiCursorInputDelegate> *delegate;
@property (nonatomic) NSObject <OLKOptionMultiCursorInputDatasource> *datasource;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@property (nonatomic) NSArray *optionObjects;

@property (nonatomic) float thresholdForPrepRestrike;
@property (nonatomic) float thresholdForStrike;
@property (nonatomic) float thresholdForRepeat;
@property (nonatomic) float thresholdForStrictReset;
@property (nonatomic) BOOL applyThresholdsAsFactors;
@property (nonatomic) BOOL enableRepeatTracking;

@property (nonatomic) BOOL useInverse;

@property (nonatomic) CGFloat radius;
@property (nonatomic) NSSize size;
@property (nonatomic) BOOL active;

@end


