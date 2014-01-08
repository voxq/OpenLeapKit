#import <Cocoa/Cocoa.h>
#import "OLKCircleMenuView.h"

@implementation OLKCircleMenuView
{
    NSImage *_image;
    NSImage *_textImage;
    NSRect _imageDrawRect;
}

@synthesize circleOptionInputs = _circleOptionInputs;

@synthesize innerRadius = _innerRadius;
@synthesize center = _center;
@synthesize active = _active;
@synthesize textFontSize = _textFontSize;
@synthesize currentAlpha = _currentAlpha;
@synthesize highlightPositions = _highlightPositions;
@synthesize inactiveAlphaMultiplier = _inactiveAlphaMultiplier;
@synthesize optionRingColor = _optionRingColor;
@synthesize optionSeparatorColor = _optionSeparatorColor;
@synthesize optionHoverColor = _optionHoverColor;
@synthesize optionHighlightColor = _optionHighlightColor;
@synthesize optionInnerHighlightColor = _optionInnerHighlightColor;
@synthesize optionSelectColor = _optionSelectColor;
@synthesize baseCircleImage = _baseCircleImage;

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

- (void)setNeedsDisplay:(BOOL)flag
{
    [super setNeedsDisplay:flag];
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
    [super setFrame:frameRect];
    NSRect boundsRect = [super bounds];
    _innerRadius = [[_circleOptionInputs objectAtIndex:0] radius] * [[_circleOptionInputs objectAtIndex:0] thresholdForHit];
    _textFontSize = ([[_circleOptionInputs objectAtIndex:0]  radius] - _innerRadius)/2;
    _textFont = [NSFont fontWithName:@"Helvetica Neue" size:_textFontSize];
    _center = boundsRect.origin;
    _center.x += boundsRect.size.width/2;
    _center.y += boundsRect.size.height/2;
    [self drawIntoImage];
}

- (void)configDefaultView
{
    _optionHighlightColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1 alpha:1];
    _optionSeparatorColor = [NSColor colorWithCalibratedRed:0.8 green:1 blue:0.8 alpha:1];
    _optionRingColor = [NSColor colorWithCalibratedRed:0.5 green:1 blue:0.5 alpha:1];
    _optionInnerHighlightColor = [NSColor colorWithCalibratedRed:0.3 green:0.8 blue:0.8 alpha:0.5];
    _optionSelectColor = [NSColor colorWithCalibratedRed:1 green:0.3 blue:0.3 alpha:0.5];
    _optionHoverColor = [NSColor colorWithCalibratedRed:0.5 green:0.75 blue:0.95 alpha:1];
    
    _currentAlpha = 1.0;
    _innerRadius = [[_circleOptionInputs objectAtIndex:0]  radius] * [[_circleOptionInputs objectAtIndex:0]  thresholdForHit];
    _textFontSize = ([[_circleOptionInputs objectAtIndex:0]  radius] - _innerRadius)/2;
    _textFont = [NSFont fontWithName:@"Helvetica Neue" size:_textFontSize];
    [self drawIntoImage];
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
}

- (void)drawIntoImage
{
    if ([[_circleOptionInputs objectAtIndex:0] optionObjects] == nil)
        return;
    
    float radius = [[_circleOptionInputs objectAtIndex:0] radius];
    float radiusWithRoomForHover = [[_circleOptionInputs objectAtIndex:0] radius]-4;
    int index;
    NSRect boundsRect = [self bounds];
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
    if (_baseCircleImage)
    {
        [_baseCircleImage setSize:NSMakeSize(radius, radius)];
        return;
    }
    _image = [[NSImage alloc] initWithSize:_imageDrawRect.size];
    [_image lockFocus];
    
    NSBezierPath *highlightPath = [NSBezierPath bezierPath] ;
    [highlightPath setLineWidth: 2 ] ;
    
    NSBezierPath *menuEntriesPath = [NSBezierPath bezierPath] ;
    [menuEntriesPath setLineWidth: 2 ] ;
    
    int objectCount = (int)[[[_circleOptionInputs objectAtIndex:0] optionObjects] count];
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
            [_optionRingColor set] ;
            // and fill it
            [menuEntriesPath fill] ;
            [_optionSeparatorColor set] ;
            [menuEntriesPath stroke] ;
            [menuEntriesPath removeAllPoints];
            position = 0;
            degAngle = 360.0/(float)objectCount * index + 90;
            
            if (closePath)
            {
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
            }
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
        [_optionRingColor set] ;
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
    
    _textImage = [[NSImage alloc] initWithSize:boundsRect.size];
    [_textImage lockFocus];
    
    float distance = radiusWithRoomForHover - (radiusWithRoomForHover - _innerRadius)/1.5;
    float offset = M_PI_4 + M_PI/objectCount;
    for (index = 0; index < objectCount; index++) {
        float radAngle;
        int pos = objectCount - 1 - index;
        NSString *string = [[[_circleOptionInputs objectAtIndex:0] optionObjects] objectAtIndex:index];
        if (pos == 0)
            radAngle = 0;
        else
            radAngle = M_PI/(float)objectCount * pos;
        
        radAngle += offset;
        radAngle *=2;
        
        NSRect textRect;
        textRect.origin.x = offsetCenter.x + distance * cos(radAngle) - 200;
        textRect.origin.x += (textRect.origin.x - offsetCenter.x)/distance*5;
        
        textRect.origin.y = offsetCenter.y + distance * sin(radAngle) - _textFontSize/2;
        textRect.origin.y -= (distance - ((textRect.origin.y - offsetCenter.y) + distance))/(distance/10);
        textRect.size.width = 400;
        textRect.size.height = _textFontSize*1.2;
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        //        NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSBoldFontMask weight:0 size:60];
        NSDictionary* attrs = [[NSDictionary alloc] initWithObjectsAndKeys:[self textFont], NSFontAttributeName, style, NSParagraphStyleAttributeName, [NSColor colorWithCalibratedRed:0 green:0.4 blue:0.2 alpha:1], NSForegroundColorAttributeName, nil];
        [string drawInRect:textRect withAttributes:attrs];
    }
    
    [_textImage unlockFocus];
}

