//
//  NSObject+KenObject.m
//  achr
//
//  Created by Ken.Liu on 16/5/6.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSObject+KenObject.h"
#import "Weakify.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (KenObject)

+ (NSString *)className {
    return NSStringFromClass(self);
}

- (NSString *)className {
    return [NSString stringWithUTF8String:class_getName([self class])];
}

+ (NSArray *)getPropertyList {
    NSMutableArray *mutableArr = [NSMutableArray array];
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList(self, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        [mutableArr addObject:[NSString stringWithUTF8String:property_getName(property)]];
    }
    
    free(properties);
    return mutableArr;
}

+ (BOOL)isNotEmpty:(id)obj {
    if (!obj || [obj isKindOfClass:[NSNull class]] ||
        ([obj isKindOfClass:[NSString class]] && ([obj isEqualToString:@""] ||
                                                  [obj isEqualToString:@"(null)"] ||
                                                  [(NSString *)obj length] < 1))) {
        return NO;
    }
    return YES;
}

+ (BOOL)isEmpty:(id)obj {
    return ![self isNotEmpty:obj];
}

#pragma mark - alert
- (void)presentInputViewInController:(UIViewController *)controller
                        confirmTitle:(NSString *)title
                             message:( NSString *)message
                        confirmHandler:(void (^)(NSString *content))confirmHandler
                         cancelHandler:(void (^)(void))cancelHandler {
    if (controller == nil || ![controller isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //添加取消按钮
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 if (cancelHandler) {cancelHandler();};
                                                             }];
        [alertController addAction:cancelAction];
        
        //添加确定按钮
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                if (confirmHandler) { confirmHandler(self.inputText); };
                                                            }];
        [alertController addAction:otherAction];
        
        //添加文本框
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField addTarget:self action:@selector(inputEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        [controller presentViewController:alertController animated:YES completion:nil];
    } else { // iOS7
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:controller
                                                  cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        void (^alertViewClickAction)(NSUInteger) =  ^(NSUInteger buttonIndex) {
            if (!buttonIndex) {
                if (cancelHandler) {cancelHandler();};
            } else {
                if (confirmHandler) { confirmHandler(self.inputText); };
            }
        };
        
        objc_setAssociatedObject(alertView, @"alertView", alertViewClickAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        [alertView show];
    }
}

- (void)inputEditingChanged:(UITextField *)textField {
    objc_setAssociatedObject(self, @selector(inputText), textField.text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)inputText {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)presentConfirmViewInController:(UIViewController *)controller
                          confirmTitle:(NSString *)title
                               message:( NSString *)message
                    confirmButtonTitle:(NSString *)confirmTitle
                     cancelButtonTitle:(NSString *)cancelTitle
                        confirmHandler:(void (^)(void))confirmHandler
                         cancelHandler:(void (^)(void))cancelHandler {
    if (controller == nil || ![controller isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    NSString *cancelTitleStr = cancelTitle ? : @"取消";
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        // Create the action.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitleStr style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
            if (cancelHandler) {cancelHandler();};
        }];
        // Add the action.
        [alertController addAction:cancelAction];
        
        if (confirmTitle) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                if (confirmHandler) {confirmHandler();};
            }];
            [alertController addAction:otherAction];
        }
        
        [controller presentViewController:alertController animated:YES completion:nil];
    } else { // iOS7
        UIAlertView *alertView;
        
        if (confirmTitle) {
            alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:controller
                                         cancelButtonTitle:cancelTitleStr otherButtonTitles:confirmTitle, nil];
        } else {
            alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:controller
                                         cancelButtonTitle:cancelTitleStr otherButtonTitles:nil];
        }
        
        alertView.alertViewStyle = UIAlertViewStyleDefault;
        
        void (^alertViewClickAction)(NSUInteger) =  ^(NSUInteger buttonIndex) {
            if (!buttonIndex) {
                if (cancelHandler) {cancelHandler();};
            } else {
                if (confirmHandler) {confirmHandler();};
            }
        };
        
        objc_setAssociatedObject(alertView, @"alertView", alertViewClickAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^alertViewClickAction)(NSUInteger) = objc_getAssociatedObject(alertView, @"alertView");
    
    if (alertViewClickAction) {
        alertViewClickAction(buttonIndex);
    }
}

