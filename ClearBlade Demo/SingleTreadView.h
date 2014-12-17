//
//  SingleTreadView.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchProcessorView.h"

@class SingleTreadView;

@protocol SingleTreadViewDelegate <NSObject>

-(void) touchEventOccurred:(SingleTreadView *)view withEvent:(NSString *)event withX:(NSInteger)x withY:(NSInteger)y;

@end

@interface SingleTreadView : TouchProcessorView

@property(nonatomic, weak) IBOutlet UIView *slider;
@property(nonatomic, weak) IBOutlet UIView *horizontalGuide;
@property (nonatomic, assign) id<SingleTreadViewDelegate> delegate;

-(void) viewAppeared;

@end
