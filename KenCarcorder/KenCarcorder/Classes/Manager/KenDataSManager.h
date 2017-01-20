//
//  KenDataSManager.h
//
//
//  Created by Ken.Liu on 2016/11/21.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KenDataSManager : NSObject

+ (KenDataSManager *)sharedDataSManager;

- (void)initData;           //初始化数据

#pragma mark - DES 加解密
+ (NSString *)encryptUseDES:(NSString *)plainText;
+ (NSString *)decryptUseDES:(NSString*)cipherText;

#pragma mark - user default
- (void)setDataByKey:(id)object forkey:(NSString *)key;
- (void)removeDataByKey:(NSString *)key;
- (id)getDataByKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
