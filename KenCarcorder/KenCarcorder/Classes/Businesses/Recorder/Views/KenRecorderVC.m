//
//  KenRecorderVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRecorderVC.h"
#import "KenAlertView.h"
#import "KenMiniVideoVC.h"
#import "KenDeviceDM.h"
#import "KenDirectConnectVC.h"

#import "thSDKlib.h"
#import "iconv.h"

@interface KenRecorderVC ()

@property (nonatomic, strong) NSString *currentWifi;
@property (nonatomic, strong) KenDeviceDM *currentDeviceInfo;

@end

@implementation KenRecorderVC
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"记录仪"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *ssid = [KenCarcorder getCurrentSSID];
    if ([NSString isNotEmpty:ssid] &&
        ([ssid containsString:@"IPCAM_AP_8"] || [ssid containsString:@"七彩云"] || 1)) {
        [self jumpDirectConnectVC:ssid];
    } else {
        [self initView];
    }
}

#pragma mark - event
- (void)nextStep {
    [self pushViewControllerString:@"KenExplain1VC" animated:YES];
}

#pragma mark - private method
- (void)initView {
    UIImageView *iCon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_iCon"]];
    iCon.center = CGPointMake(self.contentView.width / 2, self.contentView.height * 0.26);
    [self.contentView addSubview:iCon];
    
    UILabel *label = [UILabel labelWithTxt:@"您还没有设置记录仪" frame:(CGRect){0, iCon.maxY + 10, self.contentView.width, 30}
                                      font:[UIFont appFontSize16] color:[UIColor appGrayTextColor]];
    [self.contentView addSubview:label];
    
    UILabel *label1 = [UILabel labelWithTxt:@"保持记录仪处于开机状态并在您的附件，您\n可以通过 \"下一步\" 进行设置"
                                      frame:(CGRect){0, label.maxY + 10, self.contentView.width, 50}
                                       font:[UIFont appFontSize14] color:[UIColor appGrayTextColor]];
    label1.numberOfLines = 2;
    [label1 setLineSpacing:7];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label1];
    
    UIButton *nextBtn = [UIButton buttonWithImg:@"下一步" zoomIn:YES image:nil imagesec:nil target:self action:@selector(nextStep)];
    nextBtn.frame = (CGRect){60, self.contentView.height - 100, self.contentView.width - 120, 44};
    [nextBtn setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 4;
    nextBtn.layer.borderColor = [UIColor appMainColor].CGColor;
    nextBtn.layer.borderWidth = 0.5;
    [self.contentView addSubview:nextBtn];
}

#pragma mark - 直联部分
KenRecorderVC *recorderSelf;
- (void)jumpDirectConnectVC:(NSString *)ssid {
    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self showActivity];
    
    if ([ssid isEqualToString:_currentWifi] && _currentDeviceInfo) {
        [self connectDevice:_currentDeviceInfo];
    } else {
        _currentWifi = ssid;
        if (![self connectDevice168:ssid]) {
            recorderSelf = self;
            [Async background:^{
                [self searchDevice];
            }];
        }
    }
}

- (BOOL)connectDevice168:(NSString *)ssid {
    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
    device.netStat = kKenNetworkDdns;
    device.ddns = @"192.168.1.168";
    device.name = ssid;
    device.online = YES;
    
    NSInteger value = [[ssid substringFromIndex:[ssid length] - 3] integerValue];
    device.dataport = 7000 + value;
    device.httpport = 8000 + value;
    
    int64_t handle = 0;
    int connectTimes = 0;
    char *IP = (char *)[[device currentIp] cStringUsingEncoding:NSASCIIStringEncoding];
    char *usr = (char *)[device.usr cStringUsingEncoding:NSASCIIStringEncoding];
    char *pwd = (char *)[device.pwd cStringUsingEncoding:NSASCIIStringEncoding];
    int port = (int)device.dataport;
    
    thNet_Init(&handle, 11);
    device.connectHandle = handle;
    
    while (!thNet_Connect(device.connectHandle, usr, pwd, IP, IP, port, 1000, 1) && connectTimes < 1) {
        // 句柄 用户名 密码 服务器IP 设备IP 端口号 超时时间 开启接收线程
        ++connectTimes ;
    }
    
    if (thNet_IsConnect(device.connectHandle)) {
        [self connectDevice:device];
        return YES;
    }
    
    return NO;
}

- (void)connectDevice:(KenDeviceDM *)deviceInfo {
    [self hideActivity];
    recorderSelf = nil;
    
    _currentDeviceInfo = deviceInfo;
    
    KenDirectConnectVC *directVC = [[KenDirectConnectVC alloc] init];
    directVC.device = _currentDeviceInfo;
    [self pushViewController:directVC animated:YES];
}

- (void)searchDevice {
    time_t dt;
    thSearch_Init(loginSearchDevCallBack);
    
    thSearch_SearchDevice(NULL);
    dt = time(NULL);
    while(1) {
        usleep(1000*100);
        if (time(NULL) - dt >= 3) break;
    }
    thSearch_Free();
}

int login_code_convert(char *from_charset, char *to_charset, char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
    iconv_t cd = NULL;
    cd = iconv_open(to_charset, from_charset);
    if(!cd)
        return -1;
    memset(outbuf, 0, outlen);
    if(iconv(cd, &inbuf, &inlen, &outbuf, &outlen) == -1) {
        return -1;
    }
    iconv_close(cd);
    return 0;
}

void loginSearchDevCallBack(int SN,int DevType, int VideoChlCount, int DataPort, int HttpPort, char* DevName,char* DevIP, char* DevMAC, char* SubMask, char* Gateway, char* DNS1,char* DDNSHost,char* UID ) {
    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
    [device setLanIp:[NSString stringWithUTF8String:DevIP]];
    [device setSn:[NSString stringWithFormat:@"%0.8x", SN]];
    [device setDataport:DataPort];
    [device setHttpport:HttpPort];
    
    NSString *string = nil;
    unsigned long ansiLen = strlen(DevName);
    
    unsigned long utf8Len = ansiLen * 2;
    char *utf8String = (char*)malloc(utf8Len);
    memset(utf8String, 0, utf8Len);
    int result = login_code_convert("gb2312", "utf8", DevName, ansiLen, utf8String, utf8Len);
    if (result == -1) {
    } else {
        string = [[NSString alloc] initWithUTF8String:utf8String];
    }
    free(utf8String);
    
    [device setName:string];
    
    if (strlen(DDNSHost) > 1) {
        [device setDdns:[NSString stringWithUTF8String:DDNSHost]];
        NSString *sn = [NSString stringWithFormat:@"%d", SN];
        NSInteger value = [[sn substringFromIndex:[sn length] - 3] integerValue];
        NSInteger dp = value + 7000;
        NSInteger hp = value + 8000;
        [device setLanDataPort:dp];
        [device setLanHttpPort:hp];
    }
    
    [device setDdns:[NSString stringWithUTF8String:DevIP]];
    
    if (strlen(UID) > 1) {
        [device setUid:[NSString stringWithUTF8String:UID]];
        [device setUidpsd:@"admin"];
    }
    
    if (recorderSelf) {
        [Async main:^{
            [recorderSelf connectDevice:device];
        }];
    }
}

@end
