//
//  UILabel+KenLabel.h
//  achr
//
//  Created by Ken.Liu on 15/12/21.
//  Base on Tof Templates
//  Copyright © 2015年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KenHtmlLabel.h"

#pragma mark -
#pragma mark Category KenLabel for UILabel 
#pragma mark -

@interface UILabel (KenLabel)

/**
 *  标签创建
 *
 *  @param text       文案
 *  @param frame      区域
 *  @param font       字体
 *  @param color      颜色
 *
 *  @return 返回标签实例
 */
+ (UILabel*)labelWithTxt:(NSString *)text frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color;
+ (KenHtmlLabel *)htmlLabelWithTxt:(NSString *)text frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color;

+ (UILabel*)labelWithConerRadius:(CGFloat)radius text:(NSString *)text frame:(CGRect)frame font:(UIFont*)font
                           color:(UIColor*)color bgColor:(UIColor *)bgColor;

/**
 *  设置行间距（目前只支持全部内容，部分带行间距的不支持）
 *
 *  @param lineSpacing 行间距
 */
- (void)setLineSpacing:(NSUInteger)lineSpacing;

@end
