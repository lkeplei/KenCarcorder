//
//  UIViewController+KenVC.m
//  achr
//
//  Created by Ken.Liu on 15/12/30.
//  Base on Tof Templates
//  Copyright © 2015年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIViewController+KenVC.h"
#import "NSObject+KenObject.h"
#import "UIView+KenView.h"

#import <objc/runtime.h>

#pragma mark -
#pragma mark Category KenVC for UIViewController 
#pragma mark -

NSString const *UIViewController_fullScreenActivity  = @"UIViewController_fullScreenActivity";

@implementation UIViewController (KenVC)
#pragma mark - 扩展的属性
- (BOOL)fullScreenActivity {
    NSNumber *number = objc_getAssociatedObject(self, &UIViewController_fullScreenActivity);
    return number.boolValue;
}

- (void)setFullScreenActivity:(BOOL)fullScreenActivity {
    NSNumber *number = [NSNumber numberWithBool:fullScreenActivity];
    objc_setAssociatedObject(self, &UIViewController_fullScreenActivity, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - hud
- (void)showActivity {
    if (self.fullScreenActivity) {
        UIView *full = [self.view viewWithTag:8808];
        if (full == nil) {
            UIView *full = [[UIView alloc] initWithFrame:self.view.frame];
            full.backgroundColor = [UIColor clearColor];
            full.tag = 8808;
            [self.view addSubview:full];
        }
    }
    
    [self.view hideToastActivity];
    [self.view makeToastActivity:CSToastPositionCenter];
}

- (void)hideActivity {
    UIView *full = [self.view viewWithTag:8808];
    if (full) {
        [full removeFromSuperview];
        full = nil;
    }
    
    [self.view hideToastActivity];
}

- (void)showToastWithMsg:(NSString *)msg {
    [self showToastWithMsg:msg type:kToastInfomation];
}

- (void)showToastWithMsg:(NSString *)msg type:(KenToastType)type {
    UIImage *image = nil;

//    switch (type) {
//        case kToastInfomation: {
//            image = [UIImage imageNamed:@"hud_info"];
//        }
//            break;
//        case kToastWarning: {
//            image = [UIImage imageNamed:@"hud_warning"];
//        }
//            break;
//        case kToastSuccessful: {
//            image = [UIImage imageNamed:@"hud_success"];
//        }
//            break;
//        case kToastError: {
//            image = [UIImage imageNamed:@"hud_error"];
//        }
//            break;
//        default:
//            break;
//    }
    
    if ([UIApplication isNotEmpty:msg] && [msg isKindOfClass:[NSString class]]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window makeToast:msg duration:2 position:CSToastPositionCenter image:image];
    }
}
@end
