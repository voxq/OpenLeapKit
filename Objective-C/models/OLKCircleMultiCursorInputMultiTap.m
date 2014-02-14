//
//  OLKCircleMultiCursorInputMultiTap.m
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-12-11.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import "OLKCircleMultiCursorInputMultiTap.h"

@interface OLKIntentStrikeCheck : NSObject

@property (nonatomic) OLKIntentStrikeCheckState state;
@property (nonatomic) NSDate *checkStartTime;

@end

@implementation OLKIntentStrikeCheck

@synthesize checkStartTime = _checkStartTime;
@synthesize state = _state;

@end

@implementation OLKCircleMultiCursorInputMultiTap
{
    NSDictionary *_intentionalStrikeChecks;
}

@synthesize intentStrikeTimeThreshold = _intentStrikeTimeThreshold;
@synthesize nonIntendedThreshold = _nonIntendedThreshold;

- (id)init
{
    if (self = [super init])
    {
        _intentStrikeTimeThreshold = 1.2;
        _nonIntendedThreshold = INFINITY;
    }
    
    return self;
}

- (void)setThresholdForRepeat:(float)thresholdForRepeat
{
    [super setThresholdForRepeat:thresholdForRepeat];
    if (_nonIntendedThreshold == INFINITY)
        _nonIntendedThreshold = thresholdForRepeat*[self radius] + [super radius]/2;
}

- (OLKIntentStrikeCheckState)intentionalStrikeState:(id)cursorContext
{
    OLKIntentStrikeCheck *intentCheck = [_intentionalStrikeChecks objectForKey:cursorContext];
    return [intentCheck state];
}

- (void)updateIntentionalStrikeCheck:(NSPoint)cursorPos cursorContext:(id)cursorContext intentStrikeCheck:(OLKIntentStrikeCheck *)intentStrikeCheck
{
    if ([intentStrikeCheck state] == OLKIntentStrikeCheckStateNonIntended || [intentStrikeCheck state] == OLKIntentStrikeCheckStateConfirmed)
        return;
    
    float curDist = sqrtf(cursorPos.x*cursorPos.x + cursorPos.y*cursorPos.y);
    if (curDist <= [super thresholdForStrike]*[self radius])
    {
        [intentStrikeCheck setState:OLKIntentStrikeCheckStateConfirmed];
        if ([_multiTapDelegate respondsToSelector:@selector(strikeConfirmed:cursorContext:)])
            [_multiTapDelegate strikeConfirmed:self cursorContext:cursorContext];
        
        return;
    }
    else if (curDist <= _nonIntendedThreshold)
    {
        NSDate *now = [NSDate date];
        NSTimeInterval timeSinceStartCheck = [now timeIntervalSinceDate:[intentStrikeCheck checkStartTime]];
        if (timeSinceStartCheck < _intentStrikeTimeThreshold)
        {
            if (curDist > [self thresholdForRepeat] * [self radius])
                [intentStrikeCheck setState:OLKIntentStrikeCheckStateNotRepeat];
            return;
        }
        if ([intentStrikeCheck state] != OLKIntentStrikeCheckStateNotRepeat)
        {
            [intentStrikeCheck setState:OLKIntentStrikeCheckStateConfirmed];
            if ([_multiTapDelegate respondsToSelector:@selector(strikeConfirmed:cursorContext:)])
                [_multiTapDelegate strikeConfirmed:self cursorContext:cursorContext];
            return;
        }
    }

    [intentStrikeCheck setState:OLKIntentStrikeCheckStateNonIntended];
    if ([_multiTapDelegate respondsToSelector:@selector(strikeNotIntended:cursorContext:)])
        [_multiTapDelegate strikeNotIntended:self cursorContext:cursorContext];
}

- (void)resetWithAllIntentStrikeChecksSetTo:(OLKIntentStrikeCheckState)state
{
    NSEnumerator *enumerator = [_intentionalStrikeChecks keyEnumerator];
    id key = [enumerator nextObject];
    while (key)
    {
        OLKIntentStrikeCheck *intentStrikeCheck = [_intentionalStrikeChecks objectForKey:key];
        if (intentStrikeCheck.state != OLKIntentStrikeCheckStateNonIntended && intentStrikeCheck.state != OLKIntentStrikeCheckStateConfirmed)
        {
            if (state == OLKIntentStrikeCheckStateNonIntended)
            {
                [intentStrikeCheck setState:OLKIntentStrikeCheckStateNonIntended];
                if ([_multiTapDelegate respondsToSelector:@selector(strikeNotIntended:cursorContext:)])
                    [_multiTapDelegate strikeNotIntended:self cursorContext:key];
            }
            else if (state == OLKIntentStrikeCheckStateConfirmed)
            {
                [intentStrikeCheck setState:OLKIntentStrikeCheckStateConfirmed];
                if ([_multiTapDelegate respondsToSelector:@selector(strikeConfirmed:cursorContext:)])
                    [_multiTapDelegate strikeConfirmed:self cursorContext:key];
            }
            [self resetCurrentCursorTracking:key];
        }
        key = [enumerator nextObject];
    }
    [self removeAllCursorTracking];
}

