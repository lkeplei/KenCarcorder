//
//  KenTabBar.m
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenTabBar.h"
#import "KenDeallocMonitor.h"
#import "KenTabBarItem.h"
#import "KenTabBarConfig.h"

@interface KenTabBar ()

@property (copy, nonatomic) NSArray *tabbarItems;
@property (weak, nonatomic) UIButton *centerItem;
@property (copy, nonatomic) NSString *centerItemTitle;
@property (strong, nonatomic) UIView *slider;
@property (assign, nonatomic) CGFloat evenItemWidth;
@property (assign, nonatomic) NSUInteger centerItemIndex;

@end

@implementation KenTabBar

#pragma mark - Factory
+ (instancetype)tabBarWithCenterItem:(UIButton *)centerItem {
    KenTabBar *tabBar = [[KenTabBar alloc] init];
    tabBar.centerItem = centerItem;
#if SliderVisible
    [tabBar setupSlider];
#endif
    [KenDeallocMonitor addMonitorToObj:tabBar];

    return tabBar;
}

#pragma mark - Override Methods
- (void)setItems:(NSArray *)items {
    [self setItems:items animated:NO];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
    if (self.tabbarItems.count > 0) {
        return;
    }
    
    if (items.count > 0) {
        if (_tabbarItems.count) {
            for (UIButton *bt in _tabbarItems) {
                [bt removeFromSuperview];
            }
        }
        self.tabbarItems = items;
    }
}

