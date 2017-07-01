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

@interface KenDirectConnectVC ()

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) KenDeviceDM *device;

@end

@implementation KenDirectConnectVC
#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
        
        [self setDirectConnect];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"直连行车记录仪"];
    
    [self.contentView addSubview:self.videoV];
    
    [self setLeftNavItemWithImg:[UIImage imageNamed:@"app_back"] selector:@selector(back)];
}

#pragma mark - event
- (void)back {
    [_videoV finishVideo];
    [super popViewController];
}

#pragma mark - private method
- (void)setDirectConnect {
    NSString *ssid = [KenCarcorder getCurrentSSID];
    
    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
    device.netStat = kKenNetworkDdns;
    device.ddns = @"192.168.1.168";
    device.name = ssid;
    device.online = YES;
    
    NSInteger value = [[ssid substringFromIndex:[ssid length] - 3] integerValue];
    device.dataport = 7000 + value;
    device.httpport = 8000 + value;
    
    self.device = device;
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
    }
    return _videoV;
}

@end
