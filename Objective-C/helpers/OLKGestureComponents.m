//
//  OLKGestureComponents.m
//  LeapEdit
//
//  Created by Tyler Zetterstrom on 2013-07-05.
//
//

#import "OLKGestureComponents.h"

@implementation OLKGestureComponents

#pragma mark -
#pragma single hand components

+ (BOOL)handUpright:(LeapHand *)hand normalTolerance:(float)normalTolerance
{
    LeapVector *palmNormal = [hand palmNormal];
    if (palmNormal.y < normalTolerance && palmNormal.y > -normalTolerance)
        return YES;
    
    return NO;
}

+ (BOOL)handPalmDown:(LeapHand *)hand normalTolerance:(float)normalTolerance
{
    LeapVector *palmNormal = [hand palmNormal];
    
    if (palmNormal.y < -1 + normalTolerance)
        return TRUE;
    return NO;

}



#pragma mark -
#pragma two hand components

+ (NSArray*)handArraySortedFromHands:(LeapHand *)hand1 otherHand:(LeapHand*)hand2
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

+ (LeapVector*)handsMidPoint:(LeapHand *)hand1 otherHand:(LeapHand *)hand2
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

+ (BOOL)handsFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance
{
    // TODO: need to fix this, as the normals could be below the normal tolerance where one axis has a very little component, making it indistinguishable from facing or same direction.
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (fabs(palmNormal.x + compPalmNormal.x) < normalTolerance && fabs(palmNormal.y - compPalmNormal.y) < normalTolerance
        && fabs(palmNormal.z-compPalmNormal.z) < normalTolerance)
        return YES;
    
    return NO;
}

+ (BOOL)handsFacingSame:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance
{
    // TODO: need to fix this, as the normals could be below the normal tolerance where one axis has a very little component, making it indistinguishable from facing or same direction.
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmNormal = [hand1 palmNormal];
    LeapVector *compPalmNormal = [hand2 palmNormal];
    
    if (fabs(palmNormal.x - compPalmNormal.x) < normalTolerance && fabs(palmNormal.y - compPalmNormal.y) < normalTolerance
        && fabs(palmNormal.z-compPalmNormal.z) < normalTolerance)
        return YES;
    
    return NO;
}

+ (BOOL)handsUpright:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance
{
    LeapVector *palmNormal = [hand1 palmNormal];
    if (palmNormal.x > normalTolerance || palmNormal.x < normalTolerance)
        return YES;

    return NO;
}

+ (BOOL)handsPalmDown:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance
{
    if ([self handPalmDown:hand1 normalTolerance:normalTolerance] && [self handPalmDown:hand2 normalTolerance:normalTolerance])
        return TRUE;
    
    return FALSE;
}

+ (BOOL)handsBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 maxProximity:(float)maxProximity sameAxisTolerance:(float)sameAxisTolerance
{
    if ([hand1 identifier] == [hand2 identifier])
        return NO;
    
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];
    
    if (maxProximity != 0 && fabs(palmPos.x - compPalmPos.x) > maxProximity)
        return NO;
    
    if (fabs(palmPos.y - compPalmPos.y) < sameAxisTolerance
        && fabs(palmPos.z-compPalmPos.z) < sameAxisTolerance)
        return YES;
    
    return NO;
}

+ (BOOL)handsNotFurtherThan:(float)cubeDistance hand:(LeapHand*)hand1 otherHand:(LeapHand*)hand2
{
    LeapVector *palmPos = [hand1 palmPosition];
    LeapVector *compPalmPos = [hand2 palmPosition];
    if (fabs(palmPos.x - compPalmPos.x) < cubeDistance && fabs(palmPos.y - compPalmPos.y) < cubeDistance && fabs(palmPos.z - compPalmPos.z) < cubeDistance)
        return TRUE;
    
    return FALSE;
}



#pragma mark -
#pragma two hand complex components

+ (BOOL)handsClamped:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 cubeDistance:(float)cubeDistance normalTolerance:(float)normalTolerance
{
    if ([self handsNotFurtherThan:cubeDistance hand:hand1 otherHand:hand2])
        if ([self handsFacing:hand1 otherHand:hand2 normalTolerance:normalTolerance] ||
            [self handsFacingSame:hand1 otherHand:hand2 normalTolerance:normalTolerance])
        return TRUE;
    
    return FALSE;
}

+ (BOOL)handsUprightAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 normalTolerance:(float)normalTolerance
{
    if ([self handsFacing:hand1 otherHand:hand2 normalTolerance:normalTolerance])
    {
        if ([self handUpright:hand1 normalTolerance:normalTolerance])
            return YES;
    }
    return NO;
}

+ (BOOL)handsClampedAndFacing:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 cubeDistance:(float)cubeDistance normalTolerance:(float)normalTolerance
{
    if ([self handsFacing:hand1 otherHand:hand2 normalTolerance:normalTolerance])
    {
        if ([self handsClamped:hand1 otherHand:hand2 cubeDistance:cubeDistance normalTolerance:normalTolerance])
            return TRUE;
    }
    return FALSE;
}

+ (BOOL)handsPalmDownAndBeside:(LeapHand *)hand1 otherHand:(LeapHand *)hand2 maxProximity:(float)maxProximity normalTolerance:(float)normalTolerance sameAxisTolerance:(float)sameAxisTolerance
{
    if ([self handsPalmDown:hand1 otherHand:hand2 normalTolerance:normalTolerance])
    {
        if ([self handsBeside:hand1 otherHand:hand2 maxProximity:maxProximity sameAxisTolerance:sameAxisTolerance])
            return TRUE;
    }
    return FALSE;
}


@end
