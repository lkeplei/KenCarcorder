//
//  KenPlayBannerDM.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayBannerDM.h"

@implementation KenPlayBannerDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"list":@[]};
}

+ (NSDictionary *)setContainerPropertyClassMap {
    return @{@"list":[KenPlayBannerItemDM class]};
}

@end

#pragma mark - KenPlayBannerItemDM
@implementation KenPlayBannerItemDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"activeImageUrl":@"",
             @"imageUrl":@"",
             @"name":@"",};
}

+ (NSDictionary *)setCustomPropertyMap {
    return @{@"itemId":@"id"};
}

@end
