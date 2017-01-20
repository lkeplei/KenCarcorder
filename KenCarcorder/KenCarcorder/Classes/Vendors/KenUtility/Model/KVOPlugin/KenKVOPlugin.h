//
//  KenKVOPlugin.h
//
//  Created by Ken.Liu on 16/1/5.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVONotificationBlock)(id observer, id object, NSString* keypath, NSDictionary *change);

@interface KenKVOPlugin : NSObject

@property (atomic, weak, readonly) id observer;

+ (instancetype)managerWithObserver:(id)observer;
- (instancetype)initWithObserver:(id)observer retainObserved:(BOOL)retainObserved;
- (instancetype)initWithObserver:(id)observer;

- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KVONotificationBlock)block;
- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options action:(SEL)action;
- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)observe:(id)object keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options block:(KVONotificationBlock)block;
- (void)observe:(id)object keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options action:(SEL)action;
- (void)observe:(id)object keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context;

- (void)unobserve:(id)object keyPath:(NSString *)keyPath;
- (void)unobserve:(id)object;
- (void)unobserveAll;

@end
