//
//  OLKSimplePointableHandView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-13.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import "OLKSimplePointableHandView.h"

@implementation OLKSimplePointableHandView

@synthesize centerPoint = _centerPoint;
@synthesize activePoint = _activePoint;

@synthesize cursorType = _cursorType;
@synthesize hand = _hand;
@synthesize spaceView = _spaceView;

@synthesize enabled = _enabled;
@synthesize enableStable = _enableStable;

@synthesize color = _color;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cursorType = OLKHandCursorPosTypeLongFingerTip;
        // Initialization code here.
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSUInteger)hash
{
    return (NSUInteger)[[_hand leapHand] id];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!_hand || ![[_hand leapHand] isValid] || !object)
        return NO;
    
    if (![object isKindOfClass:[OLKSimplePointableHandView class]])
        return NO;
    
    LeapHand *otherHand = [[(OLKSimplePointableHandView *)object hand] leapHand];
    if ([otherHand isValid] && [[_hand leapHand] id] == [otherHand id])
        return YES;
    
    return NO;
}

- (void)setHand:(OLKHand *)hand
{
    _hand = hand;
    [self setNeedsDisplay:YES];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    _centerPoint.x = (_bounds.origin.x + _bounds.size.width)/2;
    _centerPoint.y = (_bounds.origin.y + _bounds.size.height)/2;
}


- (void)drawRect:(NSRect)dirtyRect
{
    if (!_enabled)
        return;
    
}

@end
