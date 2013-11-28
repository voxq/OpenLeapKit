//
//  OLKButton.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-21.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OLKButton <NSObject>

- (void)onFrame:(NSNotification *)notification;
- (void)draw:(NSString *)label at:(NSPoint)drawLocation;

@property (nonatomic) int identifier;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL visible;
@property (nonatomic) NSSize size;
@property (weak) id target;
@property (nonatomic) SEL action;

@end
