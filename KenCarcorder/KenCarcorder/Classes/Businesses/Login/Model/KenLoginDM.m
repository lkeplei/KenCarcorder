//
//  KenLoginDM.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenLoginDM.h"
#import "KenDeviceDM.h"

@implementation KenLoginDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"message":@"",
             @"list":@[]};
}

+ (NSDictionary *)setContainerPropertyClassMap {
    return @{@"list":[KenDeviceDM class]};
}

@end
