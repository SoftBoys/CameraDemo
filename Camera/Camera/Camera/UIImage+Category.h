//
//  UIImage+Category.h
//  CameraDemo
//
//  Created by dfhb@rdd on 2017/12/7.
//  Copyright © 2017年 f2b2b. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)
- (UIImage *)subImageWithRect:(CGRect)rect;

- (UIImage *)fixOrientation;
@end
