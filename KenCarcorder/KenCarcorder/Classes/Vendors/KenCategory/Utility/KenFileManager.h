//
//  KenFileManager.h
//  achr
//
//  Created by Ken.Liu on 16/5/13.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KenFileManager : NSObject

/**
 *  给定短文件路径转换为长路径 如"mycache/user/icon.png" -> "/Users/zhoujun/Library/Application Support/iPhone Simulator/7.1/Applications/ABCE2119-E864-4492-A3A9-A238ADA74BE5/Documents/mycache/user/icon.png".
 *
 *  @param shortFileName 短路径
 *
 *  @return 长路径
 */
+ (NSString *)fullDocumentFileName:(NSString *)shortFileName;


/**
 *  检测文件是否存在
 *
 *  @param fileName 文件路径
 *
 *  @return 是否存泽
 */
+ (BOOL)isFileExists:(NSString *)fileName;


/**
 *  创建文件
 *
 *  @param fileName        文件路径
 *  @param shouldOverwrite 是否覆盖
 */
+ (void)createFile:(NSString *)fileName overwrite:(BOOL)shouldOverwrite;

/**
 *  写文件
 *
 *  @param fileName     文件路径
 *  @param contents     要写入的数据
 *  @param shouldAppend 是否在原文件尾部追加，如果NO则覆盖原文件数据
 */
+ (void)writeFile:(NSString *)fileName contents:(NSData *)contents append:(BOOL)shouldAppend;


/**
 *  删除一个文件
 *
 *  @param fileName 文件路径
 */
+ (void)removeFile:(NSString *)fileName;

@end
