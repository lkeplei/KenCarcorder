//
//  KenAlarmS.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAlarmS.h"
#import "KenAlarmDM.h"

@implementation KenAlarmS

- (void)alarmWithCondition:(NSInteger)alarmId sn:(NSString *)sn readed:(NSString *)readed groupNo:(NSInteger)groupNo
                   success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setObject:[NSNumber numberWithInt:10] forKey:@"count"];
    if (alarmId != 0) {
        [request setObject:[NSNumber numberWithInteger:alarmId] forKey:@"startId"];
    }
    
    if ([NSString isNotEmpty:readed]) {
        [request setObject:readed forKey:@"readed"];
    }
    
    if ([NSString isNotEmpty:sn]) {
        [request setObject:sn forKey:@"sn"];
    } else if (groupNo >= 0 && groupNo < [[KenUserInfoDM getInstance].deviceGroups count]) {
        [request setObject:[NSNumber numberWithInteger:groupNo] forKey:@"groupNo"];
    }
    
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"alarm/list.json"]
            requestInfo:request start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                SafeHandleBlock(success, YES, nil, [KenAlarmDM initWithJsonDictionary:responseData]);
            }];
}

@end
