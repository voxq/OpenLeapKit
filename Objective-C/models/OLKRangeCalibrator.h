//
//  OLKRangeCalibrator.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-02.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

@interface OLKRangeCalibrator : NSObject

- (NSPoint)screenPosFromLeapPos:(LeapVector*)leapPos;
- (void)calibrate2PointWithScreenPos1:(NSPoint)screenPos1 screenPos2:(NSPoint)screenPos2 mappingLeapPos1:(LeapVector*)leapPos1 leapPos2:(LeapVector *)leapPos2;
- (void)calibrate3PointWithScreenPos1:(NSPoint)screenPos1 screenPos2:(NSPoint)screenPos2 screenPos3:(NSPoint)screenPos3 mappingLeapPos1:(LeapVector*)leapPos1 leapPos2:(LeapVector *)leapPos2 leapPos3:(LeapVector *)leapPos3;
- (void)calibrate;
- (void)configScreenPositionsFromWindow:(NSWindow *)window;
- (void)configScreenPositions;

@property (nonatomic) float heightFactor;
@property (nonatomic) float widthFactor;
@property (nonatomic) float offsetToBase;
@property (nonatomic) float offsetFromHorizCenter;
@property (nonatomic) NSRect screenFrame;
@property (nonatomic) LeapVector *leapPos1;
@property (nonatomic) LeapVector *leapPos2;
@property (nonatomic) LeapVector *leapPos3;
@property (nonatomic) NSPoint screenPos1;
@property (nonatomic) NSPoint screenPos2;
@property (nonatomic) NSPoint screenPos3;
@property (nonatomic) BOOL use3PointCalibration;
@property (nonatomic) BOOL calibrated;

@end
