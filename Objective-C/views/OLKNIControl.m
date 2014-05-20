//
//  OLKNIControl.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-13.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKNIControl.h"
#import "OLKNIControlsContainerView.h"

@implementation OLKNIControl

@synthesize context = _context;
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
@synthesize outlineLabel = _outlineLabel;
@synthesize labelFontBold = _labelFontBold;

- (id)init
{
    if (self = [super init])
    {
        _outlineLabel = YES;
        _needsRedraw = YES;
        _visible = YES;
        _active = YES;
        _enable = YES;
        _autoFontSize = YES;
        _autoCalcLabelRect = YES;
        [self calculateLabelAttributes];
    }
    return self;
}

- (void)calculateLabelAttributes
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    
    @synchronized(self)
    {
        NSFont *labelFont = [NSFont fontWithName:@"Helvetica Neue" size:_labelFontSize];
        if (_labelFontBold)
        {
            NSFontManager *fontManager = [NSFontManager sharedFontManager];
            labelFont = [fontManager fontWithFamily:labelFont.familyName traits:NSBoldFontMask weight:0 size:_labelFontSize];
        }
        _labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:labelFont, NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
        
        if (!_outlineLabel)
            return;
        
        NSMutableDictionary *backgroundAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:-18.0], NSStrokeWidthAttributeName, [NSColor whiteColor], NSStrokeColorAttributeName, nil];
        [backgroundAttrs addEntriesFromDictionary:_labelAttributes];
        _labelBackAttributes = [NSDictionary dictionaryWithDictionary:backgroundAttrs];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    OLKNIControl *copyOfSelf = [[[self class] allocWithZone:zone] init];
    copyOfSelf.context = _context;
    copyOfSelf.target = _target;
    copyOfSelf.action = _action;
    copyOfSelf.active = _active;
    copyOfSelf.size = _size;
    copyOfSelf.outlineLabel = _outlineLabel;
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
    
    return copyOfSelf;
}

- (id)copyAddingToSuper
{
    OLKNIControl *copyOfSelf = [self copy];
    if (self.superHandCursorResponder)
    {
        if ([self.superHandCursorResponder isKindOfClass:[OLKNIControlsContainerView class]])
            [(OLKNIControlsContainerView *)self.superHandCursorResponder addControl:copyOfSelf];
        else
            [self.superHandCursorResponder addHandCursorResponder:copyOfSelf];
    }
    return copyOfSelf;
}

- (BOOL)active
{
    @synchronized(self)
    {
        return _active;
    }
}
- (void)setActive:(BOOL)active
{
    @synchronized(self)
    {
        _active = active;
    }
    [self requestRedraw];
}

- (BOOL)labelFontBold
{
    @synchronized(self)
    {
        return _labelFontBold;
    }
}
- (void)setLabelFontBold:(BOOL)labelFontBold
{
    @synchronized(self)
    {
        _labelFontBold = labelFontBold;
    }
    [self setLabelFontSize:_labelFontSize];
    [self autoCalculateLabelRectBounds];
    [self prepareLabelImage];
    [self.parentView setNeedsDisplayInRect:self.frame];
}

- (void)setLabelFontSize:(float)labelFontSize
{
    @synchronized(self)
    {
        _labelFontSize = labelFontSize;

        if (_autoFontSize && !_labelFontSize)
            [self recalculateFontSize];
        else
            [self calculateLabelAttributes];
        
        if (!_autoFontSize || !labelFontSize)
        {
            [_parentView setNeedsDisplayInRect:self.labelRectBoundsFrame];
            return;
        }
        _autoFontSize = NO;
    }
    [_parentView setNeedsDisplayInRect:self.frame];
}

- (void)recalculateFontSize
{
    @synchronized(self)
    {
        if (_size.width > _size.height)
            _labelFontSize = _size.height/3.5;
        else
            _labelFontSize = _size.width/3.5;
    }
    [self calculateLabelAttributes];
}

- (float)labelFontSize
{
    @synchronized(self)
    {
        if (!_labelFontSize && _autoFontSize)
            [self recalculateFontSize];
        
        return _labelFontSize;
    }
}

- (void)setLabelAttributes:(NSDictionary *)labelAttributes
{
    @synchronized(self)
    {
        _labelAttributes = labelAttributes;
    }
}

- (NSDictionary *)labelAttributes
{
    @synchronized(self)
    {
        return _labelAttributes;
    }
}

- (void)setLabelBackAttributes:(NSDictionary *)labelBackAttributes
{
    @synchronized(self)
    {
        _labelBackAttributes = labelBackAttributes;
    }
}

- (NSDictionary *)labelBackAttributes
{
    @synchronized(self)
    {
        return _labelBackAttributes;
    }
}

