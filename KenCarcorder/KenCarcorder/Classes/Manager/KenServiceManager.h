//
//  KenServiceManager.h
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppServerHost             @"http://www.7cyun.com.cn:80/"

typedef void (^RequestStartBlock)(void);
typedef void (^ResponsedBlock)(id _Nullable responseData);
typedef void (^ResponsedSuccessBlock)(BOOL successful, NSString * _Nullable errMsg, id _Nullable responseData);
typedef void (^RequestFailureBlock)(NSInteger status, NSString * _Nullable errMsg);

@interface KenServiceManager : NSObject

+ (KenServiceManager *)sharedServiceManager;

//获取所有服务
- (NSArray *)servicesArray;

//获取分发配置路径
- (NSString *)dispathPath;

#pragma mark - account
- (void)accountLogout;

- (void)accountLoginWithName:(NSString *)name pwd:(NSString *)pwd verCode:(NSString *)verCode
                       start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)accountGetVerCode:(NSString *)phone start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
              failedBlock:(RequestFailureBlock)failed;

- (void)accountRegist:(NSString *)phone pwd:(NSString *)pwd verCode:(NSString *)verCode reset:(BOOL)reset
                start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

#pragma mark - device
- (void)deviceLoad:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceRemove:(NSString *)token
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceGetGroups:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceSaveGroups:(NSArray *)groups
                 success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceSetGroupName:(NSString *)name groupNo:(NSInteger)groupNo
                   success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

#pragma mark - alarm
- (void)alarmWithGroupNo:(NSString *)groupNo success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
             failedBlock:(RequestFailureBlock)failed;

@end
