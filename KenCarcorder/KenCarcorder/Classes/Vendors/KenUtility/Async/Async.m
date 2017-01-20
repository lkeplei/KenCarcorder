//
//  Async.m
//  Async
//
//  Created by Ken.Liu on 16/9/22.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "Async.h"
#import "GCDQueue.h"
#import "AFURLResponseSerialization.h"

@interface Async ()

@property (nonatomic, copy)   dispatch_block_t block;

@end


@implementation Async

- (instancetype)initWithBlock:(dispatch_block_t)block
{
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}

+ (Async *)async:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue
{
    dispatch_block_t tmpBlock;
    
    if (UIDevice.iOSVersion >= 8.0) {
        tmpBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block);
    }
    else {
        tmpBlock = block;
    }
    
    dispatch_async(queue, tmpBlock);
    
    return [[Async alloc] initWithBlock:tmpBlock];
}

+ (Async *)main:(dispatch_block_t)block
{
    return [Async async:block inQueue:[GCDQueue mainQueue]];
}

+ (Async *)userInteractive:(dispatch_block_t)block
{
    return [Async async:block inQueue:[GCDQueue userInteractiveQueue]];
}

+ (Async *)userInitiated:(dispatch_block_t)block
{
    return [Async async:block inQueue:[GCDQueue userInitiatedQueue]];
}

+ (Async *)utility:(dispatch_block_t)block
{
    return [Async async:block inQueue:[GCDQueue utilityQueue]];
}

+ (Async *)background:(dispatch_block_t)block
{
    return [Async async:block inQueue:[GCDQueue backgroundQueue]];
}

+ (Async *)customQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    return [Async async:block inQueue:queue];
}

+ (Async *)after:(NSTimeInterval)seconds block:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    return [Async at:time block:block inQueue:queue];
}

+ (Async *)at:(dispatch_time_t)time block:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue
{
    dispatch_block_t tmpBlock;
    
    if (UIDevice.iOSVersion >= 8.0) {
        tmpBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block);
    }
    else {
        tmpBlock = block;
    }
    
    dispatch_after(time, queue, tmpBlock);

    return [[Async alloc] initWithBlock:tmpBlock];
}

+ (Async *)mainAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [Async after:after block:block inQueue:[GCDQueue mainQueue]];
}

+ (Async *)userInteractiveAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [Async after:after block:block inQueue:[GCDQueue userInteractiveQueue]];
}

+ (Async *)userInitiatedAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [Async after:after block:block inQueue:[GCDQueue userInitiatedQueue]];
}

+ (Async *)utilityAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [Async after:after block:block inQueue:[GCDQueue utilityQueue]];
}

+ (Async *)backgroundAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [Async after:after block:block inQueue:[GCDQueue backgroundQueue]];
}

+ (Async *)customQueue:(dispatch_queue_t)queue after:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [Async after:after block:block inQueue:queue];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (Async *)chain:(dispatch_block_t)chainingBlock runInQueue:(dispatch_queue_t)queue
{
    dispatch_block_t block;
    
    if (UIDevice.iOSVersion >= 8.0) {
        block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, chainingBlock);
    }
    else {
        block = chainingBlock;
    }
    
    dispatch_block_notify(self.block, queue, block);
    return [[Async alloc] initWithBlock:block];
}

- (Async *)main:(dispatch_block_t)chainingBlock
{
    return [self chain:chainingBlock runInQueue:[GCDQueue mainQueue]];
}

- (Async *)userInteractive:(dispatch_block_t)chainingBlock
{
    return [self chain:chainingBlock runInQueue:[GCDQueue userInteractiveQueue]];
}

- (Async *)userInitiated:(dispatch_block_t)chainingBlock
{
    return [self chain:chainingBlock runInQueue:[GCDQueue userInitiatedQueue]];
}

- (Async *)utility:(dispatch_block_t)chainingBlock
{
    return [self chain:chainingBlock runInQueue:[GCDQueue utilityQueue]];
}

- (Async *)background:(dispatch_block_t)chainingBlock
{
    return [self chain:chainingBlock runInQueue:[GCDQueue backgroundQueue]];
}

- (Async *)customQueue:(dispatch_queue_t)queue chainingBlock:(dispatch_block_t)chainingBlock
{
    return [self chain:chainingBlock runInQueue:queue];
}

- (Async *)after:(NSTimeInterval)seconds chainingBlock:(dispatch_block_t)chainingBlock runInQueue:(dispatch_queue_t)queue
{
    dispatch_block_t _chainingBlock;
    if (UIDevice.iOSVersion >= 8.0) {
        _chainingBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, chainingBlock);
    }
    else {
        _chainingBlock = chainingBlock;
    }
    
    dispatch_block_t chainingWrapperBlock = ^{
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
        dispatch_after(time, queue, _chainingBlock);
    };
    
    dispatch_block_t _chainingWrapperBlock;
    if (UIDevice.iOSVersion >= 8.0) {
        _chainingWrapperBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, chainingWrapperBlock);
    }
    else {
        _chainingWrapperBlock = chainingWrapperBlock;
    }

    dispatch_block_notify(self.block, queue, _chainingWrapperBlock);

    return [[Async alloc] initWithBlock:_chainingBlock];
}

- (Async *)mainAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [self after:after chainingBlock:block runInQueue:[GCDQueue mainQueue]];
}

- (Async *)userInteractiveAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [self after:after chainingBlock:block runInQueue:[GCDQueue userInteractiveQueue]];
}

- (Async *)userInitiatedAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [self after:after chainingBlock:block runInQueue:[GCDQueue userInitiatedQueue]];
}

- (Async *)utilityAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [self after:after chainingBlock:block runInQueue:[GCDQueue utilityQueue]];
}

- (Async *)backgroundAfter:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [self after:after chainingBlock:block runInQueue:[GCDQueue backgroundQueue]];
}

- (Async *)customQueue:(dispatch_queue_t)queue after:(NSTimeInterval)after block:(dispatch_block_t)block
{
    return [self after:after chainingBlock:block runInQueue:queue];
}

- (void)cancel
{
    dispatch_block_cancel(self.block);
}

- (void)wait:(NSTimeInterval)seconds
{
    if (seconds != 0.0) {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
        dispatch_block_wait(self.block, time);
    } else {
        dispatch_block_wait(self.block, DISPATCH_TIME_FOREVER);
    }
}

- (void)wait
{
    dispatch_block_wait(self.block, DISPATCH_TIME_FOREVER);
}
#endif

@end
