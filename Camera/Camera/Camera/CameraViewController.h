//
//  CameraViewController.h
//  CameraDemo
//
//  Created by dfhb@rdd on 2017/12/7.
//  Copyright © 2017年 f2b2b. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController
+ (CameraViewController *)cameraViewControllerWithPresentedVC:(UIViewController *)presentedVC completion:(void (^)(UIImage *image, UIImage *cropImage))completion;
@end
