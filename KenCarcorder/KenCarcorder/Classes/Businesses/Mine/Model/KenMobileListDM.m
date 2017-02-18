//
//  KenMobileListDM.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenMobileListDM.h"

@implementation KenMobileListDM

+ (NSDictionary *)setContainerPropertyClassMap {
    return @{@"list":[KenMobileItemDM class]};
}

+ (NSDictionary *)setDefaultValueMap {
    return @{@"total":@0,
             @"list":@[]};
}

@end

#pragma mark - mobile item
@implementation KenMobileItemDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"updateDate":@0,
             @"createDate":@0,
             @"userId":@"",
             @"onlyId":@"",
             @"platform":@"",
             @"model":@"",
             @"releaseVersion":@"",
             @"brand":@"",
             @"tokenOrMac":@""};
}

@end
