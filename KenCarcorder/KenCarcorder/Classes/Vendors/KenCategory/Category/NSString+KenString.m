//
//  NSString+KenString.m
//  achr
//
//  Created by Ken.Liu on 16/5/13.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSString+KenString.h"
#import "NSObject+KenObject.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (KenString)

#pragma mark - 字符串加解密
- (NSString *)md5 {
    const char* cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    char *resultData = malloc(CC_MD5_DIGEST_LENGTH * 2 + 1);
    
    for (uint index = 0; index < CC_MD5_DIGEST_LENGTH; index++) {
        resultData[index * 2] = HexEncodeChars[(result[index] >> 4)];
        resultData[index * 2 + 1] = HexEncodeChars[(result[index] % 0x10)];
    }
    resultData[CC_MD5_DIGEST_LENGTH * 2] = 0;
    
    NSString *resultString = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    free(resultData);
    
    return resultString;
}

- (NSString *)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *resultString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02x", digest[i]];
    }
    
    return resultString;
}

- (NSString *)base64Encode {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)base64Decode {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - 字符操作
- (NSString *)substringFromIndex:(int)beginIndex toIndex:(int)endIndex {
    if (endIndex <= beginIndex) {
        return @"";
    }
    NSRange range = NSMakeRange(beginIndex, endIndex - beginIndex);
    return [self substringWithRange:range];
}

- (NSArray<NSString *> *)split:(NSString *)separator {
    return [self componentsSeparatedByString:separator];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSInteger)indexOfChar:(unichar)ch {
    return [self indexOfChar:ch fromIndex:0];
}

- (NSInteger)indexOfChar:(unichar)ch fromIndex:(NSInteger)index {
    if (index < 0) {
        return -1;
    }
    NSInteger len = self.length;
    
    for (NSInteger i = index; i < len; ++i) {
        if (ch == [self characterAtIndex:i]) {
            return i;
        }
    }
    
    return -1;
}

- (NSInteger)indexOfString:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    if (range.location == NSNotFound) {
        return -1;
    }
    
    return range.location;
}

- (NSInteger)indexOfString:(NSString *)string fromIndex:(NSInteger)index {
    if (index < 0) {
        return -1;
    }
    
    NSRange fromRange = NSMakeRange(index, self.length - index);
    NSRange range = [self rangeOfString:string options:NSLiteralSearch range:fromRange];
    if (range.location == NSNotFound) {
        return -1;
    }
    
    return range.location;
}

- (NSInteger)lastIndexOfChar:(unichar)ch {
    return [self lastIndexOfChar:ch fromIndex:0];
}

- (NSInteger)lastIndexOfChar:(unichar)ch fromIndex:(NSInteger)index {
    if (index < 0) {
        return -1;
    }
    
    NSInteger len = self.length;
    for (NSInteger i = len-1; i >= index; --i) {
        if (ch == [self characterAtIndex:i]) {
            return i;
        }
    }
    
    return -1;
}

- (NSInteger)lastIndexOfString:(NSString *)string {
    NSRange range = [self rangeOfString:string options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return -1;
    }
    
    return range.location;
}

- (NSInteger)lastIndexOfString:(NSString *)string fromIndex:(NSInteger)index {
    if (index < 0) {
        return -1;
    }
    
    NSRange fromRange = NSMakeRange(index, self.length - index);
    NSRange range = [self rangeOfString:string options:NSBackwardsSearch range:fromRange];
    if (range.location == NSNotFound) {
        return -1;
    }
    
    return range.location;
}

- (BOOL)equalsIgnoreCase:(NSString *)string {
    return [self.lowercaseString isEqualToString:string.lowercaseString];
}

#pragma mark - 字符转换相关
- (NSArray *)utf8Words
{
#if ! __has_feature(objc_arc)
    NSMutableArray *words = [[[NSMutableArray alloc] init] autorelease];
#else
    NSMutableArray *words = [[NSMutableArray alloc] init];
#endif
    
    const char *str = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *word;
    for (int i = 0; i < strlen(str);) {
        int len = 0;
        if (str[i] >= 0xFFFFFFFC) {
            len = 6;
        } else if (str[i] >= 0xFFFFFFF8) {
            len = 5;
        } else if (str[i] >= 0xFFFFFFF0) {
            len = 4;
        } else if (str[i] >= 0xFFFFFFE0) {
            len = 3;
        } else if (str[i] >= 0xFFFFFFC0) {
            len = 2;
        } else if (str[i] >= 0x00) {
            len = 1;
        }
        
        word = malloc(sizeof(char) * (len + 1));
        for (int j = 0; j < len; j++) {
            word[j] = str[j + i];
        }
        word[len] = '\0';
        i = i + len;
        
        NSString *oneWord = [NSString stringWithCString:word encoding:NSUTF8StringEncoding];
        free(word);
        [words addObject:oneWord];
    }
    
    return words;
}

- (NSString *)urlEncode {
    return (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) self, NULL,
                                                                         (__bridge CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                         kCFStringEncodingUTF8);
}

- (NSString *)urlDecode {
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef) result,
                                                                                         CFSTR(""), kCFStringEncodingUTF8);
}

