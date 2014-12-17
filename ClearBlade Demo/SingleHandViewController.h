//
//  SingleHandViewController.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurretCannonView.h"
#import "OneTouchControlView.h"

@interface SingleHandViewController : UIViewController<OneTouchControlViewDelegate>

@property (nonatomic, strong) IBOutlet TurretCannonView *turretCannonView;
@property (nonatomic, strong) IBOutlet OneTouchControlView *oneTouchControlView;

@end
