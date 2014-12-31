//
//  TurretCannonView.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "TurretCannonView.h"

@interface TurretCannonView()

@property(nonatomic, assign) CGPoint centerPoint;
@property(nonatomic, strong) NSTimer *turretTimer;
@property(nonatomic, strong) NSString *moveDirection;

@end

@implementation TurretCannonView


-(void)viewAppeared {
    self.centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.layer.borderWidth = 4;
    self.layer.cornerRadius = 25;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.slider.layer.cornerRadius = 25;
    self.turretTimer = nil;
    self.moveDirection = @"None";
}

-(void) rawTouchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    NSLog(@"Raw Touch: %@", eventName);
    [self moveViews:eventName withX:eventX withY:eventY];
    
    if ([eventName isEqualToString:@"BEGAN"]) {
        if (self.turretTimer == nil) {
            self.turretTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendMoveMessage:) userInfo:nil repeats:true];
        }
        [self updateMoveStatusWithX:eventX andY:eventY];
        [self sendMoveMessage:self.turretTimer];
    } else if ([eventName isEqualToString:@"MOVED"]) {
        [self updateMoveStatusWithX:eventX andY:eventY];
    } else { // CANCELLED OR ENDED
        [self.turretTimer invalidate];
        self.turretTimer = nil;
        self.moveDirection = @"None";
    }
}

-(void)updateMoveStatusWithX:(NSInteger)x andY:(NSInteger)y {
    if (ABS(x - self.centerPoint.x) > ABS(y - self.centerPoint.y)) {
        self.moveDirection = (x - self.centerPoint.x > 0) ? @"Right" : @"Left";
    } else {
        self.moveDirection = (y - self.centerPoint.y > 0) ? @"Down" : @"Up";
    }
    NSLog(@"UpdateMoveStatus: %@", self.moveDirection);
}

-(void)sendMoveMessage:(NSTimer *)timer {
    NSLog(@"SendMoveMessage: %@", self.moveDirection);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TurretMove" object:[NSDictionary dictionaryWithObject:self.moveDirection forKey:@"Direction"]];
}

-(void)moveViews:(NSString *)eventName withX:(NSInteger)x withY:(NSInteger)y {
    if ([eventName isEqualToString:@"ENDED"] || [eventName isEqualToString:@"CANCELLED"]) {
        y = self.centerPoint.y;
        x = self.centerPoint.x;
    }
    if (ABS(x - self.centerPoint.x) > ABS(y - self.centerPoint.y)) {
        y = self.centerPoint.y;
    } else {
        x = self.centerPoint.x;
    }
    
    CGRect sliderRect = self.slider.frame;
    CGRect horizGuideRect = self.horizontalGuide.frame;
    CGRect vertGuideRect = self.verticalGuide.frame;
    sliderRect.origin.y = y - (sliderRect.size.height / 2);
    sliderRect.origin.x = x - (sliderRect.size.width / 2);
    horizGuideRect.origin.y = y - (horizGuideRect.size.height / 2);
    vertGuideRect.origin.x = x - (vertGuideRect.size.width / 2);
    self.slider.frame = [self minMax:sliderRect];
    self.horizontalGuide.frame = [self minMax:horizGuideRect];
    self.verticalGuide.frame = [self minMax:vertGuideRect];
}

-(CGRect)minMax:(CGRect)rect {
    //  Tweak the x and y val to make sense given rect's size, and the size of our view.
    CGRect rval = rect;
    NSInteger minX = - (rect.size.width / 2);
    NSInteger minY = - (rect.size.height / 2);
    NSInteger maxX = self.frame.size.width - (rect.size.width / 2);
    NSInteger maxY = self.frame.size.height - (rect.size.height / 2);
    rval.origin.x = rect.origin.x <= minX ? minX : rect.origin.x >= maxX ? maxX : rect.origin.x;
    rval.origin.y = rect.origin.y <= minY ? minY : rect.origin.y >= maxY ? maxY : rect.origin.y;
    
    return rval;
}

@end
