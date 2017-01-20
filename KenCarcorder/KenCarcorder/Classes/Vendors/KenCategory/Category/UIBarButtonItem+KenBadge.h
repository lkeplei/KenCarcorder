//
//  UIBarButtonItem+KenBadge.h
//  achr
//
//  Created by Ken.Liu on 16/6/1.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KenBarButtonItemBadgeType) {
    KenBarButtonItemBadgeDot,                   //小圆点
    KenBarButtonItemBadgeNumber,                //数字角标
};

@interface UIBarButtonItem (KenBadge)

@property (nonatomic, assign) BOOL shouldHideBadgeAtZero;                       //为0时隐藏
@property (nonatomic, assign) BOOL shouldAnimateBadge;                          //改变时显示动画效果
@property (nonatomic, assign) CGFloat badgeBorderWidth;                         //边框宽度
@property (nonatomic, assign) CGFloat badgePadding;                             //Padding
@property (nonatomic, assign) CGFloat badgeMinSize;                             //最小直径
@property (nonatomic, assign) CGFloat badgeOriginX;                             //位置X坐标
@property (nonatomic, assign) CGFloat badgeOriginY;                             //位置Y坐标
@property (nonatomic, assign) KenBarButtonItemBadgeType badgeStyle;             //角标样式（小圆点、数字角标）

@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) NSString *badgeValue;                             //显示的数字
@property (nonatomic, strong) UIColor *badgeBGColor;                            //背景色
@property (nonatomic, strong) UIColor *badgeTextColor;                          //文字颜色
@property (nonatomic, strong) UIColor *badgeBorderColor;                        //边框颜色（还有点问题，没法从外部设置）
@property (nonatomic, strong) UIFont *badgeFont;                                //字体

@end
