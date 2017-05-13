//
//  KenQRCodeVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenQRCodeVC.h"
#import "KenScanningV.h"
#import "KenCaptureHelper.h"

@import AVFoundation;

@interface KenQRCodeVC ()

@property (nonatomic,assign) BOOL isInit;
@property (nonatomic,strong) UIView *userview;
@property (nonatomic,strong) UIView *preview;
@property (nonatomic,strong) KenCaptureHelper *captureHelper;
@property (nonatomic,strong) KenScanningV *scanningView;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@end

@implementation KenQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"扫一扫"];
    
    //    [self setRightNavItemWithImage:[UIImage imageNamed:@"scan_right_item.png"]
    //                            imgSec:[UIImage imageNamed:@"scan_right_item_sec.png"] selector:@selector(rightNaviItemClicked)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self isCameraAuthorized]) {
                    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                        [self startAppleQRReader];
                    }else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相机不可用。" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        alertView.delegate = self;
                        [alertView show];
                    }
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的\"设置-隐私-相机\"选项中,允许七彩云视频访问您的相机。" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                alertView.delegate = self;
                [alertView show];
            });
        }
    }];
}

- (BOOL)isCameraAuthorized {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized){
        return YES;
    } else if (authStatus == AVAuthorizationStatusDenied){
        return NO;
    } else {
        return YES;
    }
}

- (void)startAppleQRReader {
    if(!_isInit){
        _isInit = YES;
        [self.activityView startAnimating];
        @weakify(self)
        [self.captureHelper showCaptureOnView:self.preview complete:^{
            @strongify(self)
            [self.activityView stopAnimating];
            [self.scanningView scanning];
        }];
    }
}

- (UIActivityIndicatorView *)activityView {
    if(!_activityView){
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.center = CGPointMake(self.contentView.center.x, self.contentView.center.y - 60 + 20);
        [self.userview addSubview:_activityView];
    }
    return _activityView;
}

- (KenScanningV *)scanningView {
    if (!_scanningView) {
        _scanningView = [[KenScanningV alloc] initWithFrame:(CGRect){CGPointZero, self.contentView.size}];
        [self.contentView addSubview:_scanningView];
    }
    return _scanningView;
}

- (UIView *)userview {
    if(!_userview){
        _userview = [[UIView alloc] initWithFrame:self.contentView.bounds];
    }
    return _userview;
}

- (UIView *)preview {
    if (!_preview) {
        _preview = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_preview];
    }
    return _preview;
}

- (KenCaptureHelper *)captureHelper {
    if (!_captureHelper) {
        _captureHelper = [[KenCaptureHelper alloc] init];
        @weakify(self)
        [_captureHelper setDidOutputSampleBufferHandle:^(NSString *urlString) {
            @strongify(self)
            [self.delegate qrReaderViewController:self didFinishPickingInformation:urlString];
        }];
    }
    return _captureHelper;
}

#pragma mark - alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self popViewController];
}

#pragma mark - button
- (void)rightNaviItemClicked {
    DebugLog("rightNaviItemClicked");
}

@end
