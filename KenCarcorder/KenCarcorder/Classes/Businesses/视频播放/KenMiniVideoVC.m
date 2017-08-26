//
//  KenMiniVideoVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenMiniVideoVC.h"
#import "KenDeviceDM.h"
#import "KenVideoV.h"
#import "KenDeviceSettingVC.h"
#import "KenHistoryVC.h"

@interface KenMiniVideoVC ()

@property (nonatomic, assign) BOOL upDownScanning;          //是否正在上下扫描
@property (nonatomic, assign) BOOL leftRightScanning;       //是否正在左右扫描

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) UIView *functionV;
@property (nonatomic, strong) UIView *videoNav;
@property (nonatomic, strong) UIView *fullMaskV;
@property (nonatomic, strong) UIButton *speakBtn;
@property (nonatomic, strong) UIView *historyV;
@property (nonatomic, strong) UIView *settingV;
@property (nonatomic, strong) UILabel *statusL;
@property (nonatomic, strong) UILabel *speedLabebl;         //速度标签
@property (nonatomic, strong) UIButton *scanUDBtn;
@property (nonatomic, strong) UIButton *scanLRBtn;
@property (nonatomic, strong) UIButton *turnUDBtn;
@property (nonatomic, strong) UIButton *turnLRBtn;

@end

@implementation KenMiniVideoVC
#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _upDownScanning = YES;
        _leftRightScanning = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.videoNav];
    [self.contentView addSubview:self.functionV];
    [self.contentView addSubview:self.historyV];
    [self.contentView addSubview:self.settingV];
    [self.contentView addSubview:self.speakBtn];
    
    [self setLeftNavItemWithImg:[UIImage imageNamed:@"app_back"] selector:@selector(back)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    @weakify(self)
    [[KenGCDTimerManager sharedInstance] scheduledTimerWithName:@"miniVideoTime" timeInterval:1 queue:nil repeats:YES
                                                   actionOption:kKenGCDTimerAbandon action:^{
        @strongify(self)
        [Async main:^{
            self.speedLabebl.text = self.videoV.speed;
        }];
    }];
    
    [self.videoV rePlay];
    
    SysDelegate.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[KenGCDTimerManager sharedInstance] cancelTimerWithName:@"miniVideoTime"];
    
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
    [self.videoNav removeFromSuperview];
    
    self.videoV.frame = (CGRect){CGPointZero, SysDelegate.window.height, SysDelegate.window.width};
    self.statusL.frame = (CGRect){self.videoV.width - 60, 5, 46, 20};
    [SysDelegate.window addSubview:self.videoV];
    [SysDelegate.window addSubview:self.fullMaskV];
}

- (void)exitFullscreen {
    [self.videoV removeFromSuperview];
    [self.fullMaskV removeFromSuperview];
    
    self.videoV.frame = (CGRect){0, 0, MainScreenHeight, ceilf(MainScreenHeight * kAppImageHeiWid)};
    self.statusL.frame = (CGRect){self.videoV.width - 60, 5, 46, 20};
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.videoNav];
}

#pragma mark - event
- (void)back {
    //页面退出时保存最新的截图
    if (thNet_IsConnect(_device.connectHandle) && ![_device isDDNS]) {
        if ([UIApplication isNotEmpty:_videoV.lastImage]) {
            NSString *jpgPath = [NSString stringWithFormat:@"%@/%@.jpg", [KenCarcorder getHomeSnapFolder], _device.sn];
            [KenCarcorder writeImage:_videoV.lastImage toFileAtPath:jpgPath];
        }
    }
    
    //p2p 且已连通只需要断开视频，否则要完整断开；ddns 完整断开
    if ([_device isDDNS]) {
        if (thNet_IsConnect(self.device.connectHandle)) {
            [self.videoV stopVideo];
        } else {
            [self.videoV finishVideo];
        }
    } else {
        [self.videoV finishVideo];
    }

    [super popViewController];
}

- (void)speakStart {
    [self.videoV speakStart];
}

- (void)speakEnd {
    [self.videoV speakEnd];
}

