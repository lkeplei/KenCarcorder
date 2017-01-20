//
//  KenAFHttp.m
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenAFHttp.h"
#import "AFNetworking.h"
#import "KenUserInfoDM.h"

#define kKenHttpTimeoutValue       (10)

@interface KenAFHttp ()

@property (nonatomic, weak) AFHTTPSessionManager *httpSessionManager;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) AFJSONRequestSerializer *jsonRequestSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, copy) void(^progressBlock)(double progress);
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *defaultParams;

@property (nonatomic, strong) NSString *customUserAgent;                    //自定义UserAgent

@end

@implementation KenAFHttp

+ (nonnull instancetype)sharedAFHttp {
    static KenAFHttp *http = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http = [[self alloc] init];
    });
    
    return http;
}

- (instancetype)init {
    self = [super init];
    
    _httpSessionManager = [AFHTTPSessionManager manager];
    _progressBlock         = nil;
    
    //设置自定义User Agent
    NSString *customUserAgent = self.customUserAgent;
    
    //request
    _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
    _httpRequestSerializer.timeoutInterval = kKenHttpTimeoutValue;
    [_httpRequestSerializer setValue:customUserAgent forHTTPHeaderField:@"standardUA"];
    
    _jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    _jsonRequestSerializer.timeoutInterval = kKenHttpTimeoutValue;
    [_jsonRequestSerializer setValue:customUserAgent forHTTPHeaderField:@"standardUA"];
    
    [_jsonRequestSerializer setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //response
    _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    _jsonResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",
                                                      @"text/javascript", @"text/html", @"text/plain", nil];
    
    [self setDefaultParams];
    
    return self;
}

- (void)setDefaultParams {
    BOOL reset = NO;
    if ([UIApplication isEmpty:_defaultParams]) {
        reset = YES;
    } else {
        if (![[_defaultParams objectForKey:@"userId"] isEqualToString:[KenUserInfoDM sharedInstance].userName] ||
            ![[_defaultParams objectForKey:@"password"] isEqualToString:[KenUserInfoDM sharedInstance].userPwd]) {
            reset = YES;
        }
    }
    
    if (reset) {
        _defaultParams = @{@"password":[KenUserInfoDM sharedInstance].userPwd,
                           @"userId":[KenUserInfoDM sharedInstance].userName};
    }
}

- (void)asyncGet:(nonnull NSString *)url queryParams:(nullable NSDictionary<NSString *, NSString *> *)params
         success:(ResponsedBlock)success failure:(RequestFailureBlock)failure
{
    [self setDefaultParams];
    
    NSMutableDictionary *paramsDict = nil;
    if ([UIApplication isNotEmpty:_defaultParams]) {
        paramsDict = [NSMutableDictionary dictionaryWithDictionary:_defaultParams];
    }
    
    if (params) {
        if ([UIApplication isEmpty:paramsDict]) {
            paramsDict = [NSMutableDictionary dictionaryWithDictionary:params];
        } else {
            [paramsDict addEntriesFromDictionary:params];
        }
    }
    
    _httpSessionManager.requestSerializer = _httpRequestSerializer;
    _httpSessionManager.responseSerializer = _jsonResponseSerializer;
    
    [_httpSessionManager GET:url parameters:paramsDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        SafeHandleBlock(success, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SafeHandleBlock(failure, error.code, error.localizedDescription);
    }];
}

- (void)asyncPost:(nonnull NSString *)url
       postParams:(nullable NSDictionary<NSString *, NSString *> *)params
          success:(ResponsedBlock)success
          failure:(RequestFailureBlock)failure;
{
    [self setDefaultParams];
    
    NSMutableDictionary *paramsDict = nil;
    if ([UIApplication isNotEmpty:_defaultParams]) {
        paramsDict = [NSMutableDictionary dictionaryWithDictionary:_defaultParams];
    }
    
    if (params) {
        if ([UIApplication isEmpty:paramsDict]) {
            paramsDict = [NSMutableDictionary dictionaryWithDictionary:params];
        } else {
            [paramsDict addEntriesFromDictionary:params];
        }
    }
    
    _httpSessionManager.requestSerializer = _httpRequestSerializer;
    _httpSessionManager.responseSerializer = _jsonResponseSerializer;
    
    DebugLog("\n====================   ===============\
             \npath: %@\n paramsDict: %@\
             \n===================================",
             url, (paramsDict ?: @""));
    
    [_httpSessionManager POST:url parameters:paramsDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        SafeHandleBlock(success, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //针对503做一个特殊处理
        if ([(NSHTTPURLResponse *)task.response statusCode] == 503) {
//            [[SysDelegate.rootVC currentSelectedVC] showAlert:@"" content:@"服务维护中，请稍后重试"];
        } else {
            SafeHandleBlock(failure, error.code, error.localizedDescription);
        }
    }];
}

