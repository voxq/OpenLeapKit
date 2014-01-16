//
//  OLKNIControlsContainerView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKNIControlsContainerView.h"

@implementation OLKNIControlsContainerView

@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize subHandCursorResponders = _subHandCursorResponders;
@synthesize controls = _controls;

@synthesize active = _active;
@synthesize delegate = _delegate;
@synthesize enabled = _enabled;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _controls = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)controlTriggered:(OLKNIControl *)control
{
    [_delegate controlChangedValue:self control:control];
}

- (void)addControl:(OLKNIControl *)control
{
    [self addHandCursorResponder:control];
    _controls = [_controls arrayByAddingObject:control];
    
    if (![control parentView])
        control.parentView = self;

    if ([control target])
        return;
    
    control.target = self;
    control.action = @selector(controlTriggered:);
}

- (void)removeControl:(OLKNIControl *)control
{
    if (_controls && [_controls count])
    {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:_controls];
        [newArray removeObject:control];
        if ([_controls count] != [newArray count])
            _controls = [NSArray arrayWithArray:newArray];
    }
    
    if (!_subHandCursorResponders || ![_subHandCursorResponders count])
        return;
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_subHandCursorResponders];
    [newArray removeObject:control];
    if ([_subHandCursorResponders count] != [newArray count])
        _subHandCursorResponders = [NSArray arrayWithArray:newArray];
}

- (void)removeAllControls
{
    if (_subHandCursorResponders && [_subHandCursorResponders count])
    {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:_subHandCursorResponders];
        for (OLKNIControl *control in _controls)
        {
            [newArray removeObject:control];
        }
        if ([_subHandCursorResponders count] != [newArray count])
            _subHandCursorResponders = [NSArray arrayWithArray:newArray];
    }
    
    _controls = [[NSArray alloc] init];
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

- (void)addControlsForLabels:(NSArray *)controlLabels withTemplate:(OLKNIControl *)controlTemplate
{
    if (![controlLabels count])
        return;
    
    for (NSString *suggestion in controlLabels)
    {
        OLKNIControl *control = [controlTemplate copy];
        [control setLabel:suggestion];
        [self addControl:control];
    }
}

- (NSRect)layoutControlsEvenly:(NSRect)containRect forControls:(NSRange)controlRange
{
    if (![_controls count] || controlRange.location >= [_controls count])
        return NSZeroRect;
    
    NSArray *rangeOfControls = [_controls subarrayWithRange:controlRange];
    if (![rangeOfControls count])
        return NSZeroRect;
    
    OLKNIControl *templateControl = [rangeOfControls objectAtIndex:0];
    
    float controlWidth = templateControl.size.width;
    float controlHeight = templateControl.size.height;
    float controlSpacing = 40;

    int maxRows = (containRect.size.height-templateControl.size.height)/((controlHeight*2) - controlHeight);
    int columns = (int)(controlRange.length-1)/maxRows + 1;
    
    int rows = controlRange.length;
    if (rows > maxRows)
        rows = maxRows;
    
    float midPointX = containRect.origin.x+containRect.size.width/2;
    
    NSPoint controlPos;
    float usedSpaceWidth = (controlWidth+controlSpacing)*columns - controlSpacing;
    float usedSpaceHeight = (controlHeight*2)*rows - controlHeight;
    float top = containRect.origin.y + containRect.size.height - (containRect.size.height - usedSpaceHeight)/2;

    containRect.origin.x = midPointX - usedSpaceWidth/2;
    containRect.origin.y = top - usedSpaceHeight;
    containRect.size.height = usedSpaceHeight;
    containRect.size.width = usedSpaceWidth;

    top -= controlHeight;
    controlPos.x = containRect.origin.x;
    controlPos.y = top;
    
    int controlCount = 0;
    for (OLKNIControl *control in rangeOfControls)
    {
        [control setDrawLocation:controlPos];
        [control setNeedsRedraw:YES];
        controlPos.y -= templateControl.size.height*2;
        controlCount ++;
        if (!(controlCount % rows))
        {
            controlPos.y = top;
            controlPos.x += controlWidth + controlSpacing;
        }
    }
    return containRect;
}

- (void)reset
{
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    for (OLKNIControl *control in _subHandCursorResponders)
    {
        if ([control needsRedraw] || [self needsToDrawRect:[control frame]])
            [control draw]; 
    }
}

@end
