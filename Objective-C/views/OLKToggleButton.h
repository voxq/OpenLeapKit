//
//  OLKSliderButton.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-21.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKButton.h"

@interface OLKToggleButton : NSObject <OLKButton>

- (BOOL)handMovedTo:(NSPoint)position;

@property (nonatomic) int identifier;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL visible;
@property (nonatomic) NSSize size;
@property (nonatomic) float alpha;
@property (nonatomic) float switcherPosition;
@property (weak) id target;
@property (nonatomic) SEL action;

@end
