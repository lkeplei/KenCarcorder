//
//  KenBaseVC.m
//
//
//  Created by Ken.Liu on 2016/11/21.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"
#import "KenActionSheet.h"
#import "KenAlertView.h"
#import "UIBarButtonItem+KenBadge.h"
#import "KenNavigationC.h"

@interface KenBaseVC ()

@property (nonatomic, strong) UIView *topColorPlaceholderView;

@end

@implementation KenBaseVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fullScreenActivity = YES;               //默认加载框全屏

        _screenType = kKenViewScreenNormal;
        _functionType = kKenFunctionNone;
        _hideBackBtn = NO;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
	//先隐藏，didappear的时候再做是否显示的处理，不然会闪一下
	KenNavigationC *nav = (KenNavigationC *)self.navigationController;
	nav.colorMaskView.hidden = YES;
	
	//如果当前视图控制器不是根视图，并且不隐藏返回按钮，就显示默认的返回按钮
	
		if (!self.hideBackBtn) {
			if (self.navigationController.viewControllers.count > 1) {
				[self setLeftNavItemWithImg:[UIImage imageNamed:@"cw_public_nav_back"]
								   selector:@selector(popViewController)];
			}
		} else {
			[self setLeftNavItemWithText:@"" selector:@selector(popViewController)];
			
		}
	
	

    //关闭系统自动的下移功能(64)
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_screenType != kKenViewScreenUnkown) {
        CGFloat offsetY = _screenType == kKenViewScreenNormal ? 64 : 0;
        CGFloat tabbarH = self.hidesBottomBarWhenPushed ? 0 : TabBarHeight;
		
		//带导航栏的视图，默认显示白色，其他的默认透明
		if (_screenType == kKenViewScreenNormal) {
			self.navBarColor = [UIColor whiteColor];
		} else {
			self.navBarColor = [UIColor clearColor];
		}
        _contentView = [[UIView alloc] initWithFrame:(CGRect){0, offsetY, self.view.width, self.view.height - offsetY - tabbarH}];
        [_contentView setBackgroundColor:[UIColor appBackgroundColor]];
        [self.view addSubview:_contentView];
		//视图顶部的视图，显示导航栏颜色
		[self.view addSubview:self.topColorPlaceholderView];
    }
    
    if (_functionType & kKenFunctionKeyboard) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(keyboardHide:)];
        //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
        tapGestureRecognizer.cancelsTouchesInView = NO;
        //将触摸事件添加到当前view
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    
    if (_functionType & kKenFunctionBindUIModel) {
        //初始绑定
        self.uiModel = [self getUIModel];
        [self bindModelKVOEvent];
        
        self.uiModel.viewController = self;
        [self.uiModel bindVCKVOEvent];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_functionType & kKenFunctionBindUIModel) {
        //属性绑定
        [self.uiModel enableKVOEvent];
    }

	//视图出现之后，更新导航控制器上的maskView。
	[self updateNavBarMaskViewColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_functionType & kKenFunctionBindUIModel) {
        //属性绑定
        [self.uiModel disableKVOEvent];
    }
    
    [self hideActivity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - uimodel
- (KenUIModel *)getUIModel {
    return [[KenUIModel alloc] init];
}

#pragma mark - private method

- (void)setNavItem:(UIImage *)image selector:(SEL)sel left:(BOOL)left {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
	
	btn.bounds = CGRectMake(0, 0, 44, 44);
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	if (left) {
		[btn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];        //图片向左靠
		self.navigationItem.leftBarButtonItem = item;
	} else {
		self.navigationItem.rightBarButtonItem = item;
	}
	
}

- (void)setNavItemWithText:(NSString *)text selector:(SEL)sel left:(BOOL)left {
    CGSize textSize = [text sizeForFont:[UIFont appFontSize15]];
    CGFloat textWidth = textSize.width + 10;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont appFontSize15];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
    
	btn.enabled = [NSString isNotEmpty:text];
	btn.frame = CGRectMake(0, 0, MIN(textWidth, 100), 44);
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	if (left) {
		self.navigationItem.leftBarButtonItem = item;
	} else {
		self.navigationItem.rightBarButtonItem = item;
		[btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20)];
	}
	
}

//隐藏键盘
- (void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}


