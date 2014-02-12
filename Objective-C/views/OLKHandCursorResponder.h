//
//  OLKHandCursorResponder.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKHand.h"

typedef enum
{
    OLKHandCursorControlNone,
    OLKHandCursorControlGlobal,
    OLKHandCursorControlPeersAndChildren
}OLKHandCursorControl;


@protocol OLKHandCursorResponderParent;


@protocol OLKHandCursorResponder <NSObject>

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView;
- (void)removeFromSuperHandCursorResponder;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;

@optional
- (NSPoint)convertToLocalCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;

@property (nonatomic) NSView <OLKHandContainer> *controllingHandView;

@end


@protocol OLKHandCursorResponderParent <OLKHandCursorResponder>

- (void)addHandCursorResponder:(id)handCursorResponder;
- (void)removeHandCursorResponder:(id)handCursorResponder;

@property (nonatomic, readonly) NSArray *subHandCursorResponders;

@optional

- (NSPoint)convertForChildrenCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView;
- (OLKHandCursorControl)controlByHand:(NSView <OLKHandContainer> *)handView ofChild:(id)subHandCursorResponder;
- (void)controlReleasedByHand:(NSView <OLKHandContainer> *)handView;
- (id)childCursorResponderControlledByHand:(NSView <OLKHandContainer> *)handView;

@property (nonatomic, readonly) BOOL ignoreSubviews;

@end
