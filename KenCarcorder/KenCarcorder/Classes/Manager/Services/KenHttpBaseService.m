//
//  KenHttpBaseService.m
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenHttpBaseService.h"
#import "KenAFHttp.h"

@implementation KenHttpBaseService

- (void)asyncGet:(NSString *)url queryParams:(nullable NSDictionary<NSString *, NSString *> *)params
      startBlock:(RequestStartBlock)start responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed
{
    SafeHandleBlock(start);
    
    [[KenAFHttp sharedAFHttp] asyncGet:url queryParams:params success:^(id responseData) {
        SafeHandleBlock(responsed, responseData);
    } failure:^(NSInteger status, NSString *errMsg) {
        SafeHandleBlock(failed, status, errMsg);
    }];
}

- (void)asyncPost:(NSString *)url postData:(nullable NSDictionary *)postData startBlock:(RequestStartBlock)start
   responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed
{
    SafeHandleBlock(start);
    
    [[KenAFHttp sharedAFHttp] asyncPost:url postParams:postData success:^(id  _Nullable responseData) {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
#ifdef DEBUG
            NSArray *emoji = @[@"\U0001F604", @"\U0001F60D", @"\U0001F618", @"\U0001F61C", @"\U0001F601"];
            NSInteger index = arc4random() % [emoji count];
            DebugLog("\n===================================\
                     \npath: %@\nparams: %@\
                     \nresponse: %@\
                     \n%@%@%@%@:\
                     \nserviceCode: %d\
                     \nErrorMsg: %@\
                     \n===================================",
                     url, (postData ?: @""), responseData,
                     emoji[index],emoji[index],emoji[index],emoji[index],
                     [[responseData objectForKey:@"code"] intValue], [responseData objectForKey:@"msg"]);
#endif
            
            SafeHandleBlock(responsed, responseData);
        } else {
            DebugLog("\n===================================\
                     \npath: %@\nparams: %@\
                     \n\U0001F621\U0001F621\U0001F621\U0001F621\U0001F621: %@\
                     \n===================================",
                     url, (postData ?: @""), kHttpFailedErrorMsg);
            
            SafeHandleBlock(failed, kHttpFailedErrorCode, @"返回数据异常");
        }
    } failure:^(NSInteger status, NSString * _Nullable errMsg) {
        DebugLog("\n===================================\
                 \npath: %@\nparams: %@\
                 \n\U0001F621\U0001F621\U0001F621\U0001F621\U0001F621: %@\
                 \n===================================",
                 url, (postData ?: @""), errMsg);
        
        SafeHandleBlock(failed, status, errMsg);
    }];
}

- (void)uploadFile:(NSString *)Url postParams:(NSDictionary *)postParams andFileKey:(NSString *)fileKey
       andFilePath:(NSString *)filePath startBlock:(RequestStartBlock)start progress:(nullable void (^)(double progress))progress
    responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed
{
    SafeHandleBlock(start);
    
    [[KenAFHttp sharedAFHttp] upload:Url postParams:postParams fileKey:fileKey filePath:filePath
                             progress:^(double progressN) {
                                 SafeHandleBlock(progress, progressN);
                             } response:^(NSError *error, id result) {
                                 if (error) {
                                     SafeHandleBlock(failed, kHttpFailedErrorCode, kHttpFailedErrorMsg);
                                 } else {
                                     SafeHandleBlock(responsed, result);
                                 };
                             }];
}

- (void)uploadImage:(NSString *)Url postParams:(NSDictionary *)postParams andFileKey:(NSString *)fileKey
              image:(UIImage *)image startBlock:(RequestStartBlock)start progress:(nullable void (^)(double progress))progress
     responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed
{
    [[KenAFHttp sharedAFHttp] upload:Url postParams:postParams fileKey:fileKey image:image start:^{
        SafeHandleBlock(start);
    } progress:^(double progressN) {
        SafeHandleBlock(progress, progressN);
    } response:^(NSError *error, id result) {
        if (error) {
            SafeHandleBlock(failed, kHttpFailedErrorCode, kHttpFailedErrorMsg);
        } else {
            SafeHandleBlock(responsed, result);
        };
    }];
}

- (void)httpAsyncPost:(NSString *)url requestInfo:(nullable NSDictionary *)requestInfo start:(nullable RequestStartBlock)start
         successBlock:(nullable ResponsedSuccessBlock)success failedBlock:(nullable RequestFailureBlock)failed
        responseBlock:(ResponsedBlock)response {
    [self asyncPost:url postData:requestInfo startBlock:^{
        SafeHandleBlock(start);
    } responsedBlock:^(NSDictionary *responseDic) {
        NSArray *allKeys = [responseDic allKeys];
        if ([allKeys containsObject:kHttpResult] || [allKeys containsObject:kHttpMessage]) {
            if ([[responseDic objectForKey:kHttpResult] intValue] == 0 ||
                [[responseDic objectForKey:kHttpMessage] isEqualToString:@"ok"]) {
                SafeHandleBlock(response, responseDic);
            } else {
                if ([responseDic objectForKey:kHttpMessage]) {
                    SafeHandleBlock(failed, kHttpFailedErrorCode, [responseDic objectForKey:kHttpMessage]);
                } else {
                    SafeHandleBlock(failed, kHttpFailedErrorCode, kHttpFailedErrorMsg);
                }
            }
        } else {
            SafeHandleBlock(response, responseDic);
        }
    } failedBlock:^(NSInteger status, NSString *errMsg) {
        SafeHandleBlock(failed, status, kHttpFailedErrorMsg);
    }];
}

- (BOOL)httpResponseCode:(NSDictionary *)resDic successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    BOOL res = YES;
    NSInteger resCode = [[resDic objectForKey:@"code"] integerValue];
    NSString *errMsg = [resDic objectForKey:@"msg"];
    
    if (resCode != 100) {
        if ([UIApplication isNotEmpty:errMsg]) {
            if (resCode == 10000 || resCode == 10002) {
                //10000 账号被挤掉了；10002 账号未登录
                SafeHandleBlock(success, NO, errMsg, nil);
            } else {
                SafeHandleBlock(success, NO, errMsg, nil);
            }
        } else {
            SafeHandleBlock(failed, kHttpFailedErrorCode, kHttpFailedErrorMsg);
        }
        
        res = NO;
    }
    return res;
}

@end
