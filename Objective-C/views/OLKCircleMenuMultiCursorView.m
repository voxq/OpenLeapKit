//
//  OLKCircleMenuMultiCursorView.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-10.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKCircleMenuMultiCursorView.h"

@implementation OLKCircleMenuMultiCursorView
{
    NSArray *_hoverImages;
    NSArray *_selectImages;
    NSImage *_image;
    NSImage *_textImage;
    NSRect _imageDrawRect;
}

@synthesize superHandCursorResponder = _superHandCursorResponder;
@synthesize subHandCursorResponders = _subHandCursorResponders;

@synthesize optionInput = _optionInput;

@synthesize innerRadius = _innerRadius;
@synthesize center = _center;

@synthesize maintainProportion = _maintainProportion;
@synthesize active = _active;
@synthesize textFontSize = _textFontSize;
@synthesize currentAlpha = _currentAlpha;
@synthesize highlightPositions = _highlightPositions;
@synthesize inactiveAlphaMultiplier = _inactiveAlphaMultiplier;
@synthesize optionBackgroundColor = _optionBackgroundColor;
@synthesize optionSeparatorColor = _optionSeparatorColor;
@synthesize optionHoverColor = _optionHoverColor;
@synthesize optionHighlightColor = _optionHighlightColor;
@synthesize optionInnerHighlightColor = _optionInnerHighlightColor;
@synthesize optionSelectColor = _optionSelectColor;
@synthesize baseImage = _baseImage;
@synthesize hoverImage = _hoverImage;
@synthesize fillCenterColor = _fillCenterColor;
@synthesize showSelection = _showSelection;

// Many of the methods here are similar to those in the simpler DotView example.
// See that example for detailed explanations; here we will discuss those
// features that are unique to CircleView.

// CircleView draws text around a circle, using Cocoa's text system for
// glyph generation and layout, then calculating the positions of glyphs
// based on that layout, and using NSLayoutManager for drawing.

- (id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame])  {
        // First, we set default values for the various parameters.
        [self configDefaultView];
    }
    return self;
}

- (NSPoint)convertToInputCursorPos:(NSPoint)cursorPos fromView:(NSView <OLKHandContainer>*)handView
{
    return [self positionRelativeToCenter:cursorPos convertFromView:[handView superview]];
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

- (void)setOptionInput:(OLKCircleOptionMultiCursorInput *)optionInput
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
    _hoverImages = [self generateRotatedImages:_hoverImage];
}

- (void)setSelectedImage:(NSImage *)selectedImage
{
    if (selectedImage == nil)
    {
        _selectImages = nil;
        return;
    }
    _selectedImage = selectedImage;
    _selectImages = [self generateRotatedImages:_selectedImage];
}

- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees image:(NSImage *)origImage
{
    NSImage *image = [self scaledImage:origImage];
    NSSize rotatedSize = NSMakeSize(image.size.height, image.size.width) ;
    NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedSize] ;
    
    NSAffineTransform* transform = [NSAffineTransform transform] ;

//    [transform scaleBy:_optionInput.radius/_image.size.width];
    // In order to avoid clipping the image, translate
    // the coordinate system to its center
    [transform translateXBy:+image.size.width/2
                        yBy:+image.size.height/2] ;
    // then rotate
    [transform rotateByDegrees:degrees] ;
    // Then translate the origin system back to
    // the bottom left
    [transform translateXBy:-rotatedSize.width/2
                        yBy:-rotatedSize.height/2] ;
    
    [rotatedImage lockFocus] ;
    [transform concat] ;
    [image drawAtPoint:NSMakePoint(0,0)
             fromRect:NSZeroRect
            operation:NSCompositeCopy
             fraction:1.0] ;
    [rotatedImage unlockFocus] ;
    
    return rotatedImage;
}

- (NSImage *)scaledImage:(NSImage *)imageToScale
{
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize([_optionInput radius]*2, [_optionInput radius]*2)];
    [image lockFocus];
    [imageToScale drawInRect:NSMakeRect(0, 0, _optionInput.radius*2, _optionInput.radius*2) fromRect:NSMakeRect(0, 0, imageToScale.size.width, imageToScale.size.height) operation:NSCompositeSourceOver fraction:1];
    [image unlockFocus];
    return image;
}


- (NSArray *)generateRotatedImages:(NSImage *)templateImage
{
    if (!templateImage)
        return nil;
    int objectCount = (int)[[_optionInput optionObjects] count];
    NSMutableArray *rotImages = [[NSMutableArray alloc] initWithCapacity:objectCount];
    float angleInc = 360.0/(float)objectCount;
    float degAngle = 0;
    for (int i=0; i < objectCount; i++)
    {
        [rotImages addObject:[self imageRotatedByDegrees:degAngle image:templateImage]];
        degAngle += angleInc;
    }
    return [NSArray arrayWithArray:rotImages];
}

- (NSPoint)positionRelativeToCenter:(NSPoint)position convertFromView:(NSView *)view
{
    if (view)
        position = [self convertPoint:position fromView:view];
    
    NSPoint handPos;
    handPos.x = position.x - _center.x;
    handPos.y = position.y - _center.y;
    return handPos;
}

- (void)setFrame:(NSRect)frameRect
{
    BOOL redraw;
    if (NSEqualSizes(frameRect.size, self.frame.size))
        redraw = NO;
    else
        redraw = YES;

    [super setFrame:frameRect];
    if (!redraw)
        return;
    
    [self drawIntoImage];
    _hoverImages = [self generateRotatedImages:_hoverImage];
    _selectImages = [self generateRotatedImages:_selectedImage];
}

- (void)configDefaultView
{
    _showSelection = YES;
    _maintainProportion = YES;
    _optionHighlightColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1 alpha:1];
    _optionSeparatorColor = [NSColor colorWithCalibratedRed:0.8 green:1 blue:0.8 alpha:1];
    _optionBackgroundColor = [NSColor colorWithCalibratedRed:0.5 green:1 blue:0.5 alpha:1];
    _optionInnerHighlightColor = [NSColor colorWithCalibratedRed:0.3 green:0.8 blue:0.8 alpha:0.5];
    _optionSelectColor = [NSColor colorWithCalibratedRed:1 green:0.3 blue:0.3 alpha:0.5];
    _optionHoverColor = [NSColor colorWithCalibratedRed:0.5 green:0.75 blue:0.95 alpha:1];
    _fillCenterColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.75];
    
    _currentAlpha = 1.0;
    _innerRadius = [_optionInput  radius] * [_optionInput  thresholdForStrike];
    _textFontSize = ([_optionInput  radius] - _innerRadius)/2;
    _textFont = [NSFont fontWithName:@"Helvetica Neue" size:_textFontSize];
    [self redraw];
}

- (void)awakeFromNib
{
    // First, we set default values for the various parameters.
    [self configDefaultView];
}

- (void)dealloc {
}

- (void)redraw
{
    [self drawIntoImage];
    _hoverImages = [self generateRotatedImages:_hoverImage];
    _selectImages = [self generateRotatedImages:_selectedImage];
    self.needsDisplay = YES;
}

