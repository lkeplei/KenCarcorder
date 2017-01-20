//
//  KenNavigationC.h
//  CWC
//
//  Created by Ken.Liu on 2016/11/22.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KenNavigationC : UINavigationController<UIGestureRecognizerDelegate>

/**
 透明的导航栏，在切换视图的时候，左侧会有一条从顶部到底部的阴影。
 这个视图就是处理阴影的。
 1、如果当前视图与上一个视图的导航栏颜色	不一致，	则隐藏colorMaskView
 2、如果当前视图与上一个视图的导航栏颜色	一致，	则显示colorMaskView
 3、如果当前视图或上一个视图的导航栏为		透明，	则隐藏colorMaskView
 
 */
@property (nonatomic, strong) UIView *colorMaskView;
@end
