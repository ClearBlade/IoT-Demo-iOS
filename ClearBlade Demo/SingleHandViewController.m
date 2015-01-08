//
//  SingleHandViewController.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "SingleHandViewController.h"
#import "ControlMessage.h"

@interface SingleHandViewController ()


@end

@implementation SingleHandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.oneTouchControlView.delegate = self;
    [self.oneTouchControlView viewAppeared];
    [self.turretCannonView viewAppeared];
    self.turretTapper.delaysTouchesBegan = YES;
}

-(void)touchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    if ([eventName isEqualToString:@"ENDED"] || [eventName isEqualToString:@"CANCELLED"]) {
        eventX = eventY = 0;
    }
    [ControlMessage generateMessageFromSingleInput:eventName withSpeed:eventY withDirection:eventX];
}

-(IBAction)handleTap:(UITapGestureRecognizer *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TurretFire" object:[NSDictionary dictionary]];
}

@end
