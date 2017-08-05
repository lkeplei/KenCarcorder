//
//  KenAlarmRecordVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAlarmRecordVC.h"
#import "KenDeviceDM.h"
#import "KenVideoV.h"
#import "KenAlarmDM.h"

#import "thSDKlib.h"

@interface KenAlarmRecordVC ()

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UIView *funtionNav;
@property (nonatomic, strong) UIView *descV;
@property (nonatomic, strong) UIImageView *playV;

@property (nonatomic, strong) KenAlarmItemDM *itemInfo;        //当前文件名
@property (nonatomic, strong) UILabel *speedLabel;              //速度标签
@property (nonatomic, strong) UILabel *vedioSpeedLabel;         //视频播放速度标签
@property (nonatomic, strong) UIButton *recoverBtn;             //恢复按钮

@end

@implementation KenAlarmRecordVC
#pragma mark - life cycle
- (instancetype)initWithDevice:(KenDeviceDM *)device info:(KenAlarmItemDM *)info {
    self = [super init];
    if (self) {
        _deviceInfo = device;
        _itemInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"报警回看"];
    
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.funtionNav];
    [self.contentView addSubview:self.descV];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SysDelegate.allowRotation = YES;
    
    @weakify(self)
    [[KenGCDTimerManager sharedInstance] scheduledTimerWithName:@"miniVideoTime" timeInterval:1 queue:nil repeats:YES
                                                   actionOption:kKenGCDTimerAbandon action:^{
                                                       @strongify(self)
                                                       [Async main:^{
                                                           self.speedLabel.text = self.videoV.speed;
                                                       }];
                                                   }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    SysDelegate.allowRotation = NO;
    [Async background:^{
        [_videoV stopRecorder];
    }];
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
    [self.funtionNav removeFromSuperview];
    
    self.videoV.frame = (CGRect){CGPointZero, SysDelegate.window.height, SysDelegate.window.width};
    [SysDelegate.window addSubview:self.videoV];
}

- (void)exitFullscreen {
    [self.videoV removeFromSuperview];
    [self.funtionNav removeFromSuperview];
    
    self.videoV.frame = (CGRect){CGPointZero, MainScreenHeight, ceilf(MainScreenHeight * kAppImageHeiWid)};
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.funtionNav];
}

