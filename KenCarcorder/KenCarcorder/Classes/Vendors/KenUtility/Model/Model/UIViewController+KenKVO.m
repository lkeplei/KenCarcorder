//
//  UIViewController+KenKVO.m
//
//  Created by Ken.Liu on 16/1/5.
//  Base on Tof Templates
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIViewController+KenKVO.h"

#import "KenKVOPlugin.h"

#pragma mark -
#pragma mark Category KenKVO for UIViewController 
#pragma mark -

@interface UIViewController()<KVOUIModelDelegate>

@property(nonatomic, strong, nullable) KenKVOPlugin *kvoPlugin;

@end

@implementation UIViewController (KenKVO)

#pragma mark - 添加几个属性
static const void *kvoKey = &kvoKey;
static const void *kvoModelKey = &kvoModelKey;
static const void *kvoPluginKey = &kvoPluginKey;

- (id)kvoDelegate {
    return objc_getAssociatedObject(self, &kvoKey);
}

- (void)setKvoDelegate:(id<KVOViewControllerDelegate>)kvoDelegate {
    objc_setAssociatedObject(self, &kvoKey, kvoDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id)uiModel {
    return objc_getAssociatedObject(self, &kvoModelKey);
}

- (void)setUiModel:(KenUIModel *)uiModel {
    objc_setAssociatedObject(self, &kvoModelKey, uiModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)kvoPlugin {
    return objc_getAssociatedObject(self, &kvoPluginKey);
}

- (void)setKvoPlugin:(KenKVOPlugin *)kvoPlugin {
    objc_setAssociatedObject(self, &kvoPluginKey, kvoPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - only kvo
- (void)enableKVOAction:(nonnull NSString *)propertyPath action:(SEL)action {
    if ((nil == action) || (nil == propertyPath) || ([NSString isEmpty:propertyPath])) {
        return;
    }
    
    if (!self.kvoPlugin) {
        self.kvoPlugin = [KenKVOPlugin managerWithObserver:self];
    }
    
    [self.kvoPlugin observe:self keyPath:propertyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew action:action];
}

#pragma mark - uimodel kvo
- (void)bindModelKVOEvent
{
    NSCAssert(self.uiModel, @"[UIViewController bindKVO] 必须先给 uiModel 属性赋值");
    NSCAssert([self.uiModel isKindOfClass:[KenUIModel class]], @"uiModel 必须是 KenUIModel 或其子类");

    if (self.uiModel) {
        self.uiModel.kvoDelegate = self;
    }
}

- (void)enableObjectKVOEvent:(nonnull id)obj property:(nonnull NSString *)propertyPath
{
    if ((nil == obj) || (nil == propertyPath) || ([NSString isEmpty:propertyPath])) {
        return;
    }

    if (!self.kvoPlugin) {
        self.kvoPlugin = [KenKVOPlugin managerWithObserver:self];
    }

    [self.kvoPlugin observe:obj keyPath:propertyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                      block:^(id observer, id object, NSString *keypath, NSDictionary *change) {
        if ([self.kvoDelegate respondsToSelector:@selector(viewController:kvoObject:kvoPropertyChange:oldValue:newValue:)]) {
            [self.kvoDelegate viewController:self kvoObject:object kvoPropertyChange:keypath oldValue:change[NSKeyValueChangeOldKey]
                                    newValue:change[NSKeyValueChangeNewKey]];
        }
    }];
}

- (void)disableObjectKVOEvent:(nonnull id)obj property:(nonnull NSString *)propertyPath
{
    if ((nil == self.kvoPlugin) || (nil == obj) || (nil == propertyPath) || ([NSString isEmpty:propertyPath])) {
        return;
    }

    [self.kvoPlugin unobserve:obj keyPath:propertyPath];
}

- (void)enableKVOEvent:(nonnull NSString *)propertyPath
{
    if ((nil == propertyPath) || ([NSString isEmpty:propertyPath])) {
        return;
    }

    if (!self.kvoPlugin) {
        self.kvoPlugin = [KenKVOPlugin managerWithObserver:self];
    }

    [self.kvoPlugin observe:self keyPath:propertyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew block:^(id observer, id object, NSString *keypath, NSDictionary *change) {
        if ([self.kvoDelegate respondsToSelector:@selector(viewController:kvoUIControlPropertyChange:oldValue:newValue:)]) {
            [self.kvoDelegate viewController:self kvoUIControlPropertyChange:keypath oldValue:change[NSKeyValueChangeOldKey] newValue:change[NSKeyValueChangeNewKey]];
        }
    }];
}

- (void)enableKVOEvent:(nonnull NSString *)uiControl property:(nonnull NSString *)propertyName
{
    if ((nil == uiControl) || (nil == propertyName) || [NSString isEmpty:uiControl] || [NSString isEmpty:propertyName]) {
        return;
    }

    if (!self.kvoPlugin) {
        self.kvoPlugin = [KenKVOPlugin managerWithObserver:self];
    }

    NSString *kvoPath = [NSString stringWithFormat:@"%@.%@", uiControl, propertyName];

    [self.kvoPlugin observe:self keyPath:kvoPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew block:^(id observer, id object, NSString *keypath, NSDictionary *change) {

        if ([keypath indexOfString:@"."] != -1) {
            NSArray<NSString *> *keys = [keypath split:@"."];

            if ([self.kvoDelegate respondsToSelector:@selector(viewController:kvoUIControlPropertyChange:propertyName:oldValue:newValue:)]) {
                [self.kvoDelegate viewController:self kvoUIControlPropertyChange:[keys firstObject] propertyName:[keys lastObject] oldValue:change[NSKeyValueChangeOldKey] newValue:change[NSKeyValueChangeNewKey]];
            }
        }
    }];
}

- (void)disableKVOEvent:(nonnull NSString *)propertyPath
{
    if ((nil == self.kvoPlugin) || (nil == propertyPath) || ([NSString isEmpty:propertyPath])) {
        return;
    }

    [self.kvoPlugin unobserve:self keyPath:propertyPath];
}

- (void)disableKVOEvent:(nonnull NSString *)uiControl property:(nonnull NSString *)propertyName
{
    if ((nil == self.kvoPlugin) || (nil == uiControl) || (nil == propertyName) ||
        [NSString isEmpty:uiControl] || [NSString isEmpty:propertyName]) {
        return;
    }

    NSString *kvoPath = [NSString stringWithFormat:@"%@.%@", uiControl, propertyName];
    [self.kvoPlugin unobserve:self keyPath:kvoPath];
}

- (void)disableAllKVOEvent
{
    if (self.kvoPlugin) {
        [self.kvoPlugin unobserveAll];
    }
}

@end
