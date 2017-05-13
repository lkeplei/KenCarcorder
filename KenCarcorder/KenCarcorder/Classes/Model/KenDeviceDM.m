//
//  KenDeviceDM.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceDM.h"

@implementation KenDeviceDM
+ (NSDictionary *)setDefaultValueMap {
    return @{@"usr":@"admin",
             @"pwd":@"admin",
             @"uid":@"admin",
             @"uidpsd":@"admin",
             @"lanIp":@"",
             @"devWanIp":@""};
}

#pragma mark - public method
- (NSString *)currentIp {
    if ([self isLocal]) {
        return _lanIp;
    } else {
        return _ddns;
    }
}

- (BOOL)isDDNS {
    if ([self isLocal]) {
        return YES;
    }
    
    return _netStat != kKenNetworkP2p;
}

- (NSString *)name {
    if ([NSString isEmpty:_name]) {
        return _sn;
    }
    return _name;
}

#pragma mark - private method
- (BOOL)isLocal {
    BOOL res = NO;
    
//    if ([[YDController shareController] isNetStatusWifi] && [_devWanIp isEqualToString:SysDelegate.phoneWanIp]) {
//        NSArray *devLan = [_lanIp componentsSeparatedByString:@"."];
//        if (devLan && [devLan count] == 4) {
//            NSArray *localLan = [SysDelegate.phoneLanIp componentsSeparatedByString:@"."];
//            if (devLan && [devLan count] == 4) {
//                if ([[devLan objectAtIndex:2] isEqualToString:[localLan objectAtIndex:2]]) {
//                    res = YES;
//                }
//            }
//        }
//    }
    
    return res;
}
@end
