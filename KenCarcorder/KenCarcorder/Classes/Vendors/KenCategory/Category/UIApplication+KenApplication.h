//
//  UIApplication+KenApplication.h
//  achr
//
//  Created by Ken.Liu on 16/9/27.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (KenApplication)

//震动手机
+ (void)shakePhone;

/**
 *  拨打电话
 *
 *  @param controller 产生动作的 controller
 *  @param phone      电话号码
 */
+ (void)callPhone:(UIViewController *)controller phoneNumber:(NSString *)phone;

/**
 *  调用qq
 *
 *  @param controller 产生动作的 controller
 *  @param qq         qq
 */
+ (void)callQQ:(UIViewController *)controller qq:(NSString *)qq;

/**
 *  检查图片是否被PS过
 *
 *  @param path 图片资源完整路径
 *  @param key  要排查的关键字
 *
 *  @return 如果被ps过则返回匹配的Key，否则返回nil
 */
+ (NSString *)checkPicturePS:(NSString *)path key:(NSArray *)key;

+ (NSString *)checkPicturePSWithData:(NSData *)data key:(NSArray *)key;

@end
