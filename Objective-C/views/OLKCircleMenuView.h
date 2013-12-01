
#import <Cocoa/Cocoa.h>
#import "OLKCircleOptionInput.h"

@interface OLKCircleMenuView : NSView

- (NSString *)textAtAngle:(float)degree;
- (int)indexAtAngle:(float)degree;
- (NSString *)textAtIndex:(int)index;

@property (nonatomic) OLKCircleOptionInput *circleOptionInput;
@property (nonatomic) BOOL active;
@property (nonatomic) NSPoint center;
@property (nonatomic) CGFloat innerRadius;

@property (nonatomic) float currentAlpha;
@property (nonatomic) NSPoint cursorPos;
@property (nonatomic) NSSize cursorSize;
@property (nonatomic) BOOL enableCursor;
@property (nonatomic) NSArray *cellStrings;
@property (nonatomic) float textFontSize;
@property (nonatomic) NSFont *textFont;
@property (nonatomic) NSSet *highlightPositions;

@end

