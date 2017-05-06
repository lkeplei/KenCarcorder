//
//  KenHistoryVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHistoryVC.h"

//#import "YDRecorderFullV.h"
//#import "YDRecorderV.h"
//
//#import "thSDKlib.h"

@interface KenHistoryVC ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;

@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, assign) NSInteger dateSelectedIndex;
@property (nonatomic, assign) NSInteger hourSelectedIndex;
@property (nonatomic, assign) NSInteger minuteSelectedIndex;
//@property (nonatomic, strong) YDRecorderV *recorderView;
//@property (nonatomic, strong) YDRecorderFullV *fullScreenV;
@property (nonatomic, strong) UIPickerView *filePickerView;
@property (nonatomic, strong) NSMutableArray *recorderList;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSArray *dayArray;

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
    
    [self initRecorderView];
    [self initFilePicker];
    [self initFullScreenV];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[YDModel shareModel] setFilePlay:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadHistoryData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isFinished = YES;
//    thNet_RemoteFileStop(_recorderView.deviceInfo.connectHandle);
//    
//    [[YDModel shareModel] setFilePlay:NO];
//    
//    [[YDController shareController] hideLoadingV:self.view];
}

- (void)initRecorderView {
//    if (_recorderView == nil) {
//        _recorderView = [[YDRecorderV alloc] initWithDevice:_deviceInfo
//                                                      frame:(CGRect){0, kAppViewOrginY, kGSize.width, ceilf(kGSize.width * kAppImageHeiWid) + 40}
//                                                 showBanner:YES];
//        [self.view addSubview:_recorderView];
//        
//        _recorderView.controlBlock = ^(YDControlType type) {
//            if (type == kYDControlFullScreen) {
//                [KenUtils setOrientation:UIInterfaceOrientationLandscapeLeft];
//            } else if (type == kYDControlMiniScreen) {
//                [KenUtils setOrientation:UIInterfaceOrientationPortrait];
//            }
//        };
//        
//        __weak YDVedioHistoryVC *weakSelf = self;
//        _recorderView.getImageBlock = ^(UIImage *image) {
//            if (weakSelf.fullScreenV) {
//                [weakSelf.fullScreenV setBgImage:image];
//            }
//        };
//        
//        _recorderView.getImageBufferBlock = ^(CVImageBufferRef imageBuffer) {
//            if (weakSelf.fullScreenV) {
//                [weakSelf.fullScreenV setBgImageBuffer:imageBuffer];
//            }
//        };
//        
//        _recorderView.lengthBlock = ^(NSInteger length, CGFloat totalLength) {
//            [weakSelf.fullScreenV setFlovValue:length totalLength:totalLength];
//        };
//        
//        _recorderView.speedBlock = ^(NSString *speed) {
//            [weakSelf.fullScreenV setSpeedText:speed];
//        };
//        
//        _recorderView.statusChangeBlock = ^(YDVedioStatusType status) {
//            switch (status) {
//                case kYDVedioStatusRecPlayStop: {
//                    //                    [weakSelf playNextRecorder];
//                }
//                    break;
//                default:
//                    break;
//            }
//        };
//    }
}

- (void)initFilePicker {
    [self initRecorderView];
    
    _dateSelectedIndex = 0;
    _hourSelectedIndex = 0;
    _minuteSelectedIndex = 0;
    
//    _filePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_recorderView.frame), self.view.width, 220)];
    _filePickerView.delegate = self;
    _filePickerView.dataSource = self;
    [_filePickerView setBackgroundColor:[UIColor appSepLineColor]];
    
    [_filePickerView reloadAllComponents];
    
    [self.view addSubview:_filePickerView];
}