- (NSURL *)toUrl {
    if ([NSString isUrl:self]) {
        NSURL *result = [NSURL URLWithString:self];
        if (!result) {
            result = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (!result) {
            result = [NSURL URLWithString:@""];
        }
        
        return result;
    }
    return [NSURL URLWithString:@""];
}

- (nullable NSString *)stringUrlWithParams:(nullable NSString *)params, ... {
    if ([NSString isEmpty:self]) {
        return nil;
    }
    
    va_list argList;
    NSString *param;
    va_start(argList, params);
    
    if ([self indexOfString:@"?"] == -1) {
        param = [@"?" stringByAppendingFormat:@"%@&", params];
    } else {
        param = [@"&" stringByAppendingFormat:@"%@&", params];
    }
    
    while (1) {
        id value = va_arg(argList, id);
        if ([value isKindOfClass:[NSString class]]) {
            param = [param stringByAppendingFormat:@"%@&", value];
        }
        if (value == nil) {
            break;
        }
    }
    
    va_end(argList);
    
    return [self stringByAppendingString:[param substringToIndex:param.length - 1]];
}

- (nonnull NSAttributedString *)toAttributedStringByHTMLTags:(nullable UIFont *)defaultFont defaultColor:(NSString *)color {
    NSError *err = nil;
    
    if (!defaultFont) {
        defaultFont = [UIFont systemFontOfSize:14];
    }
    NSString *html = [self stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;color:%@}</style>",
                                                    defaultFont.fontName, defaultFont.pointSize, color]];
    NSAttributedString *result = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                                                            NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                       documentAttributes:nil error:&err];
    if (err) {
        result = [[NSAttributedString alloc] initWithString:@""];
    }
    return result;
}

+ (NSString *)transformFullwidthHalfwidth:(NSString *)full {
    if ([NSString isFullwidth:full]) {
        NSMutableString *convertedString = [full mutableCopy];
        //全角转半角用kCFStringTransformFullwidthHalfwidth    半角转全角用kCFStringTransformHiraganaKatakana
        CFStringTransform((CFMutableStringRef)convertedString, NULL, kCFStringTransformFullwidthHalfwidth, false);
        return convertedString;
    } else {
        return full;
    }
}

#pragma mark - 字体相关
- (CGSize)sizeForFont:(UIFont *)font {
    return [self sizeWithAttributes:@{NSFontAttributeName:font}];
}

- (CGFloat)heightForFont:(UIFont *)font {
    return [self sizeForFont:font].height;
}

- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    
    return result;
}

#pragma mark - 特殊字符判断
+ (BOOL)isNotEmpty:(NSString *)value {
    return ![NSString isEmpty:value];
}

+ (BOOL)isEmpty:(NSString *)value {
    if (value) {
        if ([self isEqual:[NSNull null]]) {
            return YES;
        }
        
        NSString *trimedString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return ([trimedString length] == 0);
    } else {
        return YES;
    }
}

