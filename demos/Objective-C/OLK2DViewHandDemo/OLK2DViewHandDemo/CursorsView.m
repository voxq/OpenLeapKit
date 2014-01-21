//
//  CursorsView.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-27.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "CursorsView.h"


@implementation CursorsView
{
    NSImage *_cursorImg;
}

@synthesize cursorTrackingController = _cursorTrackingController;
@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize active = _active;
@synthesize enable = _enable;
@synthesize cursorImg = _cursorImg;
@synthesize cursorSize = _cursorSize;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _active = NO;
        _enable = TRUE;
        _cursorSize = NSMakeSize(50, 50);
        _cursorTrackingController = [[OLKMultiCursorTrackingController alloc] init];
        [self drawIntoImage];
        // Initialization code here.
    }
    
    return self;
}

- (void)setCursorSize:(NSSize)cursorSize
{
    _cursorSize = cursorSize;
    
    [self drawIntoImage];
}

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView
{
    [_cursorTrackingController removeCursorTracking:handView];
}

- (void)removeAllCursorTracking
{
    [_cursorTrackingController removeAllCursorTracking];
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
    NSRect cursorRect;
    OLKCursorTracking *cursorTracking = [[_cursorTrackingController cursorTrackings] objectForKey:handView];
    if (cursorTracking)
    {
        cursorRect = [self rectForCursor:cursorTracking];
        [self needsToDrawRect:cursorRect];
        [cursorTracking setCursorPos:cursorPos];
    }
    else
        cursorTracking = [_cursorTrackingController createCursorTracking:cursorPos withHandView:handView];
    
    cursorRect = [self rectForCursor:cursorTracking];
    [self needsToDrawRect:cursorRect];
}

- (void)removeFromSuperHandCursorResponder
{
    if (_superHandCursorResponder)
        [_superHandCursorResponder removeHandCursorResponder:self];
}

- (void)drawIntoImage
{
    NSBezierPath *cursor = [[NSBezierPath alloc] init];
    NSRect cursorRect;
    cursorRect.origin = NSMakePoint(0, 0);
    //    cursorRect.origin.x -= _cursorSize.width/2;
    //    cursorRect.origin.y -= _cursorSize.height/2;
    cursorRect.size = _cursorSize;
    _cursorImg = [[NSImage alloc] initWithSize:cursorRect.size];
    [_cursorImg lockFocus];
    
    [cursor appendBezierPathWithOvalInRect:cursorRect];
    [[NSColor colorWithCalibratedRed:0.2 green:0.6 blue:0.2 alpha:1] set] ;
    [cursor fill];
    [_cursorImg unlockFocus];
}

- (NSRect)rectForCursor:(OLKCursorTracking *)cursor
{
    NSRect cursorRect;
    cursorRect.origin = [cursor cursorPos];
    cursorRect.origin.x -= _cursorSize.width/2;
    cursorRect.origin.y -= _cursorSize.height/2;
    cursorRect.size = _cursorSize;
    
    return cursorRect;
}

- (void)drawCursor:(OLKCursorTracking *)cursor
{
    NSRect cursorRect;
    cursorRect.origin = NSMakePoint(0, 0);
    NSPoint cursorPos = [cursor cursorPos];
    cursorPos.x -= _cursorSize.width/2;
    cursorPos.y -= _cursorSize.height/2;
    cursorRect.size = _cursorSize;
    [_cursorImg drawAtPoint:cursorPos fromRect:cursorRect operation:NSCompositeSourceOver fraction:1];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (!_enable)
        return;
    
    NSEnumerator *enumer = [[_cursorTrackingController cursorTrackings] objectEnumerator];
    OLKCursorTracking *cursor = [enumer nextObject];
    while (cursor)
    {
        if ([self needsToDrawRect:[self rectForCursor:cursor]])
        {
            [self drawCursor:cursor];
        }
        cursor = [enumer nextObject];
    }
}

@end
