//
//  KenDeviceWifiSetVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceWifiSetVC.h"
#import "KenDeviceDM.h"
#import "KenAlertView.h"

@interface KenDeviceWifiSetVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UITableView *wifiTable;
@property (nonatomic, strong) KenWifiSteInfo *wifiSte;

@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) NSMutableArray *wifiListNode;

@property (nonatomic, assign) BOOL isGetWifiNode;

@end

@implementation KenDeviceWifiSetVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        _deviceInfo = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"WIFI设置"];
    
    _sectionArray = @[@"无线局域网", @"正在获取网络"];

    [self.contentView addSubview:self.wifiTable];
    
    _wifiSte = [[KenWifiSteInfo alloc] init];
    
    [self getWifiInfo];
}

- (void)getWifiInfo {
    _isGetWifiNode = NO;
//    [[YDController shareController] showLoadingV:self.view content:@"加载中。。。" picS:NO];
//    if ([[YDModel shareModel] isDdns:_deviceInfo]) {
//        [[YDController shareController] getWifiInfo:_deviceInfo success:^(id info) {
//            [self reloadtable:info];
//        } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//            [[YDController shareController] hideLoadingV:self.view];
//        }];
//    } else {
//        NSString *url = [[NSString alloc] initWithFormat:@"%@cfg.cgi?User=%@&Psd=%@&MsgID=37",
//                         kConnectP2pHost, [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd]];
//        [NSThread detachNewThreadSelector:@selector(loadWifiSettingurl:) toTarget:self withObject:url];
//    }
}

- (void)loadWifiSettingurl:(NSString *)url {
//    bool ret;
//    char Buf[65536];
//    int BufLen;
//    int64_t handle = 0;
//    if(!thNet_IsConnect(_deviceInfo.connectHandle)) {
//        thNet_Init(&handle, 11);
//        [_deviceInfo setDeviceConnectHandle:handle];
//        ret = thNet_Connect_P2P(_deviceInfo.connectHandle, 0, (char *)[[_deviceInfo getDeviceUid] UTF8String],
//                                (char *)[[_deviceInfo getDeviceUidpsd] UTF8String], 10000, true);
//        if (!ret) return;
//    }
//    
//    thNet_HttpGet(_deviceInfo.connectHandle, (char *)[url UTF8String], Buf, &BufLen);
//    
//    NSString* data = [NSString stringWithFormat:@"%s" , Buf];
//    [self performSelectorOnMainThread:@selector(reloadtable:) withObject:data waitUntilDone:YES];
//    
//    [[YDController shareController] hideLoadingV:self.view];
}

