//
//  ViewController.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/4/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"SEGUE for container view controller");
    if ([segue.identifier isEqualToString:@"embedControlsContainer"]) {
        NSLog(@"GOT embedControlsContainer");
        self.controlTypeViewController = segue.destinationViewController;
    }
}

-(IBAction)switchControlsValueChanged:(id)sender {
    NSLog(@"We just switched the controls");
    [self.controlTypeViewController swapViewControllers];
}

@end
