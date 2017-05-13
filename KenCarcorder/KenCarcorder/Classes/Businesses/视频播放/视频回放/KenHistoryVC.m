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
    [self.contentView addSubview:self.downloadListV];
    [self.contentView addSubview:self.filePickerView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadHistoryData];
    
    SysDelegate.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isFinished = YES;
    SysDelegate.allowRotation = NO;
//    thNet_RemoteFileStop(_recorderView.deviceInfo.connectHandle);
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
        [_videoV playRecorder:[fileName stringByReplacingOccurrencesOfString:@" " withString:@""]];
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
    
    self.videoV.frame = (CGRect){CGPointZero, SysDelegate.window.height, SysDelegate.window.width};
    [SysDelegate.window addSubview:self.videoV];
}

- (void)exitFullscreen {
    [self.videoV removeFromSuperview];
    
    self.videoV.frame = (CGRect){CGPointZero, MainScreenHeight, ceilf(MainScreenHeight * kAppImageHeiWid)};
    [self.contentView addSubview:self.videoV];
}

#pragma mark - getter setter
- (KenVideoV *)videoV {
    if (_videoV == nil) {
        _videoV = [[KenVideoV alloc] initWithFrame:(CGRect){0, 0, MainScreenWidth, ceilf(MainScreenWidth * kAppImageHeiWid)}];
        [_videoV showVideoWithDevice:self.deviceInfo];
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
@end
