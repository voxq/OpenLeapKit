//
//  OLKContextHand.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-04.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKHand.h"

@interface OLKContextHand : OLKHand

- (BOOL)palmUp;
- (BOOL)palmDown;
- (BOOL)palmAimingSideway;
- (BOOL)palmAimingLeft;
- (BOOL)palmAimingRight;
- (BOOL)handPointingSideway;
- (BOOL)handPointingLeft;
- (BOOL)handPointingRight;
- (BOOL)palmAimingInOut;
- (BOOL)palmAimingIn;
- (BOOL)palmAimingOut;

@property (nonatomic) BOOL changedPalmUp;
@property (nonatomic) BOOL changedPalmDown;
@property (nonatomic) BOOL changedPalmAimingSideway;
@property (nonatomic) BOOL changedPalmAimingLeft;
@property (nonatomic) BOOL changedPalmAimingRight;
@property (nonatomic) BOOL changedHandPointingSideway;
@property (nonatomic) BOOL changedHandPointingLeft;
@property (nonatomic) BOOL changedHandPointingRight;
@property (nonatomic) BOOL changedPalmAimingInOut;
@property (nonatomic) BOOL changedPalmAimingIn;
@property (nonatomic) BOOL changedPalmAimingOut;

@property (nonatomic) LeapHand *previousLeapHand;

@property (nonatomic) float resetThresholdBufferPercent;
@property (nonatomic) float palmUpThreshold;
@property (nonatomic) float palmDownThreshold;
@property (nonatomic) float palmAimingInOutThreshold;
@property (nonatomic) float handPointingSidewayThreshold;
@property (nonatomic) float palmAimingSidewayThreshold;

@end
