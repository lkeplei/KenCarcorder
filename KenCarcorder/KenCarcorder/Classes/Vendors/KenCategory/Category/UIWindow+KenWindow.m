//
//  UIWindow+KenWindow.m
//  achr
//
//  Created by Ken.Liu on 16/9/18.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIWindow+KenWindow.h"
#import "Weakify.h"

#import <objc/runtime.h>

@implementation UIWindow (KenWindow)

#pragma mark - ShakeToEdit 摇动手机之后的回调方法
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //检测到摇动开始
    if (motion == UIEventSubtypeMotionShake) {
        KenCategoryLog("motionBegan");
        if (self.windowSakeBlock) {
            self.windowSakeBlock();
        }
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
        KenCategoryLog("motionEnded");
    }
}

#pragma mark - 扩展属性
- (void)setWindowSakeBlock:(void (^)())windowSakeBlock {
    objc_setAssociatedObject(self, @"window_shake_block_key", windowSakeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())windowSakeBlock {
    return objc_getAssociatedObject(self, @"window_shake_block_key");
}

@end
