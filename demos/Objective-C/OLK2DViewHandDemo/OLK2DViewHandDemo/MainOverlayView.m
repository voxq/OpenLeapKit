//
//  MainOverlayView.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "MainOverlayView.h"

@implementation MainOverlayView
{
    NSView *_firstHandView;
    BOOL _inAddSubview;
}

@synthesize subHandCursorResponders = _subHandCursorResponders;
@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize menuShowing = _menuShowing;
@synthesize active = _active;
@synthesize enableCursor = _enableCursor;
@synthesize menuView = _menuView;
@synthesize cursorsView = _cursorsView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self defaultConfig];
}

- (void)defaultConfig
{
    _menuShowing = YES;
    _active = NO;
    if (_menuView)
    {
        [_menuView setActive:_active];
//        [_menuView setEnableCursor:_enableCursor];
    }
}

- (NSView *)cursorsView
{
    if (!_cursorsView)
        _cursorsView = [[CursorsView alloc] initWithFrame:[self bounds]];

    return _cursorsView;
}

- (void)setMenuView:(OLKNIControlsContainerView *)menuView
{
    if (_menuView)
        [_menuView removeFromSuperview];
    if (menuView && _menuShowing)
        [self addSubview:menuView];

    _menuView = menuView;
}

- (void)setMenuShowing:(BOOL)menuShowing
{
    if (_active)
    {
        if (menuShowing)
        {
            if (!_menuShowing)
                [self addSubview:_menuView];
        }
        else if (_menuShowing)
            [_menuView removeFromSuperview];
    }
    _menuShowing = menuShowing;
}

- (void)setFrame:(NSRect)frameRect
{
    
    BOOL updateCursorsView;
    if (_enableCursor)
        updateCursorsView = NSEqualRects([self frame], frameRect);
    
    [super setFrame:frameRect];

    if (!_enableCursor || !updateCursorsView)
        return;
    
    [self.cursorsView setFrame:[self bounds]];
}

- (void)setEnableCursor:(BOOL)enableCursor
{
    if (enableCursor && !_enableCursor)
    {
        if (_menuView && _menuShowing)
            [self addSubview:self.cursorsView positioned:NSWindowAbove relativeTo:_menuView];
        else if (_firstHandView)
            [self addSubview:self.cursorsView positioned:NSWindowBelow relativeTo:_firstHandView];
        else
            [self addSubview:self.cursorsView];
    }
    else
    {
        [_cursorsView removeFromSuperview];
        [_cursorsView removeAllCursorTracking];
    }
    _enableCursor = enableCursor;
}

- (void)willRemoveSubview:(NSView *)subview
{
    if (subview != _firstHandView)
        return;
    
    NSUInteger posOfView = [self.subviews indexOfObject:_firstHandView];
    for (NSView *view in [self.subviews subarrayWithRange:NSMakeRange(posOfView, self.subviews.count - posOfView)])
        if ([view conformsToProtocol:@protocol(OLKHandContainer)])
        {
            _firstHandView = view;
            return;
        }
    _firstHandView = nil;
}

- (void)addHandView:(NSView <OLKHandContainer> *)handView
{
    _inAddSubview = YES;
    if (!_firstHandView)
    {
        if (self.cursorsView && _enableCursor)
            [self addSubview:handView positioned:NSWindowAbove relativeTo:self.cursorsView];
        else if (_menuView && _menuShowing)
            [self addSubview:handView positioned:NSWindowAbove relativeTo:_menuView];
        else
            [self addSubview:handView];
        _firstHandView = handView;
    }
    else
        [self addSubview:handView positioned:NSWindowAbove relativeTo:_firstHandView];
    _inAddSubview = NO;
}

- (void)addSubview:(NSView *)aView
{
    if (_inAddSubview || (!_enableCursor && !_menuView && !_firstHandView))
    {
        [super addSubview:aView];
        return;
    }
    _inAddSubview = YES;
    if (_menuView && _menuShowing)
        [self addSubview:aView positioned:NSWindowBelow relativeTo:_menuView];
    else if (self.cursorsView && _enableCursor)
        [self addSubview:aView positioned:NSWindowBelow relativeTo:self.cursorsView];
    else if (_firstHandView)
        [self addSubview:aView positioned:NSWindowBelow relativeTo:_firstHandView];
    _inAddSubview = NO;
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

- (void)setActive:(BOOL)active
{
    if ((active && _menuShowing && ![_menuView active]) || (!active && [_menuView active]))
    {
        [_menuView setActive:active];
    }
    _active = active;
}


@end
