//
//  OLKGeometryHelper.m
//
//  Created by Tyler Zetterstrom on 2014-03-05.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import "OLKGeometryHelper.h"

@implementation OLKGeometryHelper

+ (float)angleBetweenPoints:(NSPoint)point1 point2:(NSPoint)point2
{
    float mag = point1.x*point2.y - point1.y*point2.x;
    float angle = [self absAngleBetweenPoints:point1 point2:point2];
    if (mag < 0)
        angle = 2*M_PI-angle;
    return angle;
}

+ (float)absAngleBetweenPoints:(NSPoint)point1 point2:(NSPoint)point2
{
    float aDotB = point1.x*point2.x+point1.y*point2.y;
    float magA = sqrtf(point1.x*point1.x+point1.y*point1.y);
    float magB = sqrtf(point2.x*point2.x+point2.y*point2.y);
    float angle = acos(aDotB/(magA*magB));
    
    return angle;
}

+ (BOOL)pointOnSegment:(NSPoint)linePoint1 linePoint2:(NSPoint)linePoint2 checkPoint:(NSPoint)checkPoint
{
    if (linePoint1.x > linePoint2.x)
    {
        if (checkPoint.x < linePoint2.x || checkPoint.x > linePoint1.x)
            return NO;
    }
    else if (checkPoint.x < linePoint1.x || checkPoint.x > linePoint2.x)
        return NO;
    
    if (linePoint1.y > linePoint2.y)
    {
        if (checkPoint.y < linePoint2.y || checkPoint.y > linePoint1.y)
            return NO;
    }
    else if (checkPoint.y < linePoint1.y || checkPoint.y > linePoint2.y)
        return NO;
    return YES;
}

+ (bool)isLeftOfLine:(NSPoint)linePoint1 linePoint2:(NSPoint)linePoint2 checkPoint:(NSPoint)checkPoint
{
    return ((linePoint2.x - linePoint1.x)*(checkPoint.y - linePoint1.y) - (linePoint2.y - linePoint1.y)*(checkPoint.x - linePoint1.x)) > 0;
}

+ (NSPoint)intersectPointVertLine:(float)horizLineX line2Point1:(NSPoint)line2Point1 line2Point2:(NSPoint)line2Point2
{
    NSPoint intersectPoint;
    float slopeLine2 = line2Point2.y - line2Point1.y;
    slopeLine2 /= line2Point2.x - line2Point1.x;

    intersectPoint.x = horizLineX;
    intersectPoint.y = slopeLine2*(horizLineX-line2Point1.x) + line2Point1.y;
    return intersectPoint;
}

+ (NSPoint)intersectPoint:(NSPoint)line1Point1 line1Point2:(NSPoint)line1Point2 line2Point1:(NSPoint)line2Point1 line2Point2:(NSPoint)line2Point2
{
    NSPoint intersectPoint;
    if (line1Point2.x - line1Point1.x == 0)
        return [self intersectPointVertLine:line1Point2.x line2Point1:line2Point1 line2Point2:line2Point2];
    else if (line2Point2.x - line2Point1.x == 0)
        return [self intersectPointVertLine:line2Point2.x line2Point1:line1Point1 line2Point2:line1Point2];

    float slopeLine1 = line1Point2.y - line1Point1.y;
    slopeLine1 /= line1Point2.x - line1Point1.x;
    float slopeLine2 = line2Point2.y - line2Point1.y;
    slopeLine2 /= line2Point2.x - line2Point1.x;

    intersectPoint.x = line2Point1.y - line1Point1.y + slopeLine1*line1Point1.x - slopeLine2*line2Point1.x;
    intersectPoint.x /= slopeLine1 - slopeLine2;
    intersectPoint.y = slopeLine1*(intersectPoint.x-line1Point1.x)+line1Point1.y;
    return intersectPoint;
}

+ (float)distFromPoint:(NSPoint)position toPoint:(NSPoint)toPoint
{
    return sqrtf((position.x - toPoint.x)*(position.x - toPoint.x) + (position.y - toPoint.y)*(position.y - toPoint.y));
}

+ (BOOL)pointBetweenPointsOnLine:(NSPoint)point endPoint1:(NSPoint)endPoint1 endPoint2:(NSPoint)endPoint2
{
    if ((endPoint1.x < point.x && endPoint2.x < point.x) || (endPoint1.x > point.x && endPoint2.x > point.x)
        || (endPoint1.y < point.y && endPoint2.y < point.y) || (endPoint1.y > point.y && endPoint2.y > point.y))
        return NO;
    return YES;
}

