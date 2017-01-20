//
//  KenKVOManager.m
//
//  Created by Ken.Liu on 16/1/5.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenKVOManager.h"
#import "KenKVOInfo.h"
#import "KenKVOPlugin.h"

#import <libkern/OSAtomic.h>
#import <objc/message.h>

@implementation KenKVOManager
{
    NSHashTable *_infos;
    OSSpinLock _lock;
}

+ (instancetype)sharedInstance
{
    static KenKVOManager *_manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KenKVOManager alloc] init];
    });
    
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    
    if (nil != self) {
        NSHashTable *infos = [NSHashTable alloc];
        _infos = [infos initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        _lock = OS_SPINLOCK_INIT;
    }
    
    return self;
}

- (NSString *)debugDescription
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
    
    OSSpinLockLock(&_lock);
    
    NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:_infos.count];
    for (KenKVOInfo *info in _infos) {
        [infoDescriptions addObject:info.debugDescription];
    }
    
    [s appendFormat:@" contexts:%@", infoDescriptions];
    
    OSSpinLockUnlock(&_lock);
    
    [s appendString:@">"];
    
    return s;
}

- (void)observe:(id)object info:(KenKVOInfo *)info
{
    if (nil == info) {
        return;
    }
    
    OSSpinLockLock(&_lock);
    [_infos addObject:info];
    OSSpinLockUnlock(&_lock);
    
    [object addObserver:self forKeyPath:info.keyPath options:info.options context:(void *)info];
}

- (void)unobserve:(id)object info:(KenKVOInfo *)info
{
    if (nil == info) {
        return;
    }
    
    OSSpinLockLock(&_lock);
    [_infos removeObject:info];
    OSSpinLockUnlock(&_lock);
    
    [object removeObserver:self forKeyPath:info.keyPath context:(void *)info];
}

- (void)unobserve:(id)object infos:(NSSet *)infos
{
    if (0 == infos.count) {
        return;
    }
    
    OSSpinLockLock(&_lock);
    for (KenKVOInfo *info in infos) {
        [_infos removeObject:info];
    }
    OSSpinLockUnlock(&_lock);
    
    for (KenKVOInfo *info in infos) {
        [object removeObserver:self forKeyPath:info.keyPath context:(void *)info];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    KenKVOInfo *info;
    {
        OSSpinLockLock(&_lock);
        info = [_infos member:(__bridge id)context];
        OSSpinLockUnlock(&_lock);
    }
    
    if (nil != info) {
        KenKVOPlugin *manager = info.manager;
        if (nil != manager) {
            id observer = manager.observer;
            if (nil != observer) {
                if (info.notificationBlock) {
                    info.notificationBlock(observer, object, info.keyPath, change);
                } else if (info.action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [observer performSelector:info.action withObject:change withObject:object];
#pragma clang diagnostic pop
                } else {
                    [observer observeValueForKeyPath:keyPath ofObject:object change:change context:info->_context];
                }
            }
        }
    }
}

@end
