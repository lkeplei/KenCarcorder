//
//  UIDevice+KenDevice.h
//  将 IOS7 后获取各种UUID的方法封装成一个类
//
//  Created by Ken.Liu on 16/5/31.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (KenDevice)
//获取当前mac地址
+ (NSString *)getMacAddress;

//当前系统版本
+ (float)iOSVersion;

//每次都变化，无持续性
+ (NSString *)uuid;

//每次都变化，无持续性，但允许在内存中缓存
+ (NSString *)uuidWithKey:(id<NSCopying>)key;

//每次应用重新启动时变化，运行期间不会变化直到退出
+ (NSString *)uuidWithSession;

//每次应用重新安装时变化，卸载之前不会变化
+ (NSString *)uuidWithInstallation;

//同一供应商的所有应用程序都被卸载后变化
+ (NSString *)uuidWithVendor;

//仅在系统被重置时变化(目前使用的uuid标识)
+ (NSString *)uuidWithDevice;

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration;
+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration;
+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
                                commitMigration:(BOOL)commitMigration;
+ (NSArray *)uuidsWithUserDevices;

+ (BOOL)uuidValueIsValid:(NSString *)uuidValue;

/**
 *  获取当前设备类型描述
 *
 *  @return 当前设备类型描述字符串
 */
+ (NSString *)getCurrentDeviceModelDescription;

@end
