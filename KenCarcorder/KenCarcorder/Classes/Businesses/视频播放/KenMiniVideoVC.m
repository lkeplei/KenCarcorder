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

@interface KenMiniVideoVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL upDownScanning;          //是否正在上下扫描
@property (nonatomic, assign) BOOL leftRightScanning;       //是否正在左右扫描

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) UITableView *functionTableV;
@property (nonatomic, strong) NSArray *functionList;
@property (nonatomic, strong) UIView *functionV;
@property (nonatomic, strong) UIView *videoNav;
@property (nonatomic, strong) UIView *speakV;
@property (nonatomic, strong) UILabel *speedLabebl;         //速度标签

@end

@implementation KenMiniVideoVC
#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
    
        _functionList = @[@{@"title":@"回看", @"img":@"video_history", @"fun":@"KenHistoryVC"},
                          @{@"title":@"设置", @"img":@"video_setting", @"fun":@"KenDeviceSettingVC"}];
        
        _upDownScanning = YES;
        _leftRightScanning = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_mini_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.videoNav];
    [self.contentView addSubview:self.functionTableV];
    
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[KenGCDTimerManager sharedInstance] cancelTimerWithName:@"miniVideoTime"];
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _functionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        cell.textLabel.textColor = [UIColor appWhiteTextColor];
    }
    
    NSDictionary *function = [_functionList objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:[function objectForKey:@"img"]]];
    [cell.textLabel setText:[function objectForKey:@"title"]];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row != 0) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){kKenOffsetX(30), 0, self.contentView.width, 0.5}];
        line.backgroundColor = [UIColor colorWithHexString:@"#73BFE2"];
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self pushViewControllerString:[[_functionList objectAtIndex:indexPath.row] objectForKey:@"fun"] animated:YES];
    
    [self.videoV stopVideo];
}

#pragma mark - event
- (void)back {
    [_videoV finishVideo];
    [super popViewController];
}

- (void)speakStart {

}

- (void)speakEnd {

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
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    } else {
        [[KenServiceManager sharedServiceManager] deviceScanUpDown:self.device start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            @strongify(self)
            if (successful) {
                self.upDownScanning = !self.upDownScanning;
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
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    } else {
        [[KenServiceManager sharedServiceManager] deviceScanLeftRight:self.device start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            @strongify(self)
            if (successful) {
                self.leftRightScanning = !self.leftRightScanning;
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
        @weakify(self)
        [self presentConfirmViewInController:self confirmTitle:@"提示"
                                     message:@"分享设备将可能会耗费您较多的数据流量，并请保护自己和他人的隐私。请确认是否继续?"
                          confirmButtonTitle:@"分享" cancelButtonTitle:@"取消" confirmHandler:^{
                              @strongify(self)
                              [self.videoV shareVedio];
                          } cancelHandler:^{
                          }];
    }
}

#pragma mark - public method
- (void)setDirectConnect {
//    NSString *ssid = [KenCarcorder getCurrentSSID];
//    
//    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
//    device.netStat = kKenNetworkDdns;
//    device.ddns = @"192.168.1.168";
//    device.name = ssid;
//    
//    NSInteger value = [[ssid substringFromIndex:[ssid length] - 3] integerValue];
//    device.dataport = 7000 + value;
//    device.httpport = 8000 + value;
//    
//    self.device = device;
    
    
    
    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
    device.netStat = kKenNetworkDdns;
    device.ddns = @"80002075.7cyun.net";
    device.name = @"二楼";
    device.sn = @"80002075";
    
    device.dataport = 7075;
    device.httpport = 8075;
    
    self.device = device;
}

#pragma mark - private method
- (void)initTurnFunctionV {
    UIImageView *funtionBgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_fun_bg"]];
    funtionBgV.center = CGPointMake(self.functionV.width / 2, self.functionV.height / 2);
    [funtionBgV setUserInteractionEnabled:YES];
    [self.functionV addSubview:funtionBgV];
    
    CGFloat offset = kKenOffsetY(36);
    @weakify(self)
    UIButton *upBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_up"]
                                     imagesec:nil target:self action:@selector(functionUp)];
    upBtn.size = CGSizeMake(upBtn.width * 3, upBtn.height * 4);
    upBtn.center = CGPointMake(funtionBgV.width / 2, offset);
    [funtionBgV addSubview:upBtn];
    [upBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongUp];
    }];
    
    UIButton *downBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_down"]
                                     imagesec:nil target:self action:@selector(functionDown)];
    downBtn.size = CGSizeMake(downBtn.width * 3, downBtn.height * 4);
    downBtn.center = CGPointMake(upBtn.centerX, funtionBgV.height - offset);
    [funtionBgV addSubview:downBtn];
    [downBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongDown];
    }];
    
    UIButton *leftBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_left"]
                                     imagesec:nil target:self action:@selector(functionLeft)];
    leftBtn.size = CGSizeMake(leftBtn.width * 4, leftBtn.height * 3);
    leftBtn.center = CGPointMake(offset, funtionBgV.height / 2);
    [funtionBgV addSubview:leftBtn];
    [leftBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongLeft];
    }];
    
    UIButton *rightBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_right"]
                                     imagesec:nil target:self action:@selector(functionRight)];
    rightBtn.size = CGSizeMake(rightBtn.width * 4, rightBtn.height * 3);
    rightBtn.center = CGPointMake(funtionBgV.width - offset, leftBtn.centerY);
    [funtionBgV addSubview:rightBtn];
    [rightBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongRight];
    }];
}

