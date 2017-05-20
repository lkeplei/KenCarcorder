//
//  UIColor+KenColor.h
//  KenCategory
//
//  Created by Ken.Liu on 2016/11/3.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (KenColor)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

#pragma mark - 统一颜色
+ (UIColor *)appBlackTextColor;                             //app黑色字颜色
+ (UIColor *)appDarkGrayTextColor;                          //app深灰字颜色
+ (UIColor *)appGrayTextColor;                              //app灰字颜色
+ (UIColor *)appLightGrayTextColor;                         //app浅灰字色
+ (UIColor *)appWhiteTextColor;                             //app白色字色

+ (UIColor *)appBlueTextColor;
+ (UIColor *)appOrangeTextColor;

+ (UIColor *)appBackgroundColor;                            //app背景色
+ (UIColor *)appSepLineColor;                               //app分隔线色

+ (UIColor *)appMainColor;                                  //app主色
+ (UIColor *)appStressRedColor;                             //app强调红色
+ (UIColor *)appStressYellowColor;                          //app强调黄色
+ (UIColor *)appLinkColor;                                  //app链接色

+ (UIColor *)appAssistDarkGreenColor;                       //app辅助深绿色
+ (UIColor *)appAssistLightGreenColor;                      //app辅助浅绿色
+ (UIColor *)appAssistBlackColor;                           //app辅助黑色

+ (UIColor *)appGreenBtnHighColor;                          //app主按钮高亮色
+ (UIColor *)appGreenBtnNotEnabledColor;                    //app主按钮不可点击色

@end
