//
//  KenZoomScrollView.m
//
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import "KenZoomScrollView.h"

@interface KenZoomScrollView ()

@property (assign) CGSize staticSize;
@property (nonatomic, copy) KenZoomScrollBlock zoomBlock;

@end

@implementation KenZoomScrollView

- (instancetype)initWithBlock:(CGRect)frame block:(KenZoomScrollBlock)block {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.zoomBlock = block;
        _staticSize = frame.size;
    }
    return self;
}

- (void)setZoomView:(UIView *)zoomView {
    if (_zoomView) {
        [_zoomView removeFromSuperview];
    }
    
    _zoomView = zoomView;
    _zoomView.userInteractionEnabled = YES;
    [self addSubview:_zoomView];
    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [_zoomView addGestureRecognizer:doubleTapGesture];
    
    // 设置内容范围
    self.contentSize = _zoomView.size;
    
    [self setMaximumZoomScale:4];
//    [self setMinimumZoomScale:1];
//    [self setZoomScale:1];
}

- (void)resetFrame:(CGRect)frame {
    _staticSize = frame.size;
    self.frame = frame;

    _zoomView.frame = frame;
//    [self scrollViewDidEndZooming:self withView:_zoomView atScale:1];
}

#pragma mark - Zoom methods
- (void)handleDoubleTap:(UIGestureRecognizer *)gesture {
    [self scrollViewDidEndZooming:self withView:_zoomView atScale:1];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _zoomView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale == 1) {
        [self zoomToRect:(CGRect){0, 0, _staticSize} animated:NO];
    } else {
        [self setZoomScale:scale animated:NO];
    }

    if (self.zoomBlock) {
        CGRect rect = _zoomView.frame;
        
        if (scale == 1) {
            rect = (CGRect){0, 0, _staticSize};
        }
        
        self.zoomBlock((CGRect){rect.origin.x > 0 ? 0 : rect.origin.x, rect.origin.y > 0 ? 0 : rect.origin.y, rect.size});
    }
}
@end
