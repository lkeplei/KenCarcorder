//
//  KenTabBarItem.m
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenTabBarItem.h"
#import "KenTabBarConfig.h"
#import "KenDeallocMonitor.h"

static void* kFXTabBarItemContext;

@interface KenTabBarItem () {
    UIView *_tinyBadge;
}

@property (strong, nonatomic) UITabBarItem *tabBarItem;
@property (strong, nonatomic) UILabel *badgeLb;

@end

@implementation KenTabBarItem

+ (instancetype)itemWithTabbarItem:(UITabBarItem *)tabBarItem {
    NSParameterAssert(tabBarItem);
    
    KenTabBarItem *item = nil;
    if ([tabBarItem isKindOfClass:[UITabBarItem class]]) {
        item = [KenTabBarItem buttonWithType:UIButtonTypeCustom];
        [KenDeallocMonitor addMonitorToObj:item];
        
        item.imageView.contentMode = UIViewContentModeCenter;
        item.titleLabel.textAlignment = NSTextAlignmentCenter;
        item.backgroundColor = [UIColor clearColor];
        
        // custom configs
#ifdef ItemTitleFontSize
        item.titleLabel.font = [UIFont systemFontOfSize:ItemTitleFontSize];
#endif

//        [item setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [item setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [item addTarget:item action:@selector(userDidClickItem:) forControlEvents:UIControlEventTouchUpInside];
        
        // KVO
        item.tabBarItem = tabBarItem;
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        
        [tabBarItem addObserver:item forKeyPath:NSStringFromSelector(@selector(title)) options:options context:&kFXTabBarItemContext];
        [tabBarItem addObserver:item forKeyPath:NSStringFromSelector(@selector(badgeValue)) options:options context:&kFXTabBarItemContext];
        [tabBarItem addObserver:item forKeyPath:NSStringFromSelector(@selector(image)) options:options context:&kFXTabBarItemContext];
        [tabBarItem addObserver:item forKeyPath:NSStringFromSelector(@selector(selectedImage)) options:options context:&kFXTabBarItemContext];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [tabBarItem addObserver:item forKeyPath:NSStringFromSelector(@selector(tinyBadgeVisible)) options:options context:&kFXTabBarItemContext];
#pragma clang diagnostic pop
    }
    return item;
}

- (void)dealloc {
    [_tabBarItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(badgeValue))];
    [_tabBarItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    [_tabBarItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(image))];
    [_tabBarItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedImage))];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_tabBarItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(tinyBadgeVisible))];
#pragma clang diagnostic pop
}

#pragma mark - Layout
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (!_tabBarItem.title.length) {
        return contentRect;
    }
    
    CGFloat imageWidth = contentRect.size.width;
    CGFloat imageHeight = ceilf(contentRect.size.height*ItemImageHeightRatio);
    return CGRectMake(0, 0, imageWidth, imageHeight);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (!_tabBarItem.title.length) {
        return CGRectZero;
    }
    CGFloat titleY = ceilf(contentRect.size.height*ItemImageHeightRatio);
    CGFloat titleWidth = contentRect.size.width;
//    CGFloat titleHeight = contentRect.size.height - titleY;
    return CGRectMake(0, titleY, titleWidth, 12);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kFXTabBarItemContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(badgeValue))]) {
            [self updateBadgeValue:_tabBarItem.badgeValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(image))]) {
            [self setImage:_tabBarItem.image forState:UIControlStateNormal];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(selectedImage))]) {
            [self setImage:_tabBarItem.selectedImage forState:UIControlStateSelected];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
            if (!_tabBarItem.title.length) { return; }
            
            [self setTitle:_tabBarItem.title forState:UIControlStateNormal];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tinyBadgeVisible))]) {
            if ([_tabBarItem respondsToSelector:@selector(tinyBadgeVisible)]) {
                if ([_tabBarItem performSelector:@selector(tinyBadgeVisible)]) {
                    [self presentTinyBadge];
                } else {
                    [self dismissTinyBadge];
                }
            }
        }
#pragma clang diagnostic pop
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Action
- (void)userDidClickItem:(id)sender {
    self.selected = !self.selected;
}

#pragma mark - Effect
- (void)setHighlighted:(BOOL)highlighted {
    
}

#pragma mark - public method
- (void)setItemTitleColor:(UIColor *)normalColor selColor:(UIColor *)selColor {
    NSDictionary *attrDic = @{NSForegroundColorAttributeName : normalColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:attrDic];
    [self setAttributedTitle:attrStr forState:UIControlStateNormal];

    NSDictionary *_attrDic = @{NSForegroundColorAttributeName : selColor};
    NSAttributedString *_attrStr = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:_attrDic];
    [self setAttributedTitle:_attrStr forState:UIControlStateSelected];
}

#pragma mark - Badge
- (UILabel *)badgeLb {
    if (!_badgeLb) {
        _badgeLb = [UILabel new];
        [KenDeallocMonitor addMonitorToObj:_badgeLb withDesc:@"badgeLabel has been deallocated"];
        _badgeLb.font = [UIFont systemFontOfSize:ItemBadgeFontSize];
        _badgeLb.textColor = [UIColor whiteColor];
        _badgeLb.textAlignment = NSTextAlignmentCenter;
#ifdef BadgeBackgroundColor
        _badgeLb.backgroundColor = BadgeBackgroundColor;
#else
        _badgeLb.backgroundColor = [UIColor redColor];
#endif
        _badgeLb.layer.masksToBounds = YES;
    }
    
    return _badgeLb;
}

