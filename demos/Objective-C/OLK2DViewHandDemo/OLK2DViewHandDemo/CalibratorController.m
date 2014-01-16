//
//  CalibratorController.m
//  WordLeap
//
//  Created by Tyler Zetterstrom on 2013-12-08.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "CalibratorController.h"
#import <OpenLeapKit/OLKCircleMenuMultiCursorView.h>
#import <OpenLeapKit/OLKCircleOptionMultiCursorInput.h>

@implementation CalibratorController
{
    OLKCircleMenuMultiCursorView *_menuView;
    OLKCircleOptionMultiCursorInput *_menuModel;
    NSView *_handsSpaceViewBeforeCalibrateView;
}

@synthesize menuParentView = _menuParentView;
@synthesize calibrator = _calibrator;
@synthesize calibratorView = _calibratorView;
@synthesize screenCalibrators = _screenCalibrators;
@synthesize fullScreenCalibrateOverlayWindow = _fullScreenCalibrateOverlayWindow;
@synthesize handsOverlayController = _handsOverlayController;
@synthesize delegate = _delegate;
@synthesize showingCalibrationMenu = _showingCalibrationMenu;

+ (void)resetDefaults
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WLCalibratorControllerKey];
}

- (NSDictionary *)leapVectorToProperties:(LeapVector *)leapVect
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",leapVect.x], @"x", [NSString stringWithFormat:@"%f",leapVect.y], @"y", nil];
}

- (LeapVector *)leapVectorFromProperties:(NSDictionary *)properties
{
    return [[LeapVector alloc] initWithX:[[properties objectForKey:@"x"] floatValue] y:[[properties objectForKey:@"y"] floatValue] z:0];
}

- (NSDictionary *)screenPosToProperties:(NSPoint)screenPos
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",screenPos.x], @"x", [NSString stringWithFormat:@"%f",screenPos.y], @"y", nil];
}

- (NSPoint)screenPosFromProperties:(NSDictionary *)properties
{
    return NSMakePoint([[properties objectForKey:@"x"] floatValue], [[properties objectForKey:@"y"] floatValue]);
}

- (void)addCalibratorWithProperties:(NSDictionary *)properties forScreen:(NSScreen *)screen
{
    OLKRangeCalibrator *calibrator = [[OLKRangeCalibrator alloc] init];
    [calibrator setHeightFactor:[[properties objectForKey:WLCalibratorHeightFactor] floatValue]];
    [calibrator setWidthFactor:[[properties objectForKey:WLCalibratorWidthFactor] floatValue]];
    [calibrator setOffsetToBase:[[properties objectForKey:WLCalibratorOffsetBase] floatValue]];
    [calibrator setOffsetFromHorizCenter:[[properties objectForKey:WLCalibratorOffsetCenter] floatValue]];
    int method = [[properties objectForKey:WLCalibratorMethod] intValue];
    if (method == OLKCalibratorMethod3PointInversePyramid)
        [calibrator setUse3PointCalibration:YES];
     
    LeapVector *vector = [self leapVectorFromProperties:[properties objectForKey:WLCalibratorLeapPos1]];
    [calibrator setLeapPos1:vector];
    vector = [self leapVectorFromProperties:[properties objectForKey:WLCalibratorLeapPos2]];
    [calibrator setLeapPos2:vector];
    if (method == OLKCalibratorMethod3PointInversePyramid)
    {
        vector = [self leapVectorFromProperties:[properties objectForKey:WLCalibratorLeapPos3]];
        [calibrator setLeapPos3:vector];
    }
    
    NSPoint screenPos = [self screenPosFromProperties:[properties objectForKey:WLCalibratorScreenPos1]];
    [calibrator setScreenPos1:screenPos];
    screenPos = [self screenPosFromProperties:[properties objectForKey:WLCalibratorScreenPos2]];
    [calibrator setScreenPos2:screenPos];
    if (method == OLKCalibratorMethod3PointInversePyramid)
    {
        screenPos = [self screenPosFromProperties:[properties objectForKey:WLCalibratorScreenPos3]];
        [calibrator setScreenPos3:screenPos];
    }
    [calibrator setCalibrated:YES];
    [calibrator setScreenFrame:[screen frame]];
    [self addCalibrator:calibrator forScreen:screen];
}

