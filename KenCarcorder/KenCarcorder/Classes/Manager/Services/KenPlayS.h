//
//  KenPlayS.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHttpBaseService.h"

@interface KenPlayS : KenHttpBaseService

- (void)playBanner:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)playBannerDevice:(NSInteger)bannerId
                   start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)playWithId:(NSInteger)itemId
             start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)playPraiseWithId:(NSInteger)itemId
                   start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)playDiscussDataWithId:(NSInteger)itemId offset:(NSUInteger)offset
                        start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)playDiscuss:(NSInteger)itemId content:(NSString *)content
              start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

@end
