//
//  ControlTypeViewController.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "ControlTypeViewController.h"

#define SegueSingleHand		@"embedSingleHand"
#define SegueDualTread		@"embedDualTread"

@interface ControlTypeViewController ()

@property (nonatomic, strong) NSString *currentSegueIdentifier;

@end

@implementation ControlTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentSegueIdentifier = SegueSingleHand; // Default first view that is displayed
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SegueSingleHand]) {
        if (self.childViewControllers.count > 0) {
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:segue.destinationViewController];
        } else {
            [self addChildViewController:segue.destinationViewController];
            ((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
    } else if ([segue.identifier isEqualToString:SegueDualTread]) {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:segue.destinationViewController];
    }
}

-(void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    toViewController.view.frame = CGRectMake (0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
    }];
}

-(void)swapViewControllers {
    self.currentSegueIdentifier = ([self.currentSegueIdentifier isEqualToString:SegueSingleHand]) ? SegueDualTread : SegueSingleHand;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

@end
