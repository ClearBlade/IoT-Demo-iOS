//
//  MyoWrapper.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 1/2/15.
//  Copyright (c) 2015 Manweiler Software. All rights reserved.
//

#import "MyoWrapper.h"
#import <MyoKit/MyoKit.h>
#import "ControlMessage.h"

@interface MyoWrapper ()

@property(nonatomic, strong) UIPopoverController *popover;
@property(nonatomic, strong) TLMMyo *attachedMyo;

@end

@implementation MyoWrapper

static int direction = 1;
static bool attached = false;

-(void)attachOrDetach {
    if (!attached) {
        [[TLMHub sharedHub] attachToAdjacent];
    } else {
        [[TLMHub sharedHub] detachFromMyo:self.attachedMyo];
        self.attachedMyo = nil;
    }
}

-(id)init {
    self = [super init];
    
    [TLMHub sharedHub];
    [[TLMHub sharedHub] setLockingPolicy:TLMLockingPolicyNone];
    [[TLMHub sharedHub] setShouldNotifyInBackground:YES];
    
    //  Set up notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnlockDevice:)
                                                 name:TLMMyoDidReceiveUnlockEventNotification
                                               object:nil];
    // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLockDevice:)
                                                 name:TLMMyoDidReceiveLockEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
    return self;
}

-(void)connectWithRect:(CGRect)rect inView:(UIView *)view {
    self.popover = [TLMSettingsViewController settingsInPopoverController];
    [self.popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    NSLog(@"Popover should be displayed");
}

-(void)didConnectDevice:(NSNotification *)notif {
    NSLog(@"Connect Device: %@", (NSDictionary *)notif.userInfo);
}

-(void)didDisconnectDevice:(NSNotification *)notif {
    NSLog(@"Disconnect Device: %@", (NSDictionary *)notif.userInfo);
    self.attachedMyo = nil;
}

-(void)didSyncArm:(NSNotification *)notif {
    NSLog(@"Sync Arm");
    
}

-(void)didUnsyncArm:(NSNotification *)notif {
    NSLog(@"Unsync Arm");
    
}

-(void)didUnlockDevice:(NSNotification *)notif {
    NSLog(@"Unlock Device");
    
}

-(void)didLockDevice:(NSNotification *)notif {
    NSLog(@"Lock Device");
    
}

-(void)didReceiveOrientationEvent:(NSNotification *)notif {
    //NSLog(@"Receive Orientation Event");
    
}

-(void)didReceiveAccelerometerEvent:(NSNotification *)notif {
    //NSLog(@"Receive Accelerometer Event");
    
}

-(void)didReceivePoseChange:(NSNotification *)notif {
    NSString *poseName = @"Undefined";
    TLMPose *pose = notif.userInfo[kTLMKeyPose];
    switch (pose.type) {
        case TLMPoseTypeUnknown:
            poseName = @"Unknown";
            break;
        case TLMPoseTypeRest:
            poseName = [NSString stringWithFormat:@"Rest: %@", (direction > 0) ? @"Forward" : @"Reverse"];
            [ControlMessage generateMessageFromSingleInput:@"Motion" withSpeed:0 withDirection:0];
            break;
        case TLMPoseTypeDoubleTap:
            poseName = @"Double Tap";
            direction = -direction;
            break;
        case TLMPoseTypeFist:
            poseName = @"Fist";
            [ControlMessage generateFireMessage];
            break;
        case TLMPoseTypeWaveIn:
            poseName = @"Wave In";
            [ControlMessage generateMessageFromDualInput:@"Motion" withLeft:direction*100 withRight:direction*40];
            break;
        case TLMPoseTypeWaveOut:
            poseName = @"Wave Out";
            [ControlMessage generateMessageFromDualInput:@"Motion" withLeft:direction*40 withRight:direction*100];
            break;
        case TLMPoseTypeFingersSpread:
            [ControlMessage generateMessageFromDualInput:@"Motion" withLeft:direction *100 withRight:direction*100];
            poseName = @"Fingers Spread";
            break;
        default:
            poseName = @"WTF???";
            break;
    }
    NSLog(@"Pose: %@", poseName);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyoPoseChanged" object:[NSDictionary dictionaryWithObject:poseName forKey:@"Pose"]];
}


@end