#pragma mark - event
- (void)navBtnClicked:(UIButton *)button {
    NSInteger tag = button.tag - 1100;
    
    switch (tag) {
        case 0: {
            //快退
            [self setPlaySpeed:[self.videoV recorderRewind]];
        }
            break;
        case 1: {
            //播放
            self.playV.hidden = YES;
            
            if ([NSString isNotEmpty:_itemInfo.recfilename]) {
                [_videoV playRecorder:_itemInfo.recfilename];
            } else {
                [self showToastWithMsg:@"请选择需要播放的文件"];
            }
        }
            break;
        case 2: {
            //快进
            [self setPlaySpeed:[self.videoV recorderSpeed]];
        }
            break;
        case 100: {
            //全屏
            [KenCarcorder setOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case 101: {
            //录像
            [self.videoV recordVideo];
        }
            break;
        case 102: {
            //拍照
            if(thNet_IsConnect(self.deviceInfo.connectHandle)) {
                [_videoV capture];
                [self showToastWithMsg:@"抓拍成功"];
                [[KenCarcorder shareCarcorder] playVoiceByType:kKenVoiceCapture];
            }
        }
            break;
        case 103: {
            //下载
            [self.videoV downloadRecorder];
        }
            break;
        default:
            break;
    }
}

- (void)recoverBtnClicked {
    [self setPlaySpeed:[self.videoV recoverRecorder]];
}

#pragma mark - private method
- (void)setPlaySpeed:(NSUInteger)speed {
    self.recoverBtn.hidden = speed == 1 ? YES : NO;
    self.vedioSpeedLabel.hidden = speed == 1 ? YES : NO;
    
    self.vedioSpeedLabel.text = [NSString stringWithFormat:@"X %zd", speed];
}

#pragma mark - getter setter
- (UILabel *)vedioSpeedLabel {
    if (_vedioSpeedLabel == nil) {
        _vedioSpeedLabel = [UILabel labelWithTxt:@"" frame:(CGRect){self.contentView.width - 60, 10, 60, 30}
                                            font:[UIFont appFontSize16] color:[UIColor appWhiteTextColor]];
        [self.contentView addSubview:_vedioSpeedLabel];
    }
    return _vedioSpeedLabel;
}

- (KenVideoV *)videoV {
    if (_videoV == nil) {
        _videoV = [[KenVideoV alloc] initHistoryWithDevice:_deviceInfo frame:(CGRect){0, 0, MainScreenWidth, ceilf(MainScreenWidth * kAppImageHeiWid)}];
        
        _playV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alarm_play"]];
        _playV.center = CGPointMake(_videoV.width / 2, (_videoV.height - kKenOffsetY(86)) / 2);
        [_videoV addSubview:_playV];
        
        @weakify(self)
        [self.playV clicked:^(UIView * _Nonnull view) {
            @strongify(self)
            [self.videoV playRecorder:self.itemInfo.recfilename];
            [self.playV removeFromSuperview];
        }];
    }
    return _videoV;
}

- (UIView *)funtionNav {
    if (_funtionNav == nil) {
        _funtionNav = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY - kKenOffsetY(86), self.contentView.width, kKenOffsetY(86)}];
        _funtionNav.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        //左边功能按钮
        NSArray *btnArr = @[@"history_rewind", @"history_play", @"history_speed"];
        CGFloat offsetX = 0;
        for (NSUInteger i = 0; i < btnArr.count; i++) {
            UIButton *button = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:btnArr[i]]
                                              imagesec:nil target:self action:@selector(navBtnClicked:)];
            CGFloat width = button.width + kKenOffsetX(20);
            button.frame = (CGRect){offsetX, 0, width, _funtionNav.height};
            offsetX += width;
            
            button.tag = 1100 + i;
            
            [_funtionNav addSubview:button];
        }
        
        //速度标签
        _speedLabel = [UILabel labelWithTxt:@"" frame:(CGRect){offsetX, 0, 70, _funtionNav.height}
                                       font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _speedLabel.numberOfLines = 0;
        [_funtionNav addSubview:_speedLabel];
        
        //恢复按钮
        _recoverBtn = [UIButton buttonWithImg:@"恢复" zoomIn:NO image:nil imagesec:nil
                                       target:self action:@selector(recoverBtnClicked)];
        _recoverBtn.frame = CGRectMake(_speedLabel.maxX, 6, 40, _funtionNav.height - 12);
        _recoverBtn.hidden = YES;
        _recoverBtn.layer.cornerRadius = 4;
        _recoverBtn.layer.masksToBounds = YES;
        _recoverBtn.layer.borderWidth = 1;
        _recoverBtn.layer.borderColor = [[UIColor colorWithHexString:@"#79CDFA"] CGColor];
        [_recoverBtn setTitleColor:[UIColor colorWithHexString:@"#79CDFA"] forState:UIControlStateNormal];
        [_funtionNav addSubview:_recoverBtn];
        
        //右边功能按钮
        btnArr = @[@"history_full", @"history_video", @"history_photo"/*, @"history_download"*/];
        offsetX = _videoV.width;
        for (NSUInteger i = 0; i < btnArr.count; i++) {
            UIButton *button = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:btnArr[i]]
                                              imagesec:nil target:self action:@selector(navBtnClicked:)];
            CGFloat width = button.width + kKenOffsetX(40);
            button.frame = (CGRect){offsetX - width, 0, width, _funtionNav.height};
            offsetX = button.originX;
            
            button.tag = 1200 + i;
            
            [_funtionNav addSubview:button];
        }
    }
    return _funtionNav;
}

- (UIView *)descV {
    if (_descV == nil) {
        _descV = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width, self.contentView.height - self.videoV.maxY}];
        
        UILabel *label1 = [UILabel labelWithTxt:nil frame:(CGRect){15, 20, _descV.width, 20} font:[UIFont appFontSize16] color:[UIColor appBlackTextColor]];
        label1.textAlignment = NSTextAlignmentLeft;
        [_descV addSubview:label1];
        
        NSString *content = [@"设备名称：" stringByAppendingString:[_itemInfo getDeviceName]];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appDarkGrayTextColor] range:NSMakeRange(5, content.length - 5)];
        label1.attributedText = attributedString;
        
        UILabel *label2 = [UILabel labelWithTxt:nil frame:(CGRect){15, label1.maxY + 10, _descV.width, 20} font:[UIFont appFontSize16] color:[UIColor appBlackTextColor]];
        label2.textAlignment = NSTextAlignmentLeft;
        [_descV addSubview:label2];
        
        content = [@"报警类型：" stringByAppendingString:[_itemInfo getAlarmTypeString]];
        attributedString = [[NSMutableAttributedString alloc] initWithString:content];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appStressRedColor] range:NSMakeRange(5, content.length - 5)];
        label2.attributedText = attributedString;
        
        UILabel *label3 = [UILabel labelWithTxt:nil frame:(CGRect){15, label2.maxY + 10, _descV.width, 20} font:[UIFont appFontSize16] color:[UIColor appBlackTextColor]];
        label3.textAlignment = NSTextAlignmentLeft;
        [_descV addSubview:label3];
        
        content = [@"报警时间：" stringByAppendingString:[_itemInfo getAlarmTimeString]];
        attributedString = [[NSMutableAttributedString alloc] initWithString:content];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appDarkGrayTextColor] range:NSMakeRange(5, content.length - 5)];
        label3.attributedText = attributedString;
    }
    return _descV;
}

@end