+ (BOOL)isUrl:(NSString *)url {
    if (url) {
        NSRegularExpression *regularexpressionURL = [[NSRegularExpression alloc]
                                                     initWithPattern:@"(https?|ftp|file|achr|cw)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]"
                                                     options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numberofMatchURL = [regularexpressionURL numberOfMatchesInString:url options:NSMatchingAnchored
                                                                              range:NSMakeRange(0, url.length)];
        return (numberofMatchURL > 0);
    } else {
        return NO;
    }
}

+ (BOOL)isEmail:(NSString *)email {
    if (email) {
        NSString *emailRegex = @"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:email];
    } else {
        return NO;
    }
}

+ (BOOL)isIdCard:(NSString *)card {
    if (card) {
        return [card isIdCard];
    } else {
        return NO;
    }
}

- (BOOL)isIdCard {
    //判断位数
    if ([self length] != 18) {
        return NO;
    }
    
    //change x to X
    NSString *tmpID  = self.uppercaseString;
    NSString *cardID = tmpID;
    
    long lSumQT = 0;
    //加权因子
    int R[] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    //校验码
    unsigned char sChecker[11] = {'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    //将15位身份证号转换成18位
    NSMutableString *mString = [NSMutableString stringWithString:tmpID];
    if ([tmpID length] == 15) {
        [mString insertString:@"19" atIndex:6];
        
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i = 0; i <= 16; i++) {
            p += (pid[i]-48) * R[i];
        }
        
        int o = p % 11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        cardID = mString;
    }
    
    //判断地区码
    NSString * sProvince = [cardID substringToIndex:2];
    if (![self idAreaCode:sProvince]) {
        return NO;
    }
    
    //判断年月日是否有效
    int strYear = [[cardID substringFromIndex:6 toIndex:10] intValue];
    int strMonth = [[cardID substringFromIndex:10 toIndex:12] intValue];
    int strDay = [[cardID substringFromIndex:12 toIndex:14] intValue];
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]  ;
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:localZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    if (date == nil) {
        return NO;
    }
    
    const char *charID  = [cardID UTF8String];
    
    //检验长度
    if( 18 != strlen(charID)) return -1;
    //校验数字
    for (int i=0; i<18; i++) {
        if ( !isdigit(charID[i]) && !(('X' == charID[i] || 'x' == charID[i]) && 17 == i) ) {
            return NO;
        }
    }
    
    //验证最末的校验码
    for (int i=0; i<=16; i++) {
        lSumQT += (charID[i]-48) * R[i];
    }
    
    if (sChecker[lSumQT%11] != charID[17] ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)idAreaCode:(NSString *)code {
    NSDictionary *areaCodeDic = @{@"11":@"北京", @"12":@"天津", @"13":@"河北", @"14":@"山西", @"15":@"内蒙古", @"21":@"辽宁",
                                  @"22":@"吉林", @"23":@"黑龙江", @"31":@"上海", @"32":@"江苏", @"33":@"浙江", @"34":@"安徽",
                                  @"35":@"福建", @"36":@"江西", @"37":@"山东", @"41":@"河南", @"42":@"湖北", @"43":@"湖南",
                                  @"44":@"广东", @"45":@"广西", @"46":@"海南", @"50":@"重庆", @"51":@"四川", @"52":@"贵州",
                                  @"53":@"云南", @"54":@"西藏", @"61":@"陕西", @"62":@"甘肃", @"63":@"青海", @"64":@"宁夏",
                                  @"65":@"新疆", @"71":@"台湾", @"81":@"香港", @"82":@"澳门", @"91":@"国外"};
    
    return ([areaCodeDic objectForKey:code] != nil);
}

+ (BOOL)isInt:(NSString *)value {
    if (value) {
        NSScanner *scan = [NSScanner scannerWithString:value];
        int val;
        return[scan scanInt:&val] && [scan isAtEnd];
    } else {
        return NO;
    }
}

+ (BOOL)isContentsOfNumChar:(NSString *)value {
    if ([NSString checkWithRegularStr:value regularStr:@"^[A-Za-z0-9]+$"]) {
        if ([NSString checkWithRegularStr:value regularStr:@"^[0-9]*$"] ||
            [NSString checkWithRegularStr:value regularStr:@"^[A-Za-z]+$"]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

+ (BOOL)checkWithRegularStr:(NSString *)string regularStr:(NSString *)regular {
    NSRegularExpression *regularexpressionURL = [[NSRegularExpression alloc] initWithPattern:regular
                                                 options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatchURL = [regularexpressionURL numberOfMatchesInString:string options:NSMatchingAnchored
                                                                          range:NSMakeRange(0, string.length)];
    return (numberofMatchURL > 0);
}

+ (BOOL)isFullwidth:(NSString *)value {
    if (value) {
        const char *p = [value UTF8String];
        
        // 判断是不是全角字符
        if ((*p) & 0x80) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark - 从Html字符串中获取纯文本字符串

+ (NSString *)getStrFromHtmlString:(NSString *)htmlString {
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]
                                           initWithData:[htmlString dataUsingEncoding:
                                                         NSUnicodeStringEncoding]
                                           options:@{
                                                     NSDocumentTypeDocumentAttribute:
                                                         NSHTMLTextDocumentType
                                                     }
                                           documentAttributes:nil error:nil];
    NSString *str = [attrStr string];
    return str;
}

#pragma mark - safe code
- (NSString *)KenSubstringFromIndex:(NSUInteger)from {
    if ([self length] < from) {
        [self logWarning:[@"substringFromIndex: ==>" stringByAppendingFormat:@"from[%ld] > length[%ld]",(long)from ,(long)[self length]]];
        return nil;
    }
    
    return [self KenSubstringFromIndex:from];
}

- (NSString *)KenSubstringToIndex:(NSUInteger)to {
    if ([self length] < to) {
        [self logWarning:[@"substringToIndex: ==>" stringByAppendingFormat:@"to[%ld] > length[%ld]",(long)to ,(long)[self length]]];
        return nil;
    }
    
    return [self KenSubstringToIndex:to];
}

- (NSString *)KenSubstringWithRange:(NSRange)range {
    if ([self length] < range.location) {
        [self logWarning:[@"substringWithRange: ==>" stringByAppendingFormat:@"location[%ld] > length[%ld]",
                          (long)range.location ,(long)[self length]]];
        return nil;
    }
    
    if ([self length] < range.location + range.length) {
        [self logWarning:[@"substringWithRange: ==>" stringByAppendingFormat:@"length[%ld] > length[%ld]",
                          (long)range.location + range.length, (long)[self length]]];
        return nil;
    }
    
    return [self KenSubstringWithRange:range];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        @autoreleasepool {
            [self swizzleMethod:@selector(KenSubstringFromIndex:) tarClass:@"__NSCFString" tarSel:@selector(substringFromIndex:)];
            [self swizzleMethod:@selector(KenSubstringToIndex:) tarClass:@"__NSCFString" tarSel:@selector(substringToIndex:)];
            [self swizzleMethod:@selector(KenSubstringWithRange:) tarClass:@"__NSCFString" tarSel:@selector(substringWithRange:)];
        }
    });
}
@end
