//
//  KenAccountS.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAccountS.h"
#import "KenLoginDM.h"
#import "KenUserInfoDM.h"

@implementation KenAccountS

- (void)accountloginWithName:(NSString *)name pwd:(NSString *)pwd verCode:(NSString *)verCode
                       start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *request =   @{@"userId":name,
                                @"vericode":[NSString isNotEmpty:verCode] ? verCode : @"",
                                @"password":pwd,
                                @"brand":@"Apple",
                                @"device":[[UIDevice currentDevice] model],
                                @"model":[[UIDevice currentDevice] name],
                                @"releaseVersion":[[UIDevice currentDevice] systemVersion],
                                @"sdkVersion":[[UIDevice currentDevice] systemVersion],
                                @"mac":[UIDevice getMacAddress],
                                @"action":@"regusr"};
    
    KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
    if (userInfo == nil) {
        userInfo = [[KenUserInfoDM alloc] init];
    }
    userInfo.userName = name;
    userInfo.userPwd = pwd;
    [userInfo setInstance];
    
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"user/login.json"]
            requestInfo:request start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                SafeHandleBlock(success, YES, nil, [KenLoginDM initWithJsonDictionary:responseData]);
            }];
}

- (void)accountGetVerCode:(NSString *)phone start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
              failedBlock:(RequestFailureBlock)failed {
    NSDictionary *request =  @{@"mobile":phone};

    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"user/vericode.json"]
            requestInfo:request start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    SafeHandleBlock(success, YES, nil, nil);
                }
            }];
}

- (void)accountRegist:(NSString *)phone pwd:(NSString *)pwd verCode:(NSString *)verCode reset:(BOOL)reset
                start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *request =   @{@"userId":phone,
                                @"registerCode":[NSString isNotEmpty:verCode] ? verCode : @"",
                                @"password":pwd,
                                @"brand":@"Apple",
                                @"device":[[UIDevice currentDevice] model],
                                @"model":[[UIDevice currentDevice] name],
                                @"releaseVersion":[[UIDevice currentDevice] systemVersion],
                                @"sdkVersion":[[UIDevice currentDevice] systemVersion],
                                @"mac":[UIDevice getMacAddress],
                                @"action":reset ? @"chpwd" : @"regusr"};
    
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"user/register.json"]
            requestInfo:request start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
                    if (userInfo == nil) {
                        userInfo = [[KenUserInfoDM alloc] init];
                    }
                    userInfo.userName = phone;
                    userInfo.userPwd = pwd;
                    [userInfo setInstance];
                    
                    SafeHandleBlock(success, YES, nil, nil);
                }
            }];
}

@end