- (NSDictionary *)calibratorProperties:(OLKRangeCalibrator *)calibrator
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:[NSString stringWithFormat:@"%f", [calibrator heightFactor]] forKey:WLCalibratorHeightFactor];
    [properties setObject:[NSString stringWithFormat:@"%f", [calibrator widthFactor]] forKey:WLCalibratorWidthFactor];
    [properties setObject:[NSString stringWithFormat:@"%f", [calibrator offsetFromHorizCenter]] forKey:WLCalibratorOffsetCenter];
    [properties setObject:[NSString stringWithFormat:@"%f", [calibrator offsetToBase]] forKey:WLCalibratorOffsetBase];
    int method;
    if ([calibrator use3PointCalibration])
        method = OLKCalibratorMethod3PointInversePyramid;
    else
        method = OLKCalibratorMethodOppositeCorners;
    
    [properties setObject:[NSString stringWithFormat:@"%d", method] forKey:WLCalibratorMethod];
    
    [properties setObject:[self leapVectorToProperties:[calibrator leapPos1]] forKey:WLCalibratorLeapPos1];
    [properties setObject:[self leapVectorToProperties:[calibrator leapPos2]] forKey:WLCalibratorLeapPos2];
    if ([calibrator use3PointCalibration])
        [properties setObject:[self leapVectorToProperties:[calibrator leapPos3]] forKey:WLCalibratorLeapPos3];
    
    [properties setObject:[self screenPosToProperties:[calibrator screenPos1]] forKey:WLCalibratorScreenPos1];
    [properties setObject:[self screenPosToProperties:[calibrator screenPos2]] forKey:WLCalibratorScreenPos2];
    if ([calibrator use3PointCalibration])
        [properties setObject:[self screenPosToProperties:[calibrator screenPos3]] forKey:WLCalibratorScreenPos3];
    return [NSDictionary dictionaryWithDictionary:properties];
}

