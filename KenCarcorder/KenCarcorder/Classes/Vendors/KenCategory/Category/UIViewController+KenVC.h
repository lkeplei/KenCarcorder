//
//  UIViewController+KenVC.h
//  achr
//
//  Created by Ken.Liu on 15/12/30.
//  Base on Tof Templates
//  Copyright © 2015年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark Category KenVC for UIViewController 
#pragma mark -


typedef NS_ENUM(NSUInteger, KenToastType) {
    kToastUnkown = 0,                           //未知
    kToastInfomation,                           //消息
    kToastWarning,                              //警告
    kToastSuccessful,                           //成功
    kToastError,                                //错误
};

typedef void (^MsgAlertDismissBlock)(NSInteger button);

@interface UIViewController (KenVC)

@property (nonatomic) BOOL fullScreenActivity;              //是否为全屏加载，默认不是，是的话加载框会屏蔽其他的UI触发事件

//hud
- (void)showActivity;
- (void)hideActivity;
- (void)showToastWithMsg:(NSString *)msg;
- (void)showToastWithMsg:(NSString *)msg type:(KenToastType)type;

@end
