//
//  KenCarcorder.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KenCarcorder : NSObject

+ (KenCarcorder *)shareCarcorder;

#pragma mark - 文件目录
- (NSString *)getAlarmFolder;
- (NSString *)getHomeSnapFolder;
- (NSString *)getMarketFolder;
- (NSString *)getRecorderFolder;
- (void)deleteCachFolder;
- (long long)getCachFolderSize;

#pragma mark - 文件管理相关
+ (unsigned long long)getFileSize:(NSString*)filePath;
+ (unsigned long long)getFolderSize:(NSString*)folderPath;
+ (BOOL)deleteFileWithPath:(NSString*)path;
+ (BOOL)fileExistsAtPath:(NSString*)path;
+ (BOOL)createFolderAtPath:(NSString *)path;

/**
 *  @author Ken.Liu
 *
 *  @brief  获取当前手机连接wifi（SSID）
 *
 *  @return 返回SSID
 */
+ (NSString *)getCurrentSSID;

/**
 * 获取局域网ip
 */
+ (NSString *)localIPAddress;

@end
