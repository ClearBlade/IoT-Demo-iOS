//
//  ControlMessage.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "ControlMessage.h"

@interface ControlMessage()

@end

@implementation ControlMessage

-(id)init {
    self = [super init];
    self.name = nil;
    self.speed = 0;
    self.direction = 0;
    return self;
}

+(void)generateMessageFromSingleInput:(NSString *)messageName withSpeed:(NSInteger)speed withDirection:(NSInteger)direction {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"Name"] = messageName;
    msg[@"Speed"] = [NSNumber numberWithInteger:speed];
    msg[@"Direction"] = [NSNumber numberWithInteger:direction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpeedAndDirection" object:msg];
}

+(void)generateMessageFromDualInput:(NSString *)messageName withLeft:(NSInteger)left withRight:(NSInteger)right {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"Name"] = messageName;
    NSInteger speed = (left + right) / 2;
    NSInteger direction = ((speed >= 0) ? 1 : -1) * ((left - right) / 2);
    NSLog(@"Left: %ld, Right: %ld, Speed: %ld, Direction %ld", left, right, speed, direction);
    msg[@"Speed"] = [NSNumber numberWithInteger:speed];
    msg[@"Direction"] = [NSNumber numberWithInteger:direction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpeedAndDirection" object:msg];
}

+(void)generateFireMessage {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TurretFire" object:Nil];
}

/*
-(void)generateMessageFromDualInput:(NSString *)messageName withLeft:(NSInteger)left withRight:(NSInteger)right {
    [ControlMessage generateMessageFromDualInput:messageName withLeft:left withRight:right];
}


-(void)generateMessageFromSingleInput:(NSString *)messageName withSpeed:(NSInteger)speed withDirection:(NSInteger)direction {
    [ControlMessage generateMessageFromSingleInput:messageName withSpeed:speed withDirection:direction];
}
 */

@end
