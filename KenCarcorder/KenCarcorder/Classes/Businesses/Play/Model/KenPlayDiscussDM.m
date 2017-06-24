//
//  KenPlayDiscussDM.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/24.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayDiscussDM.h"

@implementation KenPlayDiscussDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"list":@[]};
}

+ (NSDictionary *)setContainerPropertyClassMap {
    return @{@"list":[KenPlayDiscussItemDM class]};
}

@end


@implementation KenPlayDiscussItemDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"content":@"",
             @"userName":@"",
             @"userId":@""};
}

- (NSDate *)timeDate {
    return [NSDate dateWithTimeIntervalSince1970:_createDate];
}

@end
