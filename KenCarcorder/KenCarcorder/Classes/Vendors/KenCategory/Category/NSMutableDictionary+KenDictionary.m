//
//  NSMutableDictionary+KenDictionary.m
//  achr
//
//  Created by Ken.Liu on 16/6/30.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSMutableDictionary+KenDictionary.h"
#import "NSObject+KenObject.h"

@implementation NSMutableDictionary (KenDictionary)

#pragma mark - safe
- (void)KenRemoveObjectForKey:(id)aKey {
    if (!aKey) {
        [self logWarning:@"removeObjectForKey: ==> key is nil"];
        return;
    }
    [self KenRemoveObjectForKey:aKey];
}

- (void)KenSetObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (!anObject) {
        [self logWarning:@"setObject:forKey: ==> object is nil"];
        return;
    }
    
    if (!aKey) {
        [self logWarning:@"setObject:forKey: ==> key is nil"];
        return;
    }
    [self KenSetObject:anObject forKey:aKey];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        @autoreleasepool {
            [self swizzleMethod:@selector(KenRemoveObjectForKey:) tarClass:@"__NSDictionaryM" tarSel:@selector(removeObjectForKey:)];
            [self swizzleMethod:@selector(KenSetObject:forKey:) tarClass:@"__NSDictionaryM" tarSel:@selector(setObject:forKey:)];
        }
    });
}

@end