- (void)reloadtable:(NSString *)info {
    if (!_isGetWifiNode) {
        NSArray *array = [info componentsSeparatedByString:@"\r\n"];
        NSString *Active =@"";
        NSString *IsAPMode =@"";
        NSString *SSID_AP=@"";
        NSString *Password_AP =@"";
        NSString *SSID_STA =@"";
        NSString *Password_STA=@"";
        NSString *EncryptType=@"" ;
        
        for (int i=0; i<[array count]; i++) {
            NSString * tmp = [array objectAtIndex:i];
            
            if ([tmp rangeOfString:@"wifi_Active"].length > 0) {
                Active = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            if ([tmp rangeOfString:@"wifi_IsAPMode"].length > 0) {
                IsAPMode = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            if ([tmp rangeOfString:@"wifi_SSID_AP"].length > 0) {
                SSID_AP = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            if ([tmp rangeOfString:@"wifi_Password_AP"].length > 0) {
                Password_AP = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            if ([tmp rangeOfString:@"wifi_SSID_STA"].length > 0) {
                SSID_STA = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            if ([tmp rangeOfString:@"wifi_Password_STA"].length > 0) {
                EncryptType = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            if ([tmp rangeOfString:@"wifi_EncryptType"].length > 0) {
                Password_STA = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
            }
        }
        
        Active = [Active stringByReplacingOccurrencesOfString:@";" withString:@""];
        Active = [Active stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        IsAPMode = [IsAPMode stringByReplacingOccurrencesOfString:@";" withString:@""];
        IsAPMode = [IsAPMode stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        SSID_AP = [SSID_AP stringByReplacingOccurrencesOfString:@";" withString:@""];
        SSID_AP = [SSID_AP stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        Password_AP = [Password_AP stringByReplacingOccurrencesOfString:@";" withString:@""];
        Password_AP = [Password_AP stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        SSID_STA = [SSID_STA stringByReplacingOccurrencesOfString:@";" withString:@""];
        SSID_STA = [SSID_STA stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        Password_STA = [Password_STA stringByReplacingOccurrencesOfString:@";" withString:@""];
        Password_STA = [Password_STA stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        EncryptType = [EncryptType stringByReplacingOccurrencesOfString:@";" withString:@""];
        EncryptType = [EncryptType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if ([Active isEqualToString:@"1"]) {
            [_wifiSte setWifi_Active:YES];
            
            [self getWifiNode];
        } else {
            [_wifiSte setWifi_Active:NO];
        }
        
        if ([IsAPMode isEqualToString:@"1"]) {
            [_wifiSte setWifi_IsAPMode:YES];
        } else {
            [_wifiSte setWifi_IsAPMode:NO];
        }
        
        [_wifiSte setWifi_SSID_AP:SSID_AP];
        [_wifiSte setWifi_Password_AP:Password_AP];
        [_wifiSte setWifi_SSID_STA:SSID_STA];
        [_wifiSte setWifi_Password_STA:Password_STA];
        [_wifiSte setWifi_EncryptType:EncryptType];
        
        [_wifiTable reloadData];
    } else {
        NSMutableArray *arrayNode = [[NSMutableArray alloc] init];//用来放置node
        
        NSArray *array = [info componentsSeparatedByString:@"\r\n"];
        if ([array count] > 0 ) {
            for (int i = 0; i< [array count] - 1; i++) {
                KenWifiNodeInfo *node = [[KenWifiNodeInfo alloc] init];
                
                NSString *tmp = [array objectAtIndex:i];
                NSArray *oneList = [tmp componentsSeparatedByString:@" "];
                
                if (oneList && [oneList count] >= 5) {
                    NSArray *array = [[oneList objectAtIndex:0] componentsSeparatedByString:@":"];
                    if ([array count] > 1) {
                        [node setWifiName:[array objectAtIndex:1]];
                    }
                    array = [[oneList objectAtIndex:2] componentsSeparatedByString:@":"];
                    if ([array count] > 1) {
                        [node setType:[array objectAtIndex:1]];
                    }
                    array = [[oneList objectAtIndex:4] componentsSeparatedByString:@":"];
                    if ([array count] > 1) {
                        [node setAuth:[array objectAtIndex:1]];
                    }
                    array = [[oneList objectAtIndex:1] componentsSeparatedByString:@":"];
                    if ([array count] > 1) {
                        [node setSignal:[array objectAtIndex:1]];
                    }
                }
                
                if (6 == [oneList count]) {
                    NSArray *array = [[oneList objectAtIndex:5] componentsSeparatedByString:@"="];
                    if ([array count] > 1) {
                        [node setEncode:[array objectAtIndex:1]];
                    }
                }
                [arrayNode addObject:node];
            }
            [self setWifiListNode:arrayNode];
        }
        
        _sectionArray = @[@"无线局域网", @"当前可用网络"];
        [_wifiTable reloadData];
    }
    
    [self hideActivity];
}

- (void)closeDeviceWifi {
//    if ([[YDModel shareModel] isDdns:_deviceInfo]) {
//        NSString *host = [NSString stringWithFormat:@"http://%@:%d", [[YDModel shareModel] getCurrentIp:_deviceInfo], (int)[_deviceInfo httpport]];
//        NSString *url = [NSString stringWithFormat:@"cfg.cgi?User=%@&Psd=%@&MsgID=38&wifi_IsAPMode=1",
//                         [_deviceInfo getDeviceUsr],[_deviceInfo getDevicePwd]];
//        [[YDController shareController] controlSendCmd:host url:url
//                                               success:^(id info) {
//                                                   DebugLog("info = %@", info);
//                                               } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//                                               }];
//    } else {
//        NSString* request = [[NSString alloc] initWithFormat:@"%@cfg.cgi?User=%@&Psd=%@&MsgID=38&wifi_IsAPMode=1",
//                             kConnectP2pHost, [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd]];
//        [NSThread detachNewThreadSelector:@selector(loadWifiSettingurl:) toTarget:self withObject:request];
//    }
}

- (void)switchWifi:(UISwitch *)wifi {
    [_wifiSte setWifi_Active:[wifi isOn]];
    
    if ([wifi isOn]) {
        [self getWifiNode];
    } else {
        [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"是否确认关闭wifi连接" buttonTitles:@[@"取消", @"确认"] buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
            if (index == 1) {
                [self closeDeviceWifi];
                
                [self setWifiListNode:nil];
                [_wifiTable reloadData];
            } else if (index  == 0) {
                [wifi setOn:YES];
            }
        }];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sectionArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sectionArray objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [NSString isEmpty:[_wifiSte wifi_SSID_STA]] ? 1 : 2;
    } else if(1 == section) {
        if (_wifiListNode != nil) {
            return [_wifiListNode count];
        } else
            return 0;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *wifiSettingCellIdentifier = @"wifiSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:wifiSettingCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wifiSettingCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.accessoryView = nil;
    
    if(0 == indexPath.section) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"无线局域网";
            
            UISwitch *switchWifi = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,0,0)];
            [switchWifi addTarget:self action:@selector(switchWifi:) forControlEvents:UIControlEventValueChanged];
            [switchWifi setOn:[_wifiSte wifi_Active]];
            cell.accessoryView = switchWifi;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = [_wifiSte wifi_SSID_STA];
        }
    } else if (1 == indexPath.section) {
        KenWifiNodeInfo *node = [_wifiListNode objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [node wifiName];
        
        if ([[node wifiName] isEqualToString:[_wifiSte wifi_SSID_STA]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            NSString *request = [[NSString alloc] initWithFormat:@"%@：%@", @"信号强度", [node signal]];
            CGFloat width = [request widthForFont:[UIFont appFontSize14]];
            UILabel *label = [UILabel labelWithTxt:request frame:(CGRect){cell.width - width - 30, 0, width + 10, cell.height}
                                               font:[UIFont appFontSize14] color:[UIColor grayColor]];
            cell.accessoryView = label;
        }
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath section] == 1) {
//        YDWifiPwdInputVC *inputVC = [[YDWifiPwdInputVC alloc] initWithDevice:_deviceInfo
//                                                                    wifiNode:[_wifiListNode objectAtIndex:indexPath.row]];
//        [self pushViewController:inputVC];
    }
}

- (void)getWifiNode {
    _isGetWifiNode = YES;
//    [[YDController shareController] showLoadingV:self.view content:nil picS:NO];
//    if ([[YDModel shareModel] isDdns:_deviceInfo]) {
//        NSString *host = [NSString stringWithFormat:@"http://%@:%d", [[YDModel shareModel] getCurrentIp:_deviceInfo], (int)[_deviceInfo httpport]];
//        NSString *url = [NSString stringWithFormat:@"cfg.cgi?User=%@&Psd=%@&MsgID=36", [_deviceInfo getDeviceUsr],[_deviceInfo getDevicePwd]];
//        [[YDController shareController] controlSendCmd:host url:url success:^(id info) {
//            DebugLog("info = %@", info);
//            [self reloadtable:info];
//            [[YDController shareController] hideLoadingV:self.view];
//        } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//            [[YDController shareController] hideLoadingV:self.view];
//            
//            KenCustomAlert *alert = [[KenCustomAlert shareAlert] initWithTitle:@"提示"
//                                                                       message:@"网络获取失败，是否重新获取？"
//                                                             cancelButtonTitle:@"取消"
//                                                            confirmButtonTitle:@"确定"];
//            alert.alertBlock = ^(NSInteger index) {
//                if (index == 1) {
//                    [self getWifiNode];
//                }
//            };
//        }];
//    } else {
//        NSString *url = [[NSString alloc] initWithFormat:@"%@cfg.cgi?User=%@&Psd=%@&MsgID=36",
//                         kConnectP2pHost, [_deviceInfo getDeviceUsr], [_deviceInfo getDevicePwd]];
//        [NSThread detachNewThreadSelector:@selector(loadWifiSettingurl:) toTarget:self withObject:url];
//    }
}

#pragma mark - getter setter
- (UITableView *)wifiTable {
    if (_wifiTable == nil) {
        _wifiTable = [[UITableView alloc] initWithFrame:(CGRect){0, 0, self.contentView.size} style:UITableViewStyleGrouped];
        _wifiTable.delegate = self;
        _wifiTable.dataSource = self;
        [_wifiTable setBackgroundColor:[UIColor appBackgroundColor]];
        _wifiTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _wifiTable;
}
@end


#pragma mark - wifi set
@implementation KenWifiSteInfo

@end

@implementation KenWifiNodeInfo

@end
