//
//  JSONUtils.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/8/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtils : NSObject

+(NSString *)objToStr:(id)obj;
+(id)strToObj:(NSString *)str;

@end
