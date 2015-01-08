//
//  TankMessages.h
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/11/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceivedMessage: NSObject

-(id)initWithTopic:(NSString *)topic andBody:(NSString *)body;
-(bool)messageIsA:(NSString *)msgBaseName;
-(id)component:(NSString *)key;
-(NSString *)target;
-(void)dump;
  
@end

@interface TankBaseMessage: NSObject

-(NSString *)topic;
-(NSString *)body;

@end

@interface ControllerStateMessage: TankBaseMessage

-(id)initWithController:(NSString *)controller andState:(NSString *)state;

@end

@interface TankAskStateMessage : TankBaseMessage

-(id)initWithController:(NSString *)controller;

@end

@interface TankAskPairMessage : TankBaseMessage

-(id)initWithController:(NSString *)controller andTankId:(NSString *)tankId;

@end

@interface TankDriveMessage: TankBaseMessage

-(id)initWithController:(NSString *)controller
              andTankId:(NSString *)tankId
               andSpeed:(NSInteger)speed
           andDirection:(NSInteger)direction;

@end

@interface TurretMoveMessage: TankBaseMessage

-(id)initWithController:(NSString *)controller
              andTankId:(NSString *)tankId
           andDirection:(NSString *)direction;

@end

@interface TurretFireMessage: TankBaseMessage

-(id)initWithController:(NSString *)controller
              andTankId:(NSString *)tankId;

@end