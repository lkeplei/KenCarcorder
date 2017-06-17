//
//  KenPageControl.h
//
//
//  Created by ken on 15/4/30.
//  Copyright (c) 2015年 TBJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KenPageControl : UIPageControl

- (instancetype)initWithActiveImg:(CGRect)frame activeImg:(NSString *)activeImg inactiveImg:(NSString *)inactiveImg;

@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, strong) UIImage *inactiveImage;

@end
