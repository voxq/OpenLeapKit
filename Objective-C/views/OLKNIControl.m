//
//  OLKNIControl.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKNIControl.h"



@implementation OLKNIControl

@synthesize needsRedraw = _needsRedraw;
@synthesize active = _active;
@synthesize visible = _visible;
@synthesize target = _target;
@synthesize action = _action;
@synthesize enable = _enable;
@synthesize label = _label;
@synthesize drawLocation = _drawLocation;
@synthesize size = _size;
@synthesize parentView = _parentView;

- (id)init
{
    if (self = [super init])
    {
        _needsRedraw = YES;
        _visible = YES;
        _active = YES;
        _enable = YES;
    }
    return self;
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    [super setCursorTracking:cursorPos withHandView:handView];
}

- (void)draw
{
    self.needsRedraw = NO;
}

- (NSRect)frame
{
    NSRect frameRect;
    frameRect.size = _size;
    frameRect.origin = _drawLocation;
    return frameRect;
}

@end