- (void)asyncPost:(nonnull NSString *)url postJson:(nonnull id)jsonObject
          success:(ResponsedBlock)success failure:(RequestFailureBlock)failure
{
    [self setDefaultParams];
    
    _httpSessionManager.requestSerializer = _jsonRequestSerializer;
    _httpSessionManager.responseSerializer = _jsonResponseSerializer;
    
    [_httpSessionManager POST:url parameters:jsonObject success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        SafeHandleBlock(success, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SafeHandleBlock(failure, error.code, error.localizedDescription);
    }];
}

- (void)upload:(nonnull NSString *)url
    postParams:(nullable NSDictionary<NSString *, NSString *> *)params
       fileKey:(NSString *)fkey
      filePath:(NSString *)fpath
      progress:(nullable void (^)(double progress))progress
      response:(nullable void (^)(NSError * _Nullable error, id _Nullable result))response
{
    [self setDefaultParams];
    
    NSProgress *progressObj;
    
    NSMutableDictionary *paramsDict = nil;
    if ([UIApplication isNotEmpty:_defaultParams]) {
        paramsDict = [NSMutableDictionary dictionaryWithDictionary:_defaultParams];
    }
    
    if (params) {
        if ([UIApplication isEmpty:paramsDict]) {
            paramsDict = [NSMutableDictionary dictionaryWithDictionary:params];
        } else {
            [paramsDict addEntriesFromDictionary:params];
        }
    }
    
    _httpSessionManager.requestSerializer = _httpRequestSerializer;
    _httpSessionManager.responseSerializer = _jsonResponseSerializer;
    
    NSMutableURLRequest *request = [_httpSessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:paramsDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[[NSURL alloc] initWithString:fpath] name:fkey error:nil];
    } error:nil];
    
    @weakify(self);
    NSURLSessionUploadTask *uploadTask = [_httpSessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *urlResponse, id responseObject, NSError *error) {
        
        @strongify(self);
        
        [progressObj removeObserver:self forKeyPath:@"fractionCompleted"];
        _progressBlock = nil;
        
        if (response) {
            response(error, responseObject);
        }
    }];
    
    _progressBlock = progress;
    
    [progressObj addObserver:self
                  forKeyPath:@"fractionCompleted"
                     options:NSKeyValueObservingOptionNew context:nil];
    
    [uploadTask resume];
}

- (void)upload:(nonnull NSString *)url
    postParams:(nullable NSDictionary *)params
       fileKey:(NSString *)fkey
         image:(UIImage *)image
         start:(nullable void (^)())start
      progress:(nullable void (^)(double progress))progress
      response:(nullable void (^)(NSError * _Nullable error, id _Nullable result))response
{
    [self setDefaultParams];
    
    NSProgress *progressObj;
    
    NSMutableDictionary *postDict = nil;
    
    if (params || _defaultParams) {
        postDict = [NSMutableDictionary dictionary];
        
        if (params) {
            [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
                [postDict setObject:value forKey:key];
            }];
        }
        
        if (_defaultParams) {
            [_defaultParams enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
                [postDict setObject:value forKey:key];
            }];
        }
    }
    
    _httpSessionManager.requestSerializer = _httpRequestSerializer;
    _httpSessionManager.requestSerializer.timeoutInterval = 90;
    
    _httpSessionManager.responseSerializer = _jsonResponseSerializer;
    _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    NSMutableURLRequest *request = [_httpSessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:postDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        [formData appendPartWithFileData:imageData name:fkey fileName:@"upload.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    @weakify(self);
    NSURLSessionUploadTask *uploadTask = [_httpSessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *urlResponse, id responseObject, NSError *error) {
        
        @strongify(self);
        
        [progressObj removeObserver:self forKeyPath:@"fractionCompleted"];
        _progressBlock = nil;
        
        if (response) {
            response(error, responseObject);
        }
    }];
    
    _progressBlock = progress;
    
    [progressObj addObserver:self
                  forKeyPath:@"fractionCompleted"
                     options:NSKeyValueObservingOptionNew context:nil];
    
    [uploadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        if (_progressBlock) {
            _progressBlock(progress.fractionCompleted);
        }
    }
}

#pragma mark - getter setter
- (NSString *)customUserAgent {
    if (_customUserAgent == nil) {
        NSMutableString *string = [NSMutableString stringWithString:@"{"];
        [string appendFormat:@"\"uuid\" : \"%@\",", [UIDevice uuidWithDevice]];
        [string appendString:@"\"system\" : \"iOS\","];
        [string appendFormat:@"\"version\" : \"%@\",", AppVersion];
        [string appendFormat:@"\"sysVersion\" : \"%@\",", [UIDevice currentDevice].systemVersion];
        [string appendFormat:@"\"device\" : \"%@\"}", [UIDevice getCurrentDeviceModelDescription]];
        
        _customUserAgent = [NSString stringWithString:string];
    }
    
    return _customUserAgent;
}

@end
