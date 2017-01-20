//
//  UIImage+KenImage.h
//  achr
//
//  Created by Ken.Liu on 16/5/13.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (KenImage)

/**
 *  图片缩放
 *
 *  @param size 尺寸
 */
- (UIImage *)imgScaleWithSize:(CGSize)size;
- (UIImage *)createThumbImage:(CGSize )thumbSize percent:(float)percent toPath:(NSString *)thumbPath;

/**
 *  保存图片对应的目录
 *
 *  @param aPath 默认保存在document下，path是相对docoment的路径，不是全路径
 *
 *  @return 保存成功返回YES，失败返回NO
 */
- (BOOL)writeFileWithPath:(NSString*)aPath;

/**
 *  保存image到相册
 *
 *  @param target 保存结果回调接收对象
 *  @param sel    结果回调响应SEL
 */
- (void)saveImageToPhotos:(id)target sel:(SEL)sel;

#pragma mark - 静态方法
/**
 *  根据颜色和大小，生一张纯色的图
 *
 *  @param color 颜色
 *  @param size  大小
 *
 *  @return 生成的图
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  把视图直接转换成一张图片
 *
 *  @param view 要转换的视图
 */
+ (UIImage*)imageWithUIView:(UIView*)view;

#pragma mark - 二维码
/**
 *  生成二维码图像
 *
 *  @param text       文字
 *  @param QRCodeSize 要生成的二维码图像尺寸
 *  @param icon       叠加的图标
 *
 *  @return 二维码图像
 */
+ (UIImage *)QRCodeImageWithText:(NSString *)text QRCodeSize:(CGSize)QRCodeSize icon:(UIImage *)icon;
+ (UIImage *)QRCodeImageWithText:(NSString *)text QRCodeSize:(CGSize)QRCodeSize icon:(UIImage *)icon iconSize:(CGSize)iconSize;

@end
