//
//  KenPlayDeviceDM.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayDeviceDM.h"

@implementation KenPlayDeviceDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"list":@[]};
}

+ (NSDictionary *)setContainerPropertyClassMap {
    return @{@"list":[KenPlayDeviceItemDM class]};
}

@end

#pragma mark - KenPlayBannerItemDM
@implementation KenPlayDeviceItemDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"name":@"",
             @"serverHost":@"",
             @"userName":@"",
             @"password":@"",
             @"topDiscuss":@"",
             @"imageUrl":@""};
}

+ (NSDictionary *)setCustomPropertyMap {
    return @{@"itemId":@"id"};
}

@end