+ (NSArray *)equidistantBezierPositions:(NSBezierPath *)bezierPath count:(int)count distBetween:(float *)distBetween
{
    if (!bezierPath.elementCount)
        return nil;
    
    NSPoint points[3];
    NSBezierPathElement element;
    NSMutableArray *polyPointsAndDists = [[NSMutableArray alloc] initWithCapacity:1000];
    NSPoint curPoint;
    float totalDist = 0;
    for (int i=0; i<bezierPath.elementCount; i++)
    {
        element = [bezierPath elementAtIndex:i associatedPoints:points];
        if (element == NSLineToBezierPathElement)
        {
            [polyPointsAndDists addObjectsFromArray:[self retrievePointsAndDistsForCurveToPoints:curPoint endPoint:points[0] ctlPoint1:curPoint ctlPoint2:points[0] totalDist:&totalDist]];
            curPoint  = points[0];
        }
        else if (element == NSClosePathBezierPathElement)
            break;
        else if (element == NSCurveToBezierPathElement)
        {
            [polyPointsAndDists addObjectsFromArray:[self retrievePointsAndDistsForCurveToPoints:curPoint endPoint:points[2] ctlPoint1:points[0] ctlPoint2:points[1] totalDist:&totalDist]];
            curPoint = points[2];
        }
        else if (element == NSMoveToBezierPathElement)
        {
            if (polyPointsAndDists.count)
                break;
            curPoint = points[0];
        }
    }
    
    
    NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:count];
    float distBetweenPositions = totalDist/count;
    float curDist = distBetweenPositions / 2;
    NSArray *prevPolyPointAndDist=nil;
    for (NSArray *polyPointAndDist in polyPointsAndDists) {
        curDist += [[polyPointAndDist objectAtIndex:1] floatValue];
        if (curDist >= distBetweenPositions)
        {
            [positions addObject:[polyPointAndDist objectAtIndex:0]];
            curDist = 0;
        }
        prevPolyPointAndDist = polyPointAndDist;
    }
    if (positions.count<count && prevPolyPointAndDist)
        [positions addObject:[prevPolyPointAndDist objectAtIndex:0]];
    
    *distBetween = distBetweenPositions;
    
    return [positions copy];
}

+ (NSArray *)retrievePointsAndDistsForCurveToPoints:(NSPoint)beginPoint endPoint:(NSPoint)endPoint ctlPoint1:(NSPoint)ctlPoint1 ctlPoint2:(NSPoint)ctlPoint2 totalDist:(float *)pTotalDist
{
    BOOL firstPos=YES;
    NSPoint prevPoint;
    
    NSMutableArray *polyPointsAndDists = [[NSMutableArray alloc] initWithCapacity:1000];
    for (CGFloat t = 0.0; t <= 1.00001; t += 1.0/1000) {
        
        CGPoint point = CGPointMake(
                                    [self bezierInterpolation:t a:beginPoint.x b:ctlPoint1.x c:ctlPoint2.x d:endPoint.x],
                                    [self bezierInterpolation:t a:beginPoint.y b:ctlPoint1.y c:ctlPoint2.y d:endPoint.y]);
        
        float dist;
        if (firstPos)
        {
            firstPos = NO;
            dist = 0;
        }
        else
            dist = sqrtf((point.x-prevPoint.x)*(point.x-prevPoint.x) + (point.y-prevPoint.y)*(point.y-prevPoint.y));
        
        *pTotalDist += dist;
        
        [polyPointsAndDists addObject:[NSArray arrayWithObjects:[NSValue valueWithPoint:point], [NSNumber numberWithFloat:dist], nil]];
        prevPoint = point;
    }
    return [polyPointsAndDists copy];
}

+ (CGFloat)bezierInterpolation:(CGFloat)t a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d
{
    // see also below for another way to do this, that follows the 'coefficients'
    // idea, and is a little clearer
    CGFloat t2 = t * t;
    CGFloat t3 = t2 * t;
    return a + (-a * 3 + t * (3 * a - a * t)) * t
    + (3 * b + t * (-6 * b + b * 3 * t)) * t
    + (c * 3 - c * 3 * t) * t2
    + d * t3;
}

+ (CGFloat)bezierTangent:(CGFloat)t a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d
{
    // note that abcd are aka x0 x1 x2 x3
    
    /*  the four coefficients ..
     A = x3 - 3 * x2 + 3 * x1 - x0
     B = 3 * x2 - 6 * x1 + 3 * x0
     C = 3 * x1 - 3 * x0
     D = x0
     
     and then...
     Vx = 3At2 + 2Bt + C         */
    
    // first calcuate what are usually know as the coeffients,
    // they are trivial based on the four control points:
    
    CGFloat C1 = ( d - (3.0 * c) + (3.0 * b) - a );
    CGFloat C2 = ( (3.0 * c) - (6.0 * b) + (3.0 * a) );
    CGFloat C3 = ( (3.0 * b) - (3.0 * a) );
    CGFloat C4 = ( a );  // (not needed for this calculation)
    
    // finally it is easy to calculate the slope element, using those coefficients:
    
    return ( ( 3.0 * C1 * t* t ) + ( 2.0 * C2 * t ) + C3 );
    
    // note that this routine works for both the x and y side;
    // simply run this routine twice, once for x once for y
    // note that there are sometimes said to be 8 (not 4) coefficients,
    // these are simply the four for x and four for y, calculated as above in each case.
}

+ (CGFloat)altBezierInterpolation:(CGFloat)t a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d
{
    // here's an alternative to Michal's bezierInterpolation above.
    // the result is identical.
    // of course, you could calculate the four 'coefficients' only once for
    // both this and the slope calculation
    CGFloat C1 = ( d - (3.0 * c) + (3.0 * b) - a );
    CGFloat C2 = ( (3.0 * c) - (6.0 * b) + (3.0 * a) );
    CGFloat C3 = ( (3.0 * b) - (3.0 * a) );
    CGFloat C4 = ( a );
    
    // it's now easy to calculate the point, using those coefficients:
    return ( C1*t*t*t + C2*t*t + C3*t + C4  );
}

@end
