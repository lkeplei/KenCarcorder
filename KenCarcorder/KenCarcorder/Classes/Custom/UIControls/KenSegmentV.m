//
//  KenSegmentV.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenSegmentV.h"

@interface KenSegmentV ()

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation KenSegmentV

- (instancetype)initWithItem:(NSArray *)array frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _itemArray = [NSMutableArray array];
        _selectedIndex = -1;
        
        [self updateItems:array];
    }
    return self;
}

#pragma mark - private method
- (void)updateItems:(NSArray *)array {
    CGFloat width = self.width / array.count;
    
    @weakify(self)
    for (NSUInteger i = 0; i < array.count; i++) {
        KenSegmentItemV *item = [[KenSegmentItemV alloc] initWithTitle:array[i] frame:(CGRect){width * i, 0, width, self.height}];
        item.tag = i;
        [_itemArray addObject:item];
        [self addSubview:item];
        
        [item clicked:^(UIView * _Nonnull view) {
            @strongify(self)
            self.selectedIndex = view.tag;
        }];
    }
    
    self.selectedIndex = 0;
}

#pragma mark - getter setter 
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex != _selectedIndex && selectedIndex < _itemArray.count) {
        if (_selectedIndex >= 0) {
            ((KenSegmentItemV *)[_itemArray objectAtIndex:_selectedIndex]).status = kKenSegmentItemNormal;
        }
        
        _selectedIndex = selectedIndex;
        ((KenSegmentItemV *)[_itemArray objectAtIndex:_selectedIndex]).status = kKenSegmentItemSelected;
        
        SafeHandleBlock(self.segmentSelectChanged, _selectedIndex)
    }
}

@end


#pragma mark - item
@interface KenSegmentItemV ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KenSegmentItemV

- (instancetype)initWithTitle:(NSString *)title frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = title;
        self.status = kKenSegmentItemNormal;
    }
    return self;
}

- (void)setStatus:(KenSegmentItemStatus)status {
    _status = status;
    
    if (self.status == kKenSegmentItemNormal) {
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor appMainColor];
    } else if (self.status == kKenSegmentItemSelected) {
        self.titleLabel.backgroundColor = [UIColor appMainColor];
        self.titleLabel.textColor = [UIColor appWhiteTextColor];
    }
}

#pragma mark - getter setter
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel labelWithTxt:@"" frame:(CGRect){5, 5, self.width - 10, self.height - 10} font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _titleLabel.layer.cornerRadius = 3;
        _titleLabel.layer.masksToBounds = YES;
        
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
