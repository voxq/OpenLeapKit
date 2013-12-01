//
//  OLKGestureRecognizerDispatcher.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-09-26.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKGestureRecognizerDispatcher.h"

@implementation OLKGestureRecognizerDispatcher

+ (id)sharedDispatcher {
    static OLKGestureRecognizerDispatcher *sharedDispatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDispatcher = [[self alloc] init];
    });
    return sharedDispatcher;
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (void)dispatchGestureRecognizer:(OLKGestureRecognizer *)gestureRecognizer frame:(LeapFrame*)frame controller:(LeapController *)leapController
{
    OLKGestureRecognizer *dispatchRecognizer = [[gestureRecognizer class] alloc];
    [dispatchRecognizer setIdentifier:[gestureRecognizer identifier]];
    [dispatchRecognizer updateWithFrame:frame controller:leapController];
}

@end
