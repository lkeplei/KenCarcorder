//
//  KenServiceManager.h
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestStartBlock)(void);
typedef void (^ResponsedBlock)(id _Nullable responseData);
typedef void (^ResponsedSuccessBlock)(BOOL successful, BOOL cleanUserData, NSString * _Nullable errMsg, id _Nullable responseData);
typedef void (^RequestFailureBlock)(NSInteger status, NSString * _Nullable errMsg);

@interface KenServiceManager : NSObject

//获取所有服务
- (NSArray *)servicesArray;

//获取分发配置路径
- (NSString *)dispathPath;

@end
