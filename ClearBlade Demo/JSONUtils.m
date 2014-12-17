//
//  JSONUtils.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/8/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "JSONUtils.h"

@implementation JSONUtils

+(NSString *)objToStr:(id)obj {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
}

+(id)strToObj:(NSString *)str {
    return [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

@end
