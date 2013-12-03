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
- (void)calibrateWithScreenPos1:(NSPoint)screenPos1 andScreenPos2:(NSPoint)screenPos2 mappingLeapPos1:(LeapVector*)leapPos1 andLeapPos2:(LeapVector *)leapPos2;
- (void)calibrate;
- (void)configScreenPositionsFromWindow:(NSWindow *)window;
- (void)configScreenPositions;
- (void)configScreenPositionsFromRect:(NSRect)screenRect;

@property (nonatomic) float heightFactor;
@property (nonatomic) float widthFactor;
@property (nonatomic) float offsetToBase;
@property (nonatomic) NSRect screenFrame;
@property (nonatomic) LeapVector *leapPos1;
@property (nonatomic) LeapVector *leapPos2;
@property (nonatomic) NSPoint screenPos1;
@property (nonatomic) NSPoint screenPos2;

@end
