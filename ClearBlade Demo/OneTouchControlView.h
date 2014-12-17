//
//  OneTouchControlView.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/4/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchProcessorView.h"

@protocol OneTouchControlViewDelegate <NSObject>

-(void) touchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY;

@end

@interface OneTouchControlView : TouchProcessorView

@property (nonatomic, assign) id<OneTouchControlViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIView *verticalGuide;
@property (nonatomic, weak) IBOutlet UIView *horizontalGuide;
@property (nonatomic, weak) IBOutlet UIView *slider;

-(void)viewAppeared;

@end
