//
//  ClearBlade.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/6/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "ClearBladeWrapper.h"
#import "ControlMessage.h"
#import "JSONUtils.h"
#import <UIKit/UIKit.h>
#import "TankMessages.h"

//
//  App States
//
NSString * const UP_STATE = @"Up";
NSString * const PAIRING_STATE = @"Pairing";
NSString * const PAIRED_STATE = @"Paired";
NSString * const DOWN_STATE = @"Down"; 			// This is kinda silly

//
//  ClearBlade messages that this app publishes
//
NSString * const TankAskStatePub = @"Dev/Tank/AskState";
NSString * const ControllerStatePub = @"Dev/Controller/%@/State";
NSString * const TankAskPairPub = @"/Dev/Tank/%@/AskPair";
NSString * const TankUnpairPub = @"/Dev/Tank/%@/Unpair";
NSString * const TankDrivePub = @"/Dev/Tank/%@/Drive";
NSString * const TankTurretPub = @"/Dev/Tank/%@/Turret";

//
//  ClearBlade messages that this app subscribes to
//
NSString * const TankStateSub = @"Dev/Tank/+/State";
NSString * const TankPairSub = @"Dev/Tank/+/Pair";

@interface ClearBladeWrapper ()

@property (nonatomic, strong) CBMessageClient *messageClient;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *pairedTank;
@property (nonatomic, strong) NSString *controllerState;
@property (nonatomic, assign) NSInteger subscribeCount;
@property (nonatomic, strong) NSMutableDictionary *tanks;

@end

@implementation ClearBladeWrapper

-(id) init {
    self = [super init];
    self.uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.pairedTank = @"";
    self.subscribeCount = 0;
    self.controllerState = UP_STATE;
    self.tanks = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSpeedAndDirection:) name:@"SpeedAndDirection" object:nil];
    NSError * error;
    [ClearBlade initSettingsSyncWithSystemKey:@"82f7a8c60ab6b3f49ec4eea1b59801"
                             withSystemSecret:@"82F7A8C60A88AD98BEDBBDE9BE43"
                                  withOptions:@{}
                                    withError:&error];
    if (error) {
        NSLog(@"Failed to connect with error %@", error);
        return self;
    }
    self.messageClient = [[CBMessageClient alloc] init];
    self.messageClient.delegate = self;
    [self.messageClient connect];
    return self;
}

-(void)sendSpeedAndDirection:(NSNotification *)notif {
    if ([self.pairedTank isEqualToString:@""]) {
        return;
    }
    ControlMessage *msg = (ControlMessage *)notif.object;
    TankDriveMessage *driveMsg = [[TankDriveMessage alloc] initWithController:self.uid
                                                                    andTankId:self.pairedTank
                                                                     andSpeed:msg.speed
                                                                 andDirection:msg.direction];
    
   	[self.messageClient publishMessage:[driveMsg body] toTopic:[driveMsg topic]];
}

-(NSString *)makeTankTopic:(NSString *)topicStr {
    return [NSString stringWithFormat:topicStr, self.pairedTank];
}

-(NSString *)makeControllerTopic:(NSString *)topicStr {
    return [NSString stringWithFormat:topicStr, self.uid];
}

-(void)processTankStateMessage:(ReceivedMessage *)msg {
    NSString *tankId = [msg target];
    NSString *tankState = [msg component:@"State"];
    self.tanks[tankId] = tankState;
    if ([self.controllerState isEqualToString:@"Up"] &&
        [tankState isEqualToString:@"Up"]) {
        // Try to pair
        self.controllerState = @"Pairing";
        self.pairedTank = tankId;
        TankAskPairMessage *msg = [[TankAskPairMessage alloc] initWithController:self.uid
                                   andTankId:tankId];
       	[self.messageClient publishMessage:[msg body] toTopic:[msg topic]];
    } else if ([tankId isEqualToString:self.pairedTank] && ![tankState isEqualToString:@"Paired"]) {
        // Tank crashed or something -- unpair
        self.controllerState = @"Up";
        self.pairedTank = @"";
        // XXXSWM Send Dev/Controller/<me>/State msg
        ControllerStateMessage *cMsg = [[ControllerStateMessage alloc] initWithController:self.uid andState:self.controllerState];
        [self.messageClient publishMessage:[cMsg body] toTopic:[cMsg topic]];
        // Send Dev/Tank/AskState and try to connect with another tank
        TankAskStateMessage *msg = [[TankAskStateMessage alloc] initWithController:self.uid];
       	[self.messageClient publishMessage:[msg body] toTopic:[msg topic]];
    }
}

-(void)processTankPairMessage:(ReceivedMessage *)msg {
    NSString *tankId = [msg target];
    NSString *controllerId = [msg component:@"ControllerId"];
    NSString *pairResponse = [msg component:@"Response"];
    if (![controllerId isEqualToString:self.uid]) {
        return;
    }
    if ([pairResponse isEqualToString:@"Yes"]) {
        self.controllerState = @"Paired";
        self.pairedTank = tankId;
    } else {
        //  Pairing failed. Start the discovery process all over again...
        self.controllerState = @"Up";
        self.pairedTank = @"";
        TankAskStateMessage *msg = [[TankAskStateMessage alloc] initWithController:self.uid];
       	[self.messageClient publishMessage:[msg body] toTopic:[msg topic]];
    }
}

#pragma mark - ClearBlade Message Client Delegate Methods

-(void)messageClientDidConnect:(CBMessageClient *)client {
    NSLog(@"messageClientDidConnect");
    self.subscribeCount = 2;
    [client subscribeToTopic:TankStateSub];
    [client subscribeToTopic:TankPairSub];
}

-(void)messageClientDidDisconnect:(CBMessageClient *)client {
    NSLog(@"messageClientDidDisconnect");
}

-(void)messageClient:(CBMessageClient *)client didPublishToTopic:(NSString *)topic withMessage:(CBMessage *)message {
    NSLog(@"didPublishToTopic: %@ -- %@", topic, message.payloadText);
}

-(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    NSLog(@"didReceiveMessage: %@ :: %@", message.topic, [JSONUtils strToObj:message.payloadText]);
    ReceivedMessage *msg = [[ReceivedMessage alloc] initWithTopic:message.topic andBody:message.payloadText];
    if ([msg messageIsA:@"State"]) {
        [self processTankStateMessage:msg];
    } else if ([msg messageIsA:@"Pair"]) {
        [self processTankPairMessage:msg];
    }
}

-(void)messageClient:(CBMessageClient *)client didSubscribe:(NSString *)topic {
    NSLog(@"didSubscribe");
    if (-- self.subscribeCount <= 0) {
        TankAskStateMessage *msg = [[TankAskStateMessage alloc] initWithController:self.uid];
       	[client publishMessage:[msg body] toTopic:[msg topic]];
    }
}

-(void)messageClient:(CBMessageClient *)client didUnsubscribe:(NSString *)topic {
    NSLog(@"didUnsubscribe");
}

-(void)messageClient:(CBMessageClient *)client didFailToConnect:(CBMessageClientConnectStatus)reason {
    NSLog(@"didFailToConnect");
}

@end