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
#import "KenPlayDiscussDM.h"

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

- (void)playWithId:(NSInteger)itemId
             start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *params = @{@"itemId":[NSNumber numberWithInteger:itemId], @"actionType":@1};
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"plaza/action.json"] requestInfo:params
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, nil);
                  }];
}

- (void)playPraiseWithId:(NSInteger)itemId
                   start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *params = @{@"itemId":[NSNumber numberWithInteger:itemId], @"actionType":@2};
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"plaza/action.json"] requestInfo:params
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, nil);
                  }];
}

- (void)playDiscussDataWithId:(NSInteger)itemId offset:(NSUInteger)offset
                        start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *params = @{@"itemId":[NSNumber numberWithInteger:itemId],
                             @"start":[NSNumber numberWithInteger:offset], @"limit":@10};
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"discuss/list.json"] requestInfo:params
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      KenPlayDiscussDM *discuss = [KenPlayDiscussDM initWithJsonDictionary:responseData];
                      discuss.haveMore = discuss.list.count >= 10 ? YES : NO;
                      SafeHandleBlock(success, YES, nil, discuss);
                  }];
}

- (void)playDiscuss:(NSInteger)itemId content:(NSString *)content
                        start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *params = @{@"itemId":[NSNumber numberWithInteger:itemId], @"content":content};
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"discuss/commit.json"] requestInfo:params
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, nil);
                  }];
}

@end
