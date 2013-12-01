//
//  OLKGestureRecognizer.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-09-26.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"
#import "OLKGestureComponents.h"

@class OLKGestureRecognizer;

typedef enum OLKGestureStatus {
    OLK_GESTURE_DETECT = 0,
    OLK_GESTURE_BEGIN = 1,
    OLK_GESTURE_UPDATING = 2,
    OLK_GESTURE_CANCELLED = 3,
    OLK_GESTURE_COMPLETED = 4
} OLKGestureStatus;

@protocol OLKGestureRecognizerDelegate <NSObject>

- (void)gestureBeginDetected:(OLKGestureRecognizer *)recognizer;
- (void)gestureUpdated:(OLKGestureRecognizer *)recognizer;
- (void)gestureCancelled:(OLKGestureRecognizer *)recognizer;
- (void)gestureCompleted:(OLKGestureRecognizer *)recognizer;

@end

@interface OLKGestureRecognizer : NSObject

- (void)updateWithFrame:(LeapFrame*)frame controller:(LeapController *)leapController;

@property (nonatomic) NSObject <OLKGestureRecognizerDelegate> *gestureRecognizerDelegate;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL status;
@property (nonatomic, readonly) float duration;
@property (nonatomic) int identifier;
@property (nonatomic) OLKGestureComponents *gestureComponents;

@end

@interface OLKPressGestureRecognizer : OLKGestureRecognizer

@end


@interface OLKPointingDepthThresholdRecognizer : OLKGestureRecognizer

@property (nonatomic) float threshold;
@property (nonatomic) BOOL inDirMinus;

@end


@interface OLKPointingPenetrateThresholdRecognizer : OLKGestureRecognizer

@property (nonatomic) float threshold;
@property (nonatomic) BOOL inDirMinus;

@end
