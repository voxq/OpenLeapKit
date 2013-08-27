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
//  OLKHelpers.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-21.
//

#import "OLKHelpers.h"

@implementation OLKHelpers

+ (NSPoint)convertLeapPos:(LeapVector*)leapPos toConfinedView:(NSView *)view forFrame:(LeapFrame *)frame trim:(NSSize)trimAmount
{
    LeapInteractionBox *interactionBox = [frame interactionBox];
    LeapVector *ibNormPos = [interactionBox normalizePoint:leapPos clamp:YES];
    NSRect boundsRect = [view bounds];
    NSSize viewSize = boundsRect.size;
    NSPoint viewOrigin = boundsRect.origin;
    
    NSPoint viewPos;
    viewPos.x = (ibNormPos.x-trimAmount.width)*(1/(1-trimAmount.width));
    if (viewPos.x > 1)
        viewPos.x = 1;
    if (viewPos.x < 0)
        viewPos.x = 0;
    
    viewPos.y = (ibNormPos.y-trimAmount.height)*(1/(1-trimAmount.height));
    if (viewPos.y > 1)
        viewPos.y = 1;
    if (viewPos.y < 0)
        viewPos.y = 0;
    
    viewPos.x = viewOrigin.x + viewPos.x*viewSize.width;
    viewPos.y = viewOrigin.y + viewPos.y*viewSize.height;
    
    return viewPos;
}

// TODO: Not functioning, need to complete.
+ (NSPoint)convertLeapPos:(LeapVector*)leapPos toView:(NSView *)view forFrame:(LeapFrame *)frame trim:(NSSize)trimAmount
{
    LeapInteractionBox *interactionBox = [frame interactionBox];
    LeapVector *ibNormPos = [interactionBox normalizePoint:leapPos clamp:NO];
    NSRect boundsRect = [view bounds];
    NSSize viewSize = boundsRect.size;
    
    NSPoint viewPos;
//    viewPos.x = ibNormPos.x - ;
    viewPos.y = ibNormPos.y - ibNormPos.y*trimAmount.height;
    viewPos.x = viewPos.x*viewSize.width;
    viewPos.y = viewPos.y*viewSize.height;
    return viewPos;
}


@end