- (void)scanUpdown {
    @weakify(self)
    if (_upDownScanning) {
        [[KenServiceManager sharedServiceManager] deviceScanStop:self.device start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            @strongify(self)
            if (successful) {
                self.upDownScanning = NO;
                self.leftRightScanning = NO;
                [Async main:^{
                    [self.scanLRBtn setImage:[UIImage imageNamed:@"video_scan_left_right"] forState:UIControlStateNormal];
                    [self.scanUDBtn setImage:[UIImage imageNamed:@"video_scan_up_down"] forState:UIControlStateNormal];
                }];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    } else {
        [[KenServiceManager sharedServiceManager] deviceScanUpDown:self.device start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            @strongify(self)
            if (successful) {
                self.upDownScanning = !self.upDownScanning;
                [Async main:^{
                    [self.scanUDBtn setImage:[UIImage imageNamed:self.upDownScanning ? @"video_scan_up_down_hl" : @"video_scan_up_down"] forState:UIControlStateNormal];
                }];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    }
}

- (void)scanLeftRight {
    @weakify(self)
    if (_leftRightScanning) {
        [[KenServiceManager sharedServiceManager] deviceScanStop:self.device start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            @strongify(self)
            if (successful) {
                self.upDownScanning = NO;
                self.leftRightScanning = NO;
                [Async main:^{
                    [self.scanLRBtn setImage:[UIImage imageNamed:@"video_scan_left_right"] forState:UIControlStateNormal];
                    [self.scanUDBtn setImage:[UIImage imageNamed:@"video_scan_up_down"] forState:UIControlStateNormal];
                }];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    } else {
        [[KenServiceManager sharedServiceManager] deviceScanLeftRight:self.device start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            @strongify(self)
            if (successful) {
                self.leftRightScanning = !self.leftRightScanning;
                [Async main:^{
                    [self.scanLRBtn setImage:[UIImage imageNamed:self.leftRightScanning ? @"video_scan_left_right_hl" : @"video_scan_left_right"] forState:UIControlStateNormal];
                }];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    }
}

- (void)turnUpDown {
    @weakify(self)
    [[KenServiceManager sharedServiceManager] deviceTurnUpDown:self.device flip:self.videoV.isFlip start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        @strongify(self)
        if (successful) {
            self.videoV.isFlip = !self.videoV.isFlip;
            [Async main:^{
               [self.turnUDBtn setImage:[UIImage imageNamed:self.videoV.isFlip ? @"video_turn_up_down_hl" : @"video_turn_up_down"] forState:UIControlStateNormal];
            }];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
    }];
}

- (void)turnLeftRight {
    @weakify(self)
    [[KenServiceManager sharedServiceManager] deviceTurnLeftRight:self.device mirror:self.videoV.isMirror start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        @strongify(self)
        if (successful) {
            self.videoV.isMirror = !self.videoV.isMirror;
            [Async main:^{
                [self.turnLRBtn setImage:[UIImage imageNamed:self.videoV.isMirror ? @"video_turn_left_right_hl" : @"video_turn_left_right"] forState:UIControlStateNormal];
            }];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
    }];
}

- (void)functionUp {
    if (thNet_PTZControl(_device.connectHandle, 1, 1, 400, 1)) {
        [Async mainAfter:0.2 block:^{
            thNet_PTZControl(_device.connectHandle, 2, 1, 400, 1);
        }];
    }
}

- (void)functionLongUp {
    
}

- (void)functionDown {
    if (thNet_PTZControl(_device.connectHandle, 3, 1, 400, 1)) {
        [Async mainAfter:0.2 block:^{
            thNet_PTZControl(_device.connectHandle, 4, 1, 400, 1);
        }];
    }
}

- (void)functionLongDown {
    
}

- (void)functionLeft {
    if (thNet_PTZControl(_device.connectHandle, 7, 1, 400, 1)) {
        [Async mainAfter:0.2 block:^{
            thNet_PTZControl(_device.connectHandle, 8, 1, 400, 1);
        }];
    }
}

- (void)functionLongLeft {
    
}

- (void)functionRight {
    if (thNet_PTZControl(_device.connectHandle, 5, 1, 400, 1)) {
        [Async mainAfter:0.2 block:^{
            thNet_PTZControl(_device.connectHandle, 6, 1, 400, 1);
        }];
    }
}

- (void)functionLongRight {
    
}

- (void)speaker:(UIButton *)button {
    _videoV.playAudio = !_videoV.playAudio;
    if (_videoV.playAudio) {
        [button setImage:[UIImage imageNamed:@"video_speaker"] forState:UIControlStateNormal];
        thNet_Play(_device.connectHandle, 1, 1, 0);
    } else {
        [button setImage:[UIImage imageNamed:@"video_speaker_close"] forState:UIControlStateNormal];
        thNet_Play(_device.connectHandle, 1, 0, 0);
    }
}

- (void)navBtnClicked:(UIButton *)button {
    NSUInteger type = button.tag - 1100;
    if (type == 0) {
        //全屏
        [KenCarcorder setOrientation:UIInterfaceOrientationPortrait];
    } else if (type == 1) {
        [_videoV recordVideo];
    } else if (type == 2) {
        //拍照
        if(thNet_IsConnect(_device.connectHandle)) {
            [_videoV capture];
            [self showToastWithMsg:@"抓拍成功"];
            [[KenCarcorder shareCarcorder] playVoiceByType:kKenVoiceCapture];
        }
    } else if (type == 3) {
        [self shareVedio:YES];
    } else if (type == 4) {
        [self changeDeviceNetStatus];
    }
}

- (void)shareVedio:(BOOL)ask {
    @weakify(self)
    if ([self.videoV isSharing]) {
        [self.videoV stopShareVedio];
        self.statusL.hidden = YES;
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

- (void)shareBtn {
    [self shareVedio:NO];
}

- (void)changeDeviceNetStatus {
    @weakify(self)
    [self presentConfirmViewInController:self confirmTitle:@"提示"
                                 message:[NSString stringWithFormat:@"您当前连接方式已切换为（%@）,需要退出重新连接视频", [self.device isDDNS] ? @"ddns" : @"p2p"]
                      confirmButtonTitle:@"确定" cancelButtonTitle:nil confirmHandler:^{
                          @strongify(self)
                          [self back];
                          
                          [[KenUserInfoDM sharedInstance] changeNetStatus:self.device];
                      } cancelHandler:^{
                      }];
}

#pragma mark - private method
- (void)initTurnFunctionV {
    UIImageView *funtionBgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_fun_bg"]];
    funtionBgV.center = CGPointMake(self.functionV.width / 2, self.functionV.height / 2);
    [funtionBgV setUserInteractionEnabled:YES];
    [self.functionV addSubview:funtionBgV];

    @weakify(self)
    UIView *upV = [[UIView alloc] initWithFrame:(CGRect){(funtionBgV.width - 60) / 2, 0, 60, 42}];
    upV.backgroundColor = [UIColor clearColor];
    [funtionBgV addSubview:upV];
    [upV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionUp];
    }];
    
    [upV longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongUp];
    }];
    
    UIView *downV = [[UIView alloc] initWithFrame:(CGRect){upV.originX, funtionBgV.height - upV.height, upV.size}];
    downV.backgroundColor = [UIColor clearColor];
    [funtionBgV addSubview:downV];
    [downV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionDown];
    }];
    
    [downV longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongDown];
    }];
    
    UIView *leftV = [[UIView alloc] initWithFrame:(CGRect){0, (funtionBgV.height - 42) / 2, 42, 60}];
    leftV.backgroundColor = [UIColor clearColor];
    [funtionBgV addSubview:leftV];
    [leftV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLeft];
    }];
    
    [leftV longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongLeft];
    }];
    
    UIView *rightV = [[UIView alloc] initWithFrame:(CGRect){funtionBgV.width - leftV.width, leftV.originY, leftV.size}];
    rightV.backgroundColor = [UIColor clearColor];
    [funtionBgV addSubview:rightV];
    [rightV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionRight];
    }];
    
    [rightV longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongRight];
    }];
}

