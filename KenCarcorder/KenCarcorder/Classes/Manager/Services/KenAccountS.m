//
//  KenAccountS.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAccountS.h"

@implementation KenAccountS

- (void)accountloginWithName:(NSString *)name pwd:(NSString *)pwd verCode:(NSString *)verCode
                       start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *request =   @{@"userId":name,
                                @"vericode":verCode,
                                @"password":pwd,
                                @"brand":@"Apple",
                                @"device":[[UIDevice currentDevice] model],
                                @"model":[[UIDevice currentDevice] name],
                                @"releaseVersion":[[UIDevice currentDevice] systemVersion],
                                @"sdkVersion":[[UIDevice currentDevice] systemVersion],
                                @"mac":[UIDevice getMacAddress],
                                @"action":@"regusr"};
    
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"user/login.json"]
            requestInfo:request start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                SafeHandleBlock(success, YES, nil, nil);
            }];
    
//    [_serviceBase cancelRequest:@"user/login.json"];
//    
//    NSMutableDictionary *muParam = [NSMutableDictionary dictionaryWithDictionary:params];
//    if ([[YDController shareController] getDataByKey:kDefaultDeviceToken]) {
//        [muParam setObject:[[YDController shareController] getDataByKey:kDefaultDeviceToken] forKey:@"token"];
//    }
//    
//    [_serviceBase requestPath:@"user/login.json" parameters:muParam success:^(id info) {
//        if ([[info objectForKey:kHttpResult] intValue] == 0) {
//            _userLogin = YES;
//            KenHandleBlock(success, YES, nil);
//        } else if ([[info objectForKey:kHttpResult] intValue] == 2){
//            KenHandleBlock(success, NO, [info objectForKey:kHttpMessage]);
//        } else {
//            kKenAlert([info objectForKey:kHttpMessage]);
//            KenHandleBlock(failure, 999, nil, nil);
//        }
//    } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//        DebugLog("error = %@", error.description);
//        KenHandleBlock(failure, serviceCode, requestOP, error);
//    }];
}
@end
