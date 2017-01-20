//
//  Weakify.h
//  achr
//
//  Created by Ken.Liu on 16/4/14.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#ifndef Weakify_h
#define Weakify_h

#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif



//日志输出定义
#ifdef DEBUG

#   ifdef __IPHONE_10_0
#       define KenCategoryLog(fmt, ...)   printf("%s 第%d行: %s\n\n", \
__PRETTY_FUNCTION__, \
__LINE__, \
[[NSString stringWithFormat:@fmt, ##__VA_ARGS__] UTF8String]);
#   else
#       define KenCategoryLog(fmt, ...)       NSLog((@"%s 第%d行: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   endif

#else

#   define KenCategoryLog(...)

#endif


#endif
