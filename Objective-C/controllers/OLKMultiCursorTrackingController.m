//
//  OLKMultiCursorTrackingController.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-14.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKMultiCursorTrackingController.h"

@implementation OLKCursorTracking

@synthesize cursorPos;
@synthesize handView;

@end


@implementation OLKMultiCursorTrackingController

@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize cursorTrackings = _cursorTrackings;

- (void)removeFromSuperHandCursorResponder
{
    if (_superHandCursorResponder)
        [_superHandCursorResponder removeHandCursorResponder:self];
}

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:_cursorTrackings];
    [newDict removeObjectForKey:handView];
    if ([newDict count] < [_cursorTrackings count])
        _cursorTrackings = [NSDictionary dictionaryWithDictionary:newDict];
}

- (void)removeAllCursorTracking
{
    _cursorTrackings = nil;
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    OLKCursorTracking *cursorTracking = [_cursorTrackings objectForKey:handView];
    if (!cursorTracking)
        cursorTracking = [self createCursorTracking:cursorPos withHandView:handView];
    else
        [cursorTracking setCursorPos:cursorPos];
}

- (OLKCursorTracking *)createCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    OLKCursorTracking *cursorTracking = [[OLKCursorTracking alloc] init];
    [cursorTracking setHandView:handView];
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:cursorTracking forKey:handView];
    [newDict addEntriesFromDictionary:_cursorTrackings];
    _cursorTrackings = [NSDictionary dictionaryWithDictionary:newDict];
    [cursorTracking setCursorPos:cursorPos];
    return cursorTracking;
}

@end
