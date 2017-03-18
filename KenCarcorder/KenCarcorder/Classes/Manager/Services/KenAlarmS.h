//
//  KenAlarmS.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHttpBaseService.h"

@interface KenAlarmS : KenHttpBaseService

- (void)alarmWithGroupNo:(NSString *)groupNo success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
             failedBlock:(RequestFailureBlock)failed;

@end
