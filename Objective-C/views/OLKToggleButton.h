//
//  OLKSliderButton.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-21.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKNIControl.h"

@interface OLKToggleButton : OLKNIControl

@property (nonatomic) NSView <OLKHandContainer> *controllingHandView;
@property (nonatomic) float alpha;
@property (nonatomic) float switcherPosition;
@property (nonatomic) BOOL on;

@end
