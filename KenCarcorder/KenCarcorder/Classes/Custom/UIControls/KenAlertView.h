//
//  KenAlertView.h
//  KenAlertView
//
//  Created by Ken.Liu on 2016/12/5.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class KenAlertView;

typedef void(^AlertViewButtonClickedBlock)(KenAlertView *alertView, NSInteger index);

@interface KenAlertView : UIView

/**
 *  展示一个默认的alertView   按钮小于等于2是按钮横向排列，按钮数量大于3个，按钮竖向排列,按钮数量上限为5个，大于5个，alertView不会创建
 
 *  @param title                                标题
 *  @param contentView                          自定义内容视图
 *  @param message                              内容
 *  @param buttonTitles                         按钮名称(传数组)
 *  @param buttonClickedBlock                   按钮点击回调
 */
+ (void)showAlertViewWithTitle:(nullable NSString *)title
                   contentView:(nullable UIView *)contentView
                       message:(nullable NSString *)message
                  buttonTitles:(NSArray <__kindof NSString *> *)buttonTitles
            buttonClickedBlock:(AlertViewButtonClickedBlock)buttonClickedBlock;

/**
 *  创建alertView   按钮小于等于2是按钮横向排列，按钮数量大于3个，按钮竖向排列,按钮数量上限为5个，大于5个，alertView不会创建
 
 *  @param title                                标题
 *  @param contentView                          自定义内容视图
 *  @param message                              内容
 *  @param buttonTitles                         按钮名称(传数组)
 *  @param buttonClickedBlock                   按钮点击回调
 */
- (instancetype)initWithTitle:(nullable NSString *)title
                  contentView:(nullable UIView *)contentView
                      message:(nullable NSString *)message
                 buttonTitles:(NSArray <__kindof NSString *> *)buttonTitles
           buttonClickedBlock:(AlertViewButtonClickedBlock)buttonClickedBlock;

- (void)show;

- (void)setTitleColor:(UIColor *)color ;
- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size;

- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size;
- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index;

@end
NS_ASSUME_NONNULL_END
