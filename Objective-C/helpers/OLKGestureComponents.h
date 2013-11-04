//
//  OLKGestureComponents.h
//  LeapEdit
//
//  Created by Tyler Zetterstrom on 2013-07-05.
//
//

#import "LeapObjectiveC.h"


@interface OLKGestureComponents : NSObject

@property (nonatomic) BOOL usingInteractionBox;
@property (nonatomic) BOOL usingStabilizedPalm;

#pragma mark -
#pragma single hand components

- (BOOL)palmAimingSideway:(LeapHand *)hand normalThreshold:(float)normalThreshold;
- (BOOL)palmAimingInOrOut:(LeapHand *)hand normalThreshold:(float)normalThreshold;
- (BOOL)palmAimingUpOrDown:(LeapHand *)hand normalThreshold:(float)normalThreshold;
- (BOOL)palmDown:(LeapHand *)hand normalThreshold:(float)normalThresholdl;
- (BOOL)handBeyondThreshold:(float)threshold inDirMinus:(BOOL)inDirMinus hand:(LeapHand *)hand;
- (BOOL)handBeyondThresholdPalmDown:(float)threshold inDirMinus:(BOOL)inDirMinus hand:(LeapHand *)hand normalThreshold:(float)normalThreshold;


#pragma mark -
#pragma two hand components

- (LeapVector*)handsMidPoint:(LeapHand *)hand1 otherHand:(LeapHand *)hand2;
- (BOOL)palmsFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;

- (NSArray*)handArraySortedFromHands:(LeapHand *)hand1 otherHand:(LeapHand*)hand2;

- (BOOL)palmsAimingSideway:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;
- (BOOL)palmsDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;
- (BOOL)handsBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 axisTolerance:(float)axisTolerance;
- (BOOL)handsNotFurtherThan:(float)proximity hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2;
- (BOOL)handsFurtherThan:(float)proximity hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2;
- (BOOL)handsClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;
- (BOOL)handsSpread:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 spread:(float)spread axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;


#pragma mark -
#pragma two hand complex components

- (BOOL)handsInProximityBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance;
- (BOOL)handsClampedAndPalmsFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;
- (BOOL)handsBesideAndPalmsDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold axisTolerance:(float)axisTolerance;
- (BOOL)handsInProximityBesideAndPalmsDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity normalThreshold:(float)normalThreshold axisTolerance:(float)axisTolerance;

- (BOOL)palmsSidewayAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;
- (BOOL)palmsInOutAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;
- (BOOL)palmsUpDownAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;
- (BOOL)palmsSidewayAndFacingSame:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold;

- (BOOL)palmsBesideAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;
- (BOOL)palmsSidewayClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;
- (BOOL)palmsSidewayClampedAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;
- (BOOL)palmsSpreadBesideAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 spread:(float)spread axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold;


@end
