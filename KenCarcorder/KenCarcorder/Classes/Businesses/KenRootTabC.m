//
//  KenRootTabC.m
//
//
//  Created by Ken.Liu on 2016/11/22.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenRootTabC.h"
#import "KenNavigationC.h"
//#import "KenHomeVC.h"
#import "KenMyDeviceVC.h"
#import "KenMineVC.h"
#import "KenRecorderVC.h"
#import "KenPlayVC.h"

@interface KenRootTabC ()

@end

@implementation KenRootTabC

#pragma mark - left cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    KenHomeVC *homeVC = [[KenHomeVC alloc] init];
    KenMyDeviceVC *homeVC = [[KenMyDeviceVC alloc] init];
    KenNavigationC *naviHome = [[KenNavigationC alloc] initWithRootViewController:homeVC];
    homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                      image:[UIImage imageNamed:@"tab_home_normal"]
                                              selectedImage:[UIImage imageNamed:@"tab_home_hl"]];

    KenRecorderVC *recorderVC = [[KenRecorderVC alloc] init];
    KenNavigationC *naviRecorder = [[KenNavigationC alloc] initWithRootViewController:recorderVC];
    recorderVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"记录仪"
                                                          image:[UIImage imageNamed:@"tab_recorder_normal"]
                                                  selectedImage:[UIImage imageNamed:@"tab_recorder_hl"]];
    
    KenPlayVC *playVC = [[KenPlayVC alloc] init];
    KenNavigationC *naviPlay = [[KenNavigationC alloc] initWithRootViewController:playVC];
    naviPlay.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"直播"
                                                        image:[UIImage imageNamed:@"tab_play_normal"]
                                                selectedImage:[UIImage imageNamed:@"tab_play_hl"]];
    
    _alarmVC = [[KenALarmVC alloc] init];
    KenNavigationC *naviAlarm = [[KenNavigationC alloc] initWithRootViewController:_alarmVC];
    _alarmVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"报警"
                                                        image:[UIImage imageNamed:@"tab_alarm_normal"]
                                                selectedImage:[UIImage imageNamed:@"tab_alarm_hl"]];
    
    KenMineVC *mineVC = [[KenMineVC alloc] init];
    KenNavigationC *naviMine = [[KenNavigationC alloc] initWithRootViewController:mineVC];
    mineVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我"
                                                      image:[UIImage imageNamed:@"tab_mine_normal"]
                                              selectedImage:[UIImage imageNamed:@"tab_mine_hl"]];
    
    [self setViewControllers:@[naviHome, naviRecorder, naviPlay, naviAlarm, naviMine]];
    
    //    [self setupCenterItemWithImage:[UIImage imageNamed:@"location_start_normal"]
    //                   highligtedImage:[UIImage imageNamed:@"location_start_sel"] title:@"center"];
    //    [self setCenterItemClickedEventHandler:^{
    //
    //    }];
    
    [self setTabbarItemTitleColor:[UIColor appLightGrayTextColor] selColor:[UIColor appMainColor]];
    
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
