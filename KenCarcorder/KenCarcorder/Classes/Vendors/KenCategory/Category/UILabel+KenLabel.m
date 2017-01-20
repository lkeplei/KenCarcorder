//
//  UILabel+KenLabel.m
//  achr
//
//  Created by Ken.Liu on 15/12/21.
//  Base on Tof Templates
//  Copyright © 2015年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UILabel+KenLabel.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark Category KenLabel for UILabel 
#pragma mark -

@implementation UILabel (KenLabel)

+ (UILabel*)labelWithTxt:(NSString *)text frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color {
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    if (color) {
        label.textColor = color;
    } else {
        label.textColor = [UIColor whiteColor];
    }
    
    return label;
}

+ (KenHtmlLabel *)htmlLabelWithTxt:(NSString *)text frame:(CGRect)frame font:(UIFont*)font color:(UIColor*)color {
    KenHtmlLabel *label = [[KenHtmlLabel alloc] initWithFrame:frame];
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    if (color) {
        label.textColor = color;
    } else {
        label.textColor = [UIColor whiteColor];
    }
    
    label.htmlText = text;
    
    return label;
}

+ (UILabel*)labelWithConerRadius:(CGFloat)radius text:(NSString *)text frame:(CGRect)frame font:(UIFont*)font
                           color:(UIColor*)color bgColor:(UIColor *)bgColor {
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    
    if (color) {
        label.textColor = color;
    } else {
        label.textColor = [UIColor whiteColor];
    }
    
    if (bgColor) {
        label.backgroundColor = bgColor;
    } else {
        label.backgroundColor = [UIColor clearColor];
    }
    
    label.layer.cornerRadius = radius;
    label.layer.masksToBounds = YES;
    
    return label;
}

- (void)setLineSpacing:(NSUInteger)lineSpacing {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:lineSpacing];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
    self.attributedText = attributedString;
}

@end
