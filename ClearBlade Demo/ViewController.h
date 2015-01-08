//
//  ViewController.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/4/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneTouchControlView.h"
#import "ControlTypeViewController.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *topDashboardView;
@property (nonatomic, strong) IBOutlet UIView *controlsContainerView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *controlsSwitcher;
@property (nonatomic, strong) IBOutlet ControlTypeViewController *controlTypeViewController;
@property (nonatomic, strong) IBOutlet UILabel *myoGesture;
@property (nonatomic, strong) IBOutlet UIView *singleFingerLabels;
@property (nonatomic, strong) IBOutlet UIView *dualTreadLabels;

-(IBAction)myoButtonPressed:(id)sender;

@end

