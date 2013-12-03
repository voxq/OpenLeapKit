//
//  OLKRepeatTracker.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-01.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLKRepeatTracker : NSObject

- (void)resetToDefaults;
- (void)reset;
- (void)initRepeatWithObject:(id)object;
- (BOOL)detectRepeatOfObject:(id)object;
- (void)stopRepeatIfObject:(id)object;

@property (nonatomic) BOOL isRepeating;
@property (nonatomic) int repeatRate;
@property (nonatomic) int repeatCycles;
@property (nonatomic) int repeatedCount;
@property (nonatomic) int repeatAccelOnCycles;
@property (nonatomic) int repeatAccelAmt;
@property (nonatomic) int repeatAccel;
@property (nonatomic) id repeatObject;


@end
