//
//  OLKCircleMultiCursorInputMultiTap.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-11.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <OpenLeapKit/OLKCircleOptionMultiCursorInput.h>

typedef enum {
    OLKIntentStrikeCheckStateThresholdReached,
    OLKIntentStrikeCheckStateNotRepeat,
    OLKIntentStrikeCheckStateRepeat,
    OLKIntentStrikeCheckStateConfirmed,
    OLKIntentStrikeCheckStateNonIntended
} OLKIntentStrikeCheckState;

@protocol OLKCircleMultiCursorInputMultiTapDelegate <NSObject>

@optional

- (void)strikeNotIntended:(id)sender cursorContext:(id)cursorContext;
- (void)strikeConfirmed:(id)sender cursorContext:(id)cursorContext;
- (void)strikeFollowedByCursorRemoval:(id)sender cursorContext:(id)cursorContext;

@end

@interface OLKCircleMultiCursorInputMultiTap : OLKCircleOptionMultiCursorInput

- (OLKIntentStrikeCheckState)intentionalStrikeState:(id)cursorContext;
- (void)resetWithAllIntentStrikeChecksSetTo:(OLKIntentStrikeCheckState)state;

@property (nonatomic) NSObject <OLKCircleMultiCursorInputMultiTapDelegate> *multiTapDelegate;
@property (nonatomic) NSTimeInterval intentStrikeTimeThreshold; // How long without reentry before it is certain a strike was not intended
@property (nonatomic) float nonIntendedThreshold; // Threshold that is certain to mean the strike was not the purpose

@end
