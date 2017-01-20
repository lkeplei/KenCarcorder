//
//  UIBarButtonItem+KenBadge.m
//  achr
//
//  Created by Ken.Liu on 16/6/1.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <objc/runtime.h>

#import "UIBarButtonItem+KenBadge.h"

NSString const *UIBarButtonItem_badgeKey                 = @"UIBarButtonItem_badgeKey";

NSString const *UIBarButtonItem_badgeBGColorKey          = @"UIBarButtonItem_badgeBGColorKey";
NSString const *UIBarButtonItem_badgeTextColorKey        = @"UIBarButtonItem_badgeTextColorKey";
NSString const *UIBarButtonItem_badgeBorderColorKey      = @"UIBarButtonItem_badgeBorderColorKey";
NSString const *UIBarButtonItem_badgeFontKey             = @"UIBarButtonItem_badgeFontKey";
NSString const *UIBarButtonItem_badgePaddingKey          = @"UIBarButtonItem_badgePaddingKey";
NSString const *UIBarButtonItem_badgeBorderWidthKey      = @"UIBarButtonItem_badgeBorderWidthKey";
NSString const *UIBarButtonItem_badgeMinSizeKey          = @"UIBarButtonItem_badgeMinSizeKey";
NSString const *UIBarButtonItem_badgeOriginXKey          = @"UIBarButtonItem_badgeOriginXKey";
NSString const *UIBarButtonItem_badgeOriginYKey          = @"UIBarButtonItem_badgeOriginYKey";
NSString const *UIBarButtonItem_shouldHideBadgeAtZeroKey = @"UIBarButtonItem_shouldHideBadgeAtZeroKey";
NSString const *UIBarButtonItem_shouldAnimateBadgeKey    = @"UIBarButtonItem_shouldAnimateBadgeKey";
NSString const *UIBarButtonItem_badgeValueKey            = @"UIBarButtonItem_badgeValueKey";
NSString const *UIBarButtonItem_badgeStyleKey            = @"UIBarButtonItem_badgeStyleKey";

@implementation UIBarButtonItem (KenBadge)

- (void)badgeInit {
    self.badgeStyle               = KenBarButtonItemBadgeNumber;
    self.badgeBGColor             = [UIColor redColor];
    self.badgeTextColor           = [UIColor whiteColor];
    self.badgeBorderColor         = [UIColor whiteColor];
    self.badgeFont                = [UIFont systemFontOfSize:10.0];
    self.badgeBorderWidth         = 1;
    self.badgePadding             = 1;
    self.badgeMinSize             = 4;
    self.badgeOriginX             = self.customView.frame.size.width - self.badge.frame.size.width/2;
    self.badgeOriginY             = -4;
    self.shouldHideBadgeAtZero    = YES;
    self.shouldAnimateBadge       = YES;
    self.customView.clipsToBounds = NO;
}

- (void)refreshBadge {
    self.badge.textColor        = self.badgeTextColor;
    self.badge.backgroundColor  = self.badgeBGColor;
    self.badge.font             = self.badgeFont;
}

- (CGSize) badgeExpectedSize {
    UILabel *frameLabel = [self duplicateLabel:self.badge];
    [frameLabel sizeToFit];
    
    CGSize expectedLabelSize = frameLabel.frame.size;
    return expectedLabelSize;
}

- (void)updateBadgeFrame {
    if (self.badgeStyle == KenBarButtonItemBadgeNumber) {
        CGSize expectedLabelSize = [self badgeExpectedSize];
        CGFloat minHeight = expectedLabelSize.height;
        
        minHeight = (minHeight < self.badgeMinSize) ? self.badgeMinSize : expectedLabelSize.height;
        CGFloat minWidth = expectedLabelSize.width;
        CGFloat padding = self.badgePadding;
        
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
        self.badge.frame = CGRectMake(self.badgeOriginX, self.badgeOriginY, minWidth + padding, minHeight + padding);
        self.badge.layer.cornerRadius = (minHeight + padding) / 2;
        self.badge.layer.masksToBounds = YES;
        self.badge.layer.borderColor = [UIColor whiteColor].CGColor;
        self.badge.layer.borderWidth = self.badgeBorderWidth;
    } else if (self.badgeStyle == KenBarButtonItemBadgeDot) {
        self.badge.frame = CGRectMake(self.badgeOriginX, self.badgeOriginY, 8, 8);
        self.badge.layer.cornerRadius = 4;
        self.badge.layer.masksToBounds = YES;
        self.badge.layer.borderColor = [UIColor whiteColor].CGColor;
        self.badge.layer.borderWidth = self.badgeBorderWidth;
    }
}

- (void)updateBadgeValueAnimated:(BOOL)animated {
    if (animated && self.shouldAnimateBadge && ![self.badge.text isEqualToString:self.badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4f :1.3f :1.f :1.f]];
        [self.badge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    
    self.badge.text = self.badgeValue;
    
    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        [self updateBadgeFrame];
    }];
}

