//
//  KenAlertView.m
//  KenAlertView
//
//  Created by Ken.Liu on 2016/12/5.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenAlertView.h"

/***** 获取屏幕 宽度、高度 *****/
#define SCREEN_WIDTH                            ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                           ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_BOUNDS                           ([UIScreen mainScreen].bounds)

/***** 设置UI *****/
#define KAlertViewWidth                         270 * SCREEN_WIDTH / 375
#define KButtonHeight                           44
#define Width_Adjust(Value)                     MainScreenWidth * (Value) / 375.0

/***** 设置间距 *****/
#define KMarginLeftSmall                        15
#define KMarginLeftLarge                        30
#define KMarginRightSmall                       15
#define KMarginRightLarge                       30
#define KMarginTop                              30
#define KSpaceSmall                             7
#define KSpaceLarge                             30
#define KMessageLineSpace                       5

/***** 设置字体 *****/
#define KTitleFontSize                          16
#define KMessageFontSize                        16
#define KButtonFontSize                         16

#define RGBA(R, G, B, A) [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:A]


@interface KenAlertView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, copy) AlertViewButtonClickedBlock buttonClickedBlock;


@end


@implementation KenAlertView

+ (void)showAlertViewWithTitle:(NSString *)title contentView:(UIView *)contentView message:(NSString *)message buttonTitles:(NSArray<__kindof NSString *> *)buttonTitles buttonClickedBlock:(AlertViewButtonClickedBlock)buttonClickedBlock {
    KenAlertView *alert = [[KenAlertView alloc] initWithTitle:title contentView:contentView message:message buttonTitles:buttonTitles buttonClickedBlock:buttonClickedBlock];
    [alert show];
}

- (instancetype)initWithTitle:(NSString *)title contentView:(UIView *)contentView message:(NSString *)message buttonTitles:(NSArray *)buttonTitles buttonClickedBlock:(AlertViewButtonClickedBlock)buttonClickedBlock {
    if (self) {
        self = [super initWithFrame:SCREEN_BOUNDS];
        if (buttonTitles.count > 5) {
            return nil;
        }
        _title = title;
        _message = message;
        _contentView = contentView;
        _buttonTitles = buttonTitles;
        _buttonClickedBlock = buttonClickedBlock;
        _buttonArray = [NSMutableArray array];
        
        [self setupCoverView];
        
        [self setupAlertView];
    }
    return self;
}
- (void)setupCoverView {
    _coverView = [[UIView alloc] initWithFrame:self.bounds];
    _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _coverView.alpha = 0;
    [self addSubview:_coverView];
}

