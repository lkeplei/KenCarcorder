//
//  NSObject+KenInvoker.h
//
//  Created by Ken.Liu on 16/5/3.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KenInvoker)

- (instancetype)invokeWithSelClassName:(NSString *)selName className:(NSString *)calssName error:(NSError *__autoreleasing *)error, ...;

/**
 *  接口调用部分
 *
 *  @param target   接口类的实例
 *  @param selector 接口的SEL
 *  @param argsArr  接口参数
 *  @param error    错误
 *
 *  @return 返回selector对应的返回值
 */
- (instancetype)invocateSelectorWithArgument:(NSString *)target selector:(NSString *)selector argsArr:(NSArray *)argsArr
                                       error:(NSError *__autoreleasing *)error;

@end