#pragma mark - event
- (void)userClickedItem:(id)sender {
    NSInteger index = [_tabbarItems indexOfObject:sender];
    
    if (index != NSNotFound) {
        self.selectedItemIndex = index;
        
        if ([_tabBarDelegate respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
            [_tabBarDelegate tabBar:self didSelectItemAtIndex:index];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.clipsToBounds && !self.hidden && self.alpha>0.0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [self convertPoint:point toView:subview];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result) {
                return result;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - public method
- (void)insertCenterItem:(UIButton *)centerItem {
    if (centerItem) {
        self.centerItem = centerItem;
        // trigger layoutSubview in case changing centerItem after UITabBarController viewDidLayoutSubviews finished
        [self layoutIfNeeded];
    }
}

- (void)setItemTitleColor:(UIColor *)normalColor selColor:(UIColor *)selColor {
    if (normalColor == nil || selColor == nil) {
        return;
    }
    
    for (UIView *item in [self subviews]) {
        if (([item isKindOfClass:[KenTabBarItem class]])) {
            [(KenTabBarItem *)item setItemTitleColor:normalColor selColor:selColor];
        }
    }
}

- (void)setItemBadge:(NSUInteger)index badge:(NSString *)badge {
    NSArray *subviews = [self subviews];
    NSUInteger currentIndex = 0;
    for (NSInteger i = 0; i < subviews.count; i++) {
        KenTabBarItem *item = [subviews objectAtIndex:i];
        if (([item isKindOfClass:[KenTabBarItem class]])) {
            if (currentIndex == index) {
                [item updateBadgeValue:badge];
                break;
            }
            currentIndex++;
        }
    }
}

#pragma mark - Setter & Getter
- (void)setTabbarItems:(NSArray *)tabbarItems {
    if (tabbarItems.count > 0) {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:tabbarItems.count];
        for (UITabBarItem *item in tabbarItems) {
            if ([item isKindOfClass:[UITabBarItem class]]) {
                KenTabBarItem *tabBarItem = [KenTabBarItem itemWithTabbarItem:item];
                
                [tabBarItem addTarget:self action:@selector(userClickedItem:) forControlEvents:UIControlEventTouchUpInside];
                [temp addObject:tabBarItem];
                [self addSubview:tabBarItem];
            }
        }
        _tabbarItems = [temp copy];
    }
}

- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex {
    if (selectedItemIndex<_tabbarItems.count) {
        KenTabBarItem *lastItem = _tabbarItems[_selectedItemIndex];
        KenTabBarItem *curItem = _tabbarItems[selectedItemIndex];
        
        lastItem.selected = NO;
        curItem.selected = YES;
        
        _selectedItemIndex = selectedItemIndex;
        [self slideToIndex:_selectedItemIndex];
    }
}

- (void)setCenterItem:(UIButton *)centerItem {
    if (centerItem) {
        if (_centerItem) {
            [_centerItem removeFromSuperview];
        }
        _centerItem = centerItem;
        [self addSubview:_centerItem];
    }
}

#pragma mark - Slider
- (void)setupSlider {
    self.slider = [[UIView alloc] init];
#ifdef SliderColor
    _slider.backgroundColor = SliderColor;
#else
    _slider.backgroundColor = [UIColor lightGrayColor];
#endif
    [self addSubview:_slider];
}

- (void)slideToIndex:(NSUInteger)index {
    if (_slider && index < _tabbarItems.count) {
        
        BOOL hasCenterItem = _centerItem != nil;
        BOOL overCenterIndex = index >= _centerItemIndex;
        
        CGFloat fromX = _slider.frame.origin.x;
        CGFloat toX = hasCenterItem&&overCenterIndex ? (index+1)*_evenItemWidth : index*_evenItemWidth;
        if (fromX == toX) { return; }
        
        CGRect toFrame = _slider.frame;
        toFrame.origin.x = toX;
        
        CGFloat damping = 0.7;
#ifdef SliderDamping
        damping = SliderDamping;
#endif
        [UIView animateWithDuration:0.33 delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:0
                         animations:^ {
                             _slider.frame = toFrame;
                         } completion:nil];
    }
}

#pragma mark - Layout

#ifdef TabBarHeight
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = [super sizeThatFits:size];
    newSize.height = TabBarHeight;
    return newSize;
}
#endif

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL hasCenterItem = _centerItem != nil;
    BOOL hasAtLeastFiveItems = _tabbarItems.count >= 5;
    
    if (hasCenterItem && hasAtLeastFiveItems) {
        NSLog(@"You have more than 5 items! Only 5 items will be set up!");
    }
    
    CGFloat barWidth = self.frame.size.width;
    CGFloat barHeight = self.frame.size.height;
    CGFloat itemWidth = hasCenterItem ? barWidth/(_tabbarItems.count + 1) : (barWidth/_tabbarItems.count);
    if (!_evenItemWidth) { self.evenItemWidth = itemWidth; }
    
    NSUInteger centerIndex = hasAtLeastFiveItems ? 2 : _tabbarItems.count / 2;
    if (!_centerItemIndex) { self.centerItemIndex = centerIndex; }
    
    if (hasCenterItem) {
        CGFloat centerItemHeight = [_centerItem imageForState:UIControlStateNormal].size.height;
        
        if (_centerItem.titleLabel.text > 0) {// reposition the iamge and title of centerItem
            
            // titleHeight should be equal to other item's
            CGFloat titleHeight = ceilf(self.frame.size.height * (1-ItemImageHeightRatio));
            centerItemHeight += titleHeight;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([_centerItem respondsToSelector:@selector(alignImageAndTitleVertically)]) {
                [_centerItem performSelector:@selector(alignImageAndTitleVertically)];
            }
#pragma clang diagnostic pop
        }
        centerItemHeight = centerItemHeight<barHeight ? barHeight : centerItemHeight;
        
        CGFloat centerItemX = centerIndex * itemWidth;
        CGFloat centerItemY = centerItemHeight>barHeight ? (barHeight-centerItemHeight) : 0;
        
#ifdef CenterItemYAsixOffset
        centerItemY += CenterItemYAsixOffset;
#endif
        _centerItem.frame = CGRectMake(centerItemX, centerItemY, itemWidth, centerItemHeight);
    }
    
    NSUInteger numOfItems = hasAtLeastFiveItems ? 5 : _tabbarItems.count;
    for (int i = 0; i < numOfItems; i++) {
        KenTabBarItem *item = _tabbarItems[i];
        CGFloat itemX = (hasCenterItem && i>=centerIndex) ? itemWidth*(i+1) : itemWidth*i;
        item.frame = CGRectMake(itemX, 0, itemWidth, barHeight);
    }
    
    if (_slider) {
        CGFloat sliderX = _selectedItemIndex * itemWidth;
        _slider.frame = CGRectMake(sliderX, 0, itemWidth, barHeight);
    }
}

@end

#pragma mark - UIButton + VerticalLayout

@interface UIButton (VerticalLayout)

- (void)alignImageAndTitleVertically;

@end

@implementation UIButton (VerticalLayout)

- (void)alignImageAndTitleVertically {
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    
    // A positive value shrinks, or insets, that edge—moving it closer to the center of the button. A negative value expands, or outsets, that edge.
    
    self.imageEdgeInsets = UIEdgeInsetsMake(-titleSize.height, 0, 0, -titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -imageSize.height, 0);
}

@end
