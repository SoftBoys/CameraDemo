//
//  CameraViewController.m
//  CameraDemo
//
//  Created by dfhb@rdd on 2017/12/7.
//  Copyright © 2017年 f2b2b. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraScanView.h"
#import "UIImage+Category.h"

#import <AVFoundation/AVFoundation.h>

#define Path_Resource( name ) [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Bundle.bundle"] stringByAppendingPathComponent:name]
#define UIImage( name ) [UIImage imageWithContentsOfFile:Path_Resource( name )]

@interface CameraViewController ()
/** 输入输出对象 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 输入流 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 输出流 */
@property (nonatomic, strong) AVCaptureStillImageOutput *output;
/** 预览图层 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) CameraScanView *scanView;

@property (nonatomic, copy) void (^completion)(UIImage *fullImage,UIImage *editImage);

@end

@implementation CameraViewController

+ (CameraViewController *)cameraViewControllerWithPresentedVC:(UIViewController *)presentedVC completion:(void (^)(UIImage *image, UIImage *cropImage))completion {
    if (presentedVC == nil) {
        presentedVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    CameraViewController *cameraVC = [CameraViewController new];
    cameraVC.completion = completion;
    [presentedVC presentViewController:cameraVC animated:YES completion:nil];
    return cameraVC;
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    ;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.cameraButton];
    

    self.session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

    self.output = [[AVCaptureStillImageOutput alloc] init];

    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    self.output.outputSettings = outputSettings;
    
//    AVCaptureConnection *connection = [self.output connectionWithMediaType:AVMediaTypeVideo];
//    connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;

    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }

    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    
    self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.layer.backgroundColor = [UIColor orangeColor].CGColor;
    self.layer.frame = self.contentView.layer.bounds;
    [self.contentView.layer addSublayer:self.layer];
    
    
    [self addScanView];
    
    
    
}
- (void)addScanView {
    
    // 添加扫描框
    CameraScanView *scanView = [CameraScanView new];
    [self.contentView addSubview:scanView];
    _scanView = scanView;
    
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.backBtn.frame = CGRectMake(20, 20, 44, 44);
    
    CGFloat contentT = 64, contentB = 64;
    CGFloat contentW = CGRectGetWidth(self.view.bounds);
    CGFloat contentH = CGRectGetHeight(self.view.bounds)-contentT-contentB;
    self.contentView.frame = CGRectMake(0, contentT, contentW, contentH);
    self.layer.frame = self.contentView.layer.bounds;
    _scanView.frame = self.contentView.bounds;
    
    
    CGFloat cameraW = 60;
    CGFloat cameraH = cameraW;
    CGFloat cameraY = CGRectGetMaxY(self.contentView.frame)+(contentB-cameraH)/2;
    self.cameraButton.frame = CGRectMake((CGRectGetWidth(self.view.frame)-cameraW)/2, cameraY, cameraW, cameraH);
    self.cameraButton.layer.cornerRadius = cameraW/2;
    self.cameraButton.layer.masksToBounds = YES;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if !TARGET_IPHONE_SIMULATOR
    [self.session startRunning];
#endif
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#if !TARGET_IPHONE_SIMULATOR
    [self.session stopRunning];
#endif

}
#pragma mark -
- (void)takePhoto {
    if (self.session.isRunning == NO) {
        return;
    }
    AVCaptureConnection *connection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoScaleAndCropFactor:1];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    __weak __typeof(self) weakself = self;
    [self.output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        
        __strong __typeof(weakself) strongself = weakself;

        [strongself.session stopRunning];
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *image = [UIImage imageWithData:jpegData];
        
        image = [image fixOrientation];
        
        [strongself cropImage:image];
        
        
    }];
}
- (void)cropImage:(UIImage *)image {
    
    CGRect cropViewRect = [self.scanView convertRect:self.scanView.clearRect toView:self.view];
    CGFloat scale = image.size.width / self.view.bounds.size.width;
    
    CGRect cropRect = CGRectApplyAffineTransform(cropViewRect, CGAffineTransformMakeScale(scale, scale));
    
    UIImage *cropImage = [image subImageWithRect:cropRect];
    if (self.completion) {
        self.completion(image, cropImage);
    }
}

#pragma mark - getter
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:UIImage(@"close") forState:UIControlStateNormal];
        _backBtn.backgroundColor = [UIColor redColor];
        [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
- (void)backClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}
- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.backgroundColor = [UIColor whiteColor];
        [_cameraButton setImage:UIImage(@"trigger") forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(cameraClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cameraButton;
}
- (void)cameraClick {
    [self takePhoto];
}
@end
