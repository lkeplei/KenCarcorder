//
//  GCDQueue.h
//  Async
//
//  Created by Ken.Liu on 16/9/22.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDQueue : NSObject

+ (dispatch_queue_t)mainQueue;

+ (dispatch_queue_t)userInteractiveQueue;

+ (dispatch_queue_t)userInitiatedQueue;

+ (dispatch_queue_t)utilityQueue;

+ (dispatch_queue_t)backgroundQueue;

@end
