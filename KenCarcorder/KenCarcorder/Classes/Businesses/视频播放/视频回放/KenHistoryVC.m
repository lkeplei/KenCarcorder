//
//  KenHistoryVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHistoryVC.h"
#import "KenDeviceDM.h"
#import "KenVideoV.h"

#import "thSDKlib.h"

@interface KenHistoryVC ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, assign) NSInteger dateSelectedIndex;
@property (nonatomic, assign) NSInteger hourSelectedIndex;
@property (nonatomic, assign) NSInteger minuteSelectedIndex;
@property (nonatomic, strong) NSMutableArray *recorderList;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSArray *dayArray;

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UIPickerView *filePickerView;
@property (nonatomic, strong) UIView *downloadListV;
@property (nonatomic, strong) UIView *funtionNav;

@property (nonatomic, strong) NSString *historyFileName;        //当前文件名
@property (nonatomic, assign) BOOL fileChange;                  //文件是否切换
@property (nonatomic, strong) UILabel *speedLabel;              //速度标签
@property (nonatomic, strong) UILabel *vedioSpeedLabel;         //视频播放速度标签
@property (nonatomic, strong) UIButton *recoverBtn;             //恢复按钮

@end

@implementation KenHistoryVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        _deviceInfo = device;
        _isFinished = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"历史回看"];
    
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.funtionNav];
    [self.contentView addSubview:self.downloadListV];
    [self.contentView addSubview:self.filePickerView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadHistoryData];
    
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
    
    _isFinished = YES;
    SysDelegate.allowRotation = NO;
    [_videoV stopRecorder];
}

