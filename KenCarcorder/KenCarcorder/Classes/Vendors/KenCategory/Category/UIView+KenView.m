//
//  UIView+KenView.m
//  achr
//
//  Created by Ken.Liu on 16/3/3.
//  Base on Tof Templates
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIView+KenView.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark Category KenView for UIView 
#pragma mark -

static char kDTActionHandlerTapBlockKey;
static char kDTActionHandlerTapGestureKey;
static char kDTActionHandlerLongPressBlockKey;
static char kDTActionHandlerLongPressGestureKey;

static const CGFloat CSToastMaxWidth            = 0.8;              // 80% of parent view width
static const CGFloat CSToastMaxHeight           = 0.8;              // 80% of parent view height
static const CGFloat CSToastHorizontalPadding   = 15.0;
static const CGFloat CSToastCornerRadius        = 4.0;              //圆角弧度
static const CGFloat CSToastOpacity             = 0.7;
static const CGFloat CSToastFontSize            = 15.0;
static const CGFloat CSToastMaxTitleLines       = 0;
static const CGFloat CSToastMaxMessageLines     = 0;
static const CGFloat CSToastVerticalPadding     = 15.0;

static const NSTimeInterval CSToastFadeDuration     = 0.2;
static const NSTimeInterval CSToastDefaultDuration  = 3.0;              //toast 默认显示时间
static const BOOL CSToastHidesOnTap = YES;                              //excludes activity views

static const BOOL CSToastDisplayShadow          = NO;              //是否显示阴影
static const CGFloat CSToastShadowOpacity       = 0.8;              //阴影圆角弧度
static const CGSize  CSToastShadowOffset        = { 2.0, 2.0 };

// image view size
static const CGFloat CSToastImageViewWidth      = 18.0;
static const CGFloat CSToastImageViewHeight     = 18.0;

// associative reference keys
static const NSString *CSToastTimerKey = @"CSToastTimerKey";
static const NSString * CSToastActivityViewKey  = @"CSToastActivityViewKey";
static const NSString *CSToastTapCallbackKey = @"CSToastTapCallbackKey";

//默认activity设置
static const CGFloat CSToastActivityWidth       = 58.0;
static const CGFloat CSToastActivityHeight      = 58.0;
static const NSString * CSToastActivityDefaultPosition = @"center";

// positions
NSString * const CSToastPositionTop             = @"top";
NSString * const CSToastPositionCenter          = @"center";
NSString * const CSToastPositionBottom          = @"bottom";

@implementation UIView (KenView)

#pragma mark - 点击及长按事件
- (void)clicked:(nonnull void(^)(UIView *view))clicked {
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerTapGestureKey);
    
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        if ([self isMemberOfClass:[UILabel class]] || [self isMemberOfClass:[UIImageView class]]) {
            self.userInteractionEnabled = YES;
        }
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kDTActionHandlerTapBlockKey, clicked, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        void(^action)(UIView *) = objc_getAssociatedObject(self, &kDTActionHandlerTapBlockKey);
        if (action) {
            action(self);
        }
    }
}

- (void)longPressed:(nonnull void(^)(UIView *view))longPressed {
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerLongPressGestureKey);
    
    if (!gesture) {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForLongPressGesture:)];
        if ([self isMemberOfClass:[UILabel class]] || [self isMemberOfClass:[UIImageView class]]) {
            self.userInteractionEnabled = YES;
        }
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kDTActionHandlerLongPressBlockKey, longPressed, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForLongPressGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        void(^action)(UIView *) = objc_getAssociatedObject(self, &kDTActionHandlerLongPressBlockKey);
        if (action) {
            action(self);
        }
    }
}

#pragma mark - frame相关属性
- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGSize)size {
    return self.frame.size;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGFloat)originX {
    return self.frame.origin.x;
}

- (CGFloat)originY {
    return self.frame.origin.y;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setOrigin:(CGPoint)point {
    [self setFrame:(CGRect){point, self.size}];
}

- (void)setOriginX:(CGFloat)x {
    [self setFrame:(CGRect){x, self.originY, self.size}];
}

- (void)setOriginY:(CGFloat)y {
    [self setFrame:(CGRect){self.originX, y, self.size}];
}

- (void)setSize:(CGSize)size {
    [self setFrame:(CGRect){self.origin, size}];
}

- (void)setWidth:(CGFloat)width {
    [self setFrame:(CGRect){self.origin, width, self.height}];
}

- (void)setHeight:(CGFloat)height {
    [self setFrame:(CGRect){self.origin, self.width, height}];
}

- (void)setCenterX:(CGFloat)x {
    self.center = CGPointMake(x, [self centerY]);
}

- (void)setCenterY:(CGFloat)y {
    self.center = CGPointMake([self centerX], y);
}

#pragma mark - toast
- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:CSToastDefaultDuration position:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    UIView *toast = [self viewForMessage:message title:nil image:nil];
    [self showToast:toast duration:duration position:position];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title {
    UIView *toast = [self viewForMessage:message title:title image:nil];
    [self showToast:toast duration:duration position:position];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:nil image:image];
    [self showToast:toast duration:duration position:position];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration  position:(id)position title:(NSString *)title
            image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToast:toast duration:duration position:position];
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast duration:CSToastDefaultDuration position:nil];
}

- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position {
    [self showToast:toast duration:duration position:position tapCallback:nil];
}

- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position
      tapCallback:(void(^)(void))tapCallback
{
    toast.center = [self centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;
    
    if (CSToastHidesOnTap) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    
    [self addSubview:toast];
    
    [UIView animateWithDuration:CSToastFadeDuration delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                         // associate the timer with the toast view
                         objc_setAssociatedObject (toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject (toast, &CSToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}

- (void)hideToast:(UIView *)toast {
    [UIView animateWithDuration:CSToastFadeDuration delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                     }];
}

#pragma mark - Events
- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self hideToast:(UIView *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &CSToastTimerKey);
    [timer invalidate];
    
    void (^callback)(void) = objc_getAssociatedObject(self, &CSToastTapCallbackKey);
    if (callback) {
        callback();
    }
    [self hideToast:recognizer.view];
}

#pragma mark - Helpers
- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast {
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:CSToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.height / 2) + CSToastVerticalPadding);
        } else if([point caseInsensitiveCompare:CSToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.height / 2)) - CSToastVerticalPadding);
}

- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize
          lineBreakMode:(NSLineBreakMode)lineBreakMode {
    if ([string respondsToSelector:@selector(sizeWithFont: constrainedToSize: lineBreakMode:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        CGSize rect = [string sizeWithFont:font constrainedToSize:constrainedSize  lineBreakMode:lineBreakMode];
        return CGSizeMake(ceilf(rect.width), ceilf(rect.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [string sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
}

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;
    
    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = CSToastCornerRadius;
    
    if (CSToastDisplayShadow) {
        wrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
        wrapperView.layer.shadowOpacity = CSToastShadowOpacity;
        wrapperView.layer.shadowRadius = CSToastCornerRadius;
        wrapperView.layer.shadowOffset = CSToastShadowOffset;
    }
    
    wrapperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity];
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(CSToastHorizontalPadding, CSToastVerticalPadding, CSToastImageViewWidth, CSToastImageViewHeight);
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = CSToastHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = CSToastMaxTitleLines;
        titleLabel.font = [UIFont boldSystemFontOfSize:CSToastFontSize];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeTitle = [self sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = CSToastMaxMessageLines;
        messageLabel.font = [UIFont boldSystemFontOfSize:CSToastFontSize];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeMessage = [self sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];//跟进去
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = CSToastVerticalPadding;
        titleLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;
    
    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
        messageTop = titleTop + titleHeight + CSToastVerticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    
    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (CSToastHorizontalPadding * 2)), (longerLeft + longerWidth + CSToastHorizontalPadding));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + CSToastVerticalPadding), (imageHeight + (CSToastVerticalPadding * 2)));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    
    if(titleLabel != nil) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, titleWidth, titleHeight);
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}

#pragma mark - ToastActivity
- (void)makeToastActivity {
    [self makeToastActivity:CSToastActivityDefaultPosition];
}

- (void)makeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;


    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = CSToastCornerRadius;

    if (CSToastDisplayShadow) {
        activityView.layer.shadowColor = [UIColor blackColor].CGColor;
        activityView.layer.shadowOpacity = CSToastShadowOpacity;
        activityView.layer.shadowRadius = CSToastCornerRadius;
        activityView.layer.shadowOffset = CSToastShadowOffset;
    }

    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

    // associate the activity view with self
    objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addSubview:activityView];

    [UIView animateWithDuration:CSToastFadeDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        activityView.alpha = 1.0;
    } completion:nil];
}

- (void)hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:CSToastFadeDuration delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
        animations:^{
            existingActivityView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [existingActivityView removeFromSuperview];
            objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
    }
}

#pragma mark - 震动
static NSString * const kenViewShakerAnimationKey = @"kenViewShakerAnimationKey";

- (void)shake {
    [self shakeWithDuration:0.5 completion:nil];
}

- (void)shakeWithDuration:(NSTimeInterval)duration completion:(void (^)())completion {
    self.completionBlock = completion;
    [self addShakeAnimation:duration];
}

- (void)addShakeAnimation:(NSTimeInterval)duration {
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = self.transform.tx;
    
    animation.delegate = self;
    animation.duration = duration;
    animation.values = @[ @(currentTx), @(currentTx + 15), @(currentTx-12), @(currentTx + 12), @(currentTx - 8), @(currentTx + 8), @(currentTx) ];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:kenViewShakerAnimationKey];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if (self.completionBlock) {
        self.completionBlock();
    }
}

#pragma mark - 加虚线
- (void)drawDashLine:(NSArray *)lineDash lineColor:(UIColor *)lineColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:CGPointMake(self.width / 2, self.height)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:self.height];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:lineDash];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, self.width, 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [self.layer addSublayer:shapeLayer];
}

- (void)showCornerWithPoint:(CGPoint)point color:(UIColor *)color {
    [self hideCorner];
    
    UIView *corner = [[UIView alloc] initWithFrame:(CGRect){point, 8, 8}];
    corner.backgroundColor = color;
    corner.tag = 10123;
    corner.layer.cornerRadius = 4;
    corner.layer.masksToBounds = YES;
    
    [self addSubview:corner];
}

- (void)hideCorner {
    UIView *corner = [self viewWithTag:10123];
    if (corner) {
        [corner removeFromSuperview];
        corner = nil;
    }
}

- (UIImage *)transformToImage {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - getter setter
static const void *completionBlockKey = &completionBlockKey;

- (animationCompletionBlock)completionBlock {
    return objc_getAssociatedObject(self, completionBlockKey);
}

- (void)setCompletionBlock:(animationCompletionBlock)completionBlock {
    objc_setAssociatedObject(self, completionBlockKey, completionBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
