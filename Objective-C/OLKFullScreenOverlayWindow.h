//
//  WordLeapOverlayWindow.h
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-11-19.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLKFullScreenOverlayWindow : NSPanel

- (void)resetToDefaultConfig;
- (void)moveToScreen:(NSScreen *)screen;
- (void)moveToScreenNumber:(NSNumber *)screenNumber;
- (void)moveToNextScreen;
- (NSSize)screenPhysicalSize;
- (NSSize)determinePointSizeFromDesiredPhysicalSize:(NSSize)desiredPhysicalSize;

@end
