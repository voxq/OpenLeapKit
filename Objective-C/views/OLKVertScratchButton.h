//
//  OLKVertScratchButton.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-16.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKScratchButtonShell.h"

@interface OLKVertScratchButton : OLKScratchButtonShell

- (void)updateSwitcherPosition:(NSPoint)position;
- (BOOL)positionReachedHalfwayHotzone:(NSPoint)position;
- (BOOL)inSlideInitiateZone:(NSPoint)position;
- (NSPoint)containSwitcherMovementToHalfway:(NSPoint)position;
- (NSPoint)containSwitcherMovementToBegin:(NSPoint)position;
- (void)resetSwitcherToBeginPosition;
- (NSPoint)beginCatcherDrawPosition;
- (NSPoint)halfwayCatcherDrawPosition;

- (BOOL)shouldDrawHalfwayCatcher;
- (NSRect)beginCatcherRect;
- (NSRect)beginSwitcherRect;
- (NSPoint)switcherDrawPosition;

@property (nonatomic) BOOL topInit;
@property (nonatomic) BOOL expandsOnInit;
@property (nonatomic) float expandsOutEdgePercent;
@property (nonatomic) NSRect nonExpandedRect;

@end
