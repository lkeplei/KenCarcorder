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
@end
