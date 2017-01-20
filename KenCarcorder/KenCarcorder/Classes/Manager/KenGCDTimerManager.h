//
//  KenGCDTimerManager.h
//  GCD封装的一个定时器的功能，作为全局的时间管理
//
//  Created by Ken.Liu on 16/8/10.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CWGCDTimerType)
{
    kCWGCDTimerAbandon = 0,           // 废除同一个timer之前的任务
    kCWGCDTimerMerge,                 // 将同一个timer之前的任务合并到新的任务中
};

@interface KenGCDTimerManager : NSObject

+ (KenGCDTimerManager *)sharedInstance;

/**
 *  启动一个全局timer，默认精度为0.0秒。
 *
 *  @param timerName timer的名称，作为唯一标识。
 *  @param totalTime 总时长
 *  @param frequency 总时长内，回调频率（多少次回调）
 *  @param queue     timer将被放入的队列，也就是最终action执行的队列。传入nil将自动放到一个子线程队列中。
 *  @param action    时间间隔到点时执行的block，带回当前剩余时长。
 */
- (void)scheduledGlobalTimerWithName:(NSString *)timerName
                           totalTime:(NSUInteger)totalTime
                           frequency:(NSUInteger)frequency
                               queue:(dispatch_queue_t)queue
                              action:(void(^)(NSUInteger value))action;
/**
 * 启动一个timer，默认精度为0.0秒。
 *
 * @param timerName       timer的名称，作为唯一标识。
 * @param interval        执行的时间间隔。
 * @param queue           timer将被放入的队列，也就是最终action执行的队列。传入nil将自动放到一个子线程队列中。
 * @param repeats         timer是否循环调用。
 * @param option          多次schedule同一个timer时的操作选项(目前提供将之前的任务废除或合并的选项)。
 * @param action          时间间隔到点时执行的block。
 */
- (void)scheduledTimerWithName:(NSString *)timerName
                  timeInterval:(double)interval
                         queue:(dispatch_queue_t)queue
                       repeats:(BOOL)repeats
                  actionOption:(CWGCDTimerType)option
                        action:(dispatch_block_t)action;

/**
 *  撤销某个timer
 *  @param timerName timer的名称，作为唯一标识
 */
- (void)cancelTimerWithName:(NSString *)timerName;

/**
 *  是否存在某个名称标识的timer。
 *
 *  @param timerName timer的唯一名称标识。
 *
 *  @return YES表示存在，反之
 */
- (BOOL)isExistTimer:(NSString *)timerName;

@end
