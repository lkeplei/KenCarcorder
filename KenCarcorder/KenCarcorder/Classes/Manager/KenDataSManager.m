//
//  KenDataSManager.m
//
//
//  Created by Ken.Liu on 2016/11/21.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenDataSManager.h"

#import "GTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>

#define kDesKey         @"!@#$%^&*()-1qaz3edc6yhn4rfv-qwertyuiop"

@interface KenDataSManager ()

@end

@implementation KenDataSManager

static KenDataSManager *_sharedDataSManager = nil;

+ (KenDataSManager *)sharedDataSManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSManager = [[KenDataSManager alloc] init];
    });
    return _sharedDataSManager;
}

#pragma mark - DES 加解密
+ (NSString *)encryptUseDES:(NSString *)plainText {
    return [KenDataSManager encrypt:plainText encryptOrDecrypt:kCCEncrypt key:kDesKey];
}

+ (NSString *)decryptUseDES:(NSString*)cipherText {
    return [KenDataSManager encrypt:cipherText encryptOrDecrypt:kCCDecrypt key:kDesKey];
}

+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key {
    const void *dataIn;
    size_t dataInLength;
    
    if (encryptOperation == kCCDecrypt) {
        //解码 base64
        NSData *decryptData = [GTMBase64 decodeData:[sText dataUsingEncoding:NSUTF8StringEncoding]];//转成utf-8并decode
        dataInLength = [decryptData length];
        dataIn = [decryptData bytes];
    } else {
        //加密
        NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
        dataInLength = [encryptData length];
        dataIn = (const void *)[encryptData bytes];
    }
    
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码，比如：一个人用int，一个人用long。最好用typedef来定义）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    
    Byte iv[] = {1,2,3,4,5,6,7,8};
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(encryptOperation,//  加密/解密
                       kCCAlgorithmDES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       [key UTF8String],  //密钥    加密和解密的密钥必须一致
                       kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt) {
        //得到解密出来的data数据，改变为utf-8的字符串
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved]
                                       encoding:NSUTF8StringEncoding];
    } else {
        //编码 base64 (加密过程中，把加好密的数据转成base64的）
        NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
        result = [GTMBase64 stringByEncodingData:data];
    }
    
    return result;
}

#pragma mark - user default
- (void)setDataByKey:(id)object forkey:(NSString *)key {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

- (void)removeDataByKey:(NSString *)key {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

- (id)getDataByKey:(NSString *)key {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

@end
