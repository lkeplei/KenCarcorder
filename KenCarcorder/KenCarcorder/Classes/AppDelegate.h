//
//  AppDelegate.h
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/1/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KenRootTabC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, assign) BOOL allowRotation;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) KenRootTabC *rootVC;

@end

