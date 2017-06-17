//
//  KenPageControl.m
//  
//
//  Created by ken on 15/4/30.
//  Copyright (c) 2015年 TBJ. All rights reserved.
//

#import "KenPageControl.h"

@implementation KenPageControl

- (instancetype)initWithActiveImg:(CGRect)frame activeImg:(NSString *)activeImg inactiveImg:(NSString *)inactiveImg {
    self = [super initWithFrame:frame];
    if (self) {
        _activeImage = [UIImage imageNamed:activeImg];
        _inactiveImage = [UIImage imageNamed:inactiveImg];
    }
    return self;
}

- (void)updateDots {
    for (int i = 0; i < [self.subviews count]; i++) {
        if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIView class]]) {
            UIView* dot = [self.subviews objectAtIndex:i];
            [[dot subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            if (i == self.currentPage) {
                [dot addSubview:[[UIImageView alloc] initWithImage:_activeImage]];
            } else {
                [dot addSubview:[[UIImageView alloc] initWithImage:_inactiveImage]];
            }
        } else if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIImageView class]]) {
            UIImageView* dot = [self.subviews objectAtIndex:i];
            if (i == self.currentPage) {
                dot.image = _activeImage;
            } else {
                dot.image = _inactiveImage;
            }
        }
    }
}

- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    
    if (_activeImage) {
        [self updateDots];
    }
}

@end