- (void)updateBadgeValue:(NSString *)value {
    if (!value || [value isEqualToString:@"0"]) {
        [self removeBadge];
    } else {
        [self refreshBadgeWithValue:value];
    }
}

- (void)refreshBadgeWithValue:(NSString *)value {
    [self dismissTinyBadge];
    
    CGSize badgeSize = [self sizeOfBadgeValue:value];
    
    // Manually triggering FXTabBarView's layoutSubview method in order to get real item frame
    if (self.frame.size.width == 0) {
        [self.superview layoutIfNeeded];
    }
    
    CGFloat badgeX = self.frame.size.width - badgeSize.width;
    CGFloat badgeY = 0;
    
#ifdef BadgeXAsixOffset
    badgeX += BadgeXAsixOffset;
#endif
#ifdef BadgeYAsixOffset
    badgeY += BadgeYAsixOffset;
#endif
    
    if (![self.subviews containsObject:self.badgeLb]) {// not existed
        _badgeLb.frame = CGRectMake(badgeX, badgeY, badgeSize.width, badgeSize.height);
        _badgeLb.layer.cornerRadius = badgeSize.height / 2.0;
        _badgeLb.alpha = 0.0;
        _badgeLb.transform = CGAffineTransformMakeScale(0, 0);
        
        [self addSubview:_badgeLb];
        [UIView animateWithDuration:0.33 delay:0 usingSpringWithDamping:0.66 initialSpringVelocity:1 options:0
                         animations:^ {
                             _badgeLb.alpha = 1.0;
                             _badgeLb.transform = CGAffineTransformIdentity;
                         } completion:nil];
    } else {// if existed, only change the frame of item
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.66 initialSpringVelocity:1 options:0
                         animations:^ {
                             _badgeLb.frame = CGRectMake(badgeX, badgeY, badgeSize.width, badgeSize.height);
                         } completion:nil];
    }
    // update the badge value!
    
#ifdef BadgeValueColor
    NSDictionary *attrDic = @{NSForegroundColorAttributeName: BadgeValueColor};
    self.badgeLb.attributedText = [[NSAttributedString alloc] initWithString:value attributes:attrDic];
#else
    self.badgeLb.text = value;
#endif
}

- (void)removeBadge {
    if (_badgeLb) {
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^ {
                            _badgeLb.transform = CGAffineTransformMakeScale(0, 0);
                            _badgeLb.alpha = 0.5;
                        } completion:^(BOOL finished) {
                            [_badgeLb removeFromSuperview];
                            _badgeLb = nil;
                        }];
    }
}

- (CGSize)sizeOfBadgeValue:(NSString *)value {
    CGSize size = [value sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ItemBadgeFontSize]}];
    
    BOOL addPadding = YES;
    // make sure the item is a round if the length of badge value is too short
    if (size.height > size.width && value.length == 1) {
        size.width = size.height;
        addPadding = NO;
    }
    
    return CGSizeMake(ceilf(size.width + 2 * ItemBadgeHPadding * addPadding), ceilf(size.height));
}

#pragma mark Tiny Badge
- (void)presentTinyBadge {
    [self removeBadge];
    
    if (!_tinyBadge) {
        _tinyBadge = [UIView new];
        [KenDeallocMonitor addMonitorToObj:_tinyBadge withDesc:@"tinyBadge has been deallocated"];
#ifdef TinyBadgeColor
        _tinyBadge.backgroundColor = TinyBadgeColor;
#else
        _tinyBadge.backgroundColor = [UIColor redColor];
#endif
        _tinyBadge.layer.cornerRadius = TinyBadgeRadius;
        
        // locate the tiny badge to the right top corner of the image
        UIImage *image = [self imageForState:UIControlStateNormal];
        CGSize size = image.size;
        
        if (self.frame.size.width == 0) {
            [self.superview layoutIfNeeded];
        }
        CGFloat mX = self.frame.size.width / 2.0; // center X
        CGFloat rX = mX + size.width / 2.0;       // trailing X
        
#ifdef BadgeXAsixOffset
        rX += BadgeXAsixOffset;
#endif
        
        BOOL hasTitle = _tabBarItem.title.length > 0;
        
        CGFloat y0 = hasTitle ? ceilf(self.frame.size.height*ItemImageHeightRatio-size.height) : (self.frame.size.height-size.height)/2.0;
        
#ifdef BadgeYAsixOffset
        y0 += BadgeYAsixOffset;
#endif
        
        CGRect tinyBadgeFrame = {{rX, y0}, TinyBadgeRadius*2.0, TinyBadgeRadius*2.0};
        _tinyBadge.frame = tinyBadgeFrame;
        _tinyBadge.transform = CGAffineTransformMakeScale(0, 0);
        _tinyBadge.alpha = 0.0;
        [self addSubview:_tinyBadge];
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:0
                         animations:^ {
                             _tinyBadge.transform = CGAffineTransformIdentity;
                             _tinyBadge.alpha = 1.0;
                         } completion:nil];
    }
}

- (void)dismissTinyBadge {
    if (_tinyBadge) {
        [UIView animateWithDuration:0.3 animations:^{
            _tinyBadge.alpha = 0.0;
            _tinyBadge.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished){
            [_tinyBadge removeFromSuperview];
            _tinyBadge = nil;
        }];
    }
}

@end




#pragma mark - UITabBarItem + TinyBadge
@implementation UITabBarItem (TinyBadge)

- (void)setTinyBadgeVisible:(BOOL)tinyBadgeVisible {
    if (self.tinyBadgeVisible == tinyBadgeVisible) { return; }
    
    objc_setAssociatedObject(self, @selector(tinyBadgeVisible), @(tinyBadgeVisible), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)tinyBadgeVisible {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

@end
