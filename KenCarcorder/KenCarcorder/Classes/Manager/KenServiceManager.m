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
#import "KenAlarmStatDM.h"

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
            
//            YDDeviceInfo *device = [[YDModel shareModel] getDeviceBySn:stat.deviceSn];
//            if (device) {
//                device.haveUnreadAlarm = YES;
//            }
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
