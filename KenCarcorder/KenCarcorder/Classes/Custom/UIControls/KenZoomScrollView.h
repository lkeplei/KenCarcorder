//
//  KenZoomScrollView.h
//  ScrollViewWithZoom
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KenZoomScrollBlock)(CGRect frame);

@interface KenZoomScrollView : UIScrollView <UIScrollViewDelegate>

- (instancetype)initWithBlock:(CGRect)frame block:(KenZoomScrollBlock)block;

- (void)resetFrame:(CGRect)frame;

@property (nonatomic, strong) UIView *zoomView;

@end
