//
//  KenModule.h
//  CW
//
//  Created by Ken.Liu on 2016/12/7.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KenModule_Register  \
+ (void)load {  \
    [KenModule registerAppDelegateModule:self]; \
}

@interface KenModule : NSObject

+ (void)registerAppDelegateModule:(nonnull Class)moduleClass;

+ (void)unregisterAppDelegateModule:(nonnull Class)moduleClass;

@end
