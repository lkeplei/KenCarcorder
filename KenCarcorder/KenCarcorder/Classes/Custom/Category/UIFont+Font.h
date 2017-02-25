//
//  UIFont+Font.h
//
//
//  Created by Ken.Liu on 2016/11/21.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Font)

#pragma mark - CW 统一字体
+ (UIFont *)appFontSize28;
+ (UIFont *)appFontSize24;
+ (UIFont *)appFontSize22;
+ (UIFont *)appFontSize17;
+ (UIFont *)appFontSize16;
+ (UIFont *)appFontSize15;
+ (UIFont *)appFontSize14;
+ (UIFont *)appFontSize13;
+ (UIFont *)appFontSize12;
+ (UIFont *)appFontSize11;
+ (UIFont *)appFontSize10;

#pragma mark - CW 统一字体对应高
+ (CGFloat)appFontHeight10;
+ (CGFloat)appFontHeight11;
+ (CGFloat)appFontHeight12;
+ (CGFloat)appFontHeight13;
+ (CGFloat)appFontHeight14;
+ (CGFloat)appFontHeight15;
+ (CGFloat)appFontHeight16;
+ (CGFloat)appFontHeight17;

@end
