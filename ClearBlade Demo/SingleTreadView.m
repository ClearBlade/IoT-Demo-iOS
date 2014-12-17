//
//  SingleTreadView.m
//  ClearBlade Demo
//
//  Created by Steve W. Manweiler on 12/5/14.
//  Copyright (c) 2014 Manweiler Software. All rights reserved.
//

#import "SingleTreadView.h"

@implementation SingleTreadView

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.delegate = nil;
    
    
    return self;
}

-(void)viewAppeared {
    self.slider.layer.borderWidth = 1;
    self.slider.layer.borderColor = [UIColor redColor].CGColor;
    self.slider.layer.cornerRadius = 15;
    self.layer.borderWidth = 4;
    self.layer.cornerRadius = 25;
    self.layer.borderColor = [UIColor blackColor].CGColor;
}


-(void)touchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    if (self.delegate) {
        [self.delegate touchEventOccurred:self withEvent:eventName withX:0 withY:eventY];
    }
}

-(void)rawTouchEventOccurred:(NSString *)eventName withX:(NSInteger)eventX withY:(NSInteger)eventY {
    // Raw x, y event in the window. Move the slider and the horizontal guide...
    [self moveViews:eventName withX:eventX withY:eventY];
}

-(void)moveViews:(NSString *)eventName withX:(NSInteger)x withY:(NSInteger)y {
    if ([eventName isEqualToString:@"ENDED"] || [eventName isEqualToString:@"CANCELLED"]) {
        y = self.frame.size.height / 2;
    }
    CGRect sliderRect = self.slider.frame;
    CGRect guideRect = self.horizontalGuide.frame;
    sliderRect.origin.y = y - (sliderRect.size.height / 2);
    guideRect.origin.y = y - (guideRect.size.height / 2);
    self.slider.frame = [self minMax:sliderRect];
    self.horizontalGuide.frame = [self minMax:guideRect];
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
