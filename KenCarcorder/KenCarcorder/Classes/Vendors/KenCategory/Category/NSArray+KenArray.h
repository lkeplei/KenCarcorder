//
//  NSArray+KenArray.h
//  achr
//
//  Created by Ken.Liu on 16/6/30.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (KenArray)

/**
 *  数组转换成Json字符串
 *
 *  @return Json字符串
 */
- (NSString *)toJson;

/**
 *  从JSON字符串创建字典
 *
 *  @param jsonString JSON字符串
 *
 *  @return NSDictionary
 */
+ (instancetype)fromJson:(NSString *)jsonString;

@end
