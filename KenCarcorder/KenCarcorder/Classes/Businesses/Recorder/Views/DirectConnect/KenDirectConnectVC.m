//
//  KenDirectConnectVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/4.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDirectConnectVC.h"
#import "KenAlertView.h"
#import "KenVideoV.h"
#import "KenDeviceDM.h"
#import "KenDeviceSettingVC.h"
#import "KenHistoryVC.h"

@interface KenDirectConnectVC ()

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) UIView *functionV;
@property (nonatomic, strong) UIView *fullMaskV;
@property (nonatomic, strong) UIView *historyV;
@property (nonatomic, strong) UILabel *statusL;

@end

@implementation KenDirectConnectVC
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.historyV];
    [self.contentView addSubview:self.functionV];
    
    [self setLeftNavItemWithImg:[UIImage imageNamed:@"app_back"] selector:@selector(back)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    SysDelegate.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    SysDelegate.allowRotation = NO;
}

#pragma mark - rotate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [self exitFullscreen];
    } else {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            [self enterFullscreen];
        }
    }
}

- (void)enterFullscreen {
    [self.videoV removeFromSuperview];
    [self.fullMaskV removeFromSuperview];
    
    self.videoV.frame = (CGRect){CGPointZero, SysDelegate.window.height, SysDelegate.window.width};
    self.statusL.frame = (CGRect){self.videoV.width - 60, 5, 46, 20};
    [SysDelegate.window addSubview:self.videoV];
    [SysDelegate.window addSubview:self.fullMaskV];
}

- (void)exitFullscreen {
    [self.videoV removeFromSuperview];
    [self.fullMaskV removeFromSuperview] ;
    
    self.videoV.frame = (CGRect){0, 0, MainScreenHeight, ceilf(MainScreenHeight * kAppImageHeiWid)};
    self.statusL.frame = (CGRect){self.videoV.width - 60, 5, 46, 20};
    [self.contentView addSubview:self.videoV];
}

#pragma mark - event
- (void)back {
    [_videoV finishVideo];
    
    [self popToRootViewControllerAnimated:NO];
    [SysDelegate.rootVC changToHome];
}

- (void)eventVideo {
    [self.videoV recordVideo];
}

- (void)eventHistory {
    [self pushViewController:[[KenHistoryVC alloc] initWithDevice:self.device] animated:YES];
    [self.videoV stopVideo];
}

- (void)eventPhoto {
    if(thNet_IsConnect(_device.connectHandle)) {
        [_videoV capture];
        [self showToastWithMsg:@"抓拍成功"];
        [[KenCarcorder shareCarcorder] playVoiceByType:kKenVoiceCapture];
    }
}

- (void)eventSetting {
    [self pushViewController:[[KenDeviceSettingVC alloc] initWithDevice:self.device] animated:YES];
    [self.videoV stopVideo];
}

- (void)eventShare {
    [self shareVedio:YES];
}

#pragma mark - private methos
- (UIButton *)eventBtn:(CGPoint)origin image:(UIImage *)image text:(NSString *)text action:(SEL)action {
    UIButton *button = [UIButton buttonWithImg:text zoomIn:YES image:image imagesec:nil target:self action:action];
    button.origin = origin;
    button.size = CGSizeMake(90, 36);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 6;
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 0);
    
    return button;
}

- (void)shareVedio:(BOOL)ask {
    @weakify(self)
    if ([self.videoV isSharing]) {
        self.statusL.hidden = YES;
        [self.videoV stopShareVedio];
    } else {
        if (ask) {
            [self presentConfirmViewInController:self confirmTitle:@"提示"
                                         message:@"分享设备将可能会耗费您较多的数据流量，并请保护自己和他人的隐私。请确认是否继续?"
                              confirmButtonTitle:@"分享" cancelButtonTitle:@"取消" confirmHandler:^{
                                  @strongify(self)
                                  self.statusL.hidden = NO;
                                  [self.videoV shareVedio];
                              } cancelHandler:^{
                              }];
        } else {
            self.statusL.hidden = NO;
            [self.videoV shareVedio];
        }
    }
}

