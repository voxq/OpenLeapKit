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
@synthesize labelRectBounds = _labelRectBounds;
@synthesize labelFontSize = _labelFontSize;
@synthesize autoFontSize = _autoFontSize;
@synthesize autoCalcLabelRect = _autoCalcLabelRect;
@synthesize labelImage = _labelImage;
@synthesize labelAttributes = _labelAttributes;
@synthesize labelBackAttributes = _labelBackAttributes;

- (id)init
{
    if (self = [super init])
    {
        _needsRedraw = YES;
        _visible = YES;
        _active = YES;
        _enable = YES;
        _autoFontSize = YES;
        _autoCalcLabelRect = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OLKNIControl *copyOfSelf = [[[self class] allocWithZone:zone] init];
    copyOfSelf.target = _target;
    copyOfSelf.action = _action;
    copyOfSelf.active = _active;
    copyOfSelf.size = _size;
    copyOfSelf.drawLocation = _drawLocation;
    copyOfSelf.visible = _visible;
    copyOfSelf.enable = _enable;
    copyOfSelf.needsRedraw = _needsRedraw;
    copyOfSelf.labelAttributes = _labelAttributes;
    copyOfSelf.labelBackAttributes = _labelBackAttributes;
    copyOfSelf.labelFontSize = _labelFontSize;
    copyOfSelf.autoFontSize = _autoFontSize;
    copyOfSelf.autoCalcLabelRect = _autoCalcLabelRect;
    copyOfSelf.label = _label;
    if (!copyOfSelf.autoCalcLabelRect)
        copyOfSelf.labelRectBounds = _labelRectBounds;
    copyOfSelf.parentView = _parentView;
    if (self.superHandCursorResponder)
        [self.superHandCursorResponder addHandCursorResponder:copyOfSelf];
    
    return copyOfSelf;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    [_parentView setNeedsDisplayInRect:self.frame];
}

- (void)setLabelFontSize:(float)labelFontSize
{
    _labelFontSize = labelFontSize;

    if (!_autoFontSize)
    {
        [_parentView setNeedsDisplayInRect:self.labelRectBounds];
        return;
    }
    _labelAttributes = nil;
    NSDictionary *labelAttributes = self.labelBackAttributes;
    
    _autoFontSize = NO;
    [_parentView setNeedsDisplayInRect:self.frame];
}

- (float)labelFontSize
{
    if (!_labelFontSize && _autoFontSize)
    {
        if (_size.width > _size.height)
            _labelFontSize = _size.height/4;
        else
            _labelFontSize = _size.width/4;
    }
    return _labelFontSize;
}

- (NSDictionary *)labelAttributes
{
    if (!_labelAttributes)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        
        _labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:_labelFontSize], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    }
    return _labelAttributes;
}

- (NSDictionary *)labelBackAttributes
{
    if (!_labelBackAttributes)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        
        NSMutableDictionary *backgroundAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:-18.0], NSStrokeWidthAttributeName, [NSColor whiteColor], NSStrokeColorAttributeName, nil];
        [backgroundAttrs addEntriesFromDictionary:self.labelAttributes];
        _labelBackAttributes = [NSDictionary dictionaryWithDictionary:backgroundAttrs];
    }
    return _labelBackAttributes;
}