- (void)presentSelectSheetByController:(UIViewController *)controller
                            sheetTitle:(NSString *)title
                     cancelButtonTitle:(NSString *)cancelTitle
                            btnHandler:(void (^)(NSUInteger))btnHandler
                        otherBtnTitles:(NSString *)otherBtnTitles, ... {
    
    if (controller == nil || ![controller isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    NSString *cancelTitleStr = cancelTitle ? : @"取消";
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {// iOS8
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        // add other action.
        va_list argList;
        va_start(argList, otherBtnTitles);
        
        NSString *btnTitle = nil;
        NSUInteger index = 0;
        do {
            [alertController addAction:[self addSheetActionWithTitle:[NSString isEmpty:btnTitle] ? otherBtnTitles : btnTitle
                                                               index:index btnHandler:btnHandler]];
            index++;
        } while ((btnTitle = va_arg(argList, NSString *)));

        va_end(argList);
        
        // add cancel action
        [alertController addAction:[self addSheetActionWithTitle:cancelTitleStr index:index btnHandler:nil]];
        
        [controller presentViewController:alertController animated:YES completion:nil];
    } else { // iOS7
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                 delegate:controller
                                                        cancelButtonTitle:cancelTitleStr
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:otherBtnTitles, nil];
        
        void (^sheetClickAction)(NSUInteger) =  ^(NSUInteger buttonIndex) {
            if (btnHandler) {btnHandler(buttonIndex);};
        };
        
        objc_setAssociatedObject(actionSheet, @"actionSheet", sheetClickAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        [actionSheet showInView:controller.view];
    }
}

- (UIAlertAction *)addSheetActionWithTitle:(NSString *)title index:(NSUInteger)index btnHandler:(void (^)(NSUInteger))btnHandler {
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
        if (btnHandler) {btnHandler(index);};
    }];
    return alertAction;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^sheetClickAction)(NSUInteger) = objc_getAssociatedObject(actionSheet, @"actionSheet");
    
    if (sheetClickAction) {
        sheetClickAction(buttonIndex);
    }
}

#pragma mark - swizzle hook
+ (void)swizzleMethod:(SEL)srcSel tarSel:(SEL)tarSel {
    Class clazz = [self class];
    [self swizzleMethod:clazz srcSel:srcSel tarClass:clazz tarSel:tarSel];
}

+ (void)swizzleMethod:(SEL)srcSel tarClass:(NSString *)tarClassName tarSel:(SEL)tarSel {
    if (!tarClassName) {
        return;
    }
    Class srcClass = [self class];
    Class tarClass = NSClassFromString(tarClassName);
    [self swizzleMethod:srcClass srcSel:srcSel tarClass:tarClass tarSel:tarSel];
}

+ (void)swizzleMethod:(Class)srcClass srcSel:(SEL)srcSel tarClass:(Class)tarClass tarSel:(SEL)tarSel {
    if (!srcClass || !srcSel || !tarClass || !tarSel) {
        return;
    }
    
    @try {
        Method srcMethod = class_getInstanceMethod(srcClass,srcSel);
        Method tarMethod = class_getInstanceMethod(tarClass,tarSel);
        method_exchangeImplementations(srcMethod, tarMethod);
    } @catch (NSException *exception) {
        NSString *exceptionStr = [self formatExceptionToString:exception withReason:nil];
        NSLog(@"%@", exceptionStr);
    } @finally {
        
    }
}

- (NSString *)formatExceptionToString:(NSException *)exception withReason:(NSString *)reasonStr {
    NSArray *arr = [exception callStackSymbols];
    NSString *reasonText = nil;
    if (reasonStr) {
        reasonText = reasonStr;
    } else {
        reasonText = [exception reason];
    }
    
    NSString *exceptionDes = [NSString stringWithFormat:@"\n\n%@\nname: %@\ntime: %@\nreason: %@\ncallStackSymbols: \n%@\n%@\n\n",
                              @"=============KenObject Exception Report=============",
                              [exception name],
                              [NSDate date],
                              reasonText,
                              [arr componentsJoinedByString:@"\n"],
                              @"=============KenObject Exception Report end========="];
    
    return exceptionDes;
}

- (void)logWarning:(NSString *)aString {
    @try {
        NSException *e = [NSException exceptionWithName:@"KenExceptionLog" reason:aString userInfo:nil];
        
        KenCategoryLog("%@", [self formatExceptionToString:e withReason:nil]);
#ifdef DEBUG
        @throw e;
#endif
    } @catch (NSException *exception) {
        NSString *exceptionStr = [self formatExceptionToString:exception withReason:nil];
        KenCategoryLog("%@", exceptionStr);
    }
}

@end
