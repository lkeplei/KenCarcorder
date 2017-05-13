//
//  KenUserInfoDM.m
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenUserInfoDM.h"
#import "KenDeviceDM.h"

@implementation KenUserInfoDM

static KenUserInfoDM *userInfo = nil;

+ (KenUserInfoDM *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfo = [KenUserInfoDM getInstance];
        if (userInfo == nil) {
            userInfo = [KenUserInfoDM initWithJsonDictionary:@{}];
        }
    });
    return userInfo;
}

+ (NSDictionary *)setDefaultValueMap {
    return @{@"userName":@"",
             @"userPwd":@"",
             @"deviceGroups":@[@"家",@"商店",@"单位",@"其他"],
             @"deviceArray":@[]};
}

#pragma mark - public method
- (BOOL)updateUserInfo:(NSDictionary *)dic {
    if ([self updateWithJsonDictionary:dic]) {
        return [self setInstance];
    }
    return NO;
}

- (KenDeviceDM *)deviceWithSN:(NSString *)sn {
    for (KenDeviceDM *device in _deviceArray) {
        if ([device.sn isEqualToString:sn]) {
            return device;
        }
    }
    
    return nil;
}

- (void)setDevices:(NSArray *)array {
    _deviceArray = [NSMutableArray arrayWithArray:array];
    
    [self setInstance];
}

- (void)removeDevice:(KenDeviceDM *)device {
    for (KenDeviceDM *device in _deviceArray) {
        if ([device.sn isEqualToString:device.sn]) {
            [_deviceArray removeObject:device];
            
            [self setInstance];
            
            [[KenServiceManager sharedServiceManager] getAarmStat];
            
            return;
        }
    }
}

- (BOOL)addDevice:(KenDeviceDM *)device {
    for (KenDeviceDM *info in _deviceArray) {
        if ([[info sn] isEqualToString:[device sn]]) {
            return NO;
        }
    }
    
    [_deviceArray addObject:device];
    
    [self setInstance]
    ;
    return YES;
}

- (void)saveDevicePwd:(NSString *)password device:(KenDeviceDM *)device {
    if (![[device pwd] isEqualToString:password]) {
        KenDeviceDM *selDevice = nil;
        for (KenDeviceDM *info in _deviceArray) {
            if ([info.sn isEqualToString:device.sn]) {
                selDevice = info;
                [info setPwd:password];
                break;
            }
        }
        
        if (selDevice) {
            [[KenServiceManager sharedServiceManager] deviceValidatePwd:device finish:^(BOOL lock) {
                [selDevice setDeviceLock:lock];
                [self setInstance];
            }];
        }
    }
}

@end
