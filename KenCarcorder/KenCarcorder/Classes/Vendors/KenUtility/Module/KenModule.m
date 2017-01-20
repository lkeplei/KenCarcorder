//
//  KenModule.m
//  CW
//
//  Created by Ken.Liu on 2016/12/7.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenModule.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

void KenSwizzle(Class class, SEL originalSelector, Method swizzledMethod) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    SEL swizzledSelector = method_getName(swizzledMethod);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod && originalMethod) {
        class_replaceMethod(class, swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    class_addMethod(class, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
}

#pragma mark - KenModule
static NSMutableArray<Class> *KenModuleClasses;

@implementation KenModule

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KenSwizzle([UIApplication class], @selector(setDelegate:),
                   class_getInstanceMethod([self class], @selector(module_setDelegate:)));
    });
}

+ (instancetype)sharedIsntance {
    static KenModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)registerAppDelegateModule:(Class)moduleClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KenModuleClasses = [NSMutableArray new];
    });
    
    // Register module
    if (![KenModuleClasses containsObject:moduleClass]) {
        [KenModuleClasses addObject:moduleClass];
    }
}

+ (void)unregisterAppDelegateModule:(nonnull Class)moduleClass {
    if ([KenModuleClasses containsObject:moduleClass]) {
        [KenModuleClasses removeObject:moduleClass];
    }
}

#pragma mark - set delegate
- (void)module_setDelegate:(id<UIApplicationDelegate>) delegate {
    static dispatch_once_t delegateOnceToken;
    dispatch_once(&delegateOnceToken, ^{
        
#define SwizzleDelegateMethod(__SELECTORSTRING__)    \
KenSwizzle([delegate class], @selector(__SELECTORSTRING__), \
class_getInstanceMethod([KenModule class], @selector(module_##__SELECTORSTRING__)));
        
        SwizzleDelegateMethod(applicationDidFinishLaunching:);
        SwizzleDelegateMethod(application:willFinishLaunchingWithOptions:);
        SwizzleDelegateMethod(application:didFinishLaunchingWithOptions:);
        SwizzleDelegateMethod(applicationDidBecomeActive:)
        SwizzleDelegateMethod(applicationWillResignActive:)
        SwizzleDelegateMethod(application:openURL:options:)
        SwizzleDelegateMethod(applicationDidReceiveMemoryWarning:)
        SwizzleDelegateMethod(applicationWillTerminate:)
        SwizzleDelegateMethod(applicationSignificantTimeChange:);
        SwizzleDelegateMethod(application:didRegisterForRemoteNotificationsWithDeviceToken:)
        SwizzleDelegateMethod(application:didFailToRegisterForRemoteNotificationsWithError:)
        SwizzleDelegateMethod(application:didReceiveRemoteNotification:)
        SwizzleDelegateMethod(application:didReceiveLocalNotification:)
        SwizzleDelegateMethod(application:handleEventsForBackgroundURLSession: completionHandler:)
        SwizzleDelegateMethod(application:handleWatchKitExtensionRequest: reply:)
        SwizzleDelegateMethod(applicationShouldRequestHealthAuthorization:)
        SwizzleDelegateMethod(applicationDidEnterBackground:)
        SwizzleDelegateMethod(applicationWillEnterForeground:)
        SwizzleDelegateMethod(applicationProtectedDataWillBecomeUnavailable:)
        SwizzleDelegateMethod(applicationProtectedDataDidBecomeAvailable:)
        
    });
    [self module_setDelegate:delegate];
}

#pragma mark - AppDelegate

#define KenMethodSend(_arg1_, _arg2_) \
SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);  \
\
IMP imp1 = method_getImplementation(class_getClassMethod([KenModule class], selector)); \
IMP imp2 = method_getImplementation(class_getInstanceMethod([self class], _cmd));   \
\
if (imp1 != imp2) { \
[self performSelector:selector withObject:_arg1_ withObject:_arg2_]; \
}\
\
for (id cls in KenModuleClasses) {  \
if ([cls respondsToSelector:_cmd]) {    \
[cls performSelector:_cmd withObject:_arg1_ withObject:_arg2_];  \
}   \
}


#define KenReturnMethodSend(_arg1_, _arg2_) \
SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);  \
\
IMP imp1 = method_getImplementation(class_getClassMethod([KenModule class], selector)); \
IMP imp2 = method_getImplementation(class_getInstanceMethod([self class], _cmd));   \
\
BOOL result = YES;  \
if (imp1 != imp2) { \
result = [self performSelector:selector withObject:_arg1_ withObject:_arg2_]; \
}\
\
for (id cls in KenModuleClasses) {  \
if ([cls respondsToSelector:_cmd]) {    \
[cls performSelector:_cmd withObject:_arg1_ withObject:_arg2_];  \
}   \
}\
return result;

- (void)module_applicationDidFinishLaunching:(UIApplication *)application {
    KenMethodSend(application, NULL);
}

+ (BOOL)module_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    KenReturnMethodSend(application, launchOptions);
}

