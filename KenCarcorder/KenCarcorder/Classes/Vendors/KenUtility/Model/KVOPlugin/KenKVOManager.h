//
//  KenKVOManager.h
//
//  Created by Ken.Liu on 16/1/5.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KenKVOInfo;

@interface KenKVOManager : NSObject

+ (instancetype)sharedInstance;
- (void)observe:(id)object info:(KenKVOInfo *)info;
- (void)unobserve:(id)object info:(KenKVOInfo *)info;
- (void)unobserve:(id)object infos:(NSSet *)infos;

@end
