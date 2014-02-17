//
//  OLKSimplePointableHandView.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-13.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKHand.h"

@interface OLKSimplePointableHandView : NSView <OLKHandContainer>

@property (nonatomic) OLKHandCursorPosType cursorType;

@property (nonatomic) OLKHand *hand;
@property (nonatomic) NSView *spaceView;

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL enableStable;

@property (nonatomic) NSColor *color;
@property (nonatomic) NSPoint activePoint;
@property (nonatomic) NSPoint centerPoint;

@end
