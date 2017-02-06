//
//  KenRootTabC.m
//
//
//  Created by Ken.Liu on 2016/11/22.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenRootTabC.h"
#import "KenNavigationC.h"
#import "KenHomeVC.h"
#import "KenMineVC.h"
#import "KenALarmVC.h"

@interface KenRootTabC ()

@end

@implementation KenRootTabC

#pragma mark - left cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    KenHomeVC *homeVC = [[KenHomeVC alloc] init];
    KenNavigationC *naviHome = [[KenNavigationC alloc] initWithRootViewController:homeVC];
    homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"记录仪"
                                                      image:[UIImage imageNamed:@"ken_tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"ken_tab_home_hl"]];

    KenALarmVC *alarmVC = [[KenALarmVC alloc] init];
    KenNavigationC *naviAlarm = [[KenNavigationC alloc] initWithRootViewController:alarmVC];
    alarmVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"报警"
                                                      image:[UIImage imageNamed:@"ken_tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"ken_tab_home_hl"]];
    
    KenMineVC *mineVC = [[KenMineVC alloc] init];
    KenNavigationC *naviMine = [[KenNavigationC alloc] initWithRootViewController:mineVC];
    mineVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我"
                                                      image:[UIImage imageNamed:@"ken_tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"ken_tab_home_hl"]];
    
    [self setViewControllers:@[naviHome, naviAlarm, naviMine]];
    
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
