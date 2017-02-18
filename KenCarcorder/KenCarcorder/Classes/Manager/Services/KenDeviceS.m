//
//  KenDeviceS.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceS.h"
#import "KenMobileListDM.h"

@implementation KenDeviceS

- (void)deviceLoad:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"mobile/load.json"]
            requestInfo:nil start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    SafeHandleBlock(success, YES, nil, [KenMobileListDM initWithJsonDictionary:responseData]);
                }
            }];
}

- (void)deviceRemove:(NSString *)token
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"mobile/remove.json"] requestInfo:@{@"tokenOrMac":token}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    SafeHandleBlock(success, YES, nil, [KenMobileListDM initWithJsonDictionary:responseData]);
                }
            }];
}

@end
