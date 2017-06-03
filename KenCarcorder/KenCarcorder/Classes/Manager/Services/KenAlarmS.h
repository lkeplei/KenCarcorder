//
//  KenAlarmS.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHttpBaseService.h"

@interface KenAlarmS : KenHttpBaseService

- (void)alarmWithCondition:(NSInteger)alarmId sn:(NSString *)sn readed:(NSString *)readed groupNo:(NSInteger)groupNo
                   success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmDeleteWithId:(NSArray *)alarmIdArr
                  success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmAtat:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmDeleteWithType:(NSString *)type
                    success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmReadWithId:(NSArray *)alarmIdArr
                success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmSetOnOff:(BOOL)on sn:(NSString *)sn
              success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

@end
