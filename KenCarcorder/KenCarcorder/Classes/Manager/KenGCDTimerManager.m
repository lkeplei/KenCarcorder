//
//  KenGCDTimerManager.m
//  GCD封装的一个定时器的功能，作为全局的时间管理
//
//  Created by Ken.Liu on 16/8/10.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenGCDTimerManager.h"

@interface KenGCDTimerManager()

@property (nonatomic, strong) NSMutableDictionary *timerContainer;          //计时容器
@property (nonatomic, strong) NSMutableDictionary *actionBlockCache;        //action容器
@property (nonatomic, strong) NSMutableDictionary *globalTimerCache;        //全局计时容器
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation KenGCDTimerManager

+ (KenGCDTimerManager *)sharedInstance {
    static KenGCDTimerManager *_gcdTimerManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        _gcdTimerManager = [[KenGCDTimerManager alloc] init];
    });
    
    return _gcdTimerManager;
}

#pragma mark - Public Method
- (void)scheduledGlobalTimerWithName:(NSString *)timerName
                           totalTime:(NSUInteger)totalTime
                           frequency:(NSUInteger)frequency
                               queue:(dispatch_queue_t)queue
                              action:(void(^)(NSUInteger value))action
{
    if (nil == timerName)
        return;

    NSString *globalTimerName = [@"global_" stringByAppendingString:timerName];
    if (![self.globalTimerCache objectForKey:globalTimerName]) {
        [self.globalTimerCache setObject:[NSNumber numberWithUnsignedInteger:frequency] forKey:globalTimerName];
    }
    
    if (action) {
        action([[self.globalTimerCache objectForKey:globalTimerName] unsignedIntegerValue]);
    }
    
    [self scheduledGlobalTime:globalTimerName times:totalTime / frequency queue:queue action:action];
}

- (void)scheduledTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(CWGCDTimerType)option
                                action:(dispatch_block_t)action
{
    if (nil == timerName)
        return;
    
    if (nil == queue)
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [self.timerContainer setObject:timer forKey:timerName];
    }
    
    /* timer精度为0.0秒 */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    
    switch (option) {
        case kCWGCDTimerAbandon: {
            /* 移除之前的action */
            [weakSelf removeActionCacheForTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
                
                action();
            });
        }
            break;
        case kCWGCDTimerMerge: {
            /* cache本次的action */
            [self cacheAction:action forTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
                
                NSMutableArray *actionArray = [self.actionBlockCache objectForKey:timerName];
                [actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dispatch_block_t actionBlock = obj;
                    actionBlock();
                }];
            });
        }
            break;
    }
}

- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    
    if (!timer) {
        return;
    }
    
    [self.timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
    
    [self.actionBlockCache removeObjectForKey:timerName];
}

- (BOOL)isExistTimer:(NSString *)timerName {
    if ([self.timerContainer objectForKey:timerName]) {
        return YES;
    }
    return NO;
}

#pragma mark - private method
- (void)cacheAction:(dispatch_block_t)action forTimer:(NSString *)timerName {
    id actionArray = [self.actionBlockCache objectForKey:timerName];
    
    if (actionArray && [actionArray isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)actionArray addObject:action];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithObject:action];
        [self.actionBlockCache setObject:array forKey:timerName];
    }
}

- (void)removeActionCacheForTimer:(NSString *)timerName {
    if (![self.actionBlockCache objectForKey:timerName])
        return;
    
    [self.actionBlockCache removeObjectForKey:timerName];
}

- (void)scheduledGlobalTime:(NSString *)globalTimerName times:(NSUInteger)times queue:(dispatch_queue_t)queue
                     action:(void(^)(NSUInteger value))action {
    [self scheduledTimerWithName:globalTimerName timeInterval:times queue:nil repeats:YES
                    actionOption:kCWGCDTimerAbandon action:^ {
        NSUInteger index = [[self.globalTimerCache objectForKey:globalTimerName] unsignedIntegerValue];
        index--;
        if (action) {
            action(index);
        }
        if (index == 0) {
            [self cancelTimerWithName:globalTimerName];
            [self.globalTimerCache removeObjectForKey:globalTimerName];
        } else {
            [self.globalTimerCache setObject:[NSNumber numberWithUnsignedInteger:index] forKey:globalTimerName];
        }
    }];
}

#pragma mark - getter setter
- (NSMutableDictionary *)timerContainer {
    if (!_timerContainer) {
        _timerContainer = [[NSMutableDictionary alloc] init];
    }
    return _timerContainer;
}

- (NSMutableDictionary *)actionBlockCache {
    if (!_actionBlockCache) {
        _actionBlockCache = [[NSMutableDictionary alloc] init];
    }
    return _actionBlockCache;
}

- (NSMutableDictionary *)globalTimerCache {
    if (!_globalTimerCache) {
        _globalTimerCache = [[NSMutableDictionary alloc] init];
    }
    return _globalTimerCache;
}
@end