- (void)initScanFunctionV {
    CGFloat width = kKenOffsetX(200);
    CGSize size = CGSizeMake(width, 36);
    
    _scanUDBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_scan_up_down"]
                                imagesec:nil target:self action:@selector(scanUpdown)];
    _scanUDBtn.frame = (CGRect){10, 20, size};
    [self.functionV addSubview:_scanUDBtn];
    
    _scanLRBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_scan_left_right"]
                                imagesec:nil target:self action:@selector(scanLeftRight)];
    _scanLRBtn.frame = (CGRect){_scanUDBtn.originX, self.functionV.height - 20 - size.height, size};
    [self.functionV addSubview:_scanLRBtn];
    
    _turnUDBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_turn_up_down"]
                                         imagesec:nil target:self action:@selector(turnUpDown)];
    _turnUDBtn.frame = (CGRect){self.functionV.width - 10 - size.width, _scanUDBtn.originY, size};
    [self.functionV addSubview:_turnUDBtn];
    
    _turnLRBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_turn_left_right"]
                                         imagesec:nil target:self action:@selector(turnLeftRight)];
    _turnLRBtn.frame = (CGRect){_turnUDBtn.originX, _scanLRBtn.originY, size};
    [self.functionV addSubview:_turnLRBtn];
}

#pragma mark - getter setter
- (void)setDevice:(KenDeviceDM *)device {
    _device = device;
    
    [self setNavTitle:_device.name];
    
    [self.videoV showVideoWithDevice:_device];
}