- (void)startIntentionalStrikeCheck:(NSPoint)cursorPos cursorContext:(id)cursorContext
{
    float curDist = sqrtf(cursorPos.x*cursorPos.x + cursorPos.y*cursorPos.y);
    OLKIntentStrikeCheck *intentStrikeCheck = [[OLKIntentStrikeCheck alloc] init];
    if (curDist < _nonIntendedThreshold)
        [intentStrikeCheck setState:OLKIntentStrikeCheckStateThresholdReached];
    else
    {
        [intentStrikeCheck setState:OLKIntentStrikeCheckStateNonIntended];
        if ([_multiTapDelegate respondsToSelector:@selector(strikeNotIntended:cursorContext:)])
            [_multiTapDelegate strikeNotIntended:self cursorContext:cursorContext];
    }
    [intentStrikeCheck setCheckStartTime:[NSDate date]];
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:_intentionalStrikeChecks];
    [tmpDict setObject:intentStrikeCheck forKey:cursorContext];
    _intentionalStrikeChecks = [NSDictionary dictionaryWithDictionary:tmpDict];
}

- (void)removeCursorContext:(id)cursorContext
{
    [super removeCursorTracking:cursorContext];
    if (![_intentionalStrikeChecks count])
        return;
    
    OLKIntentStrikeCheck *intentStrikeCheck = [_intentionalStrikeChecks objectForKey:cursorContext];
    if (!intentStrikeCheck)
        return;
    
    [self removeIntentStrikeCheck:cursorContext];
    if ([intentStrikeCheck state] == OLKIntentStrikeCheckStateNonIntended || [intentStrikeCheck state] == OLKIntentStrikeCheckStateConfirmed)
        return;
    
    if ([_multiTapDelegate respondsToSelector:@selector(strikeFollowedByCursorRemoval:cursorContext:)])
        [_multiTapDelegate strikeFollowedByCursorRemoval:self cursorContext:cursorContext];
}

- (void)removeIntentStrikeCheck:(id)cursorContext
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:_intentionalStrikeChecks];
    [newDict removeObjectForKey:cursorContext];
    if ([newDict count] < [_intentionalStrikeChecks count])
        _intentionalStrikeChecks = [NSDictionary dictionaryWithDictionary:newDict];

    [self resetCurrentCursorTracking:cursorContext];
}

- (void)setCursorTracking:(NSPoint)cursorPos withHandView:(NSView<OLKHandContainer> *)cursorContext
{
    int selectedIndexBefore = [super selectedIndex:cursorContext];
    OLKRepeatTracker *repeatTrack = [super repeatTrackerFor:cursorContext];
    int repeatCountBefore = repeatTrack.repeatedCount;
    BOOL repeatingBefore = repeatTrack.isRepeating;
    
    [super setCursorTracking:cursorPos withHandView:cursorContext];

    OLKIntentStrikeCheck *intentStrikeCheck = [_intentionalStrikeChecks objectForKey:cursorContext];
    
    if (selectedIndexBefore == OLKOptionMultiInputInvalidSelection && [super selectedIndex:cursorContext] != OLKOptionMultiInputInvalidSelection)
    {
        [self startIntentionalStrikeCheck:cursorPos cursorContext:cursorContext];
        return;
    }

    if (repeatCountBefore && repeatingBefore)
    {
        if (!repeatTrack.isRepeating)
            [self removeIntentStrikeCheck:cursorContext];
        return;
    }
    
    if (!repeatCountBefore && repeatTrack.repeatedCount)
    {
        [intentStrikeCheck setState:OLKIntentStrikeCheckStateRepeat];
        if ([_multiTapDelegate respondsToSelector:@selector(strikeConfirmed:cursorContext:)])
            [_multiTapDelegate strikeConfirmed:self cursorContext:cursorContext];
        return;
    }

    if (!intentStrikeCheck)
        return;

    [self updateIntentionalStrikeCheck:cursorPos cursorContext:cursorContext intentStrikeCheck:intentStrikeCheck];
    if ([intentStrikeCheck state] == OLKIntentStrikeCheckStateNonIntended || [intentStrikeCheck state] == OLKIntentStrikeCheckStateConfirmed)
        [self removeIntentStrikeCheck:cursorContext];
}


@end
