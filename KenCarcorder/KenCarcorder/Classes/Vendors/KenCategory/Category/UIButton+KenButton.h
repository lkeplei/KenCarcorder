//
//  UIButton+KenButton.h
//  achr
//
//  Created by Ken.Liu on 15/12/21.
//  Base on Tof Templates
//  Copyright © 2015年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark Category KenButton for UIButton 
#pragma mark -

@interface UIButton (KenButton)

+ (UIButton*)buttonWithImg:(NSString*)buttonText zoomIn:(BOOL)zoomIn image:(UIImage*)image
                  imagesec:(UIImage*)imagesec target:(id)target action:(SEL)action;

/**
 *  生成一个按钮
 *
 *  @param frame          区域
 *  @param text           文案
 *  @param font           字体
 *  @param titleColor     正常状态下文字颜色
 *  @param normalColor    正常状态下按钮背景色
 *  @param highlightColor 高亮状态下按钮背景色
 *  @param target         target
 *  @param action         action
 *
 *  @return 按钮实例
 */
+ (UIButton*)buttonWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font titleColor:(UIColor *)titleColor
                 normalColor:(UIColor *)normalColor highlightColor:(UIColor *)highlightColor target:(id)target action:(SEL)action;
@end
