//
//  OLKNIControl.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKHandCursorResponder.h"
#import "OLKMultiCursorTrackingController.h"

@interface OLKNIControl : OLKMultiCursorTrackingController

- (void)draw;
- (NSRect)frame;

@property (nonatomic) NSSize size;
@property (nonatomic) NSPoint drawLocation;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL visible;
@property (weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic) NSString *label;
@property (nonatomic) BOOL needsRedraw;
@property (nonatomic, weak) NSView *parentView;

@end
