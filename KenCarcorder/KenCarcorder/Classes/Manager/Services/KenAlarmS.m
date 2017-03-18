//
//  KenAlarmS.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAlarmS.h"

@implementation KenAlarmS

- (void)alarmWithGroupNo:(NSString *)groupNo success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
             failedBlock:(RequestFailureBlock)failed {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    
    
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"alarm/list.json"]
            requestInfo:request start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                SafeHandleBlock(success, YES, nil, [KenLoginDM initWithJsonDictionary:responseData]);
            }];
}



- (void)getAlarmListByCondition:(NSInteger)alarmId sn:(NSString *)sn readed:(NSString *)readed groupNo:(NSInteger)groupNo
                        success:(void(^)(id))success failure:(HttpFailureBlock)failure {
    [_serviceBase cancelRequest:@"alarm/list.json"];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:10] forKey:@"count"];
    if (alarmId != 0) {
        [params setObject:[NSNumber numberWithInteger:alarmId] forKey:@"startId"];
    }
    
    if ([KenUtils isNotEmpty:readed]) {
        [params setObject:readed forKey:@"readed"];
    }
    
    if ([KenUtils isNotEmpty:sn]) {
        [params setObject:sn forKey:@"sn"];
    } else if (groupNo >= 0 && groupNo < [[[YDModel shareModel] getUserGroups] count]) {
        [params setObject:[NSNumber numberWithInteger:groupNo] forKey:@"groupNo"];
    }
    
    [_serviceBase requestPath:@"alarm/list.json" parameters:[self getRequestDic:params] success:^(id info) {
        if ([[info objectForKey:kHttpResult] intValue] == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSArray *categoryArr = [info objectForKey:@"list"];
            for (NSDictionary *dic in categoryArr) {
                [array addObject:[dic returnAlarmInfo]];
            }
            
            KenHandleBlock(success, array);
        }
    } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
        DebugLog("error = %@", error.description);
        KenHandleBlock(failure, serviceCode, requestOP, error);
    }];
}

@end
