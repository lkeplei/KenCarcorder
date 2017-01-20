//
//  NSMutableString+KenString.m
//  achr
//
//  Created by Ken.Liu on 16/6/30.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSMutableString+KenString.h"
#import "NSObject+KenObject.h"

@implementation NSMutableString (KenString)

#pragma mark - safe
- (void)KenAppendString:(NSString *)aString {
    if (!aString) {
        [self logWarning:@"appendString: ==> aString is nil"];
        return;
    }
    [self KenAppendString:aString];
}

- (void)KenAppendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    if (!format) {
        [self logWarning:@"appendFormat: ==> aString is nil"];
        return;
    }
    va_list arguments;
    va_start(arguments, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:arguments];
    [self KenAppendFormat:@"%@",formatStr];
    va_end(arguments);
}

- (void)KenSetString:(NSString *)aString {
    if (!aString) {
        [self logWarning:@"setString: ==> aString is nil"];
        return;
    }
    [self KenSetString:aString];
}

- (void)KenInsertString:(NSString *)aString atIndex:(NSUInteger)index {
    if (index > [self length]) {
        [self logWarning:[@"insertString:atIndex: ==>" stringByAppendingFormat:@"index[%ld] >= length[%ld]",(long)index ,(long)[self length]]];
        return;
    }
    if (!aString) {
        [self logWarning:@"insertString:atIndex: ==> aString is nil"];
        return;
    }
    
    [self KenInsertString:aString atIndex:index];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        @autoreleasepool {
            [self swizzleMethod:@selector(KenAppendString:) tarClass:@"__NSCFConstantString" tarSel:@selector(appendString:)];
            [self swizzleMethod:@selector(KenAppendFormat:) tarClass:@"__NSCFConstantString" tarSel:@selector(appendFormat:)];
            [self swizzleMethod:@selector(KenSetString:) tarClass:@"__NSCFConstantString" tarSel:@selector(setString:)];
            [self swizzleMethod:@selector(KenInsertString:atIndex:) tarClass:@"__NSCFConstantString" tarSel:@selector(insertString:atIndex:)];
        }
    });
}

@end
