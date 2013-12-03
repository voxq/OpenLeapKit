//
//  OLKRangeCalibratorView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-02.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKRangeCalibrator.h"

typedef enum
{
    OLKRangeNoPositionsCalibrated,
    OLKRangeFirstPositionCalibrated,
    OLKRangeSecondPositionCalibrated,
    OLKRangeAllPositionsCalibrated
}OLKRangePositionsCalibrated;

@protocol OLKRangeCalibratorViewDelegate <NSObject>

- (void)canceledCalibration;
- (void)calibratedPosition:(OLKRangePositionsCalibrated)positionCalibrated;

@end

@interface OLKRangeCalibratorView : NSView

- (void)reset;

@property (nonatomic) OLKRangeCalibrator *rangeCalibrator;
@property (nonatomic) NSSize selectPointSize;
@property (nonatomic) NSObject <OLKRangeCalibratorViewDelegate> *delegate;
@property (nonatomic) OLKRangePositionsCalibrated positionsCalibrated;

@end
