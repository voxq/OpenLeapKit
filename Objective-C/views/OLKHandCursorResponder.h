//
//  OLKHandCursorResponder.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKHand.h"

@protocol OLKHandCursorResponderParent;

@protocol OLKHandCursorResponder <NSObject>

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (void)removeFromSuperHandCursorResponder;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@optional
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;

@end

@protocol OLKHandCursorResponderParent <NSObject>

- (void)addHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeFromSuperHandCursorResponder;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;
@property (nonatomic, readonly) NSArray *subHandCursorResponders;

@end
