//
//  KenHttpBaseService.h
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHttpFailedErrorCode            -9999
#define kHttpFailedErrorMsg             @"服务异常，请稍后重试"

#define kHttpResult         @"result"
#define kHttpMessage        @"message"

NS_ASSUME_NONNULL_BEGIN

@interface KenHttpBaseService : NSObject

- (BOOL)isWifiNet;

/**
 *  异步http请求    get
 *
 *  @param url       请求url
 *  @param params    请求所带的参数
 *  @param start     请求开始回调
 *  @param responsed 请求正常响应回调
 *  @param failed    请求失败或者异常回调
 */
- (void)asyncGet:(NSString *)url queryParams:(nullable NSDictionary<NSString *, NSString *> *)params
      startBlock:(RequestStartBlock)start responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed;

/**
 *  异步http请求
 *
 *  @param url       请求url
 *  @param postData  请求所带的参数
 *  @param start     请求开始回调
 *  @param responsed 请求正常响应回调
 *  @param failed    请求失败或者异常回调
 */
- (void)asyncPost:(NSString *)url postData:(nullable NSDictionary *)postData startBlock:(RequestStartBlock)start
   responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed;

/**
 *  上传文件
 *
 *  @param Url        请求Url
 *  @param postParams 参数
 *  @param fileKey    文件key值
 *  @param filePath   文件路径
 *  @param start      开始回调
 *  @param responsed  正常响应回调
 *  @param failed     请求失败或者异常回调
 */
- (void)uploadFile:(NSString *)Url postParams:(NSDictionary *)postParams andFileKey:(NSString *)fileKey
       andFilePath:(NSString *)filePath startBlock:(RequestStartBlock)start progress:(nullable void (^)(double progress))progress
    responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed;

/**
 *  上传UIImage
 *
 *  @param Url        请求Url
 *  @param postParams 参数
 *  @param fileKey    文件key值
 *  @param image      要上传的图片
 *  @param start      开始回调
 *  @param responsed  正常响应回调
 *  @param failed     请求失败或者异常回调
 */
- (void)uploadImage:(NSString *)Url postParams:(NSDictionary *)postParams andFileKey:(NSString *)fileKey
              image:(UIImage *)image startBlock:(RequestStartBlock)start progress:(nullable void (^)(double progress))progress
     responsedBlock:(ResponsedBlock)responsed failedBlock:(RequestFailureBlock)failed;

/**
 *  异步http请求，统一把异常的处理逻辑的方都在低层处理掉，外层只需要处理成功的地方
 *
 *  @param url          请求url
 *  @param requestInfo  请求所带的参数
 *  @param start        请求开始回调
 *  @param success      请求正常响应回调
 *  @param failed       请求失败或者异常回调
 *  @param response     这个是需要外层处理的回调，其他情况都给统一处理掉了，这里是成功不一样的地方处理
 */
- (void)httpAsyncPost:(NSString *)url requestInfo:(nullable NSDictionary *)requestInfo start:(nullable RequestStartBlock)start
         successBlock:(nullable ResponsedSuccessBlock)success failedBlock:(nullable RequestFailureBlock)failed
        responseBlock:(ResponsedBlock)response;

@end

NS_ASSUME_NONNULL_END