- (UILabel *)duplicateLabel:(UILabel *)labelToCopy {
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    
    return duplicateLabel;
}

- (void)removeBadge {
    [UIView animateWithDuration:0.2 animations:^{
        self.badge.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.badge removeFromSuperview];
        self.badge = nil;
    }];
}

- (UILabel*)badge {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeKey);
}

- (void)setBadge:(UILabel *)badgeLabel {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeKey, badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KenBarButtonItemBadgeType)badgeStyle {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeStyleKey);
    return (KenBarButtonItemBadgeType)number.integerValue;
}

- (void)setBadgeStyle:(KenBarButtonItemBadgeType)badgeStyle {
    NSNumber *number = [NSNumber numberWithInteger:(NSInteger)badgeStyle];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeStyleKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        if (badgeStyle==KenBarButtonItemBadgeDot) {
            self.badgeFont = [UIFont systemFontOfSize:0];
        }
        [self updateBadgeFrame];
    }
}

- (NSString *)badgeValue {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeValueKey);
}

- (void)setBadgeValue:(NSString *)badgeValue {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeValueKey, badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!self.badge) {
        self.badge                      = [[UILabel alloc] initWithFrame:CGRectMake(self.badgeOriginX, self.badgeOriginY, 20, 20)];
        self.badge.textColor            = self.badgeTextColor;
        self.badge.backgroundColor      = self.badgeBGColor;
        self.badge.font                 = self.badgeFont;
        self.badge.textAlignment        = NSTextAlignmentCenter;
        [self badgeInit];
        [self.customView addSubview:self.badge];
        [self updateBadgeValueAnimated:NO];
    }
    
    if (!badgeValue || [badgeValue isEqualToString:@""] || ([badgeValue isEqualToString:@"0"] && self.shouldHideBadgeAtZero)) {
        [self.badge setHidden:YES];
    } else {
        [self.badge setHidden:NO];
        [self updateBadgeValueAnimated:YES];
    }
}

- (UIColor *)badgeBGColor {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey);
}

- (void)setBadgeBGColor:(UIColor *)badgeBGColor {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey, badgeBGColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

- (UIColor *)badgeBorderColor {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeBorderColorKey);
}

- (void)setBadgeBorderColor:(UIColor *)badgeBorderColor {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeBGColorKey, badgeBorderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

- (UIColor *)badgeTextColor {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeTextColorKey);
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

- (UIFont *)badgeFont {
    return objc_getAssociatedObject(self, &UIBarButtonItem_badgeFontKey);
}

- (void)setBadgeFont:(UIFont *)badgeFont {
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeFontKey, badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self refreshBadge];
    }
}

- (CGFloat)badgePadding {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgePaddingKey);
    return number.floatValue;
}

- (void)setBadgePadding:(CGFloat)badgePadding {
    NSNumber *number = [NSNumber numberWithDouble:badgePadding];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgePaddingKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

- (CGFloat)badgeBorderWidth {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeBorderWidthKey);
    return number.floatValue;
}

- (void)setBadgeBorderWidth:(CGFloat)badgeBorderWidth {
    NSNumber *number = [NSNumber numberWithDouble:badgeBorderWidth];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeBorderWidthKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

- (CGFloat)badgeMinSize {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeMinSizeKey);
    return number.floatValue;
}

- (void)setBadgeMinSize:(CGFloat)badgeMinSize {
    NSNumber *number = [NSNumber numberWithDouble:badgeMinSize];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeMinSizeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

- (CGFloat)badgeOriginX {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey);
    return number.floatValue;
}

- (void)setBadgeOriginX:(CGFloat)badgeOriginX {
    NSNumber *number = [NSNumber numberWithDouble:badgeOriginX];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginXKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

- (CGFloat)badgeOriginY {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_badgeOriginYKey);
    return number.floatValue;
}

- (void)setBadgeOriginY:(CGFloat)badgeOriginY {
    NSNumber *number = [NSNumber numberWithDouble:badgeOriginY];
    objc_setAssociatedObject(self, &UIBarButtonItem_badgeOriginYKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badge) {
        [self updateBadgeFrame];
    }
}

- (BOOL)shouldHideBadgeAtZero {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_shouldHideBadgeAtZeroKey);
    return number.boolValue;
}

- (void)setShouldHideBadgeAtZero:(BOOL)shouldHideBadgeAtZero {
    NSNumber *number = [NSNumber numberWithBool:shouldHideBadgeAtZero];
    objc_setAssociatedObject(self, &UIBarButtonItem_shouldHideBadgeAtZeroKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldAnimateBadge {
    NSNumber *number = objc_getAssociatedObject(self, &UIBarButtonItem_shouldAnimateBadgeKey);
    return number.boolValue;
}

- (void)setShouldAnimateBadge:(BOOL)shouldAnimateBadge {
    NSNumber *number = [NSNumber numberWithBool:shouldAnimateBadge];
    objc_setAssociatedObject(self, &UIBarButtonItem_shouldAnimateBadgeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
