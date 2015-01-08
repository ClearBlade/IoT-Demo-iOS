//
//  ViewController.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/4/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "ViewController.h"
#import "MyoWrapper.h"

@interface ViewController ()

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) MyoWrapper *myo;
@property (nonatomic, assign) BOOL isSingleFingerController;


@end

@implementation ViewController

-(IBAction)myoButtonPressed:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myo = [[MyoWrapper alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(poseChanged:) name:@"MyoPoseChanged" object:nil];
    self.controlsSwitcher.tintColor = [UIColor darkGrayColor];
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:20.0f]};
    [self.controlsSwitcher setTitleTextAttributes:attrs forState:UIControlStateNormal];
    self.isSingleFingerController = true;
}

-(void)viewDidAppear:(BOOL)animated {
    [self.myo connectWithRect:[self.topDashboardView frame] inView:self.view];
    [self setupControlsSwitcher];
    [self setupLabels];
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
    self.isSingleFingerController = self.controlsSwitcher.selectedSegmentIndex == 0;
    [self.controlTypeViewController swapViewControllers];
    [self setupControlsSwitcher];
    [self setupLabels];
}

-(void)setupLabels {
    if (self.isSingleFingerController) {
        [self.singleFingerLabels setHidden:NO];
        [self.dualTreadLabels setHidden:YES];
    } else {
        [self.singleFingerLabels setHidden:YES];
        [self.dualTreadLabels setHidden:NO];
    }
}

-(void)poseChanged:(NSNotification *)notif {
    NSDictionary *msg = (NSDictionary *)notif.object;
    self.myoGesture.text = msg[@"Pose"];
}

-(void) setupControlsSwitcher {
    CGRect segFrame = self.controlsSwitcher.frame;
    segFrame.size.height = 45;
    [self.controlsSwitcher setFrame:segFrame];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setupControlsSwitcher];
}

@end
