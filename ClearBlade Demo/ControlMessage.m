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

-(void)sendMessageNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpeedAndDirection" object:self];
}

-(void)generateMessageFromSingleInput:(NSString *)messageName withSpeed:(NSInteger)speed withDirection:(NSInteger)direction {
    self.name = messageName;
    self.speed = speed;
    self.direction = direction;
    [self sendMessageNotification];
}

-(void)generateMessageFromDualInput:(NSString *)messageName withLeft:(NSInteger)left withRight:(NSInteger)right {
    self.name = messageName;
    self.speed = (left + right) / 2;
    self.direction = ((self.speed >= 0) ? 1 : -1) * ((left - right) / 2);
    NSLog(@"Left: %ld, Right: %ld, Speed: %ld, Direction %ld", left, right, self.speed, self.direction);
    [self sendMessageNotification];
}

-(NSDictionary *)asDict {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.speed], @"Speed",
            [NSNumber numberWithInteger:self.direction], @"Direction", nil];
}

@end
