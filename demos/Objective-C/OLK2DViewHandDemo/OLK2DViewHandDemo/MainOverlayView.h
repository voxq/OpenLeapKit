//
//  MainOverlayView.h
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CursorsView.h"
#import <OpenLeapKit/OLKHand.h>
#import <OpenLeapKit/OLKHandCursorResponder.h>
#import <OpenLeapKit/OLKNIControlsContainerView.h>
#import <OpenLeapKit/OLKHandsContainerViewController.h>

@interface MainOverlayView : NSView <OLKHandCursorResponderParent, OLKHandsContainerView>

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView;

- (void)addHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeFromSuperHandCursorResponder;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;
@property (nonatomic, readonly) NSArray *subHandCursorResponders;

@property (nonatomic) BOOL enableCursor;
@property (nonatomic) BOOL active;
@property (nonatomic) CursorsView *cursorsView;
@property (nonatomic) IBOutlet OLKNIControlsContainerView *menuView;
@property (nonatomic) BOOL menuShowing;

@end
