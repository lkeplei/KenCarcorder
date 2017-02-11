//
//  KenNavigationC.m
//
//
//  Created by Ken.Liu on 2016/11/22.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenNavigationC.h"
@interface KenNavigationC ()

@end

@implementation KenNavigationC

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
		//导航栏透明
		self.navigationBar.translucent = YES;
		[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
		self.navigationBar.barStyle = UIBarStyleDefault;
		[self.navigationBar setShadowImage:[UIImage new]];
		
        __weak typeof (self) weakSelf = self;
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.delegate = weakSelf;
        }
		[self.view insertSubview:self.colorMaskView belowSubview:self.navigationBar];
    }
    return self;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //禁止手势返回
    return NO;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) { // 如果push进来的不是第一个控制器
        viewController.hidesBottomBarWhenPushed = YES;      // 隐藏tabbar
    }
    
    // 这句super的push要放在后面, 让viewController可以覆盖上面设置的leftBarButtonItem
    [super pushViewController:viewController animated:animated];
}
#pragma mark - setter && getter

- (UIView *)colorMaskView {
	if (!_colorMaskView) {
		_colorMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationBar.frame), 64)];
		_colorMaskView.userInteractionEnabled = NO;
	}
	return _colorMaskView;
}

@end
