//
//  OLKHandCursorResponderController.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKHandCursorResponderController.h"

@implementation OLKHandCursorResponderController

@synthesize subHandCursorResponders = _subHandCursorResponders;
@synthesize superHandCursorResponder = _superHandCursorResponder;

- (void)walkHandCursorResponders:(NSArray *)handCursorResponders settingCursorPos:(NSPoint)cursorPos forHandView:(NSView<OLKHandContainer> *)handView
{
    for (id subResponder in handCursorResponders)
    {
        if ([subResponder conformsToProtocol:@protocol(OLKHandCursorResponderParent)])
        {
            NSArray *cursorResponderPotentials = [self arrayOfPotentialsFor:subResponder];
            if (cursorResponderPotentials)
                [self walkHandCursorResponders:[NSArray arrayWithArray:cursorResponderPotentials] settingCursorPos:cursorPos forHandView:handView];
        }
        if ([subResponder respondsToSelector:@selector(setCursorTracking:withHandView:)])
            [subResponder setCursorTracking:cursorPos withHandView:handView];
    }
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView
{
    [self walkHandCursorResponders:[NSArray arrayWithArray:_subHandCursorResponders] settingCursorPos:cursorPos forHandView:handView];
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
}

- (void)removeFromSuperHandCursorResponder
{
    if (_superHandCursorResponder)
        [_superHandCursorResponder removeHandCursorResponder:self];
}

- (NSArray *)arrayOfPotentialsFor:(id <OLKHandCursorResponderParent>)responder
{
    NSArray *cursorResponderPotentials=nil;
    if ([responder isKindOfClass:[NSView class]] && [[(NSView *)responder subviews] count])
        cursorResponderPotentials = [NSArray arrayWithArray:[(NSView *)responder subviews]];
    
    if (cursorResponderPotentials != nil)
    {
        cursorResponderPotentials = [cursorResponderPotentials arrayByAddingObjectsFromArray:[responder subHandCursorResponders]];
        NSSet *uniqueSet = [NSSet setWithArray:cursorResponderPotentials];
        cursorResponderPotentials = [uniqueSet allObjects];
    }
    else if ([[responder subHandCursorResponders] count])
        cursorResponderPotentials = [NSArray arrayWithArray:[responder subHandCursorResponders]];
    // Create a copy of the array to avoid removals while enumerating
    return cursorResponderPotentials;
}

- (void)walkHandCursorResponders:(NSArray *)handCursorResponders removingCursorTracking:(NSView<OLKHandContainer> *)handView
{
    for (id subResponder in handCursorResponders)
    {
        if ([subResponder conformsToProtocol:@protocol(OLKHandCursorResponderParent)])
        {
            NSArray *cursorResponderPotentials = [self arrayOfPotentialsFor:subResponder];
            if (cursorResponderPotentials)
                [self walkHandCursorResponders:cursorResponderPotentials removingCursorTracking:handView];
        }
        if ([subResponder respondsToSelector:@selector(removeCursorTracking:)])
            [subResponder removeCursorTracking:handView];
    }
}

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView;
{
    [self walkHandCursorResponders:[NSArray arrayWithArray:_subHandCursorResponders] removingCursorTracking:handView];
}

- (void)walkRespondersRemovingAllCursorTracking:(NSArray *)handCursorResponders
{
    for (id subResponder in handCursorResponders)
    {
        if ([subResponder conformsToProtocol:@protocol(OLKHandCursorResponderParent)])
        {
            NSArray *cursorResponderPotentials = [self arrayOfPotentialsFor:subResponder];
            if (cursorResponderPotentials)
                [self walkRespondersRemovingAllCursorTracking:cursorResponderPotentials];
        }
        if ([subResponder respondsToSelector:@selector(removeAllCursorTracking)])
        [subResponder removeAllCursorTracking];
    }
}

- (void)removeAllCursorTracking
{
    [self walkRespondersRemovingAllCursorTracking:[NSArray arrayWithArray:_subHandCursorResponders]];
}

@end
