//
//  OLKSliderControl.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-28.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OLKButton.h"

typedef enum
{
    OLKSliderOrientationHorizontal = 1,
    OLKSliderOrientationVertical = 2
}OLKSliderOrientation;

@interface OLKSliderControl : NSObject <OLKButton>

- (BOOL)handMovedTo:(NSPoint)position;

@property (nonatomic) int identifier;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL visible;
@property (nonatomic) NSSize size;
@property (nonatomic) float alpha;
@property (nonatomic) float position;
@property (weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic) NSView *parentView;
@property (nonatomic) OLKSliderOrientation orientation;

@end
