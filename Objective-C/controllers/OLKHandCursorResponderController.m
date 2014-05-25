//
//  OLKHandCursorResponderController.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKHandCursorResponderController.h"
#import "OLKMenuMultiCursorView.h"

@implementation OLKHandCursorResponderController
{
    BOOL _globalControlled;
}

@synthesize subHandCursorResponders = _subHandCursorResponders;
@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize controllingCursorResponders = _controllingCursorResponders;

- (BOOL)handTookControl:(id <OLKHandCursorResponder>)handCursorResponder forHandView:(NSView<OLKHandContainer> *)handView
{
    id superHandCursorResponder = [handCursorResponder superHandCursorResponder];
    if (![superHandCursorResponder respondsToSelector:@selector(controlByHand:ofChild:)] || ![handCursorResponder respondsToSelector:@selector(controllingHandView)])
        return NO;

    if ([handCursorResponder controllingHandView] != handView)
        return NO;
    
    OLKHandCursorControl cursorControl = [superHandCursorResponder controlByHand:handView ofChild:handCursorResponder];
    if (cursorControl == OLKHandCursorControlNone)
        return NO;
    
    if (cursorControl == OLKHandCursorControlGlobal)
    {
        NSMutableDictionary *newDict = [_controllingCursorResponders mutableCopy];
        [newDict setObject:handCursorResponder forKey:handView];
        _controllingCursorResponders = [NSDictionary dictionaryWithDictionary:newDict];
        _globalControlled = YES;
    }
    return YES;
}

- (BOOL)stillControlledCursorResponder:(id <OLKHandCursorResponder>)handCursorResponder cursorPos:(NSPoint)cursorPos forHandView:(NSView<OLKHandContainer> *)handView
{
    if ([handCursorResponder respondsToSelector:@selector(convertToLocalCursorPos:fromView:)])
        cursorPos = [handCursorResponder convertToLocalCursorPos:cursorPos fromView:handView];
    [handCursorResponder setCursorTracking:cursorPos withHandView:handView];
    if ([handCursorResponder controllingHandView] == handView)
        return YES;
    
    [[handCursorResponder superHandCursorResponder] controlReleasedByHand:handView];
    
    return NO;
}

- (void)walkHandCursorResponders:(NSArray *)handCursorResponders settingCursorPos:(NSPoint)cursorPos forHandView:(NSView<OLKHandContainer> *)handView
{
    for (id subResponder in handCursorResponders)
    {
        if ([handView.hand.leapHand isKindOfClass:[LeapFingerAsLeapHand class]] && [subResponder conformsToProtocol:@protocol(OLKMenuMultiCursorView)])
        {
            LeapFingerAsLeapHand *leapFingerHand = (LeapFingerAsLeapHand *)handView.hand.leapHand;
            if (!leapFingerHand.isControlling)
                continue;
        }

        if ([subResponder conformsToProtocol:@protocol(OLKHandCursorResponderParent)])
        {
            NSPoint convertedCusorPos;
            BOOL convertedPos = NO;
            BOOL childControlled = NO;
            if ([subResponder respondsToSelector:@selector(childCursorResponderControlledByHand:)])
            {
                id childHandCursorResponder = [subResponder childCursorResponderControlledByHand:handView];
                if (childHandCursorResponder)
                {
                    if ([subResponder respondsToSelector:@selector(convertForChildrenCursorPos:fromView:)])
                    {
                        convertedCusorPos = [subResponder convertForChildrenCursorPos:cursorPos fromView:handView];
                        convertedPos = YES;
                    }
                    convertedCusorPos = cursorPos;
                    childControlled = [self stillControlledCursorResponder:childHandCursorResponder cursorPos:convertedCusorPos forHandView:handView];
                }
                if (_reset)
                    return;
            }
            if (!childControlled)
            {
                NSArray *cursorResponderPotentials = [self arrayOfPotentialsFor:subResponder];
                if (cursorResponderPotentials)
                {
                    if (!convertedPos && [subResponder respondsToSelector:@selector(convertForChildrenCursorPos:fromView:)])
                        convertedCusorPos = [subResponder convertForChildrenCursorPos:cursorPos fromView:handView];
                    else
                        convertedCusorPos = cursorPos;
                    
                    [self walkHandCursorResponders:[NSArray arrayWithArray:cursorResponderPotentials] settingCursorPos:convertedCusorPos forHandView:handView];
                    if (_reset || _globalControlled)
                        return;
                }
            }
        }

        if ([subResponder respondsToSelector:@selector(setCursorTracking:withHandView:)])
        {
            NSPoint convertedCusorPos;
            if ([subResponder respondsToSelector:@selector(convertToLocalCursorPos:fromView:)])
                convertedCusorPos = [subResponder convertToLocalCursorPos:cursorPos fromView:handView];
            else
                convertedCusorPos = cursorPos;
            [subResponder setCursorTracking:convertedCusorPos withHandView:handView];
            if (_reset || [self handTookControl:subResponder forHandView:handView])
                return;
        }
    }
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)handView
{
    id controllingCursorResponder = nil;
    if (_controllingCursorResponders.count)
    {
        controllingCursorResponder = [_controllingCursorResponders objectForKey:handView];
        if (controllingCursorResponder)
        {
            NSObject <OLKHandCursorResponderParent> *parent = [controllingCursorResponder superHandCursorResponder];
            if ([parent respondsToSelector:@selector(convertForChildrenCursorPos:fromView:)])
                cursorPos = [parent convertForChildrenCursorPos:cursorPos fromView:handView];
            if ([controllingCursorResponder respondsToSelector:@selector(convertToLocalCursorPos:fromView:)])
                cursorPos = [controllingCursorResponder convertToLocalCursorPos:cursorPos fromView:handView];
            [controllingCursorResponder setCursorTracking:cursorPos withHandView:handView];
            if ([controllingCursorResponder controllingHandView] != handView)
            {
                [[controllingCursorResponder superHandCursorResponder] controlReleasedByHand:handView];
                NSMutableDictionary *newDict = [_controllingCursorResponders mutableCopy];
                [newDict removeObjectForKey:handView];
                _controllingCursorResponders = [NSDictionary dictionaryWithDictionary:newDict];
            }
            else
                return;
        }
    }
    _globalControlled = NO;
    if (_reset)
        _reset = NO;
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
    if ([responder isKindOfClass:[NSView class]] && (![responder respondsToSelector:@selector(ignoresSubviews)] || !responder.ignoreSubviews) && [[(NSView *)responder subviews] count])
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
    _reset = YES;
    [self walkRespondersRemovingAllCursorTracking:[NSArray arrayWithArray:_subHandCursorResponders]];
}

@end