- (void)initFullScreenV {
//    _fullScreenV = [[YDRecorderFullV alloc] initWithFrame:(CGRect){CGPointZero, kGSize.height, kGSize.width}];
//    [_fullScreenV setHidden:YES];
//    [self.view addSubview:_fullScreenV];
//    
//    __weak YDVedioHistoryVC *weakSelf = self;
//    _fullScreenV.controlBlock = ^(YDControlType type) {
//        if (type == kYDControlRecorder) {
//            [weakSelf.recorderView vedioBtnClicked:nil];
//        } else if (type == kYDControlCapture) {
//            [weakSelf.recorderView captureBtnClicked];
//        } else if (type == kYDControlMiniScreen) {
//            [KenUtils setOrientation:UIInterfaceOrientationLandscapeLeft];
//        } else if (type == kYDControlResume) {
//            [weakSelf.recorderView resumeBtnClicked:nil];
//        }
//    };
}

- (void)playNextRecorder {
    _minuteSelectedIndex++;
    NSDictionary *hourDic = [_dayArray objectAtIndex:_hourSelectedIndex];
    if (_minuteSelectedIndex >= [[hourDic objectForKey:@"minute"] count]) {
        _minuteSelectedIndex = 0;
        _hourSelectedIndex++;
        if (_hourSelectedIndex >= [_dayArray count]) {
            _hourSelectedIndex = 0;
            _dateSelectedIndex++;
            if (_hourSelectedIndex >= [_dayArray count]) {
                [self showToastWithMsg:@"所有回看记录已播放完毕"];
                return;
            }
        }
    }
    
    [self setRecorderFileName];
}

#pragma mark - data
- (void)loadHistoryData {
//    if (![_deviceInfo deviceLock]) {
//        [[YDController shareController] showLoadingV:self.view content:@"加载中..." picS:NO];
//        _shouldAutorotate = NO;
//        
//        if ([[YDModel shareModel] isDdns:_deviceInfo]) {
//            NSString *host = [NSString stringWithFormat:@"http://%@:%zd", [[YDModel shareModel] getCurrentIp:_deviceInfo],
//                              [_deviceInfo httpport]];
//            //        NSString *url = [NSString stringWithFormat:@"cfg.cgi?User=%@&Psd=%@&MsgID=83&path=/sd/&name=subdir.txt", [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd]];
//            NSString *url = @"sd/subdir.txt";
//            [[YDController shareController] controlSendCmd:host url:url success:^(id info) {
//                [self pareDateData:info];
//            } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//                kKenAlert(@"当前服务器繁忙，请稍后重试");
//                [[YDController shareController] hideLoadingV:self.view];
//                _shouldAutorotate = YES;
//            }];
//        } else {
//            NSString *url = [[NSString alloc] initWithFormat:@"%@cfg.cgi?User=%@&Psd=%@&MsgID=83&path=/sd/&name=subdir.txt",
//                             kConnectP2pHost, [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd]];
//            [NSThread detachNewThreadSelector:@selector(loadHistoryDateUrl:) toTarget:self withObject:url];
//        }
//    }
}

