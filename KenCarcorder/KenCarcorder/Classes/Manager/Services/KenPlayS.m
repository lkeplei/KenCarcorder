//
//  KenPlayS.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayS.h"
#import "KenPlayBannerDM.h"
#import "KenPlayDeviceDM.h"

@implementation KenPlayS

- (void)playBanner:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"plaza/categories.json"] requestInfo:nil
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, [KenPlayBannerDM initWithJsonDictionary:responseData]);
                  }];
}

- (void)playBannerDevice:(NSInteger)bannerId
                   start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"plaza/items.json"] requestInfo:@{@"category":[NSNumber numberWithInteger:bannerId]}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, [KenPlayDeviceDM initWithJsonDictionary:responseData]);
                  }];
}

@end
