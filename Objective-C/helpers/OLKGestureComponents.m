//
//  OLKGestureComponents.m
//  LeapEdit
//
//  Created by Tyler Zetterstrom on 2013-07-05.
//
//

#import "OLKGestureComponents.h"


@implementation OLKGestureComponents

@synthesize usingInteractionBox = _usingInteractionBox;
@synthesize usingStabilizedPalm = _usingStabilizedPalm;

- (id)init
{
    if (self = [super init])
    {
        _usingStabilizedPalm = NO;
        _usingInteractionBox = NO;
    }
    return self;
}

#pragma mark -
#pragma single hand components

- (BOOL)palmAimingLeft:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.x < -normalThreshold)
        return TRUE;
    return NO;
}

- (BOOL)palmAimingRight:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.x > normalThreshold)
        return TRUE;
    return NO;
}

- (BOOL)palmAimingSideway:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    if (palmNormal.x > normalThreshold || palmNormal.x < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmAimingIn:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.z < -normalThreshold)
        return TRUE;
    return NO;
}

- (BOOL)palmAimingOut:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.z > normalThreshold)
        return TRUE;
    return NO;
}

- (BOOL)palmAimingInOrOut:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    if (palmNormal.y > normalThreshold || palmNormal.y < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmUp:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.y > normalThreshold)
        return TRUE;
    return NO;
    
}

- (BOOL)palmDown:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.y < -normalThreshold)
        return TRUE;
    return NO;
    
}