- (KenVideoV *)videoV {
    if (_videoV == nil) {
        _videoV = [[KenVideoV alloc] initWithFrame:(CGRect){0, 0, MainScreenWidth, ceilf(MainScreenWidth * kAppImageHeiWid)}];
        
        @weakify(self)
        _videoV.deviceGetFinish = ^() {
            @strongify(self)
            [Async main:^{
                [self.turnLRBtn setImage:[UIImage imageNamed:self.videoV.isMirror ? @"video_turn_left_right_hl" : @"video_turn_left_right"] forState:UIControlStateNormal];
                [self.turnUDBtn setImage:[UIImage imageNamed:self.videoV.isFlip ? @"video_turn_up_down_hl" : @"video_turn_up_down"] forState:UIControlStateNormal];
            }];
        };
    }
    return _videoV;
}

- (UIView *)videoNav {
    if (_videoNav == nil) {
        _videoNav = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY - kKenOffsetY(86),
                                                            self.contentView.width, kKenOffsetY(86)}];
        _videoNav.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        
        UIButton *speaker = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_speaker"]
                                           imagesec:nil target:self action:@selector(speaker:)];
        speaker.frame = (CGRect){0, 0, speaker.width + kKenOffsetX(50), _videoNav.height};
        [_videoNav addSubview:speaker];
        
        _speedLabebl = [UILabel labelWithTxt:@"" frame:(CGRect){speaker.maxX, 0, 80, _videoNav.height}
                                        font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _speedLabebl.numberOfLines = 0;
        [_videoNav addSubview:_speedLabebl];
        
        NSArray *btnArr = @[@"history_full", @"history_video", @"history_photo", @"video_share", [_device isDDNS] ? @"video_net_ddns" : @"video_net_p2p"];
        CGFloat offsetX = _videoV.width;
        for (NSUInteger i = 0; i < btnArr.count; i++) {
            UIButton *button = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:btnArr[i]]
                                              imagesec:nil target:self action:@selector(navBtnClicked:)];
            CGFloat width = button.width + kKenOffsetX(50);
            button.frame = (CGRect){offsetX - width, 0, width, _videoNav.height};
            offsetX = button.originX;
            
            button.tag = 1100 + i;
            
            [_videoNav addSubview:button];
        }
    }
    return _videoNav;
}

