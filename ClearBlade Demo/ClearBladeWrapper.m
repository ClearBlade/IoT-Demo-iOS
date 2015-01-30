
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
//  The ClearBlade sensor collection info
//
NSString * const UserCollectionId = @"bcc6aac60aacffdce2a4f6fcab02";
NSString * const SensorCollectionId = @"fcf4becc0aa6e3c3a181fca2f1ab01";
NSString * const SensorFieldId = @"item_id";
NSString * const SensorFieldTimestamp = @"timestanp";
NSString * const SensorFieldRawData = @"rawdata";

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
NSString * const TankAskStatePub = @"Tank/AskState";
NSString * const ControllerStatePub = @"Controller/%@/State";
NSString * const TankAskPairPub = @"Tank/%@/AskPair";
NSString * const TankUnpairPub = @"Tank/%@/Unpair";
NSString * const TankDrivePub = @"Tank/%@/Drive";
NSString * const TankTurretMovePub = @"Tank/%@/TurretMove";
NSString * const TankTurretFirePub = @"Tank/%@/TurretFire";
NSString * const ControllerHeartbeatPub=@"Controller/%@/Heartbeat";

//
//  ClearBlade messages that this app subscribes to
//
NSString * const TankStateSub = @"Tank/+/State";
NSString * const TankPairSub = @"Tank/+/Pair";
NSString * const TankSensorsSub = @"Tank/+/Sensors";

//
//  Field Names in messages
//
NSString * const FieldControllerId = @"Controller";
NSString * const FieldTankId = @"TankId";
NSString * const FieldSpeed = @"Speed";
NSString * const FieldDirection = @"Direction";

@interface ClearBladeWrapper ()

@property (nonatomic, strong) CBMessageClient *messageClient;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *pairedTank;
@property (nonatomic, strong) NSString *controllerState;
@property (nonatomic, assign) NSInteger subscribeCount;
@property (nonatomic, strong) NSMutableDictionary *tanks;
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) CBCollection *sensorCol;
@property (nonatomic, strong) CBCollection *userCol;

@end

@implementation ClearBladeWrapper

-(id) init {
    NSLog(@"ClearBladeWrapper init");
    self = [super init];
    //self.uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.uid = @"SWMIPAD";
    self.pairedTank = @"";
    self.subscribeCount = 0;
    self.controllerState = UP_STATE;
    self.tanks = [NSMutableDictionary dictionary];
    self.heartbeatTimer = nil;
    self.sensorCol = nil;
    self.userCol = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTurretFire:)
                                                 name:@"TurretFire" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTurretMove:)
                                                 name:@"TurretMove" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSpeedAndDirection:)
                                                 name:@"SpeedAndDirection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:@"WillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:@"DidBecomeActive" object:nil];
    return self;
}

-(void)heartbeatTimer:(NSTimer *)timer {
    HeartbeatMessage *msg = [[HeartbeatMessage alloc] initWithController:self.uid];
   	[self.messageClient publishMessage:[msg body] toTopic:[msg topic]];
}

-(void)didBecomeActive:(id)sender {
    [self initClearBlade];
}

-(void)willResignActive:(id)sender {
    [self shutdownClearBlade];
}

-(void)initClearBlade {
    [self sendStateChanged:@"Connecting"];
    self.pairedTank = @"";
    self.subscribeCount = 0;
    self.controllerState = UP_STATE;
    NSError *error;
    /*
    NSMutableDictionary *userPass = [NSMutableDictionary dictionary];
    userPass[CBSettingsOptionEmail] = @"tank@clearblade.com";
    userPass[CBSettingsOptionPassword] = @"IAmATank";
     */
    [ClearBlade initSettingsSyncWithSystemKey:@"82f7a8c60ab6b3f49ec4eea1b59801"
                             withSystemSecret:@"82F7A8C60A88AD98BEDBBDE9BE43"
                                  withOptions:nil //userPass
                                    withError:&error];
    if (error) {
        NSLog(@"Failed to connect with error %@", error);
        return;
    }
    self.messageClient = [[CBMessageClient alloc] init];
    self.messageClient.delegate = self;
    self.userCol = [CBCollection collectionWithID:UserCollectionId];
    [self checkUser:@"Manny"];
    self.sensorCol = [CBCollection collectionWithID:SensorCollectionId];
    if (!self.sensorCol) {
        NSLog(@"Could not open sensor collection");
    } else {
        NSLog(@"Successfully opened sensor collection");
    }
    [self.messageClient connect];
}

