//
//  GCDQueue.m
//  Async
//
//  Created by Ken.Liu on 16/9/22.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "GCDQueue.h"

@implementation GCDQueue

+ (dispatch_queue_t)mainQueue
{
    return dispatch_get_main_queue();
}

+ (dispatch_queue_t)userInteractiveQueue
{
    if (UIDevice.iOSVersion >= 8.0) {
        return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    }
    else {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    
}

+ (dispatch_queue_t)userInitiatedQueue
{
    if (UIDevice.iOSVersion >= 8.0) {
        return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    }
    else {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
}

+ (dispatch_queue_t)utilityQueue
{
    if (UIDevice.iOSVersion >= 8.0) {
        return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
    }
    else {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
}

+ (dispatch_queue_t)backgroundQueue
{
    if (UIDevice.iOSVersion >= 8.0) {
        return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
    }
    else {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    }
}

@end
