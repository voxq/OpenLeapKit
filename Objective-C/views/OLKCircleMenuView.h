
#import <Cocoa/Cocoa.h>
#import "OLKCircleOptionInput.h"

@interface OLKCircleMenuView : NSView

- (void)redraw;
- (NSPoint)positionRelativeToCenter:(NSPoint)position convertFromView:(NSView *)view;

@property (nonatomic) NSArray *circleOptionInputs;
@property (nonatomic) BOOL active;
@property (nonatomic) NSPoint center;
@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) NSImage *baseCircleImage;

@property (nonatomic) float currentAlpha;
@property (nonatomic) float inactiveAlphaMultiplier;
@property (nonatomic) float textFontSize;
@property (nonatomic) NSFont *textFont;
@property (nonatomic) NSSet *highlightPositions;

@property (nonatomic) NSColor *optionRingColor;
@property (nonatomic) NSColor *optionSeparatorColor;
@property (nonatomic) NSColor *optionHoverColor;
@property (nonatomic) NSColor *optionHighlightColor;
@property (nonatomic) NSColor *optionInnerHighlightColor;
@property (nonatomic) NSColor *optionSelectColor;

@end

