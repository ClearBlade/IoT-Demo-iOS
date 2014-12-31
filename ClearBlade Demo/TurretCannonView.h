//
//  TurretCannonView.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchProcessorView.h"

@interface TurretCannonView : TouchProcessorView

@property (nonatomic, weak) IBOutlet UIView *verticalGuide;
@property (nonatomic, weak) IBOutlet UIView *horizontalGuide;
@property (nonatomic, weak) IBOutlet UIView *slider;

-(void)viewAppeared;

@end
