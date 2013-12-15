//
//  OLKSliderControl.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-11-27.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKButton.h"
#import <OpenLeapKit/OLKNIControl.h>

@interface OLKScratchButton : OLKNIControl

- (void)clear;

@property (nonatomic) NSView <OLKHandContainer> *controllingHandView;
@property (nonatomic) BOOL activated;
@property (nonatomic) float alpha;
@property (nonatomic) float switcherPosition;
@property (nonatomic) NSSize escapeZone;
@property (nonatomic) NSSize outerHotZone;
@property (nonatomic) NSSize resetEscapeZone;
@property (nonatomic) float innerHotZone;
@property (nonatomic) NSColor *onColor;
@property (nonatomic) NSColor *offColor;
@property (nonatomic) NSColor *halfColor;
@property (nonatomic) BOOL initiateBothSides;
@property (nonatomic) BOOL verticalOrient;

@end
