//
//  MyoWrapper.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 1/2/15.
//  Copyright (c) 2015 Manweiler Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyoWrapper : NSObject

-(id)init;
-(void)connectWithRect:(CGRect)rect inView:(UIView *)view;
-(void)attachOrDetach;

@end