#pragma mark - data
- (void)loadHistoryData {
    if (!_deviceInfo.deviceLock) {
        [[KenServiceManager sharedServiceManager] deviceLoadHistory:self.deviceInfo url:@"sd/subdir.txt" start:^{
            [self showActivity];
        } success:^(BOOL successful, NSString * _Nullable errMsg, id _Nullable info) {
            [self hideActivity];
            if (successful) {
                [self pareDateData:info];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
            [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
        }];
    }
}

- (void)pareDateData:(NSString *)info {
    if (![info isKindOfClass:[NSString class]] || [NSString isEmpty:info]) {
        [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
        [self hideActivity];
        return;
    }
    if ([info hasPrefix:@"-2"]) {
        DebugLog("找不到相关文件");
        [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
        [self hideActivity];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[info componentsSeparatedByString:@"\n"]];
        if ([UIApplication isEmpty:array] ||
            ([UIApplication isNotEmpty:array] && [[[array objectAtIndex:0] substringToIndex:2] hasPrefix:@"-2"])) {
            DebugLog("找不到相关文件");
            [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
            [self hideActivity];
        } else {
            _dateArray = [NSMutableArray array];
            for (NSInteger i = 0; i < [array count]; i++) {
                NSString *content = [array objectAtIndex:i];
                if ([KenCarcorder valideteYDDate:content]) {
                    content = [NSString stringWithFormat:@"%@.%@.%@", [content substringToIndex:4],
                               [content substringWithRange:NSMakeRange(4, 2)], [content substringFromIndex:6]];
                    [_dateArray insertObject:content atIndex:0];
                }
            }
            
            if ([_dateArray count] > 0) {
                //设置转盘默认选中项
                [_filePickerView selectRow:_dateSelectedIndex inComponent:0 animated:YES];
                [_filePickerView reloadComponent:0];
                
                [self loadDayData:_dateArray[0]];
            }
            
            [self hideActivity];
        }
    }
}

- (NSArray *)pareDataArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray array];
    if ([array count] > 0) {
        NSString *lastString = @"";
        
        NSMutableDictionary *itemDic;
        NSMutableArray *minArray;
        for (int i = 0; i < [array count]; i++) {
            NSString *content = [array objectAtIndex:i];
            if ([NSString isNotEmpty:content] && [content length] > 27) {
                NSString *substr = [content substringWithRange:NSMakeRange(22, 2)];
                NSString *minuteStr = [content substringWithRange:NSMakeRange(24, 4)];
                minuteStr = [@"" stringByAppendingFormat:@"%@ : %@", [minuteStr substringToIndex:2], [minuteStr substringFromIndex:2]];
                if ([lastString isEqualToString:substr]) {
                    [minArray addObject:minuteStr];
                } else {
                    minArray = [NSMutableArray array];
                    [minArray addObject:minuteStr];
                    
                    itemDic = [NSMutableDictionary dictionary];
                    [itemDic setObject:substr forKey:@"hour"];
                    [itemDic setObject:minArray forKey:@"minute"];
                    
                    lastString = substr;
                    [resultArray addObject:itemDic];
                }
            }
        }
    }
    
    return resultArray;
}

- (void)loadDayData:(NSString *)day {
    if (!_deviceInfo.deviceLock) {
        day = [day stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        [[KenServiceManager sharedServiceManager] deviceLoadHistory:self.deviceInfo
                                                                url:[NSString stringWithFormat:@"sd/%@/subdir.txt", [day stringByReplacingOccurrencesOfString:@" " withString:@""]]
                                                              start:^{
            [self showActivity];
        } success:^(BOOL successful, NSString * _Nullable errMsg, id _Nullable info) {
            [self hideActivity];
            if (successful) {
                [self pareDayData:info];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
            [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
        }];
    }
}

- (void)pareDayData:(NSString *)info {
    if ([info isKindOfClass:[NSString class]] && [info hasPrefix:@"-2"]) {
        DebugLog("找不到相关文件");
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[info componentsSeparatedByString:@"\n"]];
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSInteger i = 0; i < [array count]; i++) {
            NSString *content = [array objectAtIndex:i];
            if ([content length] > 0 && [content rangeOfString:@".txt"].length <= 0) {
                [newArray insertObject:content atIndex:0];
            }
        }
        
        _dayArray = [NSArray arrayWithArray:[self pareDataArray:newArray]];
        
        //设置转盘默认选中项
        [_filePickerView selectRow:_hourSelectedIndex inComponent:1 animated:YES];
        [_filePickerView selectRow:_minuteSelectedIndex inComponent:2 animated:YES];
        
        [_filePickerView reloadComponent:1];
        [_filePickerView reloadComponent:2];
        
        [self setRecorderFileName];
        
        //添加时标量
        UILabel *label = [UILabel labelWithTxt:@" : " frame:(CGRect){0,0,30,40}
                                           font:[UIFont systemFontOfSize:24] color:[UIColor blackColor]];
        label.center = CGPointMake(_filePickerView.centerX + 54, _filePickerView.centerY);
        [self.contentView addSubview:label];
    }
    
    [self hideActivity];
}

- (void)setRecorderFileName {
    NSString *day = [_dateArray[_dateSelectedIndex] stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (_hourSelectedIndex < [_dayArray count]) {
        NSDictionary *timeDic = [_dayArray objectAtIndex:_hourSelectedIndex];
        NSString *minute = [[[timeDic objectForKey:@"minute"] objectAtIndex:_minuteSelectedIndex]
                            stringByReplacingOccurrencesOfString:@": " withString:@""];
        NSString *fileName = [NSString stringWithFormat:@"/sd/%@/%@_%@%@_0.av", day, day, [timeDic objectForKey:@"hour"], minute];
        self.historyFileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

#pragma mark Picker Date Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_dateArray count];
    } else if (component == 1) {
        return [_dayArray count];
    } else {
        if ([_dayArray count] > 0) {
            return [[[_dayArray objectAtIndex:_hourSelectedIndex] objectForKey:@"minute"] count];
        } else {
            return 0;
        }
    }
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return _dateArray[row];
    } else if (component == 1) {
        if ([_dayArray count] > 0) {
            return [_dayArray[row] objectForKey:@"hour"];
        } else {
            return @"";
        }
    } else {
        if ([_dayArray count] > 0) {
            return [[_dayArray[_hourSelectedIndex] objectForKey:@"minute"] objectAtIndex:row];
        } else {
            return @"";
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 2) {
        _minuteSelectedIndex = row;
        [self setRecorderFileName];
    } else {
        if (component == 0) {
            _dateSelectedIndex = row;
            _hourSelectedIndex = 0;
            _minuteSelectedIndex = 0;
            [self loadDayData:[_dateArray objectAtIndex:row]];
        } else if (component == 1) {
            _hourSelectedIndex = row;
            _minuteSelectedIndex = 0;
            
            [_filePickerView selectRow:_minuteSelectedIndex inComponent:2 animated:YES];
            [_filePickerView reloadComponent:2];
            [self setRecorderFileName];
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //可以根据选项改变转盘宽
    if (component == 0) {
        return 150;
    } else if (component == 1) {
        return 38;
    } else {
        return 90;
    }
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
            if (_fileChange) {
                _fileChange = NO;
                [_videoV playRecorder:self.historyFileName];
            } else {
                if ([NSString isNotEmpty:self.historyFileName]) {
                    [_videoV playRecorder:self.historyFileName];
                } else {
                    [self showToastWithMsg:@"请选择需要播放的文件"];
                }
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
- (void)setHistoryFileName:(NSString *)historyFileName {
    _historyFileName = historyFileName;
    _fileChange = YES;
}

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
    }
    return _videoV;
}

- (UIView *)downloadListV {
    if (_downloadListV == nil) {
        _downloadListV = [[UIView alloc] initWithFrame:(CGRect){0, self.contentView.height - 160, self.contentView.width, 160}];
        _downloadListV.backgroundColor = [UIColor whiteColor];
    }
    return _downloadListV;
}

- (UIPickerView *)filePickerView {
    if (_filePickerView == nil) {
        _dateSelectedIndex = 0;
        _hourSelectedIndex = 0;
        _minuteSelectedIndex = 0;
        
        UIView *titleV = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width, 35}];
        titleV.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:titleV];
        
        UILabel *titleL = [UILabel labelWithTxt:@"选择时间" frame:(CGRect){10, 0, titleV.size} font:[UIFont appFontSize14] color:[UIColor appBlackTextColor]];
        titleL.textAlignment = NSTextAlignmentLeft;
        [titleV addSubview:titleL];
        
        _filePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, titleV.maxY, self.contentView.width, self.downloadListV.minY - titleV.maxY)];
        _filePickerView.delegate = self;
        _filePickerView.dataSource = self;
        [_filePickerView setBackgroundColor:[UIColor appBackgroundColor]];

        [_filePickerView reloadAllComponents];
    }
    return _filePickerView;
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
        btnArr = @[@"history_full", @"history_video", @"history_photo", @"history_download"];
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

@end
