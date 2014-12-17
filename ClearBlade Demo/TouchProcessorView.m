//
//  TouchProcessorView.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "TouchProcessorView.h"

@interface TouchProcessorView()

@property(nonatomic, assign) NSString *lastEventName;
@property(nonatomic, assign) NSInteger lastX;
@property(nonatomic, assign) NSInteger lastY;

@end

#define NUM_TIERS				(5)
#define TIER_SIZE				(20)
#define TIER_PERCENTILE			(20)
#define TIER_OFFSET(x)				((x >= 0) ? ((TIER_SIZE) / 2) : -((TIER_SIZE) / 2))

@implementation TouchProcessorView

-(BOOL)eventHasChanged:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    BOOL rval = !([eventName isEqualToString:self.lastEventName] &&
                  ((NSInteger)eventX) == ((NSInteger)self.lastX) &&
                  ((NSInteger)eventY) == ((NSInteger)self.lastY));
    if (rval) {
        self.lastEventName = eventName;
        self.lastX = eventX;
        self.lastY = eventY;
    }
    return rval;
}

-(CGPoint)convertToPercentage:(CGPoint)rawPoint {
    return CGPointMake(100.0 * (rawPoint.x / (CGFloat)self.maxX), (100.0 * (rawPoint.y / (CGFloat)self.maxY)));
}

-(CGPoint)percentToTier:(CGPoint)percentage {
    return CGPointMake((((NSInteger)(percentage.x + TIER_OFFSET(percentage.x))) / TIER_SIZE) * TIER_PERCENTILE,
                       (((NSInteger)percentage.y + TIER_OFFSET(percentage.y)) / TIER_SIZE) * TIER_PERCENTILE);
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    CGRect bounds = [self bounds];
    NSLog(@"IN VIEW: x: %f, y: %f, w: %f, h: %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    self.centerX = bounds.size.width / 2;
    self.centerY = bounds.size.height / 2;
    self.minX = - self.centerX;
    self.minY = - self.centerY;
    self.maxX = self.centerX;
    self.maxY = self.centerY;
    self.lastEventName = @"";
    self.lastX = 0;
    self.lastY = 0;
    return self;
}

-(CGPoint) sanitizedPoint:(CGPoint) transformedPoint {
    return CGPointMake (
                        transformedPoint.x < self.minX ? self.minX : transformedPoint.x > self.maxX ? self.maxX : transformedPoint.x,
                        transformedPoint.y < self.minY ? self.minY : transformedPoint.y > self.maxY ? self.maxY : transformedPoint.y
                        );
}

-(CGPoint) transformedPoint:(CGPoint) rawPoint {
    return [self sanitizedPoint:CGPointMake (rawPoint.x - self.centerX, self.centerY - rawPoint.y)];
}

-(void) logTouches:(NSSet *)touches withEvent:(UIEvent *)event withEventName:(NSString *)eventName {
    NSArray *viewTouches = [[event touchesForView:self] allObjects];
    for (int i = 0; i < [viewTouches count]; i ++) {
        UITouch *curTouch = [viewTouches objectAtIndex:i];
        CGPoint curTouchPoint = [curTouch locationInView:self];
        [self rawTouchEventOccurred:eventName withX:curTouchPoint.x withY:curTouchPoint.y];
        CGPoint touchPt = [self percentToTier:[self convertToPercentage:[self transformedPoint:[curTouch locationInView:self]]]];
        if ([self eventHasChanged:eventName withX:touchPt.x withY:touchPt.y]) {
            [self touchEventOccurred:eventName withX:touchPt.x withY:touchPt.y];
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self logTouches:touches withEvent:event withEventName:@"BEGAN"];
    // publish "motion" message
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self logTouches:touches withEvent:event withEventName:@"ENDED"];
    //  publish "freeze" message
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self logTouches:touches withEvent:event withEventName:@"MOVED"];
    // publish "motion" message
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self logTouches:touches withEvent:event withEventName:@"CANCELLED"];
    // publish "freeze" message
}

-(void)touchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    NSLog(@"TOUCH EVENT IGNORED");
}

-(void)rawTouchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    NSLog(@"RAW TOUCH EVENT IGNORED");
}

@end
