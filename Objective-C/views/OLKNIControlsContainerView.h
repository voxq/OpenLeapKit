//
//  OLKNIControlsContainerView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKHand.h"
#import "OLKNIControl.h"
#import "OLKMultiCursorTrackingController.h"

@protocol OLKNIControlsContainerViewDelegate <NSObject>

- (void)controlChangedValue:(id)sender control:(OLKNIControl *)control;

@end

@interface OLKNIControlsContainerView : NSView <OLKHandCursorResponderParent>

- (void)addControl:(OLKNIControl *)control;
- (void)addControlsForLabels:(NSArray *)controlLabels withTemplate:(OLKNIControl *)controlTemplate;
- (NSRect)layoutControlsEvenly:(NSRect)containRect forControls:(NSRange)controlRange;
- (void)removeControl:(OLKNIControl *)control;
- (void)removeAllControls;
- (void)reset;

- (void)removeFromSuperHandCursorResponder;
- (void)addHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;
- (void)removeHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder;

@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;
@property (nonatomic, readonly) NSArray *subHandCursorResponders;
@property (nonatomic) NSArray *controls;
@property (nonatomic) NSObject <OLKNIControlsContainerViewDelegate> * delegate;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL active;

@end