-(void)shutdownClearBlade {
    [self stopHeartbeatTimer];
    self.controllerState = @"Down";
    ControllerStateMessage *cMsg = [[ControllerStateMessage alloc] initWithController:self.uid andState:self.controllerState];
    [self.messageClient publishMessage:[cMsg body] toTopic:[cMsg topic]];
    
    [self.messageClient disconnect];
    [self sendStateChanged:@"Disconnected"];
}

-(void)sendSpeedAndDirection:(NSNotification *)notif {
    NSLog(@"SendSpeedAndDirection if paired");
    if ([self.pairedTank isEqualToString:@""]) {
        return;
    }
    NSDictionary *msg = (NSDictionary *)notif.object;
    TankDriveMessage *driveMsg = [[TankDriveMessage alloc] initWithController:self.uid
                                                                    andTankId:self.pairedTank
                                                                     andSpeed:[msg[@"Speed"] integerValue]
                                                                 andDirection:[msg[@"Direction"] integerValue]];
    
   	[self.messageClient publishMessage:[driveMsg body] toTopic:[driveMsg topic]];
}

-(void)sendTurretMove:(NSNotification *)notif {
    NSLog(@"Sending TurretMove if paired");
    if ([self.pairedTank isEqualToString:@""]) {
        return;
    }
    NSDictionary *msg = (NSDictionary *)notif.object;
    TurretMoveMessage *moveMsg = [[TurretMoveMessage alloc] initWithController:self.uid andTankId:self.pairedTank andDirection:msg[FieldDirection]];
    [self.messageClient publishMessage:[moveMsg body] toTopic:[moveMsg topic]];
}

-(void)sendTurretFire:(NSNotification *)notif {
    NSLog(@"SendTurretFire if paired");
    if ([self.pairedTank isEqualToString:@""]) {
        return;
    }
    TurretFireMessage *fireMsg = [[TurretFireMessage alloc] initWithController:self.uid andTankId:self.pairedTank];
    [self.messageClient publishMessage:[fireMsg body] toTopic:[fireMsg topic]];
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
        [self sendStateChanged:@"Pairing With Tank"];
        self.controllerState = @"Pairing";
        self.pairedTank = tankId;
        TankAskPairMessage *msg = [[TankAskPairMessage alloc] initWithController:self.uid
                                   andTankId:tankId];
       	[self.messageClient publishMessage:[msg body] toTopic:[msg topic]];
    } else if ([tankId isEqualToString:self.pairedTank] && ![tankState isEqualToString:@"Paired"]) {
        // Tank crashed or something -- unpair
        [self sendStateChanged:@"Finding A Tank"];
        self.controllerState = @"Up";
        self.pairedTank = @"";
        // XXXSWM Send Controller/<me>/State msg
        ControllerStateMessage *cMsg = [[ControllerStateMessage alloc] initWithController:self.uid andState:self.controllerState];
        [self.messageClient publishMessage:[cMsg body] toTopic:[cMsg topic]];
        // Send Tank/AskState and try to connect with another tank
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
        [self sendStateChanged:@"Paired With Tank"];
        self.controllerState = @"Paired";
        self.pairedTank = tankId;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TankPaired" object:nil];
        
    } else {
        //  Pairing failed. Start the discovery process all over again...
        [self sendStateChanged:@"Finding A Tank"];
        self.controllerState = @"Up";
        self.pairedTank = @"";
        TankAskStateMessage *msg = [[TankAskStateMessage alloc] initWithController:self.uid];
       	[self.messageClient publishMessage:[msg body] toTopic:[msg topic]];
    }
}