- (void)drawIntoImage
{
    if ([_optionInput optionObjects] == nil)
        return;
    
    float radius = [_optionInput radius];
    float radiusWithRoomForHover = [_optionInput radius]-4;
    NSRect boundsRect = [super bounds];
    _innerRadius = radius * [_optionInput thresholdForStrike];
    _textFontSize = (radius - _innerRadius)/2;
    _textFont = [NSFont fontWithName:@"Helvetica Neue" size:_textFontSize];
    _center = boundsRect.origin;
    _center.x += boundsRect.size.width/2;
    _center.y += boundsRect.size.height/2;

    int index;
    NSPoint offsetCenter=_center;
    
    _imageDrawRect.size.width = radius*2;
    _imageDrawRect.size.height = radius*2;
    if (boundsRect.size.width > boundsRect.size.height)
    {
        _imageDrawRect.origin.x = _center.x - radius;
        _imageDrawRect.origin.y = 0;
        offsetCenter.x = offsetCenter.y;
    }
    else
    {
        _imageDrawRect.origin.x = 0;
        _imageDrawRect.origin.y = _center.y - radius;
        offsetCenter.y = offsetCenter.x;
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

    NSBezierPath *innerFill = [NSBezierPath bezierPath];
    NSRect innerFillRectCircle;
    innerFillRectCircle.origin.x = offsetCenter.x - _innerRadius;
    innerFillRectCircle.origin.y = offsetCenter.y - _innerRadius;
    innerFillRectCircle.size.width = _innerRadius*2;
    innerFillRectCircle.size.height = _innerRadius*2;
    [innerFill appendBezierPathWithOvalInRect:innerFillRectCircle];
    [_fillCenterColor set];
    [innerFill fill];
    
    NSBezierPath *highlightPath = [NSBezierPath bezierPath] ;
    [highlightPath setLineWidth: 2 ] ;
    
    NSBezierPath *menuEntriesPath = [NSBezierPath bezierPath] ;
    [menuEntriesPath setLineWidth: 2 ] ;
    
    int objectCount = (int)[[_optionInput optionObjects] count];
    float arcAngleOffset = (360.0 / (float)objectCount) / 2.0;
    float degAngle;
    
    int position = 0;
    BOOL closePath = FALSE;
    
    for (index = 0; index < objectCount; index ++)
    {
        if (_highlightPositions && [_highlightPositions count] > 0)
        {
            NSInteger highlightCheck = objectCount-index;
            if (highlightCheck == objectCount)
                highlightCheck = 0;
            if ([_highlightPositions containsObject:[NSNumber numberWithInteger:highlightCheck]])
            {
                closePath = TRUE;
            }
        }
        if (closePath)
        {
            [_optionBackgroundColor set] ;
            // and fill it
            [menuEntriesPath fill] ;
            [_optionSeparatorColor set] ;
            [menuEntriesPath stroke] ;
            [menuEntriesPath removeAllPoints];
            position = 0;
            degAngle = 360.0/(float)objectCount * index + 90;
            
            // draw an arc (perc is a certain percentage ; something between 0 and 1
            [menuEntriesPath appendBezierPathWithArcWithCenter:offsetCenter radius:radiusWithRoomForHover startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
            [menuEntriesPath appendBezierPathWithArcWithCenter:offsetCenter radius:_innerRadius startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
            [menuEntriesPath closePath];
            [_optionHighlightColor set] ;
            // and fill it
            [menuEntriesPath fill] ;
            [_optionSeparatorColor set] ;
            [menuEntriesPath stroke] ;
            [menuEntriesPath removeAllPoints];

            closePath = FALSE;
            continue;
        }
        
        degAngle = 360.0/(float)objectCount * index + 90;
        
        // draw an arc (perc is a certain percentage ; something between 0 and 1
        [menuEntriesPath appendBezierPathWithArcWithCenter:offsetCenter radius:radiusWithRoomForHover startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
        NSPoint nextStartPoint = [menuEntriesPath currentPoint];
        [menuEntriesPath appendBezierPathWithArcWithCenter:offsetCenter radius:_innerRadius startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
        [menuEntriesPath closePath];
        [menuEntriesPath moveToPoint:nextStartPoint];
        position ++;
    }
    
    if (position != 0)
    {
        [_optionBackgroundColor set] ;
        // and fill it
        [menuEntriesPath fill] ;
        [_optionSeparatorColor set] ;
        [menuEntriesPath stroke] ;
    }
    
    if (_highlightPositions && [_highlightPositions count] > 0)
    {
        highlightPath = [NSBezierPath bezierPath] ;
        
        // set some line width
        
        [highlightPath setLineWidth: 2 ] ;
        
        // move to the center so that we have a closed slice
        // size_x and size_y are the height and width of the view
        
        [highlightPath moveToPoint: offsetCenter ] ;
        for (index = 0; index < objectCount; index +=1)
        {
            int highlightCheck = objectCount-index;
            if (highlightCheck == objectCount)
                highlightCheck = 0;
            if (![_highlightPositions containsObject:[NSNumber numberWithInteger:highlightCheck]])
                continue;
            degAngle = 360/(float)objectCount * index + 90;
            // draw an arc (perc is a certain percentage ; something between 0 and 1
            [highlightPath appendBezierPathWithArcWithCenter:offsetCenter radius:_innerRadius startAngle:degAngle-arcAngleOffset  endAngle:degAngle+arcAngleOffset ] ;
            
            // close the slice , by drawing a line to the center
            [highlightPath lineToPoint: offsetCenter ] ;
        }
        
        [_optionInnerHighlightColor set] ;
        // and fill it
        [highlightPath fill] ;
    }
    
    [_image unlockFocus];
    
    NSColor *textColor;
    if (_active)
        textColor = [NSColor blackColor];
    else
        textColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    //        NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSBoldFontMask weight:0 size:60];
    NSDictionary* attrs = [[NSDictionary alloc] initWithObjectsAndKeys:[self textFont], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor colorWithCalibratedRed:0 green:0.4 blue:0.2 alpha:1], NSForegroundColorAttributeName, nil];
    
    _textImage = [[NSImage alloc] initWithSize:boundsRect.size];
    [_textImage lockFocus];
    
    float distance = radiusWithRoomForHover - (radiusWithRoomForHover - _innerRadius)/1.5;
    float offset = M_PI_4 + M_PI/objectCount;
    for (index = 0; index < objectCount; index++) {
        float radAngle;
        int pos = objectCount - 1 - index;
        NSString *string = [[_optionInput optionObjects] objectAtIndex:index];
        if (pos == 0)
            radAngle = 0;
        else
            radAngle = M_PI/(float)objectCount * pos;
        
        radAngle += offset;
        radAngle *=2;
        
        NSRect textRect;
        textRect.size = [string sizeWithAttributes:attrs];

        textRect.origin.x = offsetCenter.x + distance * cos(radAngle) - textRect.size.width/2;
        textRect.origin.x += (textRect.origin.x - offsetCenter.x)/distance*0.5;
        
        textRect.origin.y = offsetCenter.y + distance * sin(radAngle) ;
        float offset = offsetCenter.y - distance;
        float adjustment = (distance*2 - (textRect.origin.y-offset))/25;
        textRect.origin.y -= adjustment;

        [string drawInRect:textRect withAttributes:attrs];
    }
    
    [_textImage unlockFocus];
}

- (void)setBaseImage:(NSImage *)baseCircleImage
{
    _baseImage = baseCircleImage;
    [self drawIntoImage];
}

- (void)drawSelections:(float)alpha arcAngleOffset:(float)arcAngleOffset radius:(float)radius
{
    int objectCount = [[_optionInput optionObjects] count];
    if (!objectCount)
        return;
    
    float degAngle;
    NSDictionary *selectedIndexesDict = [_optionInput selectedIndexes];
    NSEnumerator *enumer = [selectedIndexesDict objectEnumerator];
    for (NSNumber *selectedIndexNum in enumer)
    {
        int selectedIndex = [selectedIndexNum intValue];
        if (selectedIndex == OLKOptionMultiInputInvalidSelection)
            continue;
        
        if (selectedIndex < objectCount && selectedIndex >= 0)
        {
            if (_selectedImage)
            {
                int highlightCheck = objectCount-selectedIndex;
                if (highlightCheck == objectCount)
                    highlightCheck = 0;
                NSImage *selectImage = [_selectImages objectAtIndex:highlightCheck];
                [selectImage drawAtPoint:_imageDrawRect.origin fromRect:NSMakeRect(0,0, selectImage.size.width, selectImage.size.height) operation:NSCompositeSourceOver fraction:1];
                continue;
            }
            NSBezierPath *selPath = [NSBezierPath bezierPath] ;
            
            // set some line width
            
            [selPath setLineWidth: 2 ] ;
            
            // move to the center so that we have a closed slice
            // size_x and size_y are the height and width of the view
            
            degAngle = 360 - (float)arcAngleOffset*2 * (selectedIndex) + 90;
            
            [selPath moveToPoint: NSMakePoint( _center.x, _center.y ) ] ;
            // draw an arc (perc is a certain percentage ; something between 0 and 1
            [selPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radius startAngle:degAngle-arcAngleOffset  endAngle:degAngle+arcAngleOffset ] ;
            
            // close the slice , by drawing a line to the center
            [selPath lineToPoint: NSMakePoint( _center.x, _center.y ) ] ;
            
            [[_optionSelectColor colorWithAlphaComponent:alpha*[_optionSelectColor alphaComponent]] set] ;
            // and fill it
            [selPath fill] ;
        }
    }   
}

- (void)drawHover:(float)alpha arcAngleOffset:(float)arcAngleOffset radius:(float)radius
{
    int objectCount = [[_optionInput optionObjects] count];
    if (!objectCount)
        return;
    
    float degAngle;

    NSDictionary *hoverIndexesDict = [_optionInput hoverIndexes];
    NSEnumerator *enumer = [hoverIndexesDict objectEnumerator];
    for (NSNumber *selectedIndexNum in enumer)
    {
        int hoverIndex = [selectedIndexNum intValue];
        
        if (hoverIndex == OLKOptionMultiInputInvalidSelection)
            continue;
        
        if (_hoverImage)
        {
            int highlightCheck = objectCount-hoverIndex;
            if (highlightCheck == objectCount)
                highlightCheck = 0;
            NSImage *hoverImage = [_hoverImages objectAtIndex:highlightCheck];
            [hoverImage drawAtPoint:_imageDrawRect.origin fromRect:NSMakeRect(0,0, hoverImage.size.width, hoverImage.size.height) operation:NSCompositeSourceOver fraction:1];
            continue;
        }
        degAngle = 360 - (float)arcAngleOffset*2 * (hoverIndex) + 90;
        
        NSBezierPath *aimedLetterHighlightPath = [NSBezierPath bezierPath] ;
        [aimedLetterHighlightPath setLineWidth:2] ;
        
        float hoverOuter = (radius - _innerRadius)/12;
        float hoverInner = (radius - _innerRadius)/8;
        if (hoverOuter > 4)
        {
            hoverOuter = 4;
            hoverInner = 6;
        }
        // draw an arc (perc is a certain percentage ; something between 0 and 1
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radius + hoverOuter startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radius - hoverInner startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
        [aimedLetterHighlightPath closePath];
        [[_optionHoverColor colorWithAlphaComponent:alpha] set];
        [aimedLetterHighlightPath fill];
        [[[_optionHoverColor highlightWithLevel:0.8] colorWithAlphaComponent:alpha] set];
        [aimedLetterHighlightPath stroke];
        aimedLetterHighlightPath = [NSBezierPath bezierPath] ;
        [aimedLetterHighlightPath setLineWidth:1] ;
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius - hoverOuter startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius + hoverInner startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
        [aimedLetterHighlightPath closePath];
        [[_optionHoverColor colorWithAlphaComponent:alpha] set];
        [aimedLetterHighlightPath fill];
        [[[_optionHoverColor highlightWithLevel:0.8] colorWithAlphaComponent:alpha] set];
        [aimedLetterHighlightPath stroke];
    }
}

- (void)drawRect:(NSRect)rect {
    NSRect boundsRect = [self bounds];
    int objectCount = [[_optionInput optionObjects] count];
    if (!objectCount)
        return;

    NSRect circleBoundsRect = _imageDrawRect;
//    NSRect circleBoundsRect = boundsRect;
//    circleBoundsRect.origin.x -= [_image size].width/2-_center.x;
//    circleBoundsRect.origin.y -= [_image size].height/2-_center.y;
    
    NSRect intersectRect = NSIntersectionRect(rect, circleBoundsRect);
    if (NSEqualRects(NSZeroRect, intersectRect))
        return;
    
    float radiusWithRoomForHover = [_optionInput radius]-4;
    float arcAngleOffset = (180.0 / (float)objectCount);
    float degAngle;
    float scaledAlpha = _currentAlpha;
    if (!_active)
        scaledAlpha *= 0.33;
    
    NSRect imageRect = intersectRect;
    if (boundsRect.size.width > boundsRect.size.height)
        imageRect.origin.x -= (boundsRect.size.width - boundsRect.size.height)/2;
    else if (boundsRect.size.height > boundsRect.size.width)
        imageRect.origin.y -= (boundsRect.size.height - boundsRect.size.width)/2;
    
    [_image drawInRect:intersectRect fromRect:imageRect
             operation: NSCompositeSourceOver
              fraction: scaledAlpha];

    if (_showSelection)
        [self drawSelections:scaledAlpha arcAngleOffset:arcAngleOffset radius:radiusWithRoomForHover];
    
        //    NSLog(@"drawing rect: %f, %f, %f, %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    [self drawHover:scaledAlpha arcAngleOffset:arcAngleOffset radius:radiusWithRoomForHover];
    
    if (_baseImage)
        return;
    
    [_textImage drawInRect:intersectRect fromRect:imageRect
                 operation: NSCompositeSourceOver
                  fraction: scaledAlpha];
    
}

- (BOOL)isOpaque {
    return NO;
}



@end
