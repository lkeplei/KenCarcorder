//
//  KenKVOPlugin.m
//
//  Created by Ken.Liu on 16/1/5.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenKVOPlugin.h"
#import "KenKVOInfo.h"
#import "KenKVOManager.h"

#import <libkern/OSAtomic.h>
#import <objc/message.h>

#pragma mark - KenKVOPlugin
@implementation KenKVOPlugin
{
    NSMapTable *_objectInfosMap;
    OSSpinLock _lock;
}

+ (instancetype)managerWithObserver:(id)observer
{
    return [[self alloc] initWithObserver:observer];
}

- (instancetype)initWithObserver:(id)observer retainObserved:(BOOL)retainObserved
{
    self = [super init];
    if (nil != self) {
        _observer = observer;
        NSPointerFunctionsOptions keyOptions = retainObserved ? NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality : NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality;
        _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (instancetype)initWithObserver:(id)observer
{
    return [self initWithObserver:observer retainObserved:YES];
}

- (void)dealloc
{
    [self unobserveAll];
}

- (void)_observe:(id)object info:(KenKVOInfo *)info
{
    OSSpinLockLock(&_lock);
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    if ([infos containsObject:info]) {
        OSSpinLockUnlock(&_lock);
        return;
    }
    if (nil == infos) {
        infos = [NSMutableSet set];
        [_objectInfosMap setObject:infos forKey:object];
    }
    [infos addObject:info];
    
    OSSpinLockUnlock(&_lock);
    
    [[KenKVOManager sharedInstance] observe:object info:info];
}

- (void)_unobserve:(id)object info:(KenKVOInfo *)info
{
    OSSpinLockLock(&_lock);
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    KenKVOInfo *registeredInfo = [infos member:info];
    
    if (nil != registeredInfo) {
        [infos removeObject:registeredInfo];
        if (0 == infos.count) {
            [_objectInfosMap removeObjectForKey:object];
        }
    }
    
    OSSpinLockUnlock(&_lock);
    
    [[KenKVOManager sharedInstance] unobserve:object info:registeredInfo];
}

- (void)_unobserve:(id)object
{
    OSSpinLockLock(&_lock);
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    [_objectInfosMap removeObjectForKey:object];
    
    OSSpinLockUnlock(&_lock);
    
    [[KenKVOManager sharedInstance] unobserve:object infos:infos];
}

- (void)_unobserveAll
{
    OSSpinLockLock(&_lock);
    
    NSMapTable *objectInfoMaps = [_objectInfosMap copy];
    [_objectInfosMap removeAllObjects];
    
    OSSpinLockUnlock(&_lock);
    
    KenKVOManager *sharemanager = [KenKVOManager sharedInstance];
    
    for (id object in objectInfoMaps) {
        NSSet *infos = [objectInfoMaps objectForKey:object];
        [sharemanager unobserve:object infos:infos];
    }
}

- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KVONotificationBlock)block
{
    if (nil == object || 0 == keyPath.length || NULL == block) {
        return;
    }
    
    KenKVOInfo *info = [[KenKVOInfo alloc] initWithManager:self keyPath:keyPath options:options block:block];
    [self _observe:object info:info];
}

- (void)observe:(id)object keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options block:(KVONotificationBlock)block
{
    if (nil == object || 0 == keyPaths.count || NULL == block) {
        return;
    }
    
    for (NSString *keyPath in keyPaths)
    {
        [self observe:object keyPath:keyPath options:options block:block];
    }
}

- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options action:(SEL)action
{
    if (nil == object || 0 == keyPath.length || NULL == action) {
        return;
    }
    
    KenKVOInfo *info = [[KenKVOInfo alloc] initWithManager:self keyPath:keyPath options:options action:action];
    
    [self _observe:object info:info];
}

- (void)observe:(id)object keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options action:(SEL)action
{
    if (nil == object || 0 == keyPaths.count || NULL == action) {
        return;
    }
    
    for (NSString *keyPath in keyPaths)
    {
        [self observe:object keyPath:keyPath options:options action:action];
    }
}

- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if (nil == object || 0 == keyPath.length) {
        return;
    }
    
    KenKVOInfo *info = [[KenKVOInfo alloc] initWithManager:self keyPath:keyPath options:options context:context];
    
    [self _observe:object info:info];
}

- (void)observe:(id)object keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if (nil == object || 0 == keyPaths.count) {
        return;
    }
    
    for (NSString *keyPath in keyPaths)
    {
        [self observe:object keyPath:keyPath options:options context:context];
    }
}

- (void)unobserve:(id)object keyPath:(NSString *)keyPath
{
    KenKVOInfo *info = [[KenKVOInfo alloc] initWithManager:self keyPath:keyPath];
    [self _unobserve:object info:info];
}

- (void)unobserve:(id)object
{
    if (nil == object) {
        return;
    }
    
    [self _unobserve:object];
}

- (void)unobserveAll
{
    [self _unobserveAll];
}

@end
