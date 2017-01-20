//
//  UIImage+KenImage.m
//  achr
//
//  Created by Ken.Liu on 16/5/13.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIImage+KenImage.h"
#import "KenFileManager.h"
#import "Weakify.h"
#import "NSString+KenString.h"

@implementation UIImage (KenImage)

- (UIImage *)imgScaleWithSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:(CGRect){CGPointZero, size}];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)createThumbImage:(CGSize )thumbSize percent:(float)percent toPath:(NSString *)thumbPath {
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat scaleFactor = 0.0;
    CGPoint thumbPoint = CGPointMake(0.0,0.0);
    CGFloat widthFactor = thumbSize.width / width;
    CGFloat heightFactor = thumbSize.height / height;
    if (widthFactor > heightFactor) {
        scaleFactor = widthFactor;
    } else {
        scaleFactor = heightFactor;
    }
    
    CGFloat scaledWidth = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    if (widthFactor > heightFactor) {
        thumbPoint.y = (thumbSize.height - scaledHeight) * 0.5;
    } else if (widthFactor < heightFactor) {
        thumbPoint.x = (thumbSize.width - scaledWidth) * 0.5;
    }
    
    UIGraphicsBeginImageContext(thumbSize);
    CGRect thumbRect = CGRectZero;
    thumbRect.origin = thumbPoint;
    thumbRect.size.width = scaledWidth;
    thumbRect.size.height = scaledHeight;
    [self drawInRect:thumbRect];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, percent);
    
    [KenFileManager writeFile:thumbPath contents:thumbImageData append:NO];
    return thumbImage;
}

- (BOOL)writeFileWithPath:(NSString*)aPath {
    if ([NSString isEmpty:aPath])
        return NO;
    
    aPath = [KenFileManager fullDocumentFileName:aPath];
    
    @try {
        
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
        if ([ext isEqualToString:@"png"]) {
            imageData = UIImagePNGRepresentation(self);
        } else {
            imageData = UIImageJPEGRepresentation(self, 1.0);
        }
#pragma clang diagnostic pop
        
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        
        if ([KenFileManager isFileExists:aPath]) {
            [KenFileManager removeFile:aPath];
        }
        
        [imageData writeToFile:aPath atomically:YES];
        
        return YES;
    } @catch (NSException *e) {
        KenCategoryLog("create thumbnail exception.");
    }
    
    return NO;
}

#pragma mark - 静态方法
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imageWithUIView:(UIView*)view {
    if (view) {
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(view.bounds.size);
        CGContextRef currnetContext = UIGraphicsGetCurrentContext();
        [view.layer renderInContext:currnetContext];
        // 从当前context中创建一个改变大小后的图片
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        return image;
    } else {
        return nil;
    }
}

- (void)saveImageToPhotos:(id)target sel:(SEL)sel {
    UIImageWriteToSavedPhotosAlbum(self, target, sel, NULL);
}

#pragma mark - 二维码
typedef NS_ENUM(NSInteger, QRCorrectionLevel) {
    QRCorrectionLevelL = 7,  //
    QRCorrectionLevelM = 15, //
    QRCorrectionLevelQ = 25, //
    QRCorrectionLevelH = 30, //
};

+ (UIImage *)QRCodeImageWithText:(NSString *)text QRCodeSize:(CGSize)QRCodeSize icon:(UIImage *)icon {
    CIImage *image = [self createQRCodeImage:text withLevel:QRCorrectionLevelH];
//    UIImage *highImage = [self createNonInterpolatedUIImageFormCIImage:image withSize:QRCodeSize.width];

    //对图片做简单高清处理//
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
    UIImage *qrImage = [UIImage imageWithCIImage:image];
    if (icon == nil) {
        return qrImage;
//        return highImage;
    }
    return [self mergeImageWith:qrImage icon:icon iconSize:icon.size];
}

+ (UIImage *)QRCodeImageWithText:(NSString *)text QRCodeSize:(CGSize)QRCodeSize icon:(UIImage *)icon iconSize:(CGSize)iconSize {
    CIImage *image = [self createQRCodeImage:text withLevel:QRCorrectionLevelM];
    //    UIImage *highImage = [self createNonInterpolatedUIImageFormCIImage:image withSize:QRCodeSize.width];
    
    //对图片做简单高清处理//
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
    UIImage *qrImage = [UIImage imageWithCIImage:image];
    
    if (icon == nil) {
        return qrImage;
        //        return highImage;
    }
    
    return [self mergeImageWith:qrImage icon:icon iconSize:iconSize];
}

+ (CIImage *)createQRCodeImage:(NSString*)str withLevel:(QRCorrectionLevel)level {
    // 1. 实例化一个滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 1.1 设置filter的默认值
    // 因为之前如果使用过滤镜，输入有可能会被保留，因此，在使用滤镜之前，最好设置恢复默认值
    [filter setDefaults];
    
    // 2. 将传入的字符串转换为NSData
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 3. 将NSData传递给滤镜(通过KVC的方式，设置inputMessage)
    [filter setValue:data forKey:@"inputMessage"];
    
    // 4. 纠错等级 L: 7%   M: 15%   Q: 25%   H: 30%
    switch (level) {
        case QRCorrectionLevelL:
            [filter setValue:@"L" forKey:@"inputCorrectionLevel"];
            break;
        case QRCorrectionLevelM:
            [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
            break;
        case QRCorrectionLevelQ:
            [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
            break;
        case QRCorrectionLevelH:
            [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
            break;
        default:
            break;
    }
    
    // 5. 由filter输出图像
    CIImage *outputImage = [filter outputImage];
    
    // 6. 将CIImage转换为UIImage
    //[UIImage imageWithCIImage:outputImage];
    
    return outputImage;
}

/**
 * 根据二维码图片和icon图片生成一张二维码图片。
 */
+ (UIImage *)mergeImageWith:(UIImage *)image icon:(UIImage *)icon iconSize:(CGSize)size {
    if(fabs([[UIScreen mainScreen] scale]) != 1){
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(image.size);
    }
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGFloat iconW = size.width;
    CGFloat iconH = size.height;
    CGFloat iconX = (image.size.width - iconW) * 0.5;
    CGFloat iconY = (image.size.height - iconH) * 0.5;
    [icon drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    UIImage *mergeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mergeImage;
}

/**
 * 生成一张size尺寸的高清图片。
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
