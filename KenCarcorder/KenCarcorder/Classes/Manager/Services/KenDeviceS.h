//
//  KenDeviceS.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHttpBaseService.h"

@interface KenDeviceS : KenHttpBaseService

- (void)deviceLoad:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceRemove:(NSString *)token
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;
    
@end