- (void)initScanFunctionV {
    @weakify(self)
    //
    UIImage *scanUpDown = [UIImage imageNamed:@"video_scan_up_down"];
    CGFloat offsetY = (self.functionV.height - scanUpDown.size.height * 2) / 3;
    CGFloat offsetX = kKenOffsetX(30);
    //////// scan up down
    UIImageView *scanUpDownV = [[UIImageView alloc] initWithImage:scanUpDown];
    scanUpDownV.origin = CGPointMake(offsetX, offsetY);
    [self.functionV addSubview:scanUpDownV];
    
    UILabel *label = [UILabel labelWithTxt:@"上下扫描" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                      font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    label.textAlignment = NSTextAlignmentLeft;
    [scanUpDownV addSubview:label];
    
    [scanUpDownV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self scanUpdown];
    }];
    //////// scan left right
    UIImageView *scanLeftRightV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_scan_left_right"]];
    scanLeftRightV.origin = CGPointMake(scanUpDownV.originX, scanUpDownV.maxY + offsetY);
    [self.functionV addSubview:scanLeftRightV];
    
    UILabel *LRLabel = [UILabel labelWithTxt:@"左右扫描" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                        font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    LRLabel.textAlignment = NSTextAlignmentLeft;
    [scanLeftRightV addSubview:LRLabel];
    
    [scanLeftRightV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self scanLeftRight];
    }];
    //////// turn up down
    UIImageView *turnUpDownV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_turn_up_down"]];
    turnUpDownV.origin = CGPointMake(self.functionV.width - offsetX - scanUpDownV.width, scanUpDownV.originY);
    [self.functionV addSubview:turnUpDownV];
    
    UILabel *turnUDLabel = [UILabel labelWithTxt:@"上下翻转" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                            font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    turnUDLabel.textAlignment = NSTextAlignmentLeft;
    [turnUpDownV addSubview:turnUDLabel];
    
    [turnUpDownV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self turnUpDown];
    }];
    //////// turn left right
    UIImageView *turnLeftRightV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_turn_left_right"]];
    turnLeftRightV.origin = CGPointMake(turnUpDownV.originX, scanLeftRightV.originY);
    [self.functionV addSubview:turnLeftRightV];
    
    UILabel *turnLRLabel = [UILabel labelWithTxt:@"左右翻转" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                            font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    turnLRLabel.textAlignment = NSTextAlignmentLeft;
    [turnLeftRightV addSubview:turnLRLabel];
    
    [turnLeftRightV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self turnLeftRight];
    }];
}

#pragma mark - getter setter
- (void)setDevice:(KenDeviceDM *)device {
    _device = device;
    
    [self setNavTitle:_device.name];
    
    [self.videoV showVideoWithDevice:_device];
}

- (KenVideoV *)videoV {
    if (_videoV == nil) {
        _videoV = [[KenVideoV alloc] initWithFrame:(CGRect){0, 64, MainScreenWidth, ceilf(MainScreenWidth * kAppImageHeiWid)}];
    }
    return _videoV;
}

- (UIView *)videoNav {
    if (_videoNav == nil) {
        _videoNav = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY - kKenOffsetY(86),
                                                            self.contentView.width, kKenOffsetY(86)}];
        _videoNav.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        UIButton *speaker = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_speaker"]
                                           imagesec:nil target:self action:@selector(speaker:)];
        speaker.frame = (CGRect){0, 0, speaker.width + kKenOffsetX(50), _videoNav.height};
        [_videoNav addSubview:speaker];
        
        _speedLabebl = [UILabel labelWithTxt:@"" frame:(CGRect){speaker.maxX, 0, 80, _videoNav.height}
                                        font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _speedLabebl.numberOfLines = 0;
        [_videoNav addSubview:_speedLabebl];
        
        NSArray *btnArr = @[@"video_full", @"video_record", @"video_capture", @"video_share"];
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

- (UIView *)functionV {
    if (_functionV == nil) {
        UIImage *funBg = [UIImage imageNamed:@"video_fun_bg"];
        _functionV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, funBg.size.height + kKenOffsetY(60)}];
        _functionV.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        [self initTurnFunctionV];
        [self initScanFunctionV];
    }
    return _functionV;
}

- (UIView *)speakV {
    if (_speakV == nil) {
        UIImage *bg = [UIImage imageNamed:@"video_speak_bg"];
        _speakV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, bg.size.height + kKenOffsetY(120)}];
        _speakV.backgroundColor = [UIColor clearColor];
        
        UIButton *speakBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_speak_bg"]
                                            imagesec:nil target:self action:@selector(speakStart)];
        [speakBtn addTarget:self action:@selector(speakEnd) forControlEvents:UIControlEventTouchDown];
        speakBtn.center = CGPointMake(_speakV.centerX, _speakV.height / 2);
        [_speakV addSubview:speakBtn];
        
        UIImageView *speak = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_speak"]];
        speak.center = CGPointMake(speakBtn.width / 2, speakBtn.height / 2);
        [speakBtn addSubview:speak];
    }
    return _speakV;
}

- (UITableView *)functionTableV {
    if (_functionTableV == nil) {
        _functionTableV = [[UITableView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width,
                                                                    self.contentView.height - self.videoV.maxY}
                                                       style:UITableViewStyleGrouped];
        _functionTableV.delegate = self;
        _functionTableV.dataSource = self;
        _functionTableV.backgroundColor = [UIColor clearColor];
        _functionTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _functionTableV.tableFooterView = self.speakV;
        
        UIView *footV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.functionV.width, self.functionV.height + kKenOffsetY(26)}];
        footV.backgroundColor = [UIColor clearColor];
        [footV addSubview:_functionV];
        _functionTableV.tableHeaderView = footV;
    }
    return _functionTableV;
}
@end
