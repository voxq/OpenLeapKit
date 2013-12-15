//
//  OLKMultiCursorTrackingController.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-14.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKHand.h"
#import "OLKHandCursorResponder.h"

@interface OLKCursorTracking : NSObject

@property (nonatomic) NSView <OLKHandContainer> *handView;
@property (nonatomic) NSPoint cursorPos;

@end

@interface OLKMultiCursorTrackingController : NSObject <OLKHandCursorResponder>

- (OLKCursorTracking *)createCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView;
- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (void)removeFromSuperHandCursorResponder;

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;

@property (nonatomic, readonly) NSDictionary *cursorTrackings;
@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@end