#pragma mark - getter setter
- (void)setDevice:(KenDeviceDM *)device {
    _device = device;
    
    [self setNavTitle:_device.name];
    
    [self.videoV showVideoWithDevice:_device];
}

- (UIView *)historyV {
    if (_historyV == nil) {
        _historyV = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width, 0/*90*/}];
        _historyV.backgroundColor = [UIColor whiteColor];
    }
    return _historyV;
}

- (UIView *)functionV {
    if (_functionV == nil) {
        _functionV = [[UIView alloc] initWithFrame:(CGRect){0, self.historyV.maxY, self.contentView.width, self.contentView.height - self.historyV.maxY}];
        _functionV.backgroundColor = [UIColor appBackgroundColor];
        
        UIButton *videoBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"recorder_video"] imagesec:nil target:self action:@selector(eventVideo)];
        videoBtn.center = CGPointMake(_functionV.width / 2, _functionV.height / 2);
        [_functionV addSubview:videoBtn];
        
        [_functionV addSubview:[self eventBtn:(CGPoint){15, videoBtn.minY - 10}
                                        image:[UIImage imageNamed:@"recorder_history"] text:@"回看" action:@selector(eventHistory)]];
        [_functionV addSubview:[self eventBtn:(CGPoint){15, videoBtn.maxY - 26}
                                        image:[UIImage imageNamed:@"recorder_photo"] text:@"拍照" action:@selector(eventPhoto)]];
        [_functionV addSubview:[self eventBtn:(CGPoint){_functionV.width - 105, videoBtn.minY - 10}
                                        image:[UIImage imageNamed:@"recorder_setting"] text:@"设置" action:@selector(eventSetting)]];
        [_functionV addSubview:[self eventBtn:(CGPoint){_functionV.width - 105, videoBtn.maxY - 26}
                                        image:[UIImage imageNamed:@"recorder_share"] text:@"直播" action:@selector(eventShare)]];
        
    }
    return _functionV;
}

- (KenVideoV *)videoV {
    if (_videoV == nil) {
        _videoV = [[KenVideoV alloc] initWithFrame:(CGRect){0, 0, MainScreenWidth, ceilf(MainScreenWidth * kAppImageHeiWid)}];
    }
    return _videoV;
}

- (UIView *)fullMaskV {
    if (_fullMaskV == nil) {
        UIImage *image = [UIImage imageNamed:@"full_photo"];
        _fullMaskV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * 3, image.size.height)];
        _fullMaskV.center = (CGPoint){SysDelegate.window.height / 2, SysDelegate.window.width - _fullMaskV.height / 2 - 10};
        
        UIButton *photo = [UIButton buttonWithImg:nil zoomIn:YES image:image imagesec:nil target:self action:@selector(eventPhoto)];
        photo.center = (CGPoint){_fullMaskV.width / 2, _fullMaskV.height / 2};
        [_fullMaskV addSubview:photo];
        
        UIButton *share = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"full_share"] imagesec:nil target:self action:@selector(eventShare)];
        share.center = (CGPoint){share.width / 2, photo.centerY};
        [_fullMaskV addSubview:share];
        
        UIButton *play = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"full_play"] imagesec:nil target:self action:@selector(eventVideo)];
        play.center = (CGPoint){_fullMaskV.width - play.width / 2, photo.centerY};
        [_fullMaskV addSubview:play];
    }
    return _fullMaskV;
}

- (UILabel *)statusL {
    if (_statusL == nil) {
        _statusL = [UILabel labelWithTxt:@"直播中" frame:(CGRect){self.videoV.width - 60, 5, 46, 20}
                                    font:[UIFont appFontSize12] color:[UIColor whiteColor]];
        _statusL.layer.borderColor = [UIColor whiteColor].CGColor;
        _statusL.layer.masksToBounds = YES;
        _statusL.layer.borderWidth = 0.5;
        _statusL.layer.cornerRadius = 4;
        _statusL.hidden = YES;
        [self.videoV addSubview:_statusL];
    }
    return _statusL;
}

@end
