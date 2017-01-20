//
//  Async.h
//  Async
//
//  Created by Ken.Liu on 16/9/22.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Async : NSObject

#pragma mark - 类方法
// 主队列
+ (Async *)main:(dispatch_block_t)block;
// 为了提供良好的用户体验而需要被立即执行的任务。经常用来刷新UI、处理一些要求低延迟的加载工作。在App运行的期间，这个方法中的工作完成总量应该很小
+ (Async *)userInteractive:(dispatch_block_t)block;
// 从UI端初始化并可异步运行的任务。在用户等待及时反馈时和涉及继续运行用户交互的任务时被使用
+ (Async *)userInitiated:(dispatch_block_t)block;
// 长时间运行的任务，尤其是那种用户可见的进度条。经常用来处理计算、I/O、网络通信、持续数据反馈及相似的任务
+ (Async *)utility:(dispatch_block_t)block;
// 那些用户并不需要立即知晓的任务。它经常用来完成预处理、维护及一些不需要用户交互的、对完成时间并无太高要求的任务
+ (Async *)background:(dispatch_block_t)block;
// 用户自定义队列
+ (Async *)customQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

+ (Async *)mainAfter:(NSTimeInterval)after block:(dispatch_block_t)block;
+ (Async *)userInteractiveAfter:(NSTimeInterval)after block:(dispatch_block_t)block;
+ (Async *)userInitiatedAfter:(NSTimeInterval)after block:(dispatch_block_t)block;
+ (Async *)utilityAfter:(NSTimeInterval)after block:(dispatch_block_t)block;
+ (Async *)backgroundAfter:(NSTimeInterval)after block:(dispatch_block_t)block;
+ (Async *)customQueue:(dispatch_queue_t)queue after:(NSTimeInterval)after block:(dispatch_block_t)block;

#pragma mark - 实例方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (Async *)main:(dispatch_block_t)chainingBlock NS_AVAILABLE_IOS(8_0);
- (Async *)userInteractive:(dispatch_block_t)chainingBlock NS_AVAILABLE_IOS(8_0);
- (Async *)userInitiated:(dispatch_block_t)chainingBlock NS_AVAILABLE_IOS(8_0);
- (Async *)utility:(dispatch_block_t)chainingBlock NS_AVAILABLE_IOS(8_0);
- (Async *)background:(dispatch_block_t)chainingBlock NS_AVAILABLE_IOS(8_0);
- (Async *)customQueue:(dispatch_queue_t)queue chainingBlock:(dispatch_block_t)chainingBlock NS_AVAILABLE_IOS(8_0);

- (Async *)mainAfter:(NSTimeInterval)after block:(dispatch_block_t)block NS_AVAILABLE_IOS(8_0);
- (Async *)userInteractiveAfter:(NSTimeInterval)after block:(dispatch_block_t)block NS_AVAILABLE_IOS(8_0);
- (Async *)userInitiatedAfter:(NSTimeInterval)after block:(dispatch_block_t)block NS_AVAILABLE_IOS(8_0);
- (Async *)utilityAfter:(NSTimeInterval)after block:(dispatch_block_t)block NS_AVAILABLE_IOS(8_0);
- (Async *)backgroundAfter:(NSTimeInterval)after block:(dispatch_block_t)block NS_AVAILABLE_IOS(8_0);
- (Async *)customQueue:(dispatch_queue_t)queue after:(NSTimeInterval)after block:(dispatch_block_t)block NS_AVAILABLE_IOS(8_0);

- (void)cancel;

- (void)wait:(NSTimeInterval)seconds;
- (void)wait;
#endif

@end
