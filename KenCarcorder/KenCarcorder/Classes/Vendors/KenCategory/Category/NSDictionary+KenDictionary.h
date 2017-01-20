//
//  NSDictionary+KenDictionary.h
//  KenCategory
//
//  Created by Ken.Liu on 2016/11/3.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KenDictionary)

/**
 *  从JSON字符串创建字典
 *
 *  @param jsonString JSON字符串
 *
 *  @return NSDictionary
 */
+ (instancetype)fromJson:(NSString *)jsonString;

/**
 *  字典转换成Json字符串
 *
 *  @return Json字符串
 */
- (NSString *)toJson;

@end
