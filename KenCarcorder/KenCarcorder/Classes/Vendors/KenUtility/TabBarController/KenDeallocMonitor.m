//
//  KenDeallocMonitor.m
//
//  Created by Ken.Liu on 16/8/24.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenDeallocMonitor.h"
#import <objc/runtime.h>

@interface KenDeallocMonitor ()

@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) KenDeallocBlock deallocBlock;

@end

@implementation KenDeallocMonitor

#pragma mark - Public Class Methods
+ (void)addMonitorToObj:(id)obj {
    [self addMonitorToObj:obj withDesc:nil deallocBlock:nil];
}

+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc {
    [self addMonitorToObj:obj withDesc:desc deallocBlock:nil];
}

+ (void)addMonitorToObj:(id)obj withDeallocBlock:(KenDeallocBlock)deallocBlock {
    [self addMonitorToObj:obj withDesc:nil deallocBlock:deallocBlock];
}

+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc deallocBlock:(KenDeallocBlock)deallocBlock {
#ifdef DEBUG
    NSParameterAssert(obj);
    KenDeallocMonitor *monitor = [[KenDeallocMonitor alloc] init];
    if (desc.length > 0) {
        monitor.desc = [NSString stringWithFormat:@"%@: %@", obj, desc];
    } else {
        monitor.desc = [NSString stringWithFormat:@"%@ has been deallocated", obj];
    }
    
    if (deallocBlock) {
        monitor.deallocBlock = deallocBlock;
    }
    
    int randomKey;
    
    // It is true that swizzle method of dealloc in NSObject Category can do the same thing, but that will cause method polluted!
    objc_setAssociatedObject(obj, &randomKey, monitor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
}

#pragma mark - LifeCycle

- (void)dealloc {
    if (_deallocBlock) {
        _deallocBlock();
    }
}

@end
