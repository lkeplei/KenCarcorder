//
//  NSObject+KenObject.h
//  achr
//
//  Created by Ken.Liu on 16/5/6.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIAlertView.h>

@interface NSObject (KenObject)<UIAlertViewDelegate, UIActionSheetDelegate>

+ (NSString *)className;
- (NSString *)className;

+ (NSArray *)getPropertyList;

+ (BOOL)isNotEmpty:(id)obj;
+ (BOOL)isEmpty:(id)obj;

#pragma mark - alert
/**
 *  弹出系统自带，带输入框的弹框；兼容iOS7及以上版本,iOS7无需另外实现UIAlertViewDelegate的代理方法, 该Catogory会处理..
 *
 *  @param controller     呈现AlertView的Controller(nil则为无效)
 *  @param title          提示窗口标题
 *  @param message        提示消息
 *  @param confirmHandler 点击确定按钮执行的block, 不需要则设置nil
 *  @param cancelHandler  点击取消按钮执行的block, 不需要则设置nil
 */
- (void)presentInputViewInController:(UIViewController *)controller
                        confirmTitle:(NSString *)title
                             message:( NSString *)message
                      confirmHandler:(void (^)(NSString *content))confirmHandler
                       cancelHandler:(void (^)(void))cancelHandler;

/**
 *  弹出系统自带 确认窗口(两个按钮:确定和取消)或消息通知窗口(一个按钮:取消功能); 兼容iOS7及以上版本,
 iOS7无需另外实现UIAlertViewDelegate的代理方法, 该Catogory会处理..
 *
 *  @param controller     呈现AlertView的Controller(nil则为无效)
 *  @param title          提示窗口标题
 *  @param message        提示消息
 *  @param confirmTitle   确定按钮标题 (设置为nil, 即为仅包含1个取消按钮的消息通知窗口)
 *  @param cancelTitle    取消按钮标题 (nil 则为`取消`)
 *  @param confirmHandler 点击确定按钮执行的block, 不需要则设置nil
 *  @param cancelHandler  点击取消按钮执行的block, 不需要则设置nil
 */
- (void)presentConfirmViewInController:(id)controller
                          confirmTitle:(NSString *)title
                               message:( NSString *)message
                    confirmButtonTitle:(NSString *)confirmTitle
                     cancelButtonTitle:(NSString *)cancelTitle
                        confirmHandler:(void (^)(void))confirmHandler
                         cancelHandler:(void (^)(void))cancelHandler;

/**
 *  弹出系统自带 选择表单, 需指定presentingController; 兼容iOS7及以上版本; iOS7无需另外实现UIActionSheetDelegate的代理方法, 该Catogory会处理..
 *
 *  @param controller     呈现ActionSheet的Controller(nil则无效)
 *  @param title          标题(nil则无标题)
 *  @param cancelTitle    取消按钮标题(nil则为:取消)
 *  @param btnHandler     按钮触发handler block
 *  @param otherBtnTitles 其他按钮
 */
- (void)presentSelectSheetByController:(UIViewController *)controller
                            sheetTitle:(NSString *)title
                     cancelButtonTitle:(NSString *)cancelTitle
                            btnHandler:(void (^)(NSUInteger))btnHandler
                        otherBtnTitles:(NSString *)otherBtnTitles, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - swizzle hook
/*
 * To swizzle two selector for self class.
 */
+ (void)swizzleMethod:(SEL)srcSel tarSel:(SEL)tarSel;

/*
 * To swizzle two selector from self class to target class.
 */
+ (void)swizzleMethod:(SEL)srcSel tarClass:(NSString *)tarClassName tarSel:(SEL)tarSel;

/*
 * To swizzle two selector from self class to target class.
 */
+ (void)swizzleMethod:(Class)srcClass srcSel:(SEL)srcSel tarClass:(Class)tarClass tarSel:(SEL)tarSel;

- (void)logWarning:(NSString *)aString;

@end