- (void)autoCalculateLabelRectBounds
{
    @synchronized(self)
    {
        if (NSEqualSizes(NSZeroSize, _size) || !self.label || ![self.label length])
            return;
        
        if (_size.width >= _size.height)
        {
            NSDictionary *attrs;
            if (_outlineLabel)
                attrs = self.labelBackAttributes;
            else
                attrs = self.labelAttributes;
            
            _labelRectBounds.size = [self.label boundingRectWithSize:NSMakeSize(self.size.width, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs].size;
        }
        else
        {
            _labelRectBounds.size.width = _size.width*3;
            _labelRectBounds.size.height = _size.height/3;
        }
        _labelRectBounds.origin.x = (self.size.width - _labelRectBounds.size.width)/2;
        _labelRectBounds.origin.y = self.size.height/2 - _labelRectBounds.size.height/2;
    }
}

- (void)setLabelRectBounds:(NSRect)labelRectBounds
{
    @synchronized(self)
    {
        _labelRectBounds = labelRectBounds;
    }
}
- (NSRect)labelRectBounds
{
    @synchronized(self)
    {
        if (!_autoCalcLabelRect || !NSEqualRects(_labelRectBounds, NSZeroRect))
            return _labelRectBounds;
        
        [self autoCalculateLabelRectBounds];
        return _labelRectBounds;
    }
}

- (NSRect)labelRectBoundsFrame
{
    NSRect frameRect;
    @synchronized(self)
    {
        frameRect = self.labelRectBounds;
        
        frameRect.origin.x += _drawLocation.x;
        frameRect.origin.y += _drawLocation.y;
        
        return frameRect;
    }
}

- (BOOL)autoCalcLabelRect
{
    @synchronized(self)
    {
        return _autoCalcLabelRect;
    }
}

- (void)setAutoCalcLabelRect:(BOOL)autoCalcLabelRect
{
    @synchronized(self)
    {
        _autoCalcLabelRect = autoCalcLabelRect;
    }
    [self prepareLabelImage];
}

- (NSSize)size
{
    @synchronized(self)
    {
        return _size;
    }
}

- (void)setSize:(NSSize)size
{
    @synchronized(self)
    {
        _size = size;
        if (NSEqualSizes(size, _size))
            return;
    }
    [self prepareLabelImage];
    self.needsRedraw = YES;
}

- (void)prepareLabelImage
{
    NSString *label;
    NSRect labelRectBounds;
    NSDictionary *labelBackAttrs;
    NSDictionary *labelFrontAttrs;
    
    @synchronized(self)
    {
        label = self.label;
        if (![label length] || NSEqualSizes(_size, NSZeroSize))
            return;

        if (_autoFontSize && !_labelFontSize)
            [self recalculateFontSize];
        
        if (_autoCalcLabelRect)
            [self autoCalculateLabelRectBounds];

        labelBackAttrs = self.labelBackAttributes;
        labelFrontAttrs = self.labelAttributes;
        labelRectBounds = self.labelRectBounds;
    }

    NSImage *labelImage = [[NSImage alloc] initWithSize:labelRectBounds.size];
    
    NSRect labelRect;
    labelRect.size = labelImage.size;
    labelRect.origin = NSZeroPoint;
    
    [labelImage lockFocus];
    
    if (_outlineLabel)
        [label drawInRect:labelRect withAttributes:labelBackAttrs];
    [label drawInRect:labelRect withAttributes:labelFrontAttrs];
    
    [labelImage unlockFocus];

    self.labelImage = labelImage;
}

- (NSString *)label
{
    @synchronized(self)
    {
        return _label;
    }
}

- (void)setLabel:(NSString *)label
{
    NSRect prevRectBounds;
    @synchronized(self)
    {
        _label = label;
        prevRectBounds = self.labelRectBoundsFrame;
    }
    [self prepareLabelImage];
    [self.parentView setNeedsDisplayInRect:prevRectBounds];
    [self.parentView setNeedsDisplayInRect:self.labelRectBoundsFrame];
}

- (void)drawLabel
{
    NSPoint drawLocation = self.labelRectBoundsFrame.origin;
    NSImage *labelImage;
    @synchronized(self)
    {
        labelImage = _labelImage;
    }
    [labelImage drawAtPoint:drawLocation fromRect:NSMakeRect(0, 0, labelImage.size.width, labelImage.size.height) operation:NSCompositeSourceOver fraction:1];
    self.needsRedraw = FALSE;
}

- (void)draw
{
    if (!self.visible)
        return;
    [self drawLabel];
    self.needsRedraw = NO;
}

- (void)requestRedraw
{
    self.needsRedraw = YES;
    [self.parentView setNeedsDisplayInRect:[self frame]];
}

- (BOOL)visible
{
    @synchronized(self)
    {
        return _visible;
    }
}

- (void)setVisible:(BOOL)visible
{
    @synchronized(self)
    {
        _visible = visible;
    }
    [self requestRedraw];
}

- (NSRect)frameWithoutLabel
{
    NSRect frameRect;
    @synchronized(self)
    {
        frameRect.size = _size;
        frameRect.origin = _drawLocation;
        return frameRect;
    }
}

- (NSRect)frame
{
    NSRect frameRect;

    frameRect.origin = NSZeroPoint;
    
    @synchronized(self)
    {
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
    }
    return frameRect;
}

- (NSPoint)convertToParentViewCusorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView
{
    return [self.parentView convertPoint:cursorPos fromView:[handView superview]];
}

- (NSPoint)convertCursorPos:(NSPoint)cursorPos fromHandView:(NSView <OLKHandContainer> *)handView
{
    NSPoint convertedPos = [self convertToParentViewCusorPos:cursorPos fromHandView:handView];
    @synchronized(self)
    {
        convertedPos.x -= _drawLocation.x;
        convertedPos.y -= _drawLocation.y;
        return convertedPos;
    }
}


@end
