//
//  CameraScanView.m
//  CameraDemo
//
//  Created by dfhb@rdd on 2017/12/7.
//  Copyright © 2017年 f2b2b. All rights reserved.
//

#import "CameraScanView.h"

@interface CameraScanView ()
@property (nonatomic, strong) UILabel *labremind;
@end
@implementation CameraScanView
+ (CGSize)cameraSize {
    CGSize size = CGSizeZero;
    CGFloat width = 0, height = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        size = CGSizeMake(0, 0);
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        width = 662.0/750.0 * [UIScreen mainScreen].bounds.size.width;
        height = 413.0/662.0 * width;
        size = CGSizeMake(width, height);
    }
    return size;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSelf];
    }
    return self;
}
- (void)initSelf {
    
    self.backgroundColor = [UIColor clearColor];
    
    _labremind = [UILabel new];
    _labremind.textColor = [UIColor whiteColor];
    _labremind.font = [UIFont systemFontOfSize:15];
    _labremind.text = @"请将身份证边缘对齐方框拍照";
    _labremind.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_labremind];
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize cameraSize = [CameraScanView cameraSize];
    CGFloat remindY = CGRectGetMidY(self.bounds) + cameraSize.height/2 + 10;
    _labremind.frame = CGRectMake(0, remindY, CGRectGetWidth(self.frame), 20);
    
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor);
    CGContextFillRect(contextRef, rect);
    
    
    CGSize size = [CameraScanView cameraSize];
    CGFloat clearX = (CGRectGetWidth(rect)-size.width)/2;
    CGFloat clearY = (CGRectGetHeight(rect)-size.height)/2;
    CGRect clearRect = CGRectMake(clearX, clearY, size.width, size.height);
    CGContextClearRect(contextRef, clearRect);
    
    CGContextStrokeRect(contextRef, clearRect);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(contextRef, 2);
    CGContextAddRect(contextRef, clearRect);
    CGContextStrokePath(contextRef);
    
}

@end
