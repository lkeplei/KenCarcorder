//
//  KenServiceManager.m
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenServiceManager.h"
#import "KenHttpBaseService.h"
#import "KenAccountS.h"
#import "KenDeviceS.h"
#import "KenAlarmS.h"
#import "KenPlayS.h"
#import "KenAlarmStatDM.h"
#import "KenDeviceDM.h"

#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@implementation KenServiceManager

+ (KenServiceManager *)sharedServiceManager {
    static KenServiceManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[KenServiceManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - public method
- (NSArray *)servicesArray {
    return @[[[KenAccountS alloc] init],
             [[KenDeviceS alloc] init],
             [[KenPlayS alloc] init],
             [[KenAlarmS alloc] init]];
}

- (NSString *)dispathPath {
    return @"";
}

- (void)getAarmStat {
    @weakify(self)
    [self alarmAtat:^{
        
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenAlarmStatDM * _Nullable statDM) {
        @strongify(self)
        self.alarmNumbers = 0;
        for (NSInteger i = 0; i < statDM.list.count; i++) {
            KenAlarmStatItemDM *stat = [statDM.list objectAtIndex:i];
            _alarmNumbers += stat.count;
            
            KenDeviceDM *device = [[KenUserInfoDM sharedInstance] deviceWithSN:stat.sn];
            if (device) {
                device.haveUnreadAlarm = YES;
            }
        }
        
        [self updateAarmStat];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        
    }];
}

- (void)updateAarmStat {
    NSString *badge = nil;
    if (_alarmNumbers > 0) {
        badge = _alarmNumbers > 99 ? @"99+": [NSString stringWithFormat:@"%zd", _alarmNumbers];
    }
    
    [SysDelegate.rootVC setItemBadge:3 badge:badge];
}

- (void)getWanIp {
    @weakify(self)
    [self accountWanIp:^{
        
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        @strongify(self)
        if (successful) {
            self.phoneWanIp = responseData;
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        
    }];
}

- (NSString *)phoneLanIp {
    if (_phoneLanIp == nil) {
        _phoneLanIp = [self localIPAddress];
    }
    return _phoneLanIp;
}

- (BOOL)isWifiNet {
    return [((KenHttpBaseService *)[self.servicesArray objectAtIndex:0]) isWifiNet];
}

#pragma mark - 获取局域网ip
- (NSString *)localIPAddress {
    char baseHostName[256]; // Thanks, Gunnar Larisch
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '/0';
    
    NSString *hostName = @"";
#if TARGET_IPHONE_SIMULATOR
    hostName = [NSString stringWithFormat:@"%s", baseHostName];
#else
    hostName = [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
    
    struct hostent *host = gethostbyname([hostName UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

#pragma mark - 消息转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    KenHttpBaseService *service = [self serviceRespondsToSelector:aSelector];
    if (service) {
        return service;
    }
    
    return self;
}

- (id)serviceRespondsToSelector:(SEL)aSelector {
    for (KenHttpBaseService *service in [self servicesArray]) {
        if ([service respondsToSelector:aSelector]) {
            return service;
        }
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self serviceRespondsToSelector:aSelector] != nil) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

@end