- (void)autoCalculateLabelRectBounds
{
    if (NSEqualSizes(NSZeroSize, _size) || !self.label || ![self.label length])
        return;
    
    if (_size.width > _size.height)
        _labelRectBounds.size = [self.label boundingRectWithSize:NSMakeSize(self.size.width, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.labelBackAttributes].size;
    else
    {
        _labelRectBounds.size.width = _size.width*3;
        _labelRectBounds.size.height = _size.height/3;
    }
    _labelRectBounds.origin.x = (self.size.width - _labelRectBounds.size.width)/2;
    _labelRectBounds.origin.y = self.size.height/2 - _labelRectBounds.size.height/2;
}

- (NSRect)labelRectBounds
{
    if (!_autoCalcLabelRect || !NSEqualRects(_labelRectBounds, NSZeroRect))
        return _labelRectBounds;
    
    [self autoCalculateLabelRectBounds];
    return _labelRectBounds;
}

- (void)setAutoCalcLabelRect:(BOOL)autoCalcLabelRect
{
    _autoCalcLabelRect = autoCalcLabelRect;
    [self prepareLabelImage];
}

- (void)setSize:(NSSize)size
{
    _size = size;
    if (NSEqualSizes(size, _size))
        return;
    
    [self prepareLabelImage];
    self.needsRedraw = YES;
}

- (void)prepareLabelImage
{
    if (![self.label length] || NSEqualSizes(_size, NSZeroSize))
        return;

    if (_autoFontSize)
    {
        _labelFontSize = 0;
        float tmp = self.labelFontSize;
        _labelAttributes = nil;
        NSDictionary *labelAttributes = self.labelBackAttributes;
    }
    
    if (_autoCalcLabelRect)
        [self autoCalculateLabelRectBounds];

    _labelImage = [[NSImage alloc] initWithSize:self.labelRectBounds.size];
    
    NSRect labelRect;
    labelRect.size = _labelImage.size;
    labelRect.origin = NSZeroPoint;
    
    [_labelImage lockFocus];
    
    [self.label drawInRect:labelRect withAttributes:self.labelBackAttributes];
    [self.label drawInRect:labelRect withAttributes:self.labelAttributes];
    
    [_labelImage unlockFocus];
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    [self prepareLabelImage];
    [_parentView setNeedsDisplayInRect:self.labelRectBounds];
}

- (void)drawLabel
{
    NSPoint drawLocation = self.drawLocation;
    drawLocation.x += self.labelRectBounds.origin.x;
    drawLocation.y += self.labelRectBounds.origin.y;
    [_labelImage drawAtPoint:drawLocation fromRect:NSMakeRect(0, 0, _labelImage.size.width, _labelImage.size.height) operation:NSCompositeSourceOver fraction:1];
    self.needsRedraw = FALSE;
}

- (void)draw
{
    [self drawLabel];
    self.needsRedraw = NO;
}

- (void)requestRedraw
{
    self.needsRedraw = YES;
    [self.parentView setNeedsDisplayInRect:[self frame]];
}

- (NSRect)frame
{
    NSRect frameRect;

    frameRect.origin = NSZeroPoint;
    
    if (_labelRectBounds.origin.x < 0)
        frameRect.origin.x = _labelRectBounds.origin.x;

    if (_labelRectBounds.origin.y < 0)
        frameRect.origin.y = _labelRectBounds.origin.y;

    if (_size.width < _labelRectBounds.origin.x + _labelRectBounds.size.width)
        frameRect.size.width = _labelRectBounds.origin.x + _labelRectBounds.size.width - frameRect.origin.x;
    else
        frameRect.size.width = _size.width - frameRect.origin.x;
    
    if (_size.height < _labelRectBounds.origin.y + _labelRectBounds.size.height)
        frameRect.size.height = _labelRectBounds.origin.y + _labelRectBounds.size.height - frameRect.origin.y;
    else
        frameRect.size.height = _size.height - frameRect.origin.y;
    
    frameRect.origin.x += _drawLocation.x;
    frameRect.origin.y += _drawLocation.y;
    
    return frameRect;
}

- (NSPoint)convertToParentViewCusorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView
{
    return [_parentView convertPoint:cursorPos fromView:[handView superview]];
}

- (NSPoint)convertCusorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView
{
    NSPoint convertedPos = [self convertToParentViewCusorPos:cursorPos fromHandView:handView];
    convertedPos.x -= _drawLocation.x;
    convertedPos.y -= _drawLocation.y;
    return convertedPos;
}


@end
