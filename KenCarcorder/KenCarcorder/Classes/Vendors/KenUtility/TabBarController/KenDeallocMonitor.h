//
//  KenDeallocMonitor.h
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KenDeallocBlock)(void);

@interface KenDeallocMonitor : NSObject

/**
 *  Print object when it is being deallocated(before object_dispose())
 */
+ (void)addMonitorToObj:(id)obj;

/**
 *  Print object with description when it is being deallocated
 *
 *  @param obj  object
 *  @param desc description
 */
+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc;

/**
 *  Print object and excute deallocBlock when it is being deallocated
 *
 *  @param obj          object
 *  @param deallocBlock a block will run when object is being deallocated. For example, remove KVO in this block
 */
+ (void)addMonitorToObj:(id)obj withDeallocBlock:(KenDeallocBlock)deallocBlock;

/**
 *  Print object with description and and excute deallocBlock when it is being deallocated
 *
 *  @param obj          object
 *  @param desc         description
 *  @param deallocBlock a block will run when object is being deallocated
 */
+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc deallocBlock:(KenDeallocBlock)deallocBlock;

@end
