//
//  UITabBarController+KenTBC.h
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KenEventHandler)(void);

@interface UITabBarController (KenTBC)

@property (strong, readonly, nonatomic) UIButton *centerItem;


/**
 *  设置中间特殊item
 *
 *  @param image            正常状态图片
 *  @param highlightedImage 选中状态图片
 *  @param title            标题
 */
- (void)setupCenterItemWithImage:(UIImage *)image highligtedImage:(UIImage *)highlightedImage title:(NSString *)title;

/**
 *  当添加有中间item时的点击响应回调
 *
 *  @param handler 回调
 */
- (void)setCenterItemClickedEventHandler:(KenEventHandler)handler;

/**
 *  设置tabbar背景图
 *
 *  @param image 背景图
 */
- (void)setTabBarBackgroundImage:(UIImage *)image;

/**
 *  设置item的正常与选中状态下的颜色
 *
 *  @param normalColor 正常状态颜色
 *  @param selColor    选中状态颜色
 */
- (void)setTabbarItemTitleColor:(UIColor *)normalColor selColor:(UIColor *)selColor;

@end
