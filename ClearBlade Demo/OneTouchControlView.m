//
//  OneTouchControlView.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/4/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "OneTouchControlView.h"

@implementation OneTouchControlView

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.delegate = nil;
    return self;
}


-(void)touchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    if (self.delegate) {
        [self.delegate touchEventOccurred:eventName withX:eventX withY:eventY];
    }
}

-(void)rawTouchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    [self moveViews:eventName withX:eventX withY:eventY];
}


-(void)viewAppeared {
    self.slider.layer.borderWidth = 4;
    self.slider.layer.borderColor = [UIColor redColor].CGColor;
    self.slider.layer.cornerRadius = 25;
    self.layer.borderWidth = 4;
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor blackColor
                              ].CGColor;
}


-(void)moveViews:(NSString *)eventName withX:(NSInteger)x withY:(NSInteger)y {
    if ([eventName isEqualToString:@"ENDED"] || [eventName isEqualToString:@"CANCELLED"]) {
        y = self.frame.size.height / 2;
        x = self.frame.size.width / 2;
    }
    CGRect sliderRect = self.slider.frame;
    CGRect horizGuideRect = self.horizontalGuide.frame;
    CGRect vertGuideRect = self.verticalGuide.frame;
    sliderRect.origin.y = y - (sliderRect.size.height / 2);
    sliderRect.origin.x = x - (sliderRect.size.width / 2);
    horizGuideRect.origin.y = y - (horizGuideRect.size.height / 2);
    vertGuideRect.origin.x = x - (vertGuideRect.size.width / 2);
    self.slider.frame = [self minMax:sliderRect];
    self.horizontalGuide.frame = [self minMax:horizGuideRect];
    self.verticalGuide.frame = [self minMax:vertGuideRect];
}

-(CGRect)minMax:(CGRect)rect {
    //  Tweak the x and y val to make sense given rect's size, and the size of our view.
    CGRect rval = rect;
    NSInteger minX = - (rect.size.width / 2);
    NSInteger minY = - (rect.size.height / 2);
    NSInteger maxX = self.frame.size.width - (rect.size.width / 2);
    NSInteger maxY = self.frame.size.height - (rect.size.height / 2);
    rval.origin.x = rect.origin.x <= minX ? minX : rect.origin.x >= maxX ? maxX : rect.origin.x;
    rval.origin.y = rect.origin.y <= minY ? minY : rect.origin.y >= maxY ? maxY : rect.origin.y;
    
    return rval;
}

@end