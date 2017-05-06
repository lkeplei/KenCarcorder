//
//  KenWifiPwdInputVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiPwdInputVC.h"
#import "KenDeviceDM.h"
#import "KenDeviceWifiSetVC.h"
#import "thSDKlib.h"

@interface KenWifiPwdInputVC ()

@property (nonatomic, assign) BOOL exc;
@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) KenWifiNodeInfo *wifiNodeInfo;
@property (nonatomic, strong) UITextField *pwdTextField;

@end

@implementation KenWifiPwdInputVC

- (instancetype)initWithDevice:(KenDeviceDM *)device wifiNode:(KenWifiNodeInfo *)wifiNode {
    self = [super init];
    if (self) {
        _deviceInfo = device;
        _wifiNodeInfo = wifiNode;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavTitle:_wifiNodeInfo.wifiName];
    
    [self setRightNavItemWithText:@"完成" selector:@selector(finishBtnClicked)];
    
    UIView *inputV = [[UIView alloc] initWithFrame:(CGRect){0, 104, self.view.width, 44}];
    [inputV setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:inputV];
    
    UILabel *title = [UILabel labelWithTxt:@"WIFI密码" frame:(CGRect){0,0,100,44} font:[UIFont appFontSize16] color:[UIColor blackColor]];
    [inputV addSubview:title];
    
    _pwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 0, self.view.width - 110, 44)];
    _pwdTextField.placeholder = @"WIFI密码";
    _pwdTextField.font = [UIFont appFontSize14];
    _pwdTextField.clearButtonMode = UITextFieldViewModeAlways;
    _pwdTextField.clearsOnBeginEditing = NO;
    _pwdTextField.textAlignment = NSTextAlignmentLeft;
    [inputV addSubview:_pwdTextField];
}

#pragma mark - button
- (void)finishBtnClicked {
    NSString *pwd = [_pwdTextField text];
    if ([NSString isEmpty:pwd] || [pwd length] <= 0) {
        [self showToastWithMsg:@"请输入wifi密码"];
        return;
    }
    
    if (_deviceInfo.isDDNS) {
        [[KenServiceManager sharedServiceManager] deviceSetWifi:_deviceInfo name:_wifiNodeInfo.wifiName pwd:pwd start:^{
            [self showActivity];
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable info) {
            [self pareInfo:info];
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
        }];
    } else {
        NSString *request = [[NSString alloc] initWithFormat:@"%@cfg.cgi?User=%@&Psd=%@&MsgID=38&wifi_IsAPMode=0&wifi_SSID_STA=%@&wifi_Password_STA=%@", kConnectP2pHost,
                                                            _deviceInfo.usr, _deviceInfo.pwd, [_wifiNodeInfo wifiName], pwd];
        if (!_exc) {
            [NSThread detachNewThreadSelector:@selector(loadWifiPwdurl:) toTarget:self withObject:request];
            _exc = true;
        }
    }
}

- (void)loadWifiPwdurl:(NSString*)url {
    bool ret;
    char Buf[65536];
    int BufLen;
    int64_t handle = 0;
    if(!thNet_IsConnect(_deviceInfo.connectHandle)) {
        thNet_Init(&handle, 11);
        _deviceInfo.connectHandle = handle;
        ret = thNet_Connect_P2P(handle, 0, (char *)[_deviceInfo.uid UTF8String], (char *)[_deviceInfo.uidpsd UTF8String], 10000, YES);
        if (!ret) return;
    }
    
    thNet_HttpGet(_deviceInfo.connectHandle, (char *)[url UTF8String], Buf, &BufLen);
    
    NSString* data = [NSString stringWithFormat:@"%s" , Buf];
    [self performSelectorOnMainThread:@selector(pareInfo:) withObject:data waitUntilDone:YES];
}

- (void)pareInfo:(NSString*)urlData {
    if ([urlData isEqualToString:@"OKREBOOT"]) {
        [self showToastWithMsg:@"摄像机正在重启，请稍后再连接"];
    } else if ([urlData isEqualToString:@"OK"]) {
        [self showToastWithMsg:@"设置成功！"];
    } else if ([urlData isEqualToString:@"NO"]) {
        [self showToastWithMsg:@"设置失败!"];
    } else {
        [self showToastWithMsg:@"设置成功！"];
    }
    _exc = false;
    
    [self hideActivity];
}

@end
