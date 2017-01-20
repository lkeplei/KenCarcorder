//
//  KenTabBarItem.h
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KenTabBarItem : UIButton

+ (instancetype)itemWithTabbarItem:(UITabBarItem *)tabBarItem;

- (void)setItemTitleColor:(UIColor *)normalColor selColor:(UIColor *)selColor;

@end




#pragma mark - UITabBarItem+TinyBadge
@interface UITabBarItem (TinyBadge)

@property (assign, nonatomic) BOOL tinyBadgeVisible;

@end
