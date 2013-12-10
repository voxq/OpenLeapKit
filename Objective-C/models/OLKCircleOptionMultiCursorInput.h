//
//  OLKCircleOptionMultiCursorInput.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKRepeatTracker.h"

static int const OLKCircleOptionMultiInputInvalidSelection = -1;

@protocol OLKCircleOptionMultiCursorInputDelegate <NSObject>

@optional
- (void)hoverIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)selectedIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)repeatTriggered:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)repeatEnded:(int)index sender:(id)sender cursorContext:(id)cursorContext;
- (void)cursorMovedToInner:(id)sender cursorContext:(id)cursorContext;
- (void)cursorMovedToCenter:(id)sender cursorContext:(id)cursorContext;

@end



@interface OLKCircleOptionMultiCursorInput : NSObject

- (void)reset;
- (id)objectAtAngle:(float)degree;
- (int)indexAtAngle:(float)degree;
- (id)objectAtIndex:(int)index;
- (void)setCursorPos:(NSPoint)cursorPos cursorContext:(id)cursorContext;
- (void)setRequiresMoveToInner:(BOOL)requiresMoveToInner cursorContext:(id)cursorContext;
- (void)setRequiresMoveToCenter:(BOOL)requiresMoveToCenter cursorContext:(id)cursorContext;
- (int)selectedIndex:(id)cursorContext;
- (int)hoverIndex:(id)cursorContext;
- (NSDictionary *)selectedIndexes;
- (NSDictionary *)hoverIndexes;
- (void)removeCursorContext:(id)cursorContext;

@property (nonatomic) NSObject <OLKCircleOptionMultiCursorInputDelegate> *delegate;

@property (nonatomic) NSArray *optionObjects;

@property (nonatomic) CGFloat radius;
@property (nonatomic) float thresholdForHit;
@property (nonatomic) float thresholdForRepeat;
@property (nonatomic) float thresholdForCenter;

@property (nonatomic) BOOL enableRepeatTracking;


@end


