//
//  ControlMessage.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ControlMessage : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger speed;
@property (nonatomic, assign) NSInteger direction;

//-(void) generateMessageFromSingleInput:(NSString *)messageName withSpeed:(NSInteger)speed withDirection:(NSInteger)direction;
//-(void) generateMessageFromDualInput:(NSString *)messageName withLeft:(NSInteger)left withRight:(NSInteger)right;
+(void) generateMessageFromSingleInput:(NSString *)messageName withSpeed:(NSInteger)speed withDirection:(NSInteger)direction;
+(void) generateMessageFromDualInput:(NSString *)messageName withLeft:(NSInteger)left withRight:(NSInteger)right;
+(void) generateFireMessage;

@end
