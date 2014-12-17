//
//  DualTreadViewController.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurretCannonView.h"
#import "SingleTreadView.h"

@interface DualTreadViewController : UIViewController<SingleTreadViewDelegate>

@property (nonatomic, strong) IBOutlet SingleTreadView *leftTreadView;
@property (nonatomic, strong) IBOutlet SingleTreadView *rightTreadView;
@property (nonatomic, strong) IBOutlet TurretCannonView *turretCannonView;


@end
