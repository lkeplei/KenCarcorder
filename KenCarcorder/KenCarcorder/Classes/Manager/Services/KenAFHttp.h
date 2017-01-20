//
//  KenAFHttp.h
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KenAFHttp : NSObject

+ (nonnull instancetype)sharedAFHttp;

- (void)asyncGet:(nonnull NSString *)url queryParams:(nullable NSDictionary<NSString *, NSString *> *)params
         success:(ResponsedBlock)success failure:(RequestFailureBlock)failure;

- (void)asyncPost:(nonnull NSString *)url postParams:(nullable NSDictionary<NSString *, NSString *> *)params
          success:(ResponsedBlock)success failure:(RequestFailureBlock)failure;

- (void)asyncPost:(nonnull NSString *)url postJson:(nonnull id)jsonObject
          success:(ResponsedBlock)success failure:(RequestFailureBlock)failure;

- (void)upload:(nonnull NSString *)url
    postParams:(nullable NSDictionary<NSString *, NSString *> *)params
       fileKey:(NSString *)fkey
      filePath:(NSString *)fpath
      progress:(nullable void (^)(double progress))progress
      response:(nullable void (^)(NSError * _Nullable error, id _Nullable result))response;

- (void)upload:(nonnull NSString *)url
    postParams:(nullable NSDictionary *)params
       fileKey:(NSString *)fkey
         image:(UIImage *)image
         start:(nullable void (^)())start
      progress:(nullable void (^)(double progress))progress
      response:(nullable void (^)(NSError * _Nullable error, id _Nullable result))response;

@end

NS_ASSUME_NONNULL_END