- (void)updateNavBarMaskViewColor {
	NSInteger lastVCIndex = self.navigationController.viewControllers.count - 2;
	KenNavigationC *nav = (KenNavigationC *)self.navigationController;
	BOOL hiddenNavMaskColorView = YES;
	if (lastVCIndex >= 0) {
		typeof(self) lastVC = [self.navigationController.viewControllers objectAtIndex:lastVCIndex];
		hiddenNavMaskColorView = ![lastVC.navBarColor isEqual:self.navBarColor];
		
		if ([lastVC.navBarColor isEqual:[UIColor clearColor]] || [self.navBarColor isEqual:[UIColor clearColor]]) {
			hiddenNavMaskColorView = YES;
		} else {
			hiddenNavMaskColorView = NO;
		}
		
		if ([lastVC.navBarColor isEqual:self.navBarColor]) {
			hiddenNavMaskColorView = NO;
		}

	}
	if ([nav isKindOfClass:[KenNavigationC class]]) {
		nav.colorMaskView.hidden = hiddenNavMaskColorView;
		nav.colorMaskView.backgroundColor = self.navBarColor;
	}
	
	
}
#pragma mark - 视图堆栈相关方法
- (nullable KenBaseVC *)pushViewController:(KenBaseVC *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        if ([[self.navigationController viewControllers] containsObject:viewController]) {
            [self popToViewController:viewController animated:animated];
        } else {
            [viewController loadData:self finish:^(BOOL push) {
                if (push) {
                    [self.navigationController pushViewController:viewController animated:animated];
                }
            }];
        }
        return viewController;
    } else {
        return nil;
    }
}

- (nullable KenBaseVC *)pushViewControllerClass:(Class)class animated:(BOOL)animated {
    return [self pushViewController:[[class alloc] init] animated:animated];
};

- (nullable KenBaseVC *)pushViewControllerString:(NSString *)class animated:(BOOL)animated {
    return [self pushViewControllerClass:NSClassFromString(class) animated:animated];
};

- (nullable NSArray<__kindof KenBaseVC *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (self.navigationController) {
        return [self.navigationController popToRootViewControllerAnimated:animated];
    } else {
        return nil;
    }
}

- (nullable NSArray<__kindof KenBaseVC *> *)popToViewController:(KenBaseVC *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        if ([[self.navigationController viewControllers] containsObject:viewController]) {
            return [self.navigationController popToViewController:viewController animated:animated];
        } else {
            return [self popToViewControllerClass:[viewController class] animated:animated];
        }
    } else {
        return nil;
    }
}

- (nullable NSArray<__kindof KenBaseVC *> *)popToViewControllerClass:(Class)class animated:(BOOL)animated {
    if (self.navigationController) {
        for (KenBaseVC *baseVC in [self.navigationController viewControllers]) {
            if ([baseVC isKindOfClass:class]) {
                return [self popToViewController:baseVC animated:animated];
            }
        }
        return nil;
    } else {
        return nil;
    }
}

- (nullable NSArray<__kindof KenBaseVC *> *)popToViewControllerString:(NSString *)class animated:(BOOL)animated {
    return [self popToViewControllerClass:NSClassFromString(class) animated:animated];
};

- (nullable NSArray<__kindof KenBaseVC *> *)popViewControllerAnimated:(BOOL)animated {
    if (self.navigationController) {
        if ([UIApplication isEmpty:_backVC]) {
            KenBaseVC *vc = (KenBaseVC *)[self.navigationController popViewControllerAnimated:animated];
            if (vc) {
                return [NSArray arrayWithObject:vc];
            } else {
                return nil;
            }
        } else {
            return [self popToViewControllerString:_backVC animated:animated];
        }
    } else {
        return nil;
    }
}

