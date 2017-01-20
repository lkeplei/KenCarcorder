//
//  UIWindow+KenWindow.h
//  achr
//
//  Created by Ken.Liu on 16/9/18.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (KenWindow)

@property (nonatomic, copy) void(^windowSakeBlock)();

@end