- (void)setupAlertView {
    CGFloat alertViewWidth = KAlertViewWidth;
    CGFloat alertViewHeight = KMarginTop;
    
    _alertView = [[UIView alloc] init];
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 5.0f;
    _alertView.layer.masksToBounds = YES;
    
    /***** 设置title *****/
    if (_title != nil && _title.length > 0) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _title;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:KTitleFontSize];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize titleSize = [self getTitleSize];
        
        _titleLabel.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
        _titleLabel.center = CGPointMake(KAlertViewWidth / 2, KMarginTop + titleSize.height / 2);
        
        [_alertView addSubview:_titleLabel];
        
        alertViewHeight += _titleLabel.frame.size.height + KSpaceSmall;
    }
    /***** 设置自定义contentView *****/
    if (_contentView) {
        CGFloat contentViewWidth = (alertViewWidth > _contentView.frame.size.width) ? _contentView.frame.size.width : alertViewWidth;
        _contentView.frame = CGRectMake((KAlertViewWidth - _contentView.frame.size.width) / 2, alertViewHeight, contentViewWidth, _contentView.frame.size.height);
        [_alertView addSubview:_contentView];
        if ([NSString isEmpty:_message]) {
            alertViewHeight += _contentView.frame.size.height + KSpaceLarge;
        } else {
            alertViewHeight += _contentView.frame.size.height + KSpaceSmall;
        }
    }

    /***** 设置消息内容 *****/
    if (_message != nil && _message.length > 0) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = _message;
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:KMessageFontSize];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = KMessageLineSpace;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
        _messageLabel.attributedText = [[NSAttributedString alloc] initWithString:_message attributes:attributes];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        
        CGSize messageSize = [self getMessageSize];
        _messageLabel.frame = CGRectMake(KMarginLeftLarge, alertViewHeight, MAX(alertViewWidth - KMarginLeftLarge - KMarginRightLarge, messageSize.width), messageSize.height);
        
        [_alertView addSubview:_messageLabel];
        alertViewHeight += _messageLabel.frame.size.height + KSpaceLarge;
    }
    
    /***** 设置按钮 *****/
    if (_buttonTitles.count > 0) {
        //添加水平分割线
        UIView *horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, alertViewHeight, alertViewWidth, 1)];
        horizonSperatorView.backgroundColor = RGBA(218, 218, 222, 1.0);
        [_alertView addSubview:horizonSperatorView];
        
        alertViewHeight += horizonSperatorView.frame.size.height;
        /***** 按钮小于等于2是按钮横向排列，按钮数量大于3个，按钮竖向排列 *****/
        if (_buttonTitles.count <= 2) {
            CGFloat buttonWidth = alertViewWidth / _buttonTitles.count;
            for (NSString *buttonTitle in _buttonTitles) {
                NSInteger index = [_buttonTitles indexOfObject:buttonTitle];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(index * buttonWidth, alertViewHeight, buttonWidth, KButtonHeight)];
                button.tag = index;
                button.titleLabel.font = [UIFont systemFontOfSize:KButtonFontSize];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
                [button setTitleColor:RGBA(70, 130, 180, 1.0) forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_buttonArray addObject:button];
                [_alertView addSubview:button];
                //添加竖向分割线
                if (index < _buttonTitles.count - 1) {
                    UIView *verticalSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y, 1, button.frame.size.height)];
                    verticalSeperatorView.backgroundColor = RGBA(218, 218, 222, 1.0);
                    [_alertView addSubview:verticalSeperatorView];
                }
            }
            alertViewHeight += KButtonHeight;
        }
        if (_buttonTitles.count > 2) {
            
            for (NSString *buttonTitle in _buttonTitles) {
                NSInteger index = [_buttonTitles indexOfObject:buttonTitle];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, alertViewHeight, KAlertViewWidth, KButtonHeight)];
                button.tag = index;
                button.titleLabel.font = [UIFont systemFontOfSize:KButtonFontSize];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
                [button setTitleColor:RGBA(70, 130, 180, 1.0) forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_buttonArray addObject:button];
                [_alertView addSubview:button];
                alertViewHeight = alertViewHeight + KButtonHeight;
                //添加水平分割线
                if (index < _buttonTitles.count - 1) {
                    UIView *horizonSperator = [[UIView alloc] initWithFrame:CGRectMake(0, alertViewHeight, alertViewWidth, 1)];
                    horizonSperator.backgroundColor = RGBA(218, 218, 222, 1.0);
                    [_alertView addSubview:horizonSperator];
                    alertViewHeight += horizonSperator.frame.size.height;
                }
            }
        }
    }
    _alertView.frame = CGRectMake(0, 0, alertViewWidth, alertViewHeight);
    _alertView.center = self.center;
    [self addSubview:_alertView];
}

- (void)buttonClicked:(UIButton *)button {
    if (_buttonClickedBlock) {
        _buttonClickedBlock(self, button.tag);
    }
    [self dismiss];
    
}

#pragma mark - show & dismiss
- (void)show {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0) {
        UIView *subView = [windowViews objectAtIndex:[windowViews count]-1];
        for(UIView *aSubView in subView.subviews) {
            [aSubView.layer removeAllAnimations];
        }
        [self showCoverView];
        [self showAlertAnimation];
    }
}

- (void)dismiss {
    _alertView.hidden = YES;
    [self hideAlertAnimation];
    [self removeFromSuperview];
}

- (void)showCoverView {
    _coverView.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _coverView.alpha = 0.5;
    [UIView commitAnimations];
}

- (void)showAlertAnimation {
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.30;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [_alertView.layer addAnimation:animation forKey:nil];
}

- (void)hideAlertAnimation {
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _coverView.alpha = 0.0;
    [UIView commitAnimations];
}

#pragma mark - set
- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _titleLabel.textColor = color;
    }
    if (size > 0) {
        _titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _messageLabel.textColor = color;
    }
    if (size > 0) {
        _messageLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index {
    UIButton *button = _buttonArray[index];
    if (color != nil) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (size > 0) {
        button.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

#pragma mark - tools method
/***** 获取title的大小 *****/
- (CGSize)getTitleSize {
    UIFont *font = [UIFont systemFontOfSize:KTitleFontSize];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [_title boundingRectWithSize:CGSizeMake(KAlertViewWidth - (KMarginLeftSmall + KMarginRightSmall), 2000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes context:nil].size;
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    return size;
}

/***** 获取message的大小 *****/
- (CGSize)getMessageSize {
    UIFont *font = [UIFont systemFontOfSize:KMessageFontSize];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = KMessageLineSpace;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [_message boundingRectWithSize:CGSizeMake(KAlertViewWidth - (KMarginLeftLarge + KMarginRightLarge), 2000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes context:nil].size;
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

@end
