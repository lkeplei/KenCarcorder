//
//  UITabBarController+KenTBC.m
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UITabBarController+KenTBC.h"
#import <objc/runtime.h>
#import "KenTabBar.h"
#import "KenTabBarConfig.h"
#import "KenDeallocMonitor.h"
#import "KenTabBarItem.h"

@interface UITabBarController () <KenTabBarDelegate>

@end

@implementation UITabBarController (KenTBC)

#pragma mark - Hack
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        FXSwizzleInstanceMethod(class, @selector(viewDidLoad), @selector(kenViewDidLoad));
        FXSwizzleInstanceMethod(class, @selector(setSelectedViewController:), @selector(kenSetSelectedViewController:));
        FXSwizzleInstanceMethod(class, @selector(setSelectedIndex:), @selector(kenSetSelectedIndex:));
    });
}

#pragma mark - Swizzle Methods
- (void)kenViewDidLoad {
    [self kenViewDidLoad];
    
    [KenDeallocMonitor addMonitorToObj:self];
    [self setupTabBar];
}

- (void)kenSetSelectedViewController:(UIViewController *)selectedViewController {
    [self kenSetSelectedViewController:selectedViewController];
    
    NSInteger selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    if (NSNotFound != selectedIndex) {
        [self setSelectedItemAtIndex:selectedIndex];
    }
}

- (void)kenSetSelectedIndex:(NSUInteger)selectedIndex {
    [self kenSetSelectedIndex:selectedIndex];
    
    if (selectedIndex < self.viewControllers.count) {
        [self setSelectedItemAtIndex:selectedIndex];
    }
}

- (void)setSelectedItemAtIndex:(NSUInteger)selectedIndex {
    KenTabBar *tabBar = (KenTabBar *)self.tabBar;
    if ([tabBar isKindOfClass:[KenTabBar class]]) {
        tabBar.selectedItemIndex = selectedIndex;
    }
}

#pragma mark - public method
- (void)setItemBadge:(NSUInteger)index badge:(NSString *)badge {
    KenTabBar *tabBar = (KenTabBar *)self.tabBar;
    if ([tabBar isKindOfClass:[KenTabBar class]]) {
        [tabBar setItemBadge:index badge:badge];
    }
}

- (void)setupCenterItemWithImage:(UIImage *)image highligtedImage:(UIImage *)highlightedImage title:(NSString *)title {
    NSAssert(image, @"image can't be nil!");
    NSParameterAssert(image);
    
    UIButton *centerItem;
    UIImage *normalImage = image;
    if (highlightedImage) {
        centerItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [centerItem setImage:highlightedImage forState:UIControlStateHighlighted];
    } else {
        centerItem = [UIButton buttonWithType:UIButtonTypeSystem];
        normalImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    [centerItem setImage:normalImage forState:UIControlStateNormal];
    
    if (title.length > 0) {
        centerItem.imageView.contentMode = UIViewContentModeCenter;
        centerItem.titleLabel.textAlignment = NSTextAlignmentCenter;
        [centerItem setTitle:title forState:UIControlStateNormal];
#ifdef ItemTitleFontSize
        centerItem.titleLabel.font = [UIFont systemFontOfSize:ItemTitleFontSize];
#endif
    }
    
    [KenDeallocMonitor addMonitorToObj:centerItem withDesc:@"centerItem has been deallcated"];
    objc_setAssociatedObject(self, @selector(centerItem), centerItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    KenTabBar *tabBar = (KenTabBar *)self.tabBar;
    if ([tabBar isKindOfClass:[KenTabBar class]]) {
        [tabBar insertCenterItem:centerItem];
    }
}

- (void)setTabbarItemTitleColor:(UIColor *)normalColor selColor:(UIColor *)selColor {
    KenTabBar *tabbar = [self kenTabBar];
    if (tabbar) {
        [tabbar setItemTitleColor:normalColor selColor:selColor];
    }
    
    if (self.centerItem) {
        [self.centerItem setTitleColor:normalColor forState:UIControlStateNormal];
        [self.centerItem setTitleColor:selColor forState:UIControlStateSelected];
        [self.centerItem setTitleColor:selColor forState:UIControlStateHighlighted];
    }
}

- (void)setTabBarBackgroundImage:(UIImage *)image {
    NSParameterAssert(image);
    
    UIImage *scaledImage = image;
#ifdef TabBarHeight
    if (TabBarHeight != image.size.height) {
        CGSize size = CGSizeMake(image.size.width, TabBarHeight);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        scaledImage =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
#endif
    UITabBar *tabBar;
    if ((tabBar = self.tabBar)) {
        [tabBar setBackgroundImage:scaledImage];
    }
    
    objc_setAssociatedObject(self, @selector(tabBarBackgroundImage), scaledImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)tabBarBackgroundImage {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark CenterItem Action
- (void)setCenterItemClickedEventHandler:(KenEventHandler)handler {
    if (self.centerItem) {
        if (!handler) {
            [self.centerItem removeTarget:self action:@selector(userClickedCenterItem) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.centerItem addTarget:self action:@selector(userClickedCenterItem) forControlEvents:UIControlEventTouchUpInside];
        }
        
        objc_setAssociatedObject(self, @selector(userClickedCenterItem), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)userClickedCenterItem {
    KenEventHandler handler = objc_getAssociatedObject(self, _cmd);
    if (handler) {
        handler();
    }
}

#pragma mark - Setup TabBar
- (void)setupTabBar {
    if (self.centerItem) {
        NSAssert(self.tabBar.items.count%2 == 0, @"The num of tabBarItem(not include centerItem) can't be odd!");
    }
    
    KenTabBar *tabBar = [KenTabBar tabBarWithCenterItem:self.centerItem];
    UIImage *backgroundImage;
    if ((backgroundImage = self.tabBarBackgroundImage)) {
        tabBar.backgroundImage = backgroundImage;
    }
#if RemoveTabBarTopShadow
    tabBar.shadowImage = [UIImage new];
#endif
    
    // KVC: replace the tabBar created by system with custom tabBar
    [self setValue:tabBar forKey:@"tabBar"];
    
    tabBar.tabBarDelegate = self;
}

#pragma mark - FXTabBarDelegate
- (void)tabBar:(UIView *)tabBar didSelectItemAtIndex:(NSUInteger)index {
    if (index < self.viewControllers.count) {
        UIViewController *vc = self.viewControllers[index];
        [self kenSetSelectedViewController:vc];
    }
}

#pragma mark - private method
- (KenTabBar *)kenTabBar {
    KenTabBar *tabBar = [self valueForKey:@"tabBar"];
    
    if (tabBar && [tabBar isKindOfClass:[KenTabBar class]]) {
        return tabBar;
    } else {
        return nil;
    }
}

#pragma mark - 扩展属性
- (UIButton *)centerItem {
    return objc_getAssociatedObject(self, _cmd);
}

@end
