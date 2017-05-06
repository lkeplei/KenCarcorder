//
//  UIColor+KenColor.m
//  KenCategory
//
//  Created by Ken.Liu on 2016/11/3.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "UIColor+KenColor.h"
#import "NSObject+KenObject.h"

@implementation UIColor (KenColor)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    if ([UIApplication isNotEmpty:stringToConvert]) {
        NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 6) return [UIColor grayColor];
        
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"]) {
            cString = [cString substringFromIndex:2];
        }
        
        if ([cString hasPrefix:@"#"]) {
            cString = [cString substringFromIndex:1];
        }
        
        if ([cString length] != 6) {
            return [UIColor grayColor];
        }
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:1.0f];
    } else {
        return nil;
    }
}

#pragma mark - 统一颜色
+ (UIColor *)appBlackTextColor {
    return [UIColor colorWithHexString:@"#4E4E53"];
}

+ (UIColor *)appDarkGrayTextColor {
    return [UIColor colorWithHexString:@"#999999"];
}

+ (UIColor *)appGrayTextColor {
    return [UIColor colorWithHexString:@"#C1C1C1"];
}

+ (UIColor *)appLightGrayTextColor {
    return [UIColor colorWithHexString:@"#DADADA"];
}

+ (UIColor *)appWhiteTextColor {
    return [UIColor colorWithHexString:@"#FFFFFF"];
}

+ (UIColor *)appBackgroundColor {
    return [UIColor colorWithHexString:@"#F1F1F1"];
}

+ (UIColor *)appSepLineColor {
    return [UIColor colorWithHexString:@"#E2E2E2"];
}

+ (UIColor *)appMainColor {
    return [UIColor colorWithHexString:@"#00DEC9"];
}

+ (UIColor *)appStressRedColor {
    return [UIColor colorWithHexString:@"#FE3A39"];
}

+ (UIColor *)appStressYellowColor {
    return [UIColor colorWithHexString:@"#FFD022"];
}

+ (UIColor *)appLinkColor {
    return [UIColor colorWithHexString:@"#00CAFF"];
}

+ (UIColor *)appAssistDarkGreenColor {
    return [UIColor colorWithHexString:@"#00AA6E"];
}

+ (UIColor *)appAssistLightGreenColor {
    return [UIColor colorWithHexString:@"#C2EF06"];
}

+ (UIColor *)appAssistBlackColor {
    return [UIColor colorWithHexString:@"#57575B"];
}

+ (UIColor *)appGreenBtnHighColor {
    return [UIColor colorWithHexString:@"#45BF3C"];
}

+ (UIColor *)appGreenBtnNotEnabledColor {
    return [UIColor colorWithHexString:@"#5DE256"];
}
@end
