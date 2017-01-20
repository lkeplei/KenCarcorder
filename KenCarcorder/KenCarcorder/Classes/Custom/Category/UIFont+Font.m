//
//  UIFont+Font.m
//
//
//  Created by Ken.Liu on 2016/11/21.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "UIFont+Font.h"

#define fontIsIPhone4               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),[[UIScreen mainScreen] currentMode].size): NO)
#define fontIsIPhone5               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136),[[UIScreen mainScreen] currentMode].size) : NO)


@implementation UIFont (Font)

+ (UIFont *)appFontSize17 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 17 : 19];
}

+ (UIFont *)appFontSize16 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 16 : 17];
}

+ (UIFont *)appFontSize15 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 15 : 16];
}

+ (UIFont *)appFontSize14 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 14 : 15];
}

+ (UIFont *)appFontSize13 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 13 : 14];
}

+ (UIFont *)appFontSize12 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 12 : 13];
}

+ (UIFont *)appFontSize11 {
    return [UIFont systemFontOfSize:(fontIsIPhone4 | fontIsIPhone5) ? 11 : 12];
}

+ (UIFont *)appFontSize10 {
    return [UIFont systemFontOfSize:10];
}

+ (CGFloat)appFontHeight10 {
    return 12.;
}

+ (CGFloat)appFontHeight11 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 14. : 15.;
}

+ (CGFloat)appFontHeight12 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 15. : 16.;
}

+ (CGFloat)appFontHeight13 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 16. : 17.;
}

+ (CGFloat)appFontHeight14 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 17. : 18.;
}

+ (CGFloat)appFontHeight15 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 18. : 20.;
}

+ (CGFloat)appFontHeight16 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 20. : 21.;
}

+ (CGFloat)appFontHeight17 {
    return (fontIsIPhone4 | fontIsIPhone5) ? 21. : 24.;
}

@end
