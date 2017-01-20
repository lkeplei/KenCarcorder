//
//  UIViewController+KenKVO.h
//
//  Created by Ken.Liu on 16/1/5.
//  Base on Tof Templates
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KenUIModel;
@class KenKVOPlugin;

#pragma mark -
#pragma mark Category KenKVO for UIViewController 
#pragma mark -

@protocol KVOViewControllerDelegate <NSObject>

NS_ASSUME_NONNULL_BEGIN
@optional
- (void)viewController:(UIViewController *)viewController kvoUIControlPropertyChange:(NSString *)uiControl
          propertyName:(NSString *)property oldValue:(id)oldValue newValue:(id)newValue;
- (void)viewController:(UIViewController *)viewController kvoUIControlPropertyChange:(NSString *)propertyPath
              oldValue:(id)oldValue newValue:(id)newValue;
- (void)viewController:(UIViewController *)viewController kvoObject:(id)object kvoPropertyChange:(NSString *)propertyPath
              oldValue:(id)oldValue newValue:(id)newValue;
@end

@interface UIViewController (KenKVO)

@property (nonatomic, weak) id <KVOViewControllerDelegate> kvoDelegate;
@property (nonatomic, strong, nullable) __kindof KenUIModel *uiModel;

#pragma mark - AXDBaseViewControllerBuilder-开启和关闭UI控件的值变化监听
- (void)bindModelKVOEvent;

- (void)enableKVOEvent:(NSString *)uiControl property:(NSString *)propertyName;
- (void)disableKVOEvent:(NSString *)uiControl property:(NSString *)propertyName;

- (void)enableKVOEvent:(NSString *)propertyPath;
- (void)disableKVOEvent:(NSString *)propertyPath;

- (void)enableObjectKVOEvent:(id)obj property:(NSString *)propertyPath;
- (void)disableObjectKVOEvent:(id)obj property:(NSString *)propertyPath;

- (void)disableAllKVOEvent;

#pragma mark - only kvo
- (void)enableKVOAction:(nonnull NSString *)propertyPath action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
