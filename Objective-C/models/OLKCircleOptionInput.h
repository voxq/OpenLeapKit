//
//  CircleTextInput.h
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKRepeatTracker.h"

static int const OLKCircleOptionInputInvalidSelection = -1;

@protocol OLKCircleOptionInputDelegate <NSObject>

@optional
- (void)hoverIndexChanged:(int)index sender:(id)sender;
- (void)selectedIndexChanged:(int)index sender:(id)sender;
- (void)repeatTriggered:(id)sender;
- (void)repeatEnded:(id)sender;
- (void)cursorMovedToInner:(id)sender;
- (void)cursorMovedToCenter:(id)sender;

@end

@interface OLKCircleOptionInput : NSObject

- (void)reset;
- (id)objectAtAngle:(float)degree;
- (int)indexAtAngle:(float)degree;
- (id)objectAtIndex:(int)index;

@property (nonatomic) NSObject <OLKCircleOptionInputDelegate> *delegate;
@property (nonatomic) BOOL requiresMoveToCenter;
@property (nonatomic) BOOL requiresMoveToInner;

@property (nonatomic) NSArray *optionObjects;

@property (nonatomic) CGFloat radius;
@property (nonatomic) float lastUpdateCursorDistance;
@property (nonatomic) float thresholdForHit;
@property (nonatomic) float thresholdForRepeat;
@property (nonatomic) float thresholdForCenter;

@property (nonatomic) int selectedIndex;
@property (nonatomic) int hoverIndex;
@property (nonatomic) NSPoint cursorPos;

@property (nonatomic) OLKRepeatTracker *repeatTracker;

@property (nonatomic) BOOL enableRepeatTracking;
@end
