//
//  UIView+KenView.h
//  achr
//
//  Created by Ken.Liu on 16/3/3.
//  Base on Tof Templates
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark Category KenView for UIView 
#pragma mark -

NS_ASSUME_NONNULL_BEGIN

typedef void(^animationCompletionBlock)();

extern NSString * const CSToastPositionTop;
extern NSString * const CSToastPositionCenter;
extern NSString * const CSToastPositionBottom;

@interface UIView (KenView)<CAAnimationDelegate>

@property (nonatomic, copy) animationCompletionBlock completionBlock;

#pragma mark - 点击及长按事件
- (void)clicked:(nonnull void(^)(UIView *view))clicked;
- (void)longPressed:(nonnull void(^)(UIView *view))longPressed;

//这个为了给统计扩展hook使用，外部不要直接调用
- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture;
- (void)handleActionForLongPressGesture:(UITapGestureRecognizer *)gesture;

#pragma mark - frame相关属性
- (CGFloat)minX;
- (CGFloat)maxX;
- (CGFloat)minY;
- (CGFloat)maxY;
- (CGFloat)height;
- (CGFloat)width;
- (CGSize)size;
- (CGPoint)origin;
- (CGFloat)originX;
- (CGFloat)originY;
- (CGFloat)centerX;
- (CGFloat)centerY;
- (void)setOrigin:(CGPoint)point;
- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setSize:(CGSize)size;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;

#pragma mark - toast
// 根据message等信息生成默认样式的toast
- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(_Nullable id)position;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position image:(nullable UIImage *)image;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title
            image:(nullable UIImage *)image;

// 显示自定义的toast
- (void)showToast:(UIView *)toast;
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(_Nullable id)point;
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(_Nullable id)point
      tapCallback:( void(^ _Nullable )(void))tapCallback;

#pragma mark - ToastActivity
- (void)makeToastActivity;
- (void)makeToastActivity:(id)position;
- (void)hideToastActivity;

#pragma mark - 震动
- (void)shake;
- (void)shakeWithDuration:(NSTimeInterval)duration completion:( void (^ _Nullable )())completion;

#pragma mark - 加虚线
- (void)drawDashLine:(NSArray *)lineDash lineColor:(UIColor *)lineColor;

//设置角标和角标背景色
- (void)showCornerWithPoint:(CGPoint)point color:(UIColor *)color;
- (void)hideCorner;

//将本视图转换为image
- (UIImage *)transformToImage;

@end

NS_ASSUME_NONNULL_END
