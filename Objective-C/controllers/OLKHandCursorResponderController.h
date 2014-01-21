//
//  OLKHandCursorResponderController.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKHandCursorResponder.h"

@interface OLKHandCursorResponderController : NSObject <OLKHandCursorResponderParent>

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (void)addHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;

@property (nonatomic, readonly) NSArray *subHandCursorResponders;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@end
