//
//  OLKNIControlsContainerView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKNIControlsContainerView.h"
#import "OLKScratchButton.h"
@implementation OLKNIControlsContainerView

@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize subHandCursorResponders = _subHandCursorResponders;
@synthesize active = _active;
@synthesize delegate = _delegate;
@synthesize enabled = _enabled;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)controlTriggered:(OLKNIControl *)control
{
    [_delegate controlChangedValue:self control:control];
}

- (void)addControl:(OLKNIControl *)control
{
    if (!_subHandCursorResponders)
        _subHandCursorResponders = [NSArray arrayWithObject:control];
    else
        _subHandCursorResponders = [_subHandCursorResponders arrayByAddingObject:control];
    
    if (![control parentView])
        control.parentView = self;

    if ([control target])
        return;
    
    control.target = self;
    control.action = @selector(controlTriggered:);
}

- (void)removeControl:(OLKNIControl *)control
{
    if (!_subHandCursorResponders || ![_subHandCursorResponders count])
        return;
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_subHandCursorResponders];
    [newArray removeObject:control];
    if ([_subHandCursorResponders count] != [newArray count])
        _subHandCursorResponders = [NSArray arrayWithArray:newArray];
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
}

- (void)addHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder
{
    if (!_subHandCursorResponders)
        _subHandCursorResponders = [NSArray arrayWithObject:handCursorResponder];
    else
        _subHandCursorResponders = [_subHandCursorResponders arrayByAddingObject:handCursorResponder];
    [handCursorResponder setSuperHandCursorResponder:self];
}

- (void)removeHandCursorResponder:(NSObject <OLKHandCursorResponder> *)handCursorResponder
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_subHandCursorResponders];
    [newArray removeObject:handCursorResponder];
    _subHandCursorResponders = [NSArray arrayWithArray:newArray];
    [handCursorResponder setSuperHandCursorResponder:nil];
}

- (void)removeFromSuperHandCursorResponder
{
    if (_superHandCursorResponder)
        [_superHandCursorResponder removeHandCursorResponder:self];
}


- (void)reset
{
    
}

- (void)drawRect:(NSRect)dirtyRect
{
//    NSMutableSet *controlsToRedraw = [[NSMutableSet alloc] init];
    for (OLKNIControl *control in _subHandCursorResponders)
    {
        if ([control needsRedraw] || [self needsToDrawRect:[control frame]])
            [control draw];
    }
//    if (![controlsToRedraw count])
//        return;
//
//    [_containerImage lockFocus];
//    for (OLKNIControl *control in controlsToRedraw)
//    {
//        [control draw];
//    }
//    [_containerImage unlockFocus];
//    
//    NSRect menuRect;
//    menuRect.origin = NSMakePoint(0, 0);
//    menuRect.size = [self bounds].size;
//    
//    float currentAlpha;
//    if (_active)
//        currentAlpha = 1;
//    else
//        currentAlpha = 0.3;
//    [_menuImage drawAtPoint:[self bounds].origin fromRect:menuRect operation:NSCompositeSourceOver fraction:currentAlpha];
}

@end
