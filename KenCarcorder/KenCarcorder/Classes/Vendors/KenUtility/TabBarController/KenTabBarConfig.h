//
//  KenTabBarConfig.h
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#ifndef KenTabBarConfig_h
#define KenTabBarConfig_h

// ====================    Optional Contants Start    ====================
// Please feel free to comment out some properties if you prefer the system's default appearance

// the height of view for each childViewController of UITabBarController will vary with the tabBar height
#define TabBarHeight 49

// the offset for the position(center) of centerItem in Y-Asix. Negetive num will make centerItem move up; otherwise, move down
//#define CenterItemYAsixOffset 0

// the offset for the postion of badge(also tinyBadge) in X-Asix. Negetive num will make badge move left; otherwise, move right
#define BadgeXAsixOffset -4

// the offset for the postion of badge(also  tinyBadge) in Y-Asix. Negetive num will make badge move up; otherwise, move down
#define BadgeYAsixOffset 2

// badge background color(hex number of rgb color)
#define BadgeBackgroundColor UIColorFromHexRGB(0xFFA500)

// badge value color(hex number of rgb color)
#define BadgeValueColor UIColorFromHexRGB(0x6B8E23)

// tiny badge color(hex number of rgb color), default is redColor
#define TinyBadgeColor UIColorFromHexRGB(0xFFA500)

// slider visibility(set false won't create slider for you)
#define SliderVisible false

// slider color(hex number of rgb color), default is lightGrayColor
#define SliderColor UIColorFromHexRGB(0x87CEFA)

// slider spring damping: To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
#define SliderDamping 0.66

// remove tabBar top shadow if this value true; otherwise, keep system style
#define RemoveTabBarTopShadow true

// ====================    Optional Contants End    ====================


// --------------------      Required Constants Start    --------------------
// Please think twice before you comment out any macros below..But feel free to change any values to meet your requirements

#define ItemTitleFontSize 10

// the ratio of image's height to item's.  (0 ~ 1)
#define ItemImageHeightRatio 0.65

#define ItemBadgeFontSize 13

// horizontal padding
#define ItemBadgeHPadding 4

// radius of tiny badge(dot)
#define TinyBadgeRadius 3

// --------------------      Required Constants End    --------------------


// ====================      PreDefined Macro Start       ====================

#define UIColorFromHexRGB(rgbValue) \
([UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 \
green:((float)((rgbValue&0xFF00)>>8))/255.0 \
blue:((float)(rgbValue&0xFF))/255.0 \
alpha:1])

#define FXSwizzleInstanceMethod(class, originalSEL, swizzleSEL) {\
Method originalMethod = class_getInstanceMethod(class, originalSEL);\
Method swizzleMethod = class_getInstanceMethod(class, swizzleSEL);\
BOOL didAddMethod = class_addMethod(class, originalSEL, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));\
if (didAddMethod) {\
class_replaceMethod(class, swizzleSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));\
}\
else {\
method_exchangeImplementations(originalMethod, swizzleMethod);\
}\
}

#endif /* KenTabBarConfig_h */
