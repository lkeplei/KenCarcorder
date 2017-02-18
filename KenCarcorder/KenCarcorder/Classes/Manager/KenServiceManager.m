//
//  KenServiceManager.m
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenServiceManager.h"
#import "KenHttpBaseService.h"
#import "KenAccountS.h"
#import "KenDeviceS.h"

@implementation KenServiceManager

+ (KenServiceManager *)sharedServiceManager {
    static KenServiceManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[KenServiceManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - public method
- (NSArray *)servicesArray {
    return @[[[KenAccountS alloc] init],
             [[KenDeviceS alloc] init]];
}

- (NSString *)dispathPath {
    return @"";
}

#pragma mark - 消息转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    KenHttpBaseService *service = [self serviceRespondsToSelector:aSelector];
    if (service) {
        return service;
    }
    
    return self;
}

- (id)serviceRespondsToSelector:(SEL)aSelector {
    for (KenHttpBaseService *service in [self servicesArray]) {
        if ([service respondsToSelector:aSelector]) {
            return service;
        }
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self serviceRespondsToSelector:aSelector] != nil) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

@end
