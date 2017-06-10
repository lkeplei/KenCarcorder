//
//  KenDeviceWifiSetVC.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@interface KenDeviceWifiSetVC : KenBaseVC

- (instancetype)initWithDevice:(KenDeviceDM *)device;

@end



#pragma mark - wifi set
@interface KenWifiSteInfo : NSObject

@property (nonatomic, strong) NSString *wifi_SSID_AP;
@property (nonatomic, strong) NSString *wifi_Password_AP;
@property (nonatomic, strong) NSString *wifi_SSID_STA;
@property (nonatomic, strong) NSString *wifi_Password_STA;
@property (nonatomic, strong) NSString *wifi_EncryptType;
@property (nonatomic, assign) BOOL wifi_Active;
@property (nonatomic, assign) BOOL wifi_IsAPMode;

@end

@interface KenWifiNodeInfo : NSObject

@property (nonatomic, strong)  NSString *wifiName;
@property (nonatomic, strong)  NSString *type;
@property (nonatomic, strong)  NSString *auth;
@property (nonatomic, strong)  NSString *encode;
@property (nonatomic, strong)  NSString *signal;

@end