- (BOOL)palmAimingUpOrDown:(LeapHand *)hand normalThreshold:(float)normalThreshold
{
    LeapVector *palmNormal = [hand palmNormal];
    if (palmNormal.z > normalThreshold || palmNormal.z < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)handBeyondThreshold:(float)threshold inDirMinus:(BOOL)inDirMinus hand:(LeapHand *)hand
{
    if (hand == nil)
        return NO;
    
    LeapVector *position;
    if (_usingStabilizedPalm)
        position = [hand stabilizedPalmPosition];
    else
        position = [hand palmPosition];
    
    if (_usingInteractionBox)
    {
        LeapFrame *frame = [hand frame];
        LeapInteractionBox *interactionBox = [frame interactionBox];
        position = [interactionBox normalizePoint:position clamp:YES];
    }
    
    if (inDirMinus)
    {
        if (position.z >= threshold)
            return NO;
    }
    else
        if (position.z <= threshold)
            return NO;
    
    return YES;
}


#pragma mark -
#pragma single hand combo components

- (BOOL)handBeyondThresholdPalmDown:(float)threshold inDirMinus:(BOOL)inDirMinus hand:(LeapHand *)hand normalThreshold:(float)normalThreshold // frame:(LeapFrame *)frame
{
    if (![self handBeyondThreshold:threshold inDirMinus:inDirMinus hand:hand])
        return NO;

    return [self palmDown:hand normalThreshold:normalThreshold];
}


#pragma mark -
#pragma two hand components

- (NSArray*)handArraySortedFromHands:(LeapHand *)hand1 otherHand:(LeapHand*)hand2
{
    if ([hand1 identifier] > [hand2 identifier])
    {
        LeapHand *handSwap = hand1;
        hand1 = hand2;
        hand2 = handSwap;
    }
    NSArray *hands = [NSArray arrayWithObjects:hand1, hand2, nil];
    return hands;
}

- (LeapVector*)handsMidPoint:(LeapHand *)hand1 otherHand:(LeapHand *)hand2
{
    if ([hand1 identifier] == [hand2 identifier])
        return nil;
    
    float xdif = ([hand1 palmPosition].x - [hand2 palmPosition].x);
    float x = [hand1 palmPosition].x - xdif/2.0;
    float ydif = ([hand1 palmPosition].y - [hand2 palmPosition].y);
    float y = [hand1 palmPosition].y - ydif/2.0;
    float zdif = ([hand1 palmPosition].z - [hand2 palmPosition].z);
    float z = [hand1 palmPosition].z-zdif/2.0;
    return [[LeapVector alloc] initWithX:x y:y z:z];
}

// TODO: This assumes facing on one of the three axis, need to change to work for an arbitrary direction. Need to rotate one hand to a known axis, then apply this rotation to the other, then check the normal threshold against this.
- (BOOL)palmsFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (palmNormal.x > normalThreshold && compPalmNormal.x < -normalThreshold)
        return YES;
    
    if (compPalmNormal.x > normalThreshold && palmNormal.x < -normalThreshold)
        return YES;
    
    if (palmNormal.z > normalThreshold && compPalmNormal.z < -normalThreshold)
        return YES;
    
    if (compPalmNormal.z > normalThreshold && palmNormal.z < -normalThreshold)
        return YES;
    
    if (palmNormal.y > normalThreshold && compPalmNormal.y < -normalThreshold)
        return YES;
    
    if (compPalmNormal.y > normalThreshold && palmNormal.y < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmsSidewayAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (palmNormal.x > normalThreshold && compPalmNormal.x < -normalThreshold)
        return YES;
    
    if (compPalmNormal.x > normalThreshold && palmNormal.x < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmsSidewayAndFacingSame:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (palmNormal.x > normalThreshold && compPalmNormal.x > normalThreshold)
        return YES;
    
    if (compPalmNormal.x < -normalThreshold && palmNormal.x < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmsInOutAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (palmNormal.z > normalThreshold && compPalmNormal.z < -normalThreshold)
        return YES;
    
    if (compPalmNormal.z > normalThreshold && palmNormal.z < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmsUpDownAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (palmNormal.y > normalThreshold && compPalmNormal.y < -normalThreshold)
        return YES;
    
    if (compPalmNormal.y > normalThreshold && palmNormal.y < -normalThreshold)
        return YES;
    
    return NO;
}

// TODO: This assumes facing on one of the three axis, need to change to work for an arbitrary direction. Need to rotate one hand to a known axis, then apply this rotation to the other, then check the normal threshold against this.
- (BOOL)palmsFacingSame:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (palmNormal.x > normalThreshold && compPalmNormal.x > normalThreshold)
        return YES;
    
    if (compPalmNormal.x < -normalThreshold && palmNormal.x < -normalThreshold)
        return YES;
    
    if (palmNormal.z > normalThreshold && compPalmNormal.z > normalThreshold)
        return YES;
    
    if (compPalmNormal.z < -normalThreshold && palmNormal.z < -normalThreshold)
        return YES;
    
    if (palmNormal.y > normalThreshold && compPalmNormal.y > normalThreshold)
        return YES;
    
    if (compPalmNormal.y < -normalThreshold && palmNormal.y < -normalThreshold)
        return YES;
    
    return NO;
}

- (BOOL)palmsAimingSideway:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([self palmAimingSideway:hand1 normalThreshold:normalThreshold] && [self palmAimingSideway:hand2 normalThreshold:normalThreshold])
        return YES;
    
    return NO;
}

- (BOOL)palmsDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold
{
    if ([self palmDown:hand1 normalThreshold:normalThreshold] && [self palmDown:hand2 normalThreshold:normalThreshold])
        return TRUE;
    
    return FALSE;
}

- (BOOL)handsBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 axisTolerance:(float)axisTolerance
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];

    if (fabs(palmPos.y - compPalmPos.y) < axisTolerance
        && fabs(palmPos.z-compPalmPos.z) < axisTolerance)
        return YES;
    
    return NO;
}

- (BOOL)handsInProximity:(float)proximity hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2
{
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];
    
    if (fabs(palmPos.x - compPalmPos.x) < proximity && fabs(palmPos.y - compPalmPos.y) < proximity && fabs(palmPos.z - compPalmPos.z) < proximity)
        return TRUE;
    
    return FALSE;
}

- (BOOL)handsCloserThan:(float)proximity hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2
{
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];

    float dist = (palmPos.x - compPalmPos.x)*(palmPos.x - compPalmPos.x) + (palmPos.y - compPalmPos.y)*(palmPos.y - compPalmPos.y) + (palmPos.z - compPalmPos.z)*(palmPos.z - compPalmPos.z);
    dist = sqrtf(dist);
    
    if (dist < proximity)
        return TRUE;
    
    return FALSE;
}

- (BOOL)handsFurtherThan:(float)proximity hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2
{
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];
    
    float dist = (palmPos.x - compPalmPos.x)*(palmPos.x - compPalmPos.x) + (palmPos.y - compPalmPos.y)*(palmPos.y - compPalmPos.y) + (palmPos.z - compPalmPos.z)*(palmPos.z - compPalmPos.z);
    dist = sqrtf(dist);
    
    if (dist > proximity)
        return TRUE;
    
    return FALSE;
}

