//
//  OLKGeometryHelper.h
//  
//
//  Created by Tyler Zetterstrom on 2014-03-05.
//  Copyright (c) 2014 Tyler Zetterstrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLKGeometryHelper : NSObject

+ (float)angleBetweenPoints:(NSPoint)point1 point2:(NSPoint)point2;
+ (float)absAngleBetweenPoints:(NSPoint)point1 point2:(NSPoint)point2;
+ (NSPoint)intersectPoint:(NSPoint)line1Point1 line1Point2:(NSPoint)line1Point2 line2Point1:(NSPoint)line2Point1 line2Point2:(NSPoint)line2Point2;
+ (BOOL)pointOnSegment:(NSPoint)linePoint1 linePoint2:(NSPoint)linePoint2 checkPoint:(NSPoint)checkPoint;
+ (bool)isLeftOfLine:(NSPoint)linePoint1 linePoint2:(NSPoint)linePoint2 checkPoint:(NSPoint)checkPoint;
+ (float)distFromPoint:(NSPoint)position toPoint:(NSPoint)toPoint;
+ (NSArray *)equidistantBezierPositions:(NSBezierPath *)bezierPath count:(int)count distBetween:(float *)distBetween;
+ (NSArray *)retrievePointsAndDistsForCurveToPoints:(NSPoint)beginPoint endPoint:(NSPoint)endPoint ctlPoint1:(NSPoint)ctlPoint1 ctlPoint2:(NSPoint)ctlPoint2 totalDist:(float *)pTotalDist;
+ (CGFloat)bezierInterpolation:(CGFloat)t a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d;
+ (CGFloat)altBezierInterpolation:(CGFloat)t a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d;
+ (CGFloat)bezierTangent:(CGFloat)t a:(CGFloat)a b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d;

@end
