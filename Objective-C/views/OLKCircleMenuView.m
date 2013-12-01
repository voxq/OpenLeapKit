#import <Cocoa/Cocoa.h>
#import "OLKCircleMenuView.h"

@implementation OLKCircleMenuView
{
    NSImage *_image;
    NSImage *_textImage;
}

@synthesize circleOptionInput = _circleOptionInput;

@synthesize innerRadius = _innerRadius;
@synthesize center = _center;
@synthesize active = _active;
@synthesize textFontSize = _textFontSize;
@synthesize currentAlpha = _currentAlpha;
@synthesize highlightPositions = _highlightPositions;

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
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    NSRect boundsRect = [super bounds];
    _innerRadius = [_circleOptionInput radius] * [_circleOptionInput thresholdForHit];
    _textFontSize = ([_circleOptionInput radius] - _innerRadius)/2;
    _textFont = [NSFont fontWithName:@"Helvetica Neue" size:_textFontSize];
    _center = boundsRect.origin;
    _center.x += boundsRect.size.width/2;
    _center.y += boundsRect.size.height/2;
    [self drawIntoImage];
}

- (void)configDefaultView
{
    _currentAlpha = 1.0;
    _innerRadius = [_circleOptionInput radius] * [_circleOptionInput thresholdForHit];
    _textFontSize = ([_circleOptionInput radius] - _innerRadius)/2;
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

- (void)drawIntoImage
{
    if ([_circleOptionInput optionObjects] == nil)
        return;
    
    float radiusWithRoomForHover = [_circleOptionInput radius]-4;
    int index;
    NSRect boundsRect = [self bounds];

    _image = [[NSImage alloc] initWithSize:boundsRect.size];
    [_image lockFocus];
        
    NSBezierPath *highlightPath = [NSBezierPath bezierPath] ;
    [highlightPath setLineWidth: 2 ] ;
    
    NSBezierPath *greenPath = [NSBezierPath bezierPath] ;
    [greenPath setLineWidth: 2 ] ;

    int objectCount = [[_circleOptionInput optionObjects] count];
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
        if (closePath || index == [_circleOptionInput selectedIndex])
        {
            [[NSColor colorWithCalibratedRed:0.5 green:1 blue:0.5 alpha:1] set] ;
            // and fill it
            [greenPath fill] ;
            [[NSColor colorWithCalibratedRed:0.8 green:1 blue:0.8 alpha:1] set] ;
            [greenPath stroke] ;
            [greenPath removeAllPoints];
            position = 0;
            closePath = FALSE;
            degAngle = 360.0/(float)objectCount * index + 90;
            
            // draw an arc (perc is a certain percentage ; something between 0 and 1
            [greenPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
            [greenPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
            [greenPath closePath];
            [[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1 alpha:1] set] ;
            // and fill it
            [greenPath fill] ;
            [[NSColor colorWithCalibratedRed:0.8 green:1 blue:0.8 alpha:1] set] ;
            [greenPath stroke] ;
            [greenPath removeAllPoints];
            continue;
        }
        
        degAngle = 360.0/(float)objectCount * index + 90;
        
        // draw an arc (perc is a certain percentage ; something between 0 and 1
        [greenPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
        NSPoint nextStartPoint = [greenPath currentPoint];
        [greenPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
        [greenPath closePath];
        [greenPath moveToPoint:nextStartPoint];
        position ++;
    }

    if (position != 0)
    {
        [[NSColor colorWithCalibratedRed:0.5 green:1 blue:0.5 alpha:1] set] ;
        // and fill it
        [greenPath fill] ;
        [[NSColor colorWithCalibratedRed:0.8 green:1 blue:0.8 alpha:1] set] ;
        [greenPath stroke] ;
    }
    
    if (_highlightPositions && [_highlightPositions count] > 0)
    {
        highlightPath = [NSBezierPath bezierPath] ;
        
        // set some line width
        
        [highlightPath setLineWidth: 2 ] ;
        
        // move to the center so that we have a closed slice
        // size_x and size_y are the height and width of the view
        
        [highlightPath moveToPoint: NSMakePoint( _center.x, _center.y ) ] ;
        for (index = 0; index < objectCount; index +=1)
        {
            int highlightCheck = objectCount-index;
            if (highlightCheck == objectCount)
                highlightCheck = 0;
            if (![_highlightPositions containsObject:[NSNumber numberWithInteger:highlightCheck]])
                continue;
            if (index == [_circleOptionInput selectedIndex])
                continue;
            degAngle = 360/(float)objectCount * index + 90;
            // draw an arc (perc is a certain percentage ; something between 0 and 1
            [highlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius startAngle:degAngle-arcAngleOffset  endAngle:degAngle+arcAngleOffset ] ;
            
            // close the slice , by drawing a line to the center
            [highlightPath lineToPoint: NSMakePoint( _center.x, _center.y ) ] ;
        }
        
        [[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1 alpha:0.5] set] ;
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
        NSString *string = [[_circleOptionInput optionObjects] objectAtIndex:index];
        if (pos == 0)
            radAngle = 0;
        else
            radAngle = M_PI/(float)objectCount * pos;
        
        radAngle += offset;
        radAngle *=2;
        
        NSRect textRect;
        textRect.origin.x = _center.x + distance * cos(radAngle) - 200;
        textRect.origin.x += (textRect.origin.x - _center.x)/distance*5;
        
        textRect.origin.y = _center.y + distance * sin(radAngle) - _textFontSize/2;
        textRect.origin.y -= (distance - ((textRect.origin.y - _center.y) + distance))/distance;
        textRect.size.width = 400;
        textRect.size.height = _textFontSize*1.5;
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
    int objectCount = [[_circleOptionInput optionObjects] count];
    if (!objectCount)
        return;
    float radiusWithRoomForHover = [_circleOptionInput radius]-4;
    float arcAngleOffset = (360.0 / (float)objectCount) / 2.0;
    float degAngle;
    float scaledAlpha = _currentAlpha;
    if (!_active)
        scaledAlpha *= 0.33;
    
    if ([_circleOptionInput selectedIndex] < objectCount && [_circleOptionInput selectedIndex] >= 0)
    {
        NSBezierPath *selPath = [NSBezierPath bezierPath] ;
        
        // set some line width
        
        [selPath setLineWidth: 2 ] ;
        
        // move to the center so that we have a closed slice
        // size_x and size_y are the height and width of the view

        degAngle = 360 - (float)arcAngleOffset*2 * ([_circleOptionInput selectedIndex]) + 90;
        
        [selPath moveToPoint: NSMakePoint( _center.x, _center.y ) ] ;
        // draw an arc (perc is a certain percentage ; something between 0 and 1
        [selPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover startAngle:degAngle-arcAngleOffset  endAngle:degAngle+arcAngleOffset ] ;
        
        // close the slice , by drawing a line to the center
        [selPath lineToPoint: NSMakePoint( _center.x, _center.y ) ] ;
        
        [[NSColor colorWithCalibratedRed:1 green:0.3 blue:0.3 alpha:scaledAlpha] set] ;
        // and fill it
        [selPath fill] ;
    }

    // Draw the image in the current context.
    boundsRect.origin.x -= [_image size].width/2-_center.x;
    boundsRect.origin.y -= [_image size].height/2-_center.y;
    [_image drawInRect:boundsRect fromRect:NSMakeRect(0, 0, [_image size].width, [_image size].height)
              operation: NSCompositeSourceOver
               fraction: scaledAlpha];
    
//    NSLog(@"drawing rect: %f, %f, %f, %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    degAngle = 360 - (float)arcAngleOffset*2 * ([_circleOptionInput hoverIndex]) + 90;

    NSBezierPath *aimedLetterHighlightPath = [NSBezierPath bezierPath] ;
    [aimedLetterHighlightPath setLineWidth:2] ;
    
    // draw an arc (perc is a certain percentage ; something between 0 and 1
    [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover + (radiusWithRoomForHover - _innerRadius)/12 startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
    [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:radiusWithRoomForHover - (radiusWithRoomForHover - _innerRadius)/8 startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
    [aimedLetterHighlightPath closePath];
    [[NSColor colorWithCalibratedRed:0.5 green:0.7 blue:1 alpha:scaledAlpha] set];
    [aimedLetterHighlightPath fill];
    [[NSColor colorWithCalibratedRed:0.7 green:0.95 blue:1 alpha:scaledAlpha] set];
    [aimedLetterHighlightPath stroke];
    aimedLetterHighlightPath = [NSBezierPath bezierPath] ;
    [aimedLetterHighlightPath setLineWidth:1] ;
    [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius - (radiusWithRoomForHover - _innerRadius)/12 startAngle:degAngle-arcAngleOffset endAngle:degAngle+arcAngleOffset ] ;
    [aimedLetterHighlightPath appendBezierPathWithArcWithCenter:NSMakePoint( _center.x, _center.y ) radius:_innerRadius + (radiusWithRoomForHover - _innerRadius)/8 startAngle:degAngle+arcAngleOffset endAngle:degAngle-arcAngleOffset clockwise:YES];
    [aimedLetterHighlightPath closePath];
    [[NSColor colorWithCalibratedRed:0.5 green:0.7 blue:1 alpha:scaledAlpha] set];
    [aimedLetterHighlightPath fill];
    [[NSColor colorWithCalibratedRed:0.7 green:0.95 blue:1 alpha:scaledAlpha] set];
    [aimedLetterHighlightPath stroke];
    [_textImage drawInRect:boundsRect fromRect:NSMakeRect(0, 0, [_textImage size].width, [_textImage  size].height)
             operation: NSCompositeSourceOver
              fraction: scaledAlpha];
}

- (BOOL)isOpaque {
    return NO;
}

// DotView changes location on mouse up, but here we choose to do so
// on mouse down and mouse drags, so the text will follow the mouse.

- (void)mouseDown:(NSEvent *)event {
    NSPoint eventLocation = [event locationInWindow];
    _center = [self convertPoint:eventLocation fromView:nil];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint eventLocation = [event locationInWindow];
    _center = [self convertPoint:eventLocation fromView:nil];
    [self setNeedsDisplay:YES];
    NSLog(@"center = %f, %f", _center.x, _center.y);
}

@end

