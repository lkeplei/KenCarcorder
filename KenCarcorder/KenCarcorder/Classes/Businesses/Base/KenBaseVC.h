//
//  KenBaseVC.h
//
//
//  Created by Ken.Liu on 2016/11/21.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KenUIModel.h"
#import "UIViewController+KenKVO.h"

typedef NS_OPTIONS(NSUInteger, CWFunctionType)  {
    kKenFunctionNone = 0,
    kKenFunctionKeyboard = 1,                                //隐藏键盘的功能
    kKenFunctionBindUIModel = 1 << 1,                        //界面绑定UIModel
};

typedef NS_ENUM(NSUInteger, CWViewScreenType) {
    kKenViewScreenUnkown = 0,          //未知
    kKenViewScreenNormal,              //带状态栏，也带导航栏
    kKenViewScreenWithStatus,          //带状态栏，不带导航栏
    kKenViewScreenFull,                //全屏
};

NS_ASSUME_NONNULL_BEGIN

@interface KenBaseVC : UIViewController


@property (nonatomic, assign) CWViewScreenType screenType;      //屏幕状态（正常、只带状态栏、全屏）
@property (nonatomic, assign) CWFunctionType functionType;      //功能类型
@property (nonatomic, strong) NSString *backVC;                 //当前视图返回时要跳转的视图
@property (nonatomic, strong) UIView *contentView;              //内容视图，这个用于所有内容的填写（根据屏幕状态自动适配覆盖区域）
@property (nonatomic, strong) UIColor *navBarColor;             // 导航栏颜色
@property (nonatomic, assign) BOOL hideBackBtn;                 //是否隐藏返回按钮（默认不隐藏）

#pragma mark - 堆栈处理
/**
 *  视图入栈
 *
 *  @param viewController 入栈视图, 同时支持字符串和class的方式
 *  @param animated       是否带过渡动画
 *  @return 返回进栈视图
 */
- (nullable KenBaseVC *)pushViewController:(KenBaseVC *)viewController animated:(BOOL)animated;
- (nullable KenBaseVC *)pushViewControllerClass:(Class)class animated:(BOOL)animated;
- (nullable KenBaseVC *)pushViewControllerString:(NSString *)class animated:(BOOL)animated;

/**
 *  返回到rootVC
 *
 *  @param animated 是否带过渡动画
 *
 *  @return 返回过程pop出来的controllers
 */
- (nullable NSArray<__kindof KenBaseVC *> *)popToRootViewControllerAnimated:(BOOL)animated;

/** 2015-12-10 14:22:34
 *  @desc   返回到某一个视图
 *
 *  @param viewController   终点视图(同时支持string和class)
 *  @param animated         是否带过渡动画
 *  @return                 返回跳过的视图队列
 */
- (nullable NSArray<__kindof KenBaseVC *> *)popToViewController:(KenBaseVC *)viewController animated:(BOOL)animated;
- (nullable NSArray<__kindof KenBaseVC *> *)popToViewControllerClass:(Class)class animated:(BOOL)animated;
- (nullable NSArray<__kindof KenBaseVC *> *)popToViewControllerString:(NSString *)class animated:(BOOL)animated;

- (void)popViewController;

/** 2015-12-10 14:30:18
 *  @desc   返回上一级视图,如果有定义特殊返回的话，返回到特殊vc
 *
 *  @param animated     是否带过渡动画
 *  @return             返回跳过的视图队列
 */
- (nullable NSArray<__kindof KenBaseVC *> *)popViewControllerAnimated:(BOOL)animated; // Returns the popped controller.

#pragma mark - navigation
/**
 *  设置导航栏按钮角标
 */
- (void)setNavItemCorner:(BOOL)show left:(BOOL)left;

/**
 *  设置导航栏左右边的按钮（图标）
 *
 *  @param image 图片
 *  @param sel   action响应方法
 */
- (void)setLeftNavItemWithImg:(UIImage *)image selector:(SEL)sel;
- (void)setRightNavItemWithImg:(UIImage *)image selector:(SEL)sel;

/**
 *  设置导航栏左右边的按钮（文案）
 *
 *  @param text     文案
 *  @param color    文案颜色
 *  @param sel      action响应方法
 */
- (void)setLeftNavItemWithText:(NSString *)text color:(UIColor *)color selector:(SEL)sel;
- (void)setRightNavItemWithText:(NSString *)text color:(UIColor *)color selector:(SEL)sel;
- (void)setLeftNavItemWithText:(NSString *)text selector:(SEL)sel;
- (void)setRightNavItemWithText:(NSString *)text selector:(SEL)sel;

/**
 *  设置导航栏文案
 *
 *  @param navTitle 标题
 *  @param color    标题颜色，默认辅助黑
 */
- (void)setNavTitle:(NSString *)navTitle color:(UIColor *)color;
- (void)setNavTitle:(NSString *)navTitle;





#pragma mark - public mehtod

/** 2015-12-11 10:35:08
 *  @desc   用于给页面加载数据(这里主要用在页面被入栈之前,入栈之后的数据加载最好不要在这里使用)
 *
 *  @param parentVC     父vc
 *  @param finishBlock  数据加载结束之后的回调
 *                      回调中带一个是否需要新视图入栈的布尔参数
 */
- (void)loadData:(KenBaseVC *)parentVC finish:(void(^)(BOOL push))finishBlock;

//弹框强提示
- (void)showAlert:(NSString *)title content:(NSString *)content;
- (void)showAlert:(NSString *)title content:(NSString *)content type:(KenToastType)type;

/**
 *  用户数据请求正常逻辑失败处理，是否要清除用户数据跳到登录
 *
 *  @param control  文案显示父VC
 *  @param clean    是否需要clean用户数据
 *  @param errMsg   错误文案
 */
- (void)cleanUserDataWithErrmsg:(UIViewController *)control clean:(BOOL)clean errMsg:(NSString *)errMsg;

#pragma mark - uimodel
- (KenUIModel *)getUIModel;

@end

NS_ASSUME_NONNULL_END
