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

/**
 *  @author Ken.Liu
 *
 *  @brief  获取当前手机连接wifi（SSID）
 *
 *  @return 返回SSID
 */
+ (NSString *)getCurrentSSID;

@end
