//
//  DualTreadViewController.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "DualTreadViewController.h"
#import "ControlMessage.h"

@interface DualTreadViewController ()

@property (nonatomic, assign) NSInteger lastLeftY, lastRightY;

@end

@implementation DualTreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftTreadView.delegate = self;
    self.rightTreadView.delegate = self;
    self.lastLeftY = self.lastRightY = 0;
    [self.leftTreadView viewAppeared];
    [self.turretCannonView viewAppeared];
    [self.rightTreadView viewAppeared];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// SingleTreadViewDelegate methods
//
-(void) touchEventOccurred:(SingleTreadView *)view
                 withEvent:(NSString *)event
                     withX:(NSInteger)eventX
                     withY:(NSInteger)eventY {
    if ([event isEqualToString:@"ENDED"] ||[ event isEqualToString:@"CANCELLED"]) {
        eventY = 0;
    }
    if (view == self.leftTreadView) {
        self.lastLeftY = eventY;
    } else {
        self.lastRightY = eventY;
    }
    [ControlMessage generateMessageFromDualInput:@"Motion" withLeft:self.lastLeftY withRight:self.lastRightY];
}

-(IBAction)handleTap:(UITapGestureRecognizer *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TurretFire" object:[NSDictionary dictionary]];
}

@end
