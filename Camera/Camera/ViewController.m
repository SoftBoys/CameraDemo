//
//  ViewController.m
//  Camera
//
//  Created by dfhb@rdd on 2017/12/8.
//  Copyright © 2017年 f2b2b. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)cameraClick:(id)sender {
    [CameraViewController cameraViewControllerWithPresentedVC:self completion:^(UIImage *fullImage, UIImage *editImage) {
        
    }];
}


@end
