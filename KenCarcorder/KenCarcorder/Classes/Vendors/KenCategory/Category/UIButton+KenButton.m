//
//  UIButton+KenButton.m
//  achr
//
//  Created by Ken.Liu on 15/12/21.
//  Base on Tof Templates
//  Copyright © 2015年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIButton+KenButton.h"
#import "NSObject+KenObject.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark Category KenButton for UIButton 
#pragma mark -

@implementation UIButton (KenButton)

+ (UIButton*)buttonWithImg:(NSString*)buttonText zoomIn:(BOOL)zoomIn image:(UIImage*)image
                  imagesec:(UIImage*)imagesec target:(id)target action:(SEL)action {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];

    if (buttonText != nil) {
        NSString* text = [NSString stringWithFormat:@"%@", buttonText];
        [button setTitle:text forState:UIControlStateNormal];

        if (image == nil && imagesec == nil) {
            NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]],
                            NSFontAttributeName, nil, NSForegroundColorAttributeName, nil];
            CGSize size = [buttonText sizeWithAttributes:attributes];

            button.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        }
    }

    if (zoomIn) {
        [button setImage:image forState:UIControlStateNormal];
        if (imagesec != nil) {
            [button setImage:imagesec forState:UIControlStateHighlighted];
            [button setImage:imagesec forState:UIControlStateSelected];
        }
    } else {
        [button setBackgroundImage:image forState:UIControlStateNormal];
        if (imagesec != nil) {
            [button setBackgroundImage:imagesec forState:UIControlStateHighlighted];
            [button setBackgroundImage:imagesec forState:UIControlStateSelected];
        }
    }

    button.adjustsImageWhenHighlighted = NO;

    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

+ (UIButton*)buttonWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font titleColor:(UIColor *)titleColor
                 normalColor:(UIColor *)normalColor highlightColor:(UIColor *)highlightColor target:(id)target action:(SEL)action  {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.titleLabel.font = font;
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    [button setBackgroundImage:[self imageWithColorToButton:normalColor] forState:UIControlStateNormal];
    if (highlightColor) {
        [button setBackgroundImage:[self imageWithColorToButton:highlightColor] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[self imageWithColorToButton:highlightColor] forState:UIControlStateSelected];
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIImage *)imageWithColorToButton:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



#pragma mark - 透明特殊效果扩展
static const NSString *unTranslucentKey = @"unTranslucentKey";

- (void)KenSetSelected:(BOOL)selected {
    BOOL unTranslucent = objc_getAssociatedObject(self, &unTranslucentKey);
    
    if (!unTranslucent) {
        if (selected) {
            self.alpha = 0.5;
        } else {
            self.alpha = 1;
        }
    }
    
    [self KenSetSelected:selected];
}

- (void)KenSetHighlighted:(BOOL)highlighted {
    BOOL unTranslucent = objc_getAssociatedObject(self, &unTranslucentKey);
    
    if (!unTranslucent) {
        if (highlighted) {
            self.alpha = 0.5;
        } else {
            self.alpha = 1;
        }
    }
    
    [self KenSetHighlighted:highlighted];
}

- (void)KenSetBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
        objc_setAssociatedObject(self, &unTranslucentKey, @YES, OBJC_ASSOCIATION_ASSIGN);
    }
        
    [self KenSetBackgroundImage:image forState:state];
}

- (void)KenSetImage:(UIImage *)image forState:(UIControlState)state {
    if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
        objc_setAssociatedObject(self, &unTranslucentKey, @YES, OBJC_ASSOCIATION_ASSIGN);
    }
    
    [self KenSetImage:image forState:state];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        @autoreleasepool {
            [self swizzleMethod:@selector(KenSetSelected:) tarSel:@selector(setSelected:)];
            [self swizzleMethod:@selector(KenSetHighlighted:) tarSel:@selector(setHighlighted:)];
            [self swizzleMethod:@selector(KenSetBackgroundImage:forState:) tarSel:@selector(setBackgroundImage:forState:)];
            [self swizzleMethod:@selector(KenSetImage:forState:) tarSel:@selector(setImage:forState:)];
        }
    });
}
@end
