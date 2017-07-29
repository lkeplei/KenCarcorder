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
@property (nonatomic, strong) UIView *historyV;

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
        [self.videoV stopShareVedio];
    } else {
        if (ask) {
            [self presentConfirmViewInController:self confirmTitle:@"提示"
                                         message:@"分享设备将可能会耗费您较多的数据流量，并请保护自己和他人的隐私。请确认是否继续?"
                              confirmButtonTitle:@"分享" cancelButtonTitle:@"取消" confirmHandler:^{
                                  @strongify(self)
                                  [self.videoV shareVedio];
                              } cancelHandler:^{
                              }];
        } else {
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

@end