// TODO: This assumes facing on one of the three axis, need to change to work for an arbitrary direction. Need to rotate one hand to a known axis, then apply this rotation to the other, then check the normal threshold against this.
- (BOOL)handsClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self handsInProximity:proximity hand:hand1 otherHand:hand2])
        if ([self palmsFacing:hand1 otherHand:hand2 normalThreshold:normalThreshold] ||
            [self palmsFacingSame:hand1 otherHand:hand2 normalThreshold:normalThreshold])
            return TRUE;
    
    return FALSE;
}



#pragma mark -
#pragma two hand complex components


// TODO: This assumes facing on one of the three axis, need to change to work for an arbitrary direction. Need to rotate one hand to a known axis, then apply this rotation to the other, then check the normal threshold against this.
- (BOOL)handsSpreadPalmsParallel:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 spread:(float)spread axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self handsFurtherThan:spread hand:hand1 otherHand:hand2])
        if ([self palmsFacing:hand1 otherHand:hand2 normalThreshold:normalThreshold] ||
            [self palmsFacingSame:hand1 otherHand:hand2 normalThreshold:normalThreshold])
            return TRUE;
    
    return FALSE;
}

- (BOOL)handsInProximityBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];
    
    if (proximity != 0 && fabs(palmPos.x - compPalmPos.x) > proximity)
        return NO;
    
    if (fabs(palmPos.y - compPalmPos.y) < axisTolerance
        && fabs(palmPos.z-compPalmPos.z) < axisTolerance)
        return YES;
    
    return NO;
}

// TODO: This assumes facing on one of the three axis, need to change to work for an arbitrary direction. Need to rotate one hand to a known axis, then apply this rotation to the other, then check the normal threshold against this.
- (BOOL)palmsClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsFacing:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if ([self handsClamped:hand1 otherHand:hand2 proximity:proximity axisTolerance:axisTolerance normalThreshold:normalThreshold])
            return TRUE;
    }
    return FALSE;
}

- (BOOL)handsBesideAndPalmsDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalThreshold:(float)normalThreshold axisTolerance:(float)axisTolerance
{
    if ([self palmsDown:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if ([self handsBeside:hand1 otherHand:hand2 axisTolerance:axisTolerance])
            return TRUE;
    }
    return FALSE;
}

- (BOOL)handsSidewayClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsAimingSideway:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if (fabsf([hand1 palmPosition].x - [hand2 palmPosition].x) < proximity)
            return TRUE;
    }
    return FALSE;
}

- (BOOL)handsInProximityBesideAndPalmsDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity normalThreshold:(float)normalThreshold axisTolerance:(float)axisTolerance
{
    if ([self palmsDown:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if ([self handsInProximityBeside:hand1 otherHand:hand2 proximity:proximity axisTolerance:axisTolerance])
            return TRUE;
    }
    return FALSE;
}

- (BOOL)palmsBesideAimingSideway:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsAimingSideway:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if ([self handsBeside:hand1 otherHand:hand2 axisTolerance:axisTolerance])
            return YES;
    }
    return NO;
}

- (BOOL)palmsBesideAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsSidewayAndFacing:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if ([self handsBeside:hand1 otherHand:hand2 axisTolerance:axisTolerance])
            return YES;
    }
    return NO;
}

- (BOOL)palmsSidewayClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 proximity:(float)proximity axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsSidewayAndFacing:hand1 otherHand:hand2 normalThreshold:normalThreshold])
    {
        if (fabsf([hand1 palmPosition].x - [hand2 palmPosition].x) < proximity)
            return TRUE;
    }
    return FALSE;
}

- (BOOL)palmsSpreadBesideAimingSideway:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 spread:(float)spread axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsBesideAimingSideway:hand1 otherHand:hand2 axisTolerance:axisTolerance normalThreshold:normalThreshold])
    {
        if (fabsf([hand1 palmPosition].x - [hand2 palmPosition].x) > spread)
            return TRUE;
    }
    return FALSE;
}

- (BOOL)palmsSpreadBesideAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 spread:(float)spread axisTolerance:(float)axisTolerance normalThreshold:(float)normalThreshold
{
    if ([self palmsBesideAndFacing:hand1 otherHand:hand2 axisTolerance:axisTolerance normalThreshold:normalThreshold])
    {
        if (fabsf([hand1 palmPosition].x - [hand2 palmPosition].x) > spread)
            return TRUE;
    }
    return FALSE;
}


@end
