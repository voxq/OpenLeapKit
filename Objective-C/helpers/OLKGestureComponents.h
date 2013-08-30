//
//  OLKGestureComponents.h
//  LeapEdit
//
//  Created by Tyler Zetterstrom on 2013-07-05.
//
//

#import "LeapObjectiveC.h"

@interface OLKGestureComponents : NSObject

#pragma mark -
#pragma single hand components

+ (BOOL)handUpright:(LeapHand *)hand normalTolerance:(float)normalTolerance;
+ (BOOL)handPalmDown:(LeapHand *)hand normalTolerance:(float)normalTolerance;


#pragma mark -
#pragma two hand components

+ (NSArray*)handArraySortedFromHands:(LeapHand *)hand1 otherHand:(LeapHand*)hand2;

+ (LeapVector*)handsMidPoint:(LeapHand *)hand1 otherHand:(LeapHand *)hand2;

+ (BOOL)handsFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance;
+ (BOOL)handsFacingSame:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance;
+ (BOOL)handsPalmDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance;
+ (BOOL)handsUpright:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance;
+ (BOOL)handsBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 maxProximity:(float)maxProximity sameAxisTolerance:(float)sameAxisTolerance;
+ (BOOL)handsNotFurtherThan:(float)cubeDistance hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2;


#pragma mark -
#pragma two hand complex components

+ (BOOL)handsUprightAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance;
+ (BOOL)handsClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 cubeDistance:(float)cubeDistance normalTolerance:(float)normalTolerance;
+ (BOOL)handsClampedAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 cubeDistance:(float)cubeDistance normalTolerance:(float)normalTolerance;
+ (BOOL)handsPalmDownAndBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 maxProximity:(float)maxProximity normalTolerance:(float)normalTolerance sameAxisTolerance:(float)sameAxisTolerance;

@end
