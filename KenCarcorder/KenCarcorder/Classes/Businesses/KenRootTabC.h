//
//  KenRootTabC.h
//
//
//  Created by Ken.Liu on 2016/11/22.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KenALarmVC.h"

@interface KenRootTabC : UITabBarController

@property (nonatomic, strong) KenALarmVC *alarmVC;

- (KenBaseVC *)currentSelectedVC;

- (void)changToHome;

@end
