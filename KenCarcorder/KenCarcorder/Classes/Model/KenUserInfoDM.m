//
//  KenUserInfoDM.m
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenUserInfoDM.h"

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

@end
