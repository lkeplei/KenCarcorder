//
//  NSString+KenString.h
//  achr
//
//  Created by Ken.Liu on 16/5/13.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (KenString)

#pragma mark - 字符串加解密
- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)base64Encode;
- (NSString *)base64Decode;

#pragma mark - 字符操作
- (NSString *)substringFromIndex:(int)beginIndex toIndex:(int)endIndex;
- (NSArray<NSString *> *)split:(NSString *)separator;
- (NSString *)trim;

- (NSInteger)indexOfChar:(unichar)ch;
- (NSInteger)indexOfChar:(unichar)ch fromIndex:(NSInteger)index;
- (NSInteger)indexOfString:(NSString *)string;
- (NSInteger)indexOfString:(NSString *)string fromIndex:(NSInteger)index;
- (NSInteger)lastIndexOfChar:(unichar)ch;
- (NSInteger)lastIndexOfChar:(unichar)ch fromIndex:(NSInteger)index;
- (NSInteger)lastIndexOfString:(NSString *)string;
- (NSInteger)lastIndexOfString:(NSString *)string fromIndex:(NSInteger)index;

- (BOOL)equalsIgnoreCase:(NSString *)string;

#pragma mark - 字符转换相关
- (NSArray *)utf8Words;

- (NSString *)urlEncode;
- (NSString *)urlDecode;

- (nullable NSURL *)toUrl;
- (nullable NSString *)stringUrlWithParams:(nullable NSString *)params,... NS_REQUIRES_NIL_TERMINATION;
- (nonnull NSAttributedString *)toAttributedStringByHTMLTags:(nullable UIFont *)defaultFont defaultColor:(NSString *)color;

//全角转半角
+ (NSString *)transformFullwidthHalfwidth:(NSString *)full;

#pragma mark - 字体相关
- (CGSize)sizeForFont:(UIFont *)font;
- (CGFloat)heightForFont:(UIFont *)font;
- (CGFloat)widthForFont:(UIFont *)font;
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

#pragma mark - 特殊字符判断
+ (BOOL)isEmpty:(NSString *)value;
+ (BOOL)isNotEmpty:(NSString *)value;
+ (BOOL)isUrl:(NSString *)url;
+ (BOOL)isEmail:(NSString *)email;
+ (BOOL)isIdCard:(NSString *)card;
+ (BOOL)isInt:(NSString *)value;
+ (BOOL)isContentsOfNumChar:(NSString *)value;

//string是否符合正则规范
+ (BOOL)checkWithRegularStr:(NSString *)string regularStr:(NSString *)regular;

//判断是否为全角字符串
+ (BOOL)isFullwidth:(NSString *)string;

#pragma mark - 从Html字符串中获取纯文本字符串
//通过属性字符串从Html字符串中获取纯文本字符串
+ (NSString *)getStrFromHtmlString:(NSString *)htmlString;

@end

NS_ASSUME_NONNULL_END
