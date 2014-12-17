//
//  TouchProcessorView.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchProcessorView : UIView

@property (nonatomic) NSInteger centerX, centerY, minX, minY, maxX, maxY;

-(void)touchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY;
-(void)rawTouchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY;

@end
