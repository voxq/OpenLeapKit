//
//  OLKNIControlsContainerView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKNIControlsContainerView.h"

@implementation OLKNIControlsContainerView
{
    NSMutableDictionary *_handControlled;
    NSArray *_exclControls;
    NSArray *_exclControlsTypes;
}

@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize subHandCursorResponders = _subHandCursorResponders;
@synthesize controls = _controls;

@synthesize active = _active;
@synthesize delegate = _delegate;
@synthesize enabled = _enabled;
@synthesize defaultCursorControl = _defaultCursorControl;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enabled = YES;
        _controls = [[NSArray alloc] init];
        _exclControls = [[NSArray alloc] init];
        _exclControlsTypes = [[NSArray alloc] init];
        _handControlled = [[NSMutableDictionary alloc] init];
        _defaultCursorControl = OLKHandCursorControlPeersAndChildren;
    }
    
    return self;
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer> *)cursorContext
{
}

- (OLKHandCursorControl)controlByHand:(NSView <OLKHandContainer> *)handView ofChild:(id)subHandCursorResponder
{
    NSUInteger controlIndex = [_exclControls indexOfObject:subHandCursorResponder];
    if (controlIndex == NSNotFound)
        return OLKHandCursorControlNone;
    
    NSNumber *exclusiveControlNum = [_exclControlsTypes objectAtIndex:controlIndex];
    if (!exclusiveControlNum)
        return OLKHandCursorControlNone;
    
    [_handControlled setObject:subHandCursorResponder forKey:handView];
    
    return [exclusiveControlNum intValue];
}

- (void)controlReleasedByHand:(NSView <OLKHandContainer> *)handView
{
    [_handControlled removeObjectForKey:handView];
}

- (id)childCursorResponderControlledByHand:(NSView <OLKHandContainer> *)handView
{
    return [_handControlled objectForKey:handView];
}

- (void)controlTriggered:(OLKNIControl *)control
{
    [_delegate controlChangedValue:self control:control];
}

- (void)addControl:(OLKNIControl *)control withExclusiveControl:(OLKHandCursorControl)exclusiveControl
{
    [self addHandCursorResponder:control];
    _controls = [_controls arrayByAddingObject:control];
    
    if (![control parentView])
        control.parentView = self;
    
    if (![control target])
    {
        control.target = self;
        control.action = @selector(controlTriggered:);
    }

    if (exclusiveControl != OLKHandCursorControlNone)
        [self changeControl:control toExclusiveControl:exclusiveControl];
}

- (void)changeControl:(OLKNIControl *)control toExclusiveControl:(OLKHandCursorControl)exclusiveControl
{
    _exclControls = [_exclControls arrayByAddingObject:control];
    _exclControlsTypes = [_exclControlsTypes arrayByAddingObject:[NSNumber numberWithInt:exclusiveControl]];
}

- (void)addControl:(OLKNIControl *)control
{
    [self addControl:control withExclusiveControl:_defaultCursorControl];
}

- (BOOL)removeMutalExclControl:(OLKNIControl *)control
{
    if (!_exclControls.count || !control)
        return NO;
    
    NSUInteger controlIndex = [_exclControls indexOfObject:control];
    if (controlIndex == NSNotFound)
        return NO;
    
    NSMutableArray *newArray = [_exclControls mutableCopy];
    [newArray removeObjectAtIndex:controlIndex];
    _exclControls = [newArray copy];
    
    newArray = [_exclControlsTypes mutableCopy];
    [newArray removeObjectAtIndex:controlIndex];
    _exclControlsTypes = [newArray copy];
    
    return YES;
}

- (void)removeControl:(OLKNIControl *)control
{
    [self removeMutalExclControl:control];
    
    if (_controls.count)
    {
        NSMutableArray *newArray = [_controls mutableCopy];
        [newArray removeObject:control];
        if ([_controls count] != [newArray count])
            _controls = [newArray copy];
    }
    
    if (!_subHandCursorResponders || ![_subHandCursorResponders count])
        return;
    
    NSMutableArray *newArray = [_subHandCursorResponders mutableCopy];
    [newArray removeObject:control];
    if ([_subHandCursorResponders count] != [newArray count])
        _subHandCursorResponders = [newArray copy];
}

- (void)removeAllControls
{
    for (OLKNIControl *control in _controls)
        [self removeControl:control];
}

- (void)removeCursorTracking:(NSView <OLKHandContainer> *)handView
{
    [_handControlled removeObjectForKey:handView];
}

- (void)removeAllCursorTracking
{
    [_handControlled removeAllObjects];
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
    NSMutableArray *newArray = [_subHandCursorResponders mutableCopy];
    [newArray removeObject:handCursorResponder];
    _subHandCursorResponders = [newArray copy];
    [handCursorResponder setSuperHandCursorResponder:nil];
}

- (void)removeFromSuperHandCursorResponder
{
    [self removeAllCursorTracking];
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

- (void)addControlsForLabels:(NSArray *)controlLabels withTemplate:(OLKNIControl *)controlTemplate exclusiveControl:(OLKHandCursorControl)exclusiveControl
{
    if (![controlLabels count])
        return;
    
    for (NSString *suggestion in controlLabels)
    {
        OLKNIControl *control = [controlTemplate copy];
        [control setLabel:suggestion];
        [self addControl:control withExclusiveControl:exclusiveControl];
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
    if (!_enabled)
        return;
    
    for (OLKNIControl *control in _subHandCursorResponders)
    {
        if ([control needsRedraw] || [self needsToDrawRect:[control frame]])
            [control draw]; 
    }
}

@end