- (BOOL)module_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    KenReturnMethodSend(application, launchOptions);
}

+ (void)module_applicationDidBecomeActive:(UIApplication *)application {
    KenMethodSend(application, NULL);
}

+ (void)ytxmodule_applicationWillResignActive:(UIApplication *)application {
    KenMethodSend(application, NULL);
}

// no equiv. notification. return NO if the application can't open for some reaso
+ (BOOL)module_application:(UIApplication *)app openURL:(NSURL *)url
                      options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0) {
    BOOL result = YES;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);
    
    IMP imp1 = method_getImplementation(class_getClassMethod([KenModule class], selector));
    IMP imp2 = method_getImplementation(class_getInstanceMethod([self class], _cmd));
    
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, selector, app, url, options);
    }
    
    BOOL (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in KenModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, app, url, options);
        }
    }
    return result;
}

// try to clean up as much memory as possible. next step is to terminate ap
+ (void)module_applicationDidReceiveMemoryWarning:(UIApplication *)application {
    KenMethodSend(application, NULL);
}

+ (void)module_applicationWillTerminate:(UIApplication *)application {
    KenMethodSend(application, NULL);
}

// midnight, carrier time update, daylight savings time chang
+ (void)module_applicationSignificantTimeChange:(UIApplication *)application {
    KenMethodSend(application, NULL);
}

+ (void)module_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_IOS(3_0)
{
    KenMethodSend(application, deviceToken);
}

+ (void)module_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    KenMethodSend(application, error);
}

+ (void)module_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0) {
    KenMethodSend(application, userInfo);
}

+ (void)module_application:(UIApplication *)application didReceiveLocalNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0) {
    KenMethodSend(application, userInfo);
}

#define KenMethodMoreArgsSend(_arg1_, _arg2_, _arg3_) \
SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);  \
\
IMP imp1 = method_getImplementation(class_getClassMethod([KenModule class], selector)); \
IMP imp2 = method_getImplementation(class_getInstanceMethod([self class], _cmd));   \
\
if (imp1 != imp2) { \
    ((void (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, selector, _arg1_, _arg2_, _arg3_); \
}\
\
void (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;  \
for (id cls in KenModuleClasses) {  \
    if ([cls respondsToSelector:_cmd]) {    \
        typed_msgSend(cls, _cmd, _arg1_, _arg2_, _arg3_);   \
    }   \
}

+ (void)module_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
            completionHandler:(void (^)())completionHandler NS_AVAILABLE_IOS(7_0) {
    KenMethodMoreArgsSend(application, identifier, completionHandler)
}

+ (void)module_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo
                        reply:(void(^)(NSDictionary * __nullable replyInfo))reply NS_AVAILABLE_IOS(8_2) {
    KenMethodMoreArgsSend(application, userInfo, reply)
}

+ (void)module_applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_AVAILABLE_IOS(9_0) {
    KenMethodSend(application, NULL);
}

+ (void)module_applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0) {
    KenMethodSend(application, NULL);
}

+ (void)module_applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0) {
    KenMethodSend(application, NULL);
}

+ (void)module_applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application NS_AVAILABLE_IOS(4_0) {
    KenMethodSend(application, NULL);
}

+ (void)module_applicationProtectedDataDidBecomeAvailable:(UIApplication *)application    NS_AVAILABLE_IOS(4_0) {
    KenMethodSend(application, NULL);
}

@end