- (UIView *)fullMaskV {
    if (_fullMaskV == nil) {
        UIImage *image = [UIImage imageNamed:@"full_photo"];
        _fullMaskV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * 3, image.size.height)];
        _fullMaskV.center = (CGPoint){SysDelegate.window.height / 2, SysDelegate.window.width - _fullMaskV.height / 2 - 10};
        
        UIButton *photo = [UIButton buttonWithImg:nil zoomIn:YES image:image imagesec:nil target:self action:@selector(navBtnClicked:)];
        photo.center = (CGPoint){_fullMaskV.width / 2, _fullMaskV.height / 2};
        photo.tag = 1100 + 2;
        [_fullMaskV addSubview:photo];
        
        UIButton *share = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"full_share"] imagesec:nil target:self action:@selector(shareBtn)];
        share.center = (CGPoint){share.width / 2, photo.centerY};
        [_fullMaskV addSubview:share];
        
        UIButton *play = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"full_play"] imagesec:nil target:self action:@selector(navBtnClicked:)];
        play.center = (CGPoint){_fullMaskV.width - play.width / 2, photo.centerY};
        play.tag = 1100 + 1;
        [_fullMaskV addSubview:play];
    }
    return _fullMaskV;
}

- (UIView *)functionV {
    if (_functionV == nil) {
        UIImage *funBg = [UIImage imageNamed:@"video_fun_bg"];
        _functionV = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width, funBg.size.height + kKenOffsetY(60)}];
        _functionV.backgroundColor = [UIColor whiteColor];
        
        [self initTurnFunctionV];
        [self initScanFunctionV];
    }
    return _functionV;
}

- (UIView *)historyV {
    if (_historyV == nil) {
        _historyV = [[UIView alloc] initWithFrame:(CGRect){20, self.functionV.maxY + 25, 90, 36}];
        _historyV.backgroundColor = [UIColor whiteColor];
        _historyV.layer.cornerRadius = 4;
        _historyV.layer.masksToBounds = YES;
        
        UIImageView *iCon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_history"]];
        iCon.center = CGPointMake(10 + iCon.width / 2, _historyV.height / 2);
        [_historyV addSubview:iCon];
        
        UILabel *label = [UILabel labelWithTxt:@"回看" frame:(CGRect){iCon.maxX, 0, _historyV.width - iCon.maxX, _historyV.height}
                                          font:[UIFont appFontSize14] color:[UIColor appMainColor]];
        [_historyV addSubview:label];
        
        @weakify(self)
        [_historyV clicked:^(UIView * _Nonnull view) {
            @strongify(self)
            [self pushViewController:[[KenHistoryVC alloc] initWithDevice:self.device] animated:YES];
            [self.videoV stopVideo];
        }];
    }
    return _historyV;
}

- (UIView *)settingV {
    if (_settingV == nil) {
        _settingV = [[UIView alloc] initWithFrame:(CGRect){self.contentView.width - self.historyV.originX - self.historyV.width, self.historyV.originY, self.historyV.size}];
        _settingV.backgroundColor = [UIColor whiteColor];
        _settingV.layer.cornerRadius = 4;
        _settingV.layer.masksToBounds = YES;
        
        UIImageView *iCon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_setting"]];
        iCon.center = CGPointMake(10 + iCon.width / 2, _settingV.height / 2);
        [_settingV addSubview:iCon];
        
        UILabel *label = [UILabel labelWithTxt:@"设置" frame:(CGRect){iCon.maxX, 0, _settingV.width - iCon.maxX, _settingV.height}
                                          font:[UIFont appFontSize14] color:[UIColor appMainColor]];
        [_settingV addSubview:label];
        
        @weakify(self)
        [_settingV clicked:^(UIView * _Nonnull view) {
            @strongify(self)
            [self pushViewController:[[KenDeviceSettingVC alloc] initWithDevice:self.device] animated:YES];
            [self.videoV stopVideo];
        }];
    }
    return _settingV;
}

- (UIButton *)speakBtn {
    if (_speakBtn == nil) {
        UIImage *hlImage = [UIImage imageNamed:@"video_speaking"];
        _speakBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_speak"]
                                   imagesec:hlImage target:self action:@selector(speakStart)];
        _speakBtn.frame = (CGRect){(self.contentView.width - hlImage.size.width) / 2, self.contentView.height - hlImage.size.height - 20, hlImage.size};
        [_speakBtn addTarget:self action:@selector(speakEnd) forControlEvents:UIControlEventTouchDown];
        
        _speakBtn.backgroundColor = [UIColor whiteColor];
        _speakBtn.layer.cornerRadius = _speakBtn.width / 2;
        _speakBtn.layer.masksToBounds = YES;
    }
    return _speakBtn;
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
