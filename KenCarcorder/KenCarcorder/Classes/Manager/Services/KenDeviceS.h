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

- (void)deviceGetGroups:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceSaveGroups:(NSArray *)groups
                 success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceSetGroupName:(NSString *)name groupNo:(NSInteger)groupNo
                   success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceShareRegister:(KenDeviceDM *)device
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceScanStop:(KenDeviceDM *)device
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceScanUpDown:(KenDeviceDM *)device
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceScanLeftRight:(KenDeviceDM *)device
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceTurnUpDown:(KenDeviceDM *)device flip:(BOOL)flip
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceTurnLeftRight:(KenDeviceDM *)device mirror:(BOOL)mirror
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;
@end
