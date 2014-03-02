//
//  OLKLineMenuMultiCursorView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2014-02-10.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import "OLKLineMenuMultiCursorView.h"

@implementation OLKLineMenuMultiCursorView
{
    NSArray *_hoverImages;
    NSImage *_image;
    NSImage *_textImage;
    NSRect _imageDrawRect;
}

@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize subHandCursorResponders = _subHandCursorResponders;

@synthesize optionInput = _optionInput;

@synthesize maintainProportion = _maintainProportion;
@synthesize active = _active;
@synthesize textFontSize = _textFontSize;
@synthesize currentAlpha = _currentAlpha;
@synthesize inactiveAlphaMultiplier = _inactiveAlphaMultiplier;
@synthesize optionBackgroundColor = _optionBackgroundColor;
@synthesize optionSeparatorColor = _optionSeparatorColor;
@synthesize optionHoverColor = _optionHoverColor;
@synthesize optionHighlightColor = _optionHighlightColor;
@synthesize optionSelectColor = _optionSelectColor;
@synthesize baseImage = _baseImage;
@synthesize hoverImage = _hoverImage;
@synthesize showSelection = _showSelection;
@synthesize optionTextColor = _optionTextColor;
@synthesize fastEdit = _fastEdit;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configDefaultView];
    }
    
    return self;
}

- (NSPoint)convertToInputCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView
{
    if (handView)
        cursorPos = [self convertPoint:cursorPos fromView:[handView superview]];
    
    return cursorPos;
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView <OLKHandContainer>*)handView
{
}

- (void)setActive:(BOOL)active
{
    _active = active;
    [_optionInput removeAllCursorTracking];
}

- (NSArray *)subHandCursorResponders
{
    if (!_active)
        return nil;
    
    return _subHandCursorResponders;
}

- (void)setOptionInput:(OLKLineOptionMultiCursorInput *)optionInput
{
    if (_optionInput)
        [self removeHandCursorResponder:optionInput];
    
    _optionInput = optionInput;
    if (!_optionInput.datasource)
        _optionInput.datasource = self;
    [self addHandCursorResponder:optionInput];
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

- (void)removeCursorTracking:(NSView<OLKHandContainer> *)handView
{
}

- (void)removeAllCursorTracking
{
}

- (void)setHoverImage:(NSImage *)hoverImage
{
    if (hoverImage == nil)
    {
        _hoverImages = nil;
        return;
    }
    _hoverImage = hoverImage;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self drawIntoImage];
}

- (void)configDefaultView
{
    _optionHighlightColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1 alpha:1];
    _optionSeparatorColor = [NSColor colorWithCalibratedRed:0.8 green:1 blue:0.8 alpha:1];
    _optionBackgroundColor = [NSColor colorWithCalibratedRed:0.5 green:1 blue:0.5 alpha:1];
    _optionSelectColor = [NSColor colorWithCalibratedRed:1 green:0.3 blue:0.3 alpha:0.5];
    _optionHoverColor = [NSColor colorWithCalibratedRed:0.5 green:0.75 blue:0.95 alpha:1];
    _optionTextColor = [NSColor colorWithCalibratedRed:0 green:0.4 blue:0.2 alpha:1];
    _currentAlpha = 1.0;
    _textFont = [NSFont fontWithName:@"Helvetica Neue" size:_textFontSize];
    [self redraw];
}

- (void)awakeFromNib
{
    // First, we set default values for the various parameters.
    [self configDefaultView];
}


- (void)redraw
{
    [self drawIntoImage];
    self.needsDisplay = YES;
}

