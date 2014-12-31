//
//  TankMessages.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/11/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "TankMessages.h"
#import "JSONUtils.h"

@interface TankBaseMessage ()

@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSString *topicId;

@end

@interface ReceivedMessage ()

@property(nonatomic, strong) NSString *messageType;
@property(nonatomic, strong) NSString *messageClass;
@property(nonatomic, strong) NSString *messageTarget;
@property(nonatomic, strong) NSDictionary *dict;

@end

@implementation ReceivedMessage

-(id)initWithTopic:(NSString *)topic andBody:(NSString *)body {
    self = [super init];
    NSArray *components = [topic componentsSeparatedByString:@"/"];
    self.messageClass = @"";
    self.messageType = components[components.count - 1];
    self.messageTarget = @"";
    if (components.count > 3) {
        self.messageTarget = components[components.count - 2];
        self.messageClass = components[1];
    }
    self.dict = [JSONUtils strToObj:body];
    return self;
}

-(BOOL)messageIsA:(NSString *)msgBaseName {
    return [self.messageType isEqualToString:msgBaseName] && [self.messageClass isEqualToString:@"Tank"];
}

-(id)component:(NSString *)key {
    
    return self.dict[key];
}

-(NSString *)target {
    return self.messageTarget;
}

@end

@implementation TankBaseMessage

-(id)initWithTopic:(NSString *)topic {
    self = [super init];
    self.topicId = topic;
    self.dict = [NSMutableDictionary dictionary];
    return self;
}

-(NSString *)body {
    return [JSONUtils objToStr:self.dict];
}

-(NSString *)topic {
    return self.topicId;
}

@end

@implementation ControllerStateMessage

-(id)initWithController:(NSString *)controller andState:(NSString *)state {
    self = [super initWithTopic:[NSString stringWithFormat:@"Dev/Controller/%@/State", controller]];
    self.dict[@"ControllerId"] = controller;
    self.dict[@"State"] = state;
    return self;
}

@end

@implementation TankAskStateMessage

-(id)initWithController:(NSString *)controller {
    self = [super initWithTopic:@"Dev/Tank/AskState"];
    self.dict[@"ControllerId"] = controller;
    return self;
}

@end

@implementation TankAskPairMessage

-(id)initWithController:(NSString *)controller andTankId:(NSString *)tankId {
    self = [super initWithTopic:[NSString stringWithFormat:@"Dev/Tank/%@/AskPair", tankId]];
    self.dict[@"ControllerId"] = controller;
    self.dict[@"TankId"] = tankId;
    
    return self;
}

@end


@implementation TankDriveMessage

-(id)initWithController:(NSString *)controller
              andTankId:(NSString *)tankId
               andSpeed:(NSInteger)speed
           andDirection:(NSInteger)direction {
    self = [super initWithTopic:[NSString stringWithFormat:@"Dev/Tank/%@/Drive", tankId]];
    self.dict[@"ControllerId"] = controller;
    self.dict[@"TankId"] = tankId;
    self.dict[@"Speed"] = [NSNumber numberWithInteger:speed];
    self.dict[@"Direction"] = [NSNumber numberWithInteger:direction];
    
    return self;
}

@end

@implementation TurretMoveMessage

-(id)initWithController:(NSString *)controller andTankId:(NSString *)tankId andDirection:(NSString *)direction {
    self = [super initWithTopic:[NSString stringWithFormat:@"Dev/Tank/%@/TurretMove", tankId]];
    self.dict[@"ControllerId"] = controller;
    self.dict[@"TankId"] = tankId;
    self.dict[@"Direction"] = direction;
    
    return self;
}

@end

@implementation TurretFireMessage

-(id)initWithController:(NSString *)controller andTankId:(NSString *)tankId {
    self = [super initWithTopic:[NSString stringWithFormat:@"Dev/Tank/%@/TurretFire", tankId]];
    self.dict[@"ControllerId"] = controller;
    self.dict[@"TankId"] = tankId;
    
    return self;
}

@end