//
//  OLKGestureRecognizerDispatcher.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-09-26.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLKGestureRecognizer.h"

@interface OLKGestureRecognizerDispatcher : NSObject

- (void)dispatchGestureRecognizer:(OLKGestureRecognizer *)gestureRecognizer frame:(LeapFrame*)frame controller:(LeapController *)leapController;
+ (id)sharedDispatcher;

@end
