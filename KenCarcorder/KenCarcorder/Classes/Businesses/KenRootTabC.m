//
//  KenRootTabC.m
//
//
//  Created by Ken.Liu on 2016/11/22.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenRootTabC.h"
#import "KenNavigationC.h"

@interface KenRootTabC ()

@end

@implementation KenRootTabC

#pragma mark - left cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    KenBaseVC *homeVC = [[KenBaseVC alloc] init];
    KenNavigationC *naviHome = [[KenNavigationC alloc] initWithRootViewController:homeVC];
    homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                      image:[UIImage imageNamed:@"ken_tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"ken_tab_home_hl"]];

    KenBaseVC *teamVC = [[KenBaseVC alloc] init];
    KenNavigationC *naviTeam = [[KenNavigationC alloc] initWithRootViewController:teamVC];
    teamVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"团队"
                                                      image:[UIImage imageNamed:@"ken_tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"ken_tab_home_hl"]];
    
    KenBaseVC *mineVC = [[KenBaseVC alloc] init];
    KenNavigationC *naviMine = [[KenNavigationC alloc] initWithRootViewController:mineVC];
    mineVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                      image:[UIImage imageNamed:@"ken_tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"ken_tab_home_hl"]];
    
    [self setViewControllers:@[naviHome, naviTeam, naviMine]];
    
    //    [self setupCenterItemWithImage:[UIImage imageNamed:@"location_start_normal"]
    //                   highligtedImage:[UIImage imageNamed:@"location_start_sel"] title:@"center"];
    //    [self setCenterItemClickedEventHandler:^{
    //
    //    }];
    
    [self setTabbarItemTitleColor:[UIColor appGrayTextColor] selColor:[UIColor appMainColor]];
    
    [self setTabBarBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:self.tabBar.size]];
    
    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.tabBar.layer.shadowOffset = CGSizeMake(0, 5);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    self.tabBar.layer.shadowOpacity = 0.9;//阴影透明度，默认0
    self.tabBar.layer.shadowRadius = 4;//阴影半径，默认3
}

#pragma mark - public method
- (KenBaseVC *)currentSelectedVC {
    KenBaseVC *selectedVC = (KenBaseVC *)((KenNavigationC *)self.selectedViewController).topViewController;
    return selectedVC;
}

- (void)changToHome {
    self.selectedIndex = 0;
    [[self currentSelectedVC] popToRootViewControllerAnimated:NO];
}

@end
