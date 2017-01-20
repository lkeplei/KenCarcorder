//
//  KenConfig.h
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/1/20.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#ifndef KenConfig_h
#define KenConfig_h

/*当前APP版本号*/
#define AppVersion              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppBuildVersion         [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]

//设备
#define isIPhone4               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),[[UIScreen mainScreen] currentMode].size): NO)
#define isIPhone5               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136),[[UIScreen mainScreen] currentMode].size) : NO)

/**
 *  block 宏定义
 */
#define SafeHandleBlock(block, ...)         if(block) { block(__VA_ARGS__); }

//日志输出定义
#ifdef DEBUG

#   ifdef __IPHONE_10_0
#       define DebugLog(fmt, ...)   printf("%s: %s 第%d行: %s\n\n",\
[[[NSDate date] stringWithFormat:@"yyyy-MM-dd hh:mm:ss"] UTF8String], \
__PRETTY_FUNCTION__, \
__LINE__, \
[[NSString stringWithFormat:@fmt, ##__VA_ARGS__] UTF8String]);
#   else
#       define DebugLog(fmt, ...)       NSLog((@"%s 第%d行: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   endif

#else

#   define DebugLog(...)

#endif

//调试日志输入宏
#define KenWriteDebugLog(content)   \
if ([DebugSettingDM getInstance].openLog) {\
[KenDebugLogRLM writeDebugLogWithFunction:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]\
line:__LINE__\
text:content];\
}

#pragma mark - app 内使用的宏定义
#define StatusBarHeight             [[UIApplication sharedApplication] statusBarFrame].size.height
#define SysDelegate                 ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define MainScreenWidth             [UIScreen mainScreen].bounds.size.width
#define MainScreenHeight            [UIScreen mainScreen].bounds.size.height

#define kKenOffset                   (15)

/*消除方法弃用警告*/
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/*消除未声明_Nonnull等警告*/
#pragma clang diagnostic ignored "-Wnullability-completeness"
/*消除方法未实现警告*/
#pragma clang diagnostic ignored "-Wincomplete-implementation"

#endif /* KenConfig_h */