- (void)drawIntoImage
{
    if ([_optionInput optionObjects] == nil)
        return;
    
    int optionObjCount = (int)_optionInput.optionObjects.count;
    float optionDimension;
    if (_optionInput.vertical)
    {
        optionDimension = _optionInput.size.height/optionObjCount;
        if (_optionInput.size.width > optionDimension)
            _textFontSize = optionDimension*0.75;
        else
            _textFontSize = _optionInput.size.width*0.75;
    }
    else
    {
        optionDimension = _optionInput.size.width/optionObjCount;
        if (_optionInput.size.height > optionDimension)
            _textFontSize = optionDimension*0.75;
        else
            _textFontSize = _optionInput.size.height*0.75;
    }
        
    NSRect boundsRect = [super bounds];    
    int index;
    
    _imageDrawRect.size = _optionInput.size;

    if (boundsRect.size.width > boundsRect.size.height)
    {
        _imageDrawRect.origin.x = (boundsRect.origin.x+boundsRect.size.width)/2 - _optionInput.size.width/2;
        _imageDrawRect.origin.y = 0;
    }
    else
    {
        _imageDrawRect.origin.x = 0;
        _imageDrawRect.origin.y = (boundsRect.origin.y+boundsRect.size.height)/2 - _optionInput.size.height/2;
    }
    _image = [[NSImage alloc] initWithSize:_imageDrawRect.size];
    [_image lockFocus];
    
    if (_baseImage)
    {
        NSRect sourceRect;
        sourceRect.origin = NSZeroPoint;
        sourceRect.size = _baseImage.size;
        [_baseImage drawInRect:_imageDrawRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
        [_image unlockFocus];
        return;
    }
    
    NSBezierPath *menuEntriesPath = [NSBezierPath bezierPath] ;
    [menuEntriesPath setLineWidth: 2 ] ;
    
    for (index = 0; index < optionObjCount; index ++)
    {
        NSRect optionRect = [_optionInput optionRectForIndex:index];
        optionRect.origin.x += _imageDrawRect.origin.x;
        optionRect.origin.y += _imageDrawRect.origin.y;
        [menuEntriesPath appendBezierPathWithRect:optionRect];
    }

    [_optionBackgroundColor set];
    [menuEntriesPath fill];
    [[NSColor blackColor] set];
    [menuEntriesPath stroke];
    
    [_image unlockFocus];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    //        NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSBoldFontMask weight:0 size:60];
    NSDictionary* attrs = [[NSDictionary alloc] initWithObjectsAndKeys:[self textFont], NSFontAttributeName, style, NSParagraphStyleAttributeName, _optionTextColor, NSForegroundColorAttributeName, nil];
    
    _textImage = [[NSImage alloc] initWithSize:boundsRect.size];
    [_textImage lockFocus];
    
    for (index = 0; index < optionObjCount; index++) {
        NSString *string = [[_optionInput optionObjects] objectAtIndex:index];
        
        NSRect optionRect = [_optionInput optionRectForIndex:index];
        optionRect.origin.x += _imageDrawRect.origin.x;
        optionRect.origin.y += _imageDrawRect.origin.y;
        optionRect.size.height /= 2;
        optionRect.size.height += _textFontSize/2;
        [string drawInRect:optionRect withAttributes:attrs];
    }
    
    [_textImage unlockFocus];    
}

- (void)setBaseImage:(NSImage *)baseCircleImage
{
    _baseImage = baseCircleImage;
    [self drawIntoImage];
}

- (void)drawSelections:(float)alpha
{
    int objectCount = _optionInput.optionObjects.count;
    if (!objectCount)
        return;
    
    NSBezierPath *selectEntriesPath = [NSBezierPath bezierPath] ;
    [selectEntriesPath setLineWidth: 4 ] ;
    
    NSDictionary *selectedIndexesDict = [_optionInput selectedIndexes];
    NSEnumerator *enumer = [selectedIndexesDict objectEnumerator];
    for (NSNumber *selectedIndexNum in enumer)
    {
        int selectedIndex = [selectedIndexNum intValue];
        if (selectedIndex < objectCount && selectedIndex >= 0)
        {
            NSRect optionRect = [_optionInput optionRectForIndex:selectedIndex];
            optionRect.origin.x += _imageDrawRect.origin.x;
            optionRect.origin.y += _imageDrawRect.origin.y;
            [selectEntriesPath appendBezierPathWithRect:optionRect];
        }
    }
    
    if (selectedIndexesDict.count)
    {
        [[_optionSelectColor colorWithAlphaComponent:alpha*[_optionSelectColor alphaComponent]] set] ;
        [selectEntriesPath fill] ;
    }
}

- (void)drawRect:(NSRect)rect {
    NSRect boundsRect = [self bounds];
    int objectCount = _optionInput.optionObjects.count;
    if (!objectCount)
        return;
    
    NSRect imageRect = NSIntersectionRect(rect, _imageDrawRect);
    
    if (NSEqualRects(NSZeroRect, imageRect))
        return;
    
    float scaledAlpha = _currentAlpha;
    if (!_active)
        scaledAlpha *= 0.33;
    
    [_image drawInRect:imageRect fromRect:imageRect
             operation: NSCompositeSourceOver
              fraction: scaledAlpha];
    
    if (_showSelection)
        [self drawSelections:scaledAlpha];
    
    if (_baseImage)
        return;
    
    [_textImage drawInRect:imageRect fromRect:imageRect
                 operation: NSCompositeSourceOver
                  fraction: scaledAlpha];
    
}

- (BOOL)isOpaque {
    return NO;
}



@end