- (void)drawRect:(NSRect)rect {
    NSRect boundsRect = [self bounds];
    int objectCount = [[[_circleOptionInputs objectAtIndex:0] optionObjects] count];
    if (!objectCount)
        return;
    float radiusWithRoomForHover = [[_circleOptionInputs objectAtIndex:0] radius]-4;
    float arcAngleOffset = (180.0 / (float)objectCount);
    float degAngle;
    float scaledAlpha = _currentAlpha;
    if (!_active)
        scaledAlpha *= 0.33;
    if (_baseCircleImage)
        _image = _baseCircleImage;

// debug see the view container translucently
//    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect ];
//    [[[NSColor whiteColor] colorWithAlphaComponent:0.5] set];
//    [path fill];
    
    boundsRect.origin.x -= [_image size].width/2-_center.x;
    boundsRect.origin.y -= [_image size].height/2-_center.y;
    [_image drawInRect:_imageDrawRect fromRect:NSMakeRect(0, 0, [_image size].width, [_image size].height)
             operation: NSCompositeSourceOver
              fraction: scaledAlpha];
    
    for (OLKCircleOptionInput *circleOptionInput in _circleOptionInputs)
    {
        
        if ([circleOptionInput selectedIndex] < objectCount && [circleOptionInput selectedIndex] >= 0)
        {
            NSBezierPath *selPath = [NSBezierPath bezierPath] ;
            
            // set some line width
            
            [selPath setLineWidth: 2 ] ;
            
            // move to the center so that we have a closed slice
            // size_x and size_y are the height and width of the view
            
            degAngle = 360 - (float)arcAngleOffset*2 * ([circleOptionInput selectedIndex]) + 90;
            
            [selPath moveToPoint: NSMakePoint( _center.x, _center.y ) ] ;
            // draw an arc (perc is a certain percentage ; something between 0 and 1
            [selPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover startAngle:degAngle-arcAngleOffset  endAngle:degAngle+arcAngleOffset ] ;
            
            // close the slice , by drawing a line to the center
            [selPath lineToPoint: NSMakePoint( _center.x, _center.y ) ] ;
            
            [[_optionSelectColor colorWithAlphaComponent:scaledAlpha*[_optionSelectColor alphaComponent]] set] ;
            // and fill it
            [selPath fill] ;
        }
        
        //    NSLog(@"drawing rect: %f, %f, %f, %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        degAngle = 360 - (float)arcAngleOffset*2 * ([circleOptionInput hoverIndex]) + 90;
        
        NSBezierPath *aimedLetterHighlightPath = [NSBezierPath bezierPath] ;
        [aimedLetterHighlightPath setLineWidth:2] ;
        
        // draw an arc (perc is a certain percentage ; something between 0 and 1
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover + (radiusWithRoomForHover - _innerRadius)/12 startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover - (radiusWithRoomForHover - _innerRadius)/8 startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
        [aimedLetterHighlightPath closePath];
        [[_optionHoverColor colorWithAlphaComponent:scaledAlpha] set];
        [aimedLetterHighlightPath fill];
        [[[_optionHoverColor highlightWithLevel:0.8] colorWithAlphaComponent:scaledAlpha] set];
        [aimedLetterHighlightPath stroke];
        aimedLetterHighlightPath = [NSBezierPath bezierPath] ;
        [aimedLetterHighlightPath setLineWidth:1] ;
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius - (radiusWithRoomForHover - _innerRadius)/12 startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
        [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius + (radiusWithRoomForHover - _innerRadius)/8 startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
        [aimedLetterHighlightPath closePath];
        [[_optionHoverColor colorWithAlphaComponent:scaledAlpha] set];
        [aimedLetterHighlightPath fill];
        [[[_optionHoverColor highlightWithLevel:0.8] colorWithAlphaComponent:scaledAlpha] set];
        [aimedLetterHighlightPath stroke];
    }
    
    if (_baseCircleImage)
        return;
    
    [_textImage drawInRect:boundsRect fromRect:NSMakeRect(0, 0, [_textImage size].width, [_textImage  size].height)
                 operation: NSCompositeSourceOver
                  fraction: scaledAlpha];
    
}

- (BOOL)isOpaque {
    return NO;
}


@end

