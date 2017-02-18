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

- (void)deviceGetGroups:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"group/load.json"]
            requestInfo:nil start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    NSMutableArray *groups = [NSMutableArray array];
                    NSArray *array = [responseData objectForKey:@"list"];
                    
                    if ([array count] > 0) {
                        for (int i = 0; i < [array count]; i++) {
                            [groups addObject:[[array objectAtIndex:i] objectForKey:@"name"]];
                        }
                    }
                    
                    SafeHandleBlock(success, YES, nil, groups);
                }
            }];
}

- (void)deviceSaveGroups:(NSArray *)groups
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"group/saveAll.json"] requestInfo:@{@"groupNames":[groups toJson]}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      if ([[responseData objectForKey:@"result"] intValue] != 0) {
                          SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                      } else {
                          SafeHandleBlock(success, YES, nil, nil);
                      }
                  }];
}

- (void)deviceSetGroupName:(NSString *)name groupNo:(NSInteger)groupNo
                 success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *request = @{@"groupNo":[NSNumber numberWithInteger:groupNo], @"groupName":name};
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"group/save.json"] requestInfo:request
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      if ([[responseData objectForKey:@"result"] intValue] != 0) {
                          SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                      } else {
                          SafeHandleBlock(success, YES, nil, nil);
                      }
                  }];
}

@end