- (void)saveCalibratorDefaults
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumer = [_screenCalibrators keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        id object = [_screenCalibrators objectForKey:key];
        [properties setObject:[self calibratorProperties:object] forKey:key];
        key = [enumer nextObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:properties] forKey:WLCalibratorControllerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadFromDefaults
{
    NSDictionary *calibrations = [[NSUserDefaults standardUserDefaults] objectForKey:WLCalibratorControllerKey];
    
    NSEnumerator *enumer = [calibrations keyEnumerator];
    id key = [enumer nextObject];
    while (key)
    {
        id object = [calibrations objectForKey:key];
        for (NSScreen *screen in [NSScreen screens])
        {
            NSString *screenNumString = [NSString stringWithFormat:@"%@",[[screen deviceDescription] objectForKey:@"NSScreenNumber"]];
            if ([screenNumString isEqualToString:key])
            {
                [self addCalibratorWithProperties:object forScreen:screen];
                break;
            }
        }
        key = [enumer nextObject];
    }
    
//    [calibrations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//    {
//    }];
}

- (void)selectedIndexChanged:(int)index sender:(id)sender cursorContext:(id)cursorContext
{
    if (index == OLKCircleOptionMultiInputInvalidSelection)
    {
        NSLog(@"Deselected Index");
        [_menuView setNeedsDisplay:YES];
        return;
    }
    
    switch (index)
    {
        case 0:
            [self showCalibrate:NO];
            break;
            
        case 1:
            [self showCalibrate:YES];
            break;
            
        case 2:
            [self exitCalibrationMenu];
            break;
    }
    NSLog(@"Selected Index: %d", index);
    [_menuModel setRequiresMoveToInner:TRUE cursorContext:cursorContext];
    [_menuView setNeedsDisplay:YES];
}

- (void)exitCalibrationMenu
{
    _showingCalibrationMenu = NO;
    [_menuView removeFromSuperview];
    [_menuModel removeAllCursorTracking];
    if ([_delegate respondsToSelector:@selector(exitedCalibrationMenu)])
        [_delegate exitedCalibrationMenu];
}

- (void)showCalibrationMenu
{
    _showingCalibrationMenu = YES;
    _handsSpaceViewBeforeCalibrateView = [_handsOverlayController handsSpaceView];
    if (!_menuView)
    {
        _menuView = [[OLKCircleMenuMultiCursorView alloc] initWithFrame:[_menuParentView bounds]];
        _menuModel = [[OLKCircleOptionMultiCursorInput alloc] init];
        [_menuModel setDelegate:self];
        [_menuModel setOptionObjects:[NSArray arrayWithObjects:@"2 Point Calibrate", @"3 Point Calibrate", @"exit", nil]];
        [_menuView setCircleInput:_menuModel];
    }
    
    [_menuParentView addSubview:_menuView];
    
    NSRect keyViewRect = [_menuParentView bounds];
    
    NSRect viewRect;
    viewRect.size = [(OLKFullScreenOverlayWindow *)[_menuParentView window] determinePointSizeFromDesiredPhysicalSize:NSMakeSize(170, 150)];
    viewRect.origin = NSMakePoint(keyViewRect.origin.x+keyViewRect.size.width/4, keyViewRect.origin.y+keyViewRect.size.height/4);
    
    [_menuModel setRadius:viewRect.size.height/2.0];
    
    [_menuView setFrame:viewRect];
    
    [_menuView setActive:YES];
    [_menuView setNeedsDisplay:YES];
}


- (IBAction)resetCalibration:(id)sender
{
    [_handsOverlayController setCalibrator:nil];
    [_handsOverlayController updateHandsAndPointablesViews];
}

- (void)calibratedPosition:(OLKRangePositionsCalibrated)positionCalibrated
{
    OLKHand *hand = nil;
    NSArray *hands = [_handsOverlayController hands];
    if ([hands count])
        hand = [hands objectAtIndex:0];
    
    switch (positionCalibrated)
    {
        case OLKRangeFirstPositionCalibrated:
            if (!hand)
                [_calibratorView setPositionsCalibrated:OLKRangeNoPositionsCalibrated];
            else
                [_calibrator setLeapPos1:[hand palmPosition]];
            break;
            
        case OLKRangeSecondPositionCalibrated:
            if (!hand)
                [_calibratorView setPositionsCalibrated:OLKRangeSecondPositionCalibrated];
            else
                [_calibrator setLeapPos2:[hand palmPosition]];
            break;
            
        case OLKRangeAllPositionsCalibrated:
            
            if ([_calibrator use3PointCalibration])
            {
                if (!hand)
                {
                    [_calibratorView setPositionsCalibrated:OLKRangeSecondPositionCalibrated];
                    return;
                }
                [_calibrator setLeapPos3:[hand palmPosition]];
            }
            else
            {
                if (!hand)
                {
                    [_calibratorView setPositionsCalibrated:OLKRangeFirstPositionCalibrated];
                    return;
                }
                [_calibrator setLeapPos2:[hand palmPosition]];
            }
            [self completeCalibration];
            break;
    }
}

- (void)addCalibrator:(OLKRangeCalibrator *)calibrator forScreen:(NSScreen *)screen
{
    if (!_screenCalibrators)
        _screenCalibrators = [[NSMutableDictionary alloc] init];
    NSDictionary *devDesc = [screen deviceDescription];

    [_screenCalibrators setObject:calibrator forKey:[NSString stringWithFormat:@"%@",[devDesc objectForKey:@"NSScreenNumber"]]];
}

- (void)completeCalibration
{
    [_calibrator calibrate];
    [self addCalibrator:_calibrator forScreen:[[_menuParentView window] screen]];
    [_handsOverlayController setCalibrator:_calibrator];
    [self exitCalibration];
    if ([_delegate respondsToSelector:@selector(completeCalibration)])
        [_delegate completedCalibration];
    
    [self saveCalibratorDefaults];
}

- (void)exitCalibration
{
    [_fullScreenCalibrateOverlayWindow orderOut:self];
    _calibratorView = nil;
    _calibrator = nil;
    _fullScreenCalibrateOverlayWindow = nil;
    
    [_handsOverlayController setHandsSpaceView:_handsSpaceViewBeforeCalibrateView];
    [[_handsSpaceViewBeforeCalibrateView window] orderFront:self];
    [[_handsSpaceViewBeforeCalibrateView window] makeFirstResponder:_handsSpaceViewBeforeCalibrateView];
    
    [_handsOverlayController updateHandsAndPointablesViews];
}

- (void)changeToScreen:(NSScreen *)screen
{
    _calibrator = [self calibratorForScreen:screen];
    [_handsOverlayController setCalibrator:_calibrator];
    [_handsOverlayController updateHandsAndPointablesViews];
    
}

- (OLKRangeCalibrator *)calibratorForScreen:(NSScreen *)screen
{
    return _calibrator = [_screenCalibrators objectForKey:[NSString stringWithFormat:@"%@",[[screen deviceDescription] objectForKey:@"NSScreenNumber"]]];
}

- (void)canceledCalibration
{
    [self exitCalibration];
    if ([_delegate respondsToSelector:@selector(canceledCalibration)])
        [_delegate canceledCalibration];
}

- (void)showCalibrate:(BOOL)threePoint
{
    NSScreen *screen = [[_menuParentView window] screen];
    [[_menuParentView window] orderOut:self];
    
    _fullScreenCalibrateOverlayWindow = [[OLKFullScreenOverlayWindow alloc] init];
    [_fullScreenCalibrateOverlayWindow setFrame:[screen frame] display:YES];
    
    _calibrator = [[OLKRangeCalibrator alloc] init];
    [_calibrator setUse3PointCalibration:threePoint];
    
    [_calibrator setScreenFrame:[screen frame]];
    [_calibrator configScreenPositions];
    
    _calibratorView = [[OLKRangeCalibratorView alloc] initWithFrame:[screen frame]];
    [_calibratorView setRangeCalibrator:_calibrator];
    [_calibratorView setDelegate:self];
    [_handsOverlayController setHandsSpaceView:_calibratorView];
    [_handsOverlayController updateHandsAndPointablesViews];
    [_fullScreenCalibrateOverlayWindow setContentView:_calibratorView];
    [_fullScreenCalibrateOverlayWindow makeKeyAndOrderFront:self];
    [_fullScreenCalibrateOverlayWindow makeFirstResponder:_calibratorView];
}

- (void)setCursorPos:(NSPoint)cursorPos cursorContext:(id)cursorContext
{
    if (_calibratorView)
        return;
    int selectedIndex = [_menuModel selectedIndex:cursorContext];
    int hoverIndex = [_menuModel hoverIndex:cursorContext];
    [_menuModel setCursorPos:[_menuView positionRelativeToCenter:cursorPos convertFromView:_handsSpaceViewBeforeCalibrateView] cursorContext:cursorContext];
    if ([_menuModel selectedIndex:cursorContext] != selectedIndex || [_menuModel hoverIndex:cursorContext] != hoverIndex)
        [_menuView setNeedsDisplay:YES];
}

- (void)removeCursorContext:(id)cursorContext
{
    [_menuModel removeCursorContext:cursorContext];
}

@end