- (void)loadHistoryDateUrl:(NSString *)url {
//    bool ret;
//    char Buf[65536];
//    memset(Buf, 0, 65536);
//    int BufLen;
//    
//    if(!thNet_IsConnect(_recorderView.deviceInfo.connectHandle)) {
//        int64_t handle;
//        thNet_Init(&handle, 11);
//        ret = thNet_Connect_P2P(handle, 0, (char *)[[_deviceInfo getDeviceUid] UTF8String],
//                                (char *)[[_deviceInfo getDeviceUidpsd] UTF8String], 10000, true);
//        [_recorderView.deviceInfo setDeviceConnectHandle:handle];
//        if (!ret) return;
//    }
//    
//    thNet_HttpGet([_recorderView.deviceInfo connectHandle], (char *)[url UTF8String], Buf, &BufLen);
//    
//    [self performSelectorOnMainThread:@selector(pareDateData:) withObject:[NSString stringWithFormat:@"%s" , Buf] waitUntilDone:YES];
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
//    if (![_deviceInfo deviceLock]) {
//        day = [day stringByReplacingOccurrencesOfString:@"." withString:@""];
//        _shouldAutorotate = NO;
//        
//        if ([[YDModel shareModel] isDdns:_deviceInfo]) {
//            NSString *host = [NSString stringWithFormat:@"http://%@:%d", [[YDModel shareModel] getCurrentIp:_deviceInfo],
//                              (int)[_deviceInfo httpport]];
//            NSString *url = [NSString stringWithFormat:@"sd/%@/subdir.txt", [day stringByReplacingOccurrencesOfString:@" " withString:@""]];
//            [[YDController shareController] showLoadingV:self.view content:@"加载中..." picS:NO];
//            [[YDController shareController] controlSendCmd:host url:url
//                                                   success:^(id info) {
//                                                       [self pareDayData:info];
//                                                   } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//                                                       kKenAlert(@"当前服务器繁忙，请稍后重试");
//                                                       [[YDController shareController] hideLoadingV:self.view];
//                                                       _shouldAutorotate = YES;
//                                                   }];
//        } else {
//            NSString* url = [[NSString alloc] initWithFormat:@"%@cfg.cgi?User=%@&Psd=%@&MsgID=83&path=/sd/%@/&name=subdir.txt",
//                             kConnectP2pHost, [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd],
//                             [day stringByReplacingOccurrencesOfString:@" " withString:@""]];
//            [NSThread detachNewThreadSelector:@selector(loadHistoryDayUrl:) toTarget:self withObject:url];
//        }
//    }
}

//- (void)loadHistoryDayUrl:(NSString *)url {
//    bool ret;
//    char Buf[65536];
//    memset(Buf, 0, 65536);
//    int BufLen;
//    
//    if(!thNet_IsConnect(_recorderView.deviceInfo.connectHandle)) {
//        int64_t handle;
//        thNet_Init(&handle, 11);
//        ret = thNet_Connect_P2P(handle, 0, (char *)[[_deviceInfo getDeviceUid] UTF8String],
//                                (char *)[[_deviceInfo getDeviceUidpsd] UTF8String], 10000, true);
//        [_recorderView.deviceInfo setDeviceConnectHandle:handle];
//        if (!ret) return;
//    }
//    
//    thNet_HttpGet([_recorderView.deviceInfo connectHandle], (char *)[url UTF8String], Buf, &BufLen);
//    
//    [self performSelectorOnMainThread:@selector(pareDayData:) withObject:[NSString stringWithFormat:@"%s" , Buf] waitUntilDone:YES];
//    //    [self pareDayData:[NSString stringWithFormat:@"%s" , Buf]];
//}

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
        [self.view addSubview:label];
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
//        [_recorderView playRecorder:[fileName stringByReplacingOccurrencesOfString:@" " withString:@""] play:NO];
    }
}

- (void)loadVedioHeightWidth {
//    NSString *host = [NSString stringWithFormat:@"http://%@:%d", [[YDModel shareModel] getCurrentIp:_deviceInfo],
//                      (int)[_deviceInfo httpport]];
//    [[YDController shareController] controlSendCmd:host url:[NSString stringWithFormat:@"cfg.cgi?User=%@&Psd=%@&MsgID=5",
//                                                             [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd]]
//                                           success:^(id info) {
//                                               if ([info length] > 10) {
//                                                   
//                                               }
//                                           } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//                                               kKenAlert(@"当前服务器繁忙，请稍后重试");
//                                               [[YDController shareController] hideLoadingV:self.view];
//                                           }];
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
//- (void)showFullScreen:(BOOL)show {
//    if (show) {
//        [_recorderView showFullScreen];
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        [self.navigationController.navigationBar setHidden:YES];
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//    } else {
//        [_recorderView showMiniScreen];
//        [self.navigationController.navigationBar setHidden:NO];
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    }
//    
//    [_filePickerView setHidden:show];
//    [_fullScreenV setHidden:!show];
//}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
//        [self showFullScreen:NO];
//    } else {
//        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
//            [self showFullScreen:YES];
//        }
//    }
//}
@end