-(void)writeToSensorCollection:(ReceivedMessage *)msg {
    if (!self.sensorCol) {
        NSLog(@"Ignoring sensor write because we do not have a collection connection");
        return;
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[SensorFieldRawData] = [JSONUtils objToStr:[msg asDict]];
    //data[SensorFieldRawData] = @"This is some data";
    NSLog(@"Trying to write: %@", data);
    [self.sensorCol createWithData:data withSuccessCallback:^(CBItem *newItem) {
        NSLog(@"Successfully wrote to sensor collection");
    }withErrorCallback:^(CBItem *item, NSError *error, id JSON) {
        NSLog(@"Sensor write failed: %@: %@", error, JSON);
    }];
}

-(void)processTankSensorsMessage:(ReceivedMessage *)msg {
    //  Just shove each sensor message into the db...
    [self writeToSensorCollection:msg];
}

-(void)sendStateChanged:(NSString *)newState {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StateChanged" object:[NSDictionary dictionaryWithObject:newState forKey:@"State"]];
}

-(void)stopHeartbeatTimer {
    if (self.heartbeatTimer) {
        [self.heartbeatTimer invalidate];
        self.heartbeatTimer = nil;
    }
}

-(void)startHeartbeatTimer {
    [self stopHeartbeatTimer];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(heartbeatTimer:) userInfo:nil repeats:YES];
}

-(void) checkUser: (NSString *) userString {
    //Sets up the query to be on the same collection as userCol
    CBQuery *userQuery = [CBQuery queryWithCollectionID:[self.userCol collectionID]];
    [userQuery equalTo:userString for:@"username"]; //Adds the query parameter that username must be equal to the userString
                                                    //Searches for all users with the same username
    [userQuery fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *foundUsers = successfulResponse.dataItems; // Pull the array of items matching the query out of the response object
                                                                   //If foundUsers count is zero, means no one else has logged in with that username before
        if (foundUsers.count == 0) {
            [self.userCol createWithData:@{@"username": userString} withSuccessCallback:^(CBItem *newUser) {
                NSLog(@"new user created");
            } withErrorCallback:^(CBItem * item, NSError *err, id ret) {
                NSLog(@"ERROR: %@: %@", err, ret);
            }];
        } else {
            //foundUsers is greater than zero so someone has logged in with this username at least once.
        }
    } withErrorCallback:^(NSError *error, id JSON) {
        NSLog(@"ERROR: %@: %@", error, JSON);
    }];
}

#pragma mark - ClearBlade Message Client Delegate Methods

-(void)messageClientDidConnect:(CBMessageClient *)client {
    [self sendStateChanged:@"Connected"];
    NSLog(@"messageClientDidConnect");
    self.subscribeCount = 3;
    [client subscribeToTopic:TankStateSub];
    [client subscribeToTopic:TankPairSub];
    [client subscribeToTopic:TankSensorsSub];
    [self startHeartbeatTimer];
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
    } else if ([msg messageIsA:@"Sensors"]) {
        [self processTankSensorsMessage:msg];
    }
}

-(void)messageClient:(CBMessageClient *)client didSubscribe:(NSString *)topic {
    NSLog(@"didSubscribe");
    if (-- self.subscribeCount <= 0) {
        self.controllerState = @"Up";
        ControllerStateMessage *cMsg = [[ControllerStateMessage alloc] initWithController:self.uid andState:self.controllerState];
        [self.messageClient publishMessage:[cMsg body] toTopic:[cMsg topic]];
        [self sendStateChanged:@"Finding A Tank"];
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
