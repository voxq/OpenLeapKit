/*
 
 Copyright (c) 2013, Tyler Zetterstrom
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

//
//  OLKHelpers.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-21.
//


#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

@interface OLKHelpers : NSObject

// Uses the leap interaction box to map leap positions to a view, trimming off a specified amount of the interaction box when its values are non-optimal.
+ (NSPoint)convertInteractionBoxLeapPos:(LeapVector*)leapPos toConfinedView:(NSView *)view forFrame:(LeapFrame *)frame trim:(NSSize)trimAmount;

// Maps leap positions to a view, using the device range with supplied offset, and horizontal angle to calculate .
+ (NSPoint)convertLeapPos:(LeapVector*)leapPos toConfinedView:(NSView *)view proximityOffset:(float)proximityOffset rangeOffset:(float)rangeOffset percentRangeOfMaxWidth:(float)percentRangeOfMaxWidth forLeapDevice:(LeapDevice *)leapDevice;
+ (float)distanceToDepthBoundary:(LeapVector *)position leapDevice:(LeapDevice *)leapDevice;
+ (float)distanceToWidthBoundary:(LeapVector *)position leapDevice:(LeapDevice *)leapDevice;

@end
