//
//  KenKVOInfo.m
//  
//
//  Created by Ken.Liu on 16/1/5.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenKVOInfo.h"

#pragma mark - 内部函数
static NSString *describe_option(NSKeyValueObservingOptions option)
{
    switch (option) {
        case NSKeyValueObservingOptionNew:
            return @"NSKeyValueObservingOptionNew";
            break;
        case NSKeyValueObservingOptionOld:
            return @"NSKeyValueObservingOptionOld";
            break;
        case NSKeyValueObservingOptionInitial:
            return @"NSKeyValueObservingOptionInitial";
            break;
        case NSKeyValueObservingOptionPrior:
            return @"NSKeyValueObservingOptionPrior";
            break;
        default:
            return nil;
            break;
    }
}

static void append_option_description(NSMutableString *s, NSUInteger option)
{
    if (0 == s.length) {
        [s appendString:describe_option(option)];
    } else {
        [s appendString:@"|"];
        [s appendString:describe_option(option)];
    }
}

static NSUInteger enumerate_flags(NSUInteger *ptrFlags)
{
    NSCAssert(ptrFlags, @"ptrFlags 参数非法");
    if (!ptrFlags) {
        return 0;
    }
    
    NSUInteger flags = *ptrFlags;
    if (!flags) {
        return 0;
    }
    
    NSUInteger flag = 1 << __builtin_ctzl(flags);
    flags &= ~flag;
    *ptrFlags = flags;
    return flag;
}

static NSString *describe_options(NSKeyValueObservingOptions options)
{
    NSMutableString *s = [NSMutableString string];
    
    NSUInteger option;
    while (0 != (option = enumerate_flags(&options))) {
        append_option_description(s, option);
    }
    
    return s;
}

@implementation KenKVOInfo
- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                          block:(KVONotificationBlock)block action:(SEL)action context:(void *)context
{
    self = [super init];
    if (nil != self) {
        _manager = manager;
        _notificationBlock = [block copy];
        _keyPath = [keyPath copy];
        _options = options;
        _action = action;
        _context = context;
    }
    return self;
}

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                          block:(KVONotificationBlock)block
{
    return [self initWithManager:manager keyPath:keyPath options:options block:block action:NULL context:NULL];
}

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                         action:(SEL)action
{
    return [self initWithManager:manager keyPath:keyPath options:options block:NULL action:action context:NULL];
}

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                        context:(void *)context
{
    return [self initWithManager:manager keyPath:keyPath options:options block:NULL action:NULL context:context];
}

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath
{
    return [self initWithManager:manager keyPath:keyPath options:0 block:NULL action:NULL context:NULL];
}

- (NSUInteger)hash
{
    return [_keyPath hash] | [_notificationBlock hash];
}

- (BOOL)isEqual:(id)object
{
    if (nil == object) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [_keyPath isEqualToString:((KenKVOInfo *)object)->_keyPath];
}

- (NSString *)debugDescription
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@", NSStringFromClass([self class]), self, _keyPath];
    if (0 != _options) {
        [s appendFormat:@" options:%@", describe_options(_options)];
    }
    if (NULL != _action) {
        [s appendFormat:@" action:%@", NSStringFromSelector(_action)];
    }
    if (NULL != _context) {
        [s appendFormat:@" context:%p", _context];
    }
    if (NULL != _notificationBlock) {
        [s appendFormat:@" block:%p", _notificationBlock];
    }
    [s appendString:@">"];
    return s;
}
@end