- (void)popViewController {
    if (_hideBackBtn) {
        return;
    }
    
    if (self.navigationController) {
        [self popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - public method
- (void)setNavItemCorner:(BOOL)show left:(BOOL)left {
    if (_screenType == kKenViewScreenNormal || self.navigationController == nil) {
        if (show) {
            self.navigationItem.rightBarButtonItem.badgeValue = @"1";
        } else {
            self.navigationItem.rightBarButtonItem.badgeValue = @"0";
        }
        UIBarButtonItem *item = left ? self.navigationItem.leftBarButtonItem : self.navigationItem.rightBarButtonItem;
        item.badgeStyle = KenBarButtonItemBadgeDot;
        item.badgeOriginX = 28;
        item.badgeOriginY = 12;
        item.badgeBGColor = [UIColor colorWithRed:0.957 green:0.275 blue:0.114 alpha:1];
    } else {
        UIButton *button = (UIButton *)[self.contentView viewWithTag:left ? 1101 : 1102];
        if (button) {
            if (!show) {
                [button hideCorner];
                return;
            }
            UIImage *image = [button imageForState:UIControlStateNormal];
            if (image) {
                [button showCornerWithPoint:(CGPoint){(button.width + image.size.width) / 2 - 4, (button.height - image.size.height) / 2}
                                      color:[UIColor colorWithHexString:@"FE3A39"]];
            } else {
                NSString *text = [button titleForState:UIControlStateNormal];
                CGSize textSize = [text sizeForFont:[UIFont appFontSize15]];
                [button showCornerWithPoint:(CGPoint){button.width - 2, (button.height - textSize.height) / 2 - 2}
                                      color:[UIColor colorWithHexString:@"FE3A39"]];
            }
        }
    }
}

- (void)setLeftNavItemWithImg:(UIImage *)image selector:(SEL)sel {
    [self setNavItem:image selector:sel left:YES];
}

- (void)setRightNavItemWithImg:(UIImage *)image selector:(SEL)sel {
    [self setNavItem:image selector:sel left:NO];
}

- (void)setLeftNavItemWithText:(NSString *)text selector:(SEL)sel {
    [self setNavItemWithText:text selector:sel left:YES];
}

- (void)setRightNavItemWithText:(NSString *)text selector:(SEL)sel {
    [self setNavItemWithText:text selector:sel left:NO];
}

- (void)setNavTitle:(NSString *)navTitle {
    [self setNavTitle:navTitle color:[UIColor appAssistBlackColor]];
}

- (void)setNavTitle:(NSString *)navTitle color:(UIColor *)color {
	UILabel *lab = (UILabel *)self.navigationItem.titleView;
	
	CGFloat textWidth = [navTitle widthForFont:[UIFont appFontSize17]] + 20;
	if (lab) {
		lab.text = navTitle;
	} else {
		UILabel *titleLab = [UILabel labelWithTxt:navTitle frame:CGRectMake(0, 0, MAX(textWidth, 120), 44)
											 font:[UIFont appFontSize17] color:color];
		self.navigationItem.titleView = titleLab;
	}
}

- (void)setNavBarColor:(UIColor *)color {
	_navBarColor = color;
	self.topColorPlaceholderView.backgroundColor = color;
}


#pragma mark - 页面特殊数据加载
- (void)loadData:(KenBaseVC *)parentVC finish:(void(^)(BOOL push))finishBlock {
    SafeHandleBlock(finishBlock, YES);
}

- (void)strokBgWithHeight:(CGFloat)height {
    [self.contentView.layer addSublayer:[self gradientLayerWithHeight:height]];
}

- (CAGradientLayer *)gradientLayerWithHeight:(CGFloat)height {
    UIBezierPath *progressline = [UIBezierPath bezierPath];
    [progressline moveToPoint:CGPointMake(0, height / 2)];
    [progressline addLineToPoint:CGPointMake(self.contentView.width, height / 2)];
    [progressline setLineWidth:height];
    [progressline setLineCapStyle:kCGLineCapSquare];
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    _shapeLayer.lineWidth = height;
    _shapeLayer.strokeEnd = 1;
    _shapeLayer.lineCap = kCALineCapSquare;
    _shapeLayer.path = progressline.CGPath;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0.0, 0.9);
    gradientLayer.endPoint = CGPointMake(1.0, 0.4);
    gradientLayer.frame = CGRectMake(0, 0, self.contentView.width * 1.4, height * 1.2);
    NSArray *colors = @[(id)[UIColor colorWithHexString:@"#00AA6E"].CGColor,
                        (id)[UIColor colorWithHexString:@"#33C752"].CGColor,
                        (id)[UIColor colorWithHexString:@"#C2EF06"].CGColor];
    gradientLayer.colors = colors;
    
    [gradientLayer setMask:_shapeLayer];
    
    return gradientLayer;
}

#pragma mark - empty view
- (void)showViewEmpty:(UIView *)view message:(NSString *)message {
    UIView *emptyV = (UIImageView *)[view viewWithTag:9999];
    if (emptyV) {
        [emptyV setHidden:NO];
    } else {
        emptyV = [[UIView alloc] initWithFrame:(CGRect){0,0, view.size}];
        emptyV.tag   = 9999;
        [view addSubview:emptyV];
        
        UIImageView *emptyImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cw_public_empty"]];
        emptyImgV.center = CGPointMake(emptyV.width / 2, emptyV.height / 2 - emptyImgV.height);
        [emptyV addSubview:emptyImgV];
        
        UILabel *info = [UILabel labelWithTxt:message
                                        frame:(CGRect){0, CGRectGetMaxY(emptyImgV.frame) + kKenOffset, view.width, 20}
                                         font:[UIFont appFontSize15] color:[UIColor appGrayTextColor]];
        [emptyV addSubview:info];
    }
}
- (void)showViewEmpty:(UIView *)view {
    [self showViewEmpty:view message:@"还没有内容耶，少年快加把劲"];
}

- (void)hideViewEmpty:(UIView *)view {
    UIImageView *emptyImgV = (UIImageView *)[view viewWithTag:9999];
    if (emptyImgV) {
        [emptyImgV setHidden:YES];
    }
}

- (void)showErrorViewForReload:(UIView *)view selector:(SEL)sel {
    UIView *errView = (UIView *)[view viewWithTag:100009];
    if (errView == nil) {
        UIView *errView = [[UIView alloc] initWithFrame:(CGRect){0,0, view.size}];
        errView.backgroundColor = [UIColor appBackgroundColor];
        errView.tag = 100009;
        [view addSubview:errView];
        
        UIImageView *errorImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cw_public_load_error"]];
        errorImgV.center = CGPointMake(errView.width / 2, errView.height / 2 - errorImgV.height);
        [errView addSubview:errorImgV];
        
        UILabel *descLabel = [UILabel labelWithTxt:@"网络出错，请检查网络后重试"
                                             frame:(CGRect){0, CGRectGetMaxY(errorImgV.frame) + kKenOffset, view.width, 20}
                                              font:[UIFont systemFontOfSize:16] color:[UIColor appGrayTextColor]];
        [errView addSubview:descLabel];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((errView.width - 100) / 2, CGRectGetMaxY(descLabel.frame) + kKenOffset, 100, 31);
        button.titleLabel.font = [UIFont appFontSize14];
        [button setBackgroundColor:[UIColor clearColor]];
        
        [button setTitle:@"重新加载" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
        
        button.layer.borderColor = [UIColor appMainColor].CGColor;
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        
        [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        
        [errView addSubview:button];
    }
}

- (void)hideErrorViewForReload:(UIView *)view {
    UIView *errView = (UIView *)[view viewWithTag:100009];
    if (errView) {
        [errView removeFromSuperview];
        errView = nil;
    }
}

- (void)showLoading:(UIView *)view {
    UIImageView *animation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cw_loading_1.png"]];
    animation.center = CGPointMake(view.width / 2, view.height / 2);
    animation.animationImages = @[[UIImage imageNamed:@"cw_loading_1.png"],
                                        [UIImage imageNamed:@"cw_loading_2.png"],
                                        [UIImage imageNamed:@"cw_loading_3.png"],
                                        [UIImage imageNamed:@"cw_loading_4.png"],
                                        [UIImage imageNamed:@"cw_loading_5.png"],
                                        [UIImage imageNamed:@"cw_loading_6.png"],
                                        [UIImage imageNamed:@"cw_loading_7.png"],
                                        [UIImage imageNamed:@"cw_loading_8.png"],
                                        [UIImage imageNamed:@"cw_loading_9.png"],
                                        [UIImage imageNamed:@"cw_loading_10.png"],
                                        [UIImage imageNamed:@"cw_loading_11.png"],
                                        [UIImage imageNamed:@"cw_loading_12.png"],
                                        [UIImage imageNamed:@"cw_loading_13.png"]];
    animation.tag = 110009;
    animation.animationDuration = 0.6;         // 设定所有的图片在多少秒内播放完毕
    animation.animationRepeatCount = 0;        // 不重复播放多少遍，0表示无数遍
    [animation startAnimating];                // 开始播放
    [view addSubview:animation];
}

- (void)hideLoading:(UIView *)view {
    UIImageView *loading = (UIImageView *)[view viewWithTag:110009];
    if (loading) {
        [loading stopAnimating];
        [loading removeFromSuperview];
        loading = nil;
    }
}

- (void)showAlert:(NSString *)title content:(NSString *)content {
    [self showAlert:title content:content type:kToastInfomation];
}

- (void)showAlert:(NSString *)title content:(NSString *)content type:(KenToastType)type {
    [KenAlertView showAlertViewWithTitle:title contentView:nil message:content buttonTitles:@[@"确定"]
                     buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {}];
}

#pragma mark - setter && getter
- (UIView *)topColorPlaceholderView {
	if (!_topColorPlaceholderView) {
		_topColorPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
		_topColorPlaceholderView.backgroundColor = [UIColor whiteColor];
		_topColorPlaceholderView.userInteractionEnabled = NO;
	}
	return _topColorPlaceholderView;
}

@end
