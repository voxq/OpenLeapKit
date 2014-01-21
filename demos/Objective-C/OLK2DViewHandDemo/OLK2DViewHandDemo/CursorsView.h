//
//  CursorsView.h
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-27.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenLeapKit/OLKHand.h>
#import <OpenLeapKit/OLKHandCursorResponder.h>
#import <OpenLeapKit/OLKMultiCursorTrackingController.h>

@interface CursorsView : NSView <OLKHandCursorResponder>

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView;
- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
- (void)removeAllCursorTracking;
- (void)removeFromSuperHandCursorResponder;

@property (nonatomic) OLKMultiCursorTrackingController *cursorTrackingController;
@property (nonatomic) NSObject <OLKHandCursorResponderParent> *superHandCursorResponder;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL active;
@property (nonatomic) NSImage *cursorImg;
@property (nonatomic) NSSize cursorSize;

@end
