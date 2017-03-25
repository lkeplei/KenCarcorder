//
//  KenTabBar.h
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KenTabBarDelegate <NSObject>

@optional
- (void)tabBar:(UIView *)tabBar didSelectItemAtIndex:(NSUInteger)index;

@end

@interface KenTabBar : UITabBar

@property (weak, nonatomic) id<KenTabBarDelegate> tabBarDelegate;
@property (weak, readonly, nonatomic) UIButton *centerItem;
@property (assign, nonatomic) NSUInteger selectedItemIndex;

+ (instancetype)tabBarWithCenterItem:(UIButton *)centerItem;

/**
 *  This method is mainly for initializing UITabBarController programmatically to add centerItem
 *
 *  @param centerItem centerItem
 */
- (void)insertCenterItem:(UIButton *)centerItem;

- (void)setItemTitleColor:(UIColor *)normalColor selColor:(UIColor *)selColor;

- (void)setItemBadge:(NSUInteger)index badge:(NSString *)badge;

@end
