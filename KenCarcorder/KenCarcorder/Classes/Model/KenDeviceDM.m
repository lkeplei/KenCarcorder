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

@end
