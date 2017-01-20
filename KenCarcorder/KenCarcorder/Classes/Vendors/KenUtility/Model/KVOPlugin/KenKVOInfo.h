//
//  KenKVOInfo.h
//
//  Created by Ken.Liu on 16/1/5.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KenKVOPlugin.h"

@interface KenKVOInfo : NSObject
{
@public
    void *_context;
}

@property (nonatomic, assign) NSKeyValueObservingOptions options;

@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, weak) KenKVOPlugin *manager;
@property (nonatomic, copy) KVONotificationBlock notificationBlock;

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                          block:(KVONotificationBlock)block action:(SEL)action context:(void *)context;

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                          block:(KVONotificationBlock)block;

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                         action:(SEL)action;

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
                        context:(void *)context;

- (instancetype)initWithManager:(KenKVOPlugin *)manager keyPath:(NSString *)keyPath;

@end
