//
//  KenUIModel.m
//
//  Created by Ken.Liu on 16/1/11.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenUIModel.h"
#import "XPSuperClassInfo.h"
#import "KenKVOPlugin.h"

#import "UIViewController+KenKVO.h"

@interface KenUIModel () <KVOViewControllerDelegate>

@property (nonatomic, strong) KenKVOPlugin *kvoPlugin;
@property (nonatomic, strong) XPSClassInfo *clsInfo;

@end

@implementation KenUIModel
- (id)init
{
    self = [super init];

    _clsInfo         = [XPSClassInfo classInfoWithClass:self.class];
    _viewController = nil;
    
    _kvoPlugin    = nil;
    
    return self;
}

- (void)dealloc
{
    [self disableKVOEvent];
}

+ (NSArray<NSString *> *)setPropertyBlacklist
{
    NSMutableArray *blackList = [NSMutableArray arrayWithObjects:@"viewController", @"kvoDelegate", @"description",
                                 @"debugDescription", @"superclass", @"hash", nil];
    [blackList addObjectsFromArray:[self getIgnoreList]];
    return blackList;
}

+ (NSArray *)getIgnoreList {
    return [NSArray array];
}

- (void)bindVCKVOEvent
{
    NSCAssert(self.viewController, @"[CWBaseUIModel bindKVO] 必须先给 viewController 属性赋值");
    NSCAssert([self.viewController isKindOfClass:[UIViewController class]],
              @"[CWBaseUIModel bindKVO] viewController 必须是 UIViewController 或其子类");
    
    if (self.viewController) {
        self.viewController.kvoDelegate = self;
    }
}

- (BOOL)isHardIgnore:(NSString *)propertyName
{
    __block BOOL result = NO;
    NSArray<NSString *> *_baseIgnorePropertys = [KenUIModel setPropertyBlacklist];
    [_baseIgnorePropertys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([propertyName isEqualToString:obj]) {
            result = YES;
            *stop  = YES;
        }
    }];
    
    if (result) {
        return result;
    }
    
    if ([[self class] respondsToSelector:@selector(setPropertyBlacklist)]) {
        NSArray<NSString *> *_subIgnorePropertys = [self.class setPropertyBlacklist];
        [_subIgnorePropertys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([propertyName isEqualToString:obj]) {
                result = YES;
                *stop  = YES;
            }
        }];
    }
    
    return result;
}

- (void)enableKVOEvent
{
    for (XPSClassPropertyInfo *propertyInfo in _clsInfo.propertyInfos.allValues) {
        if ([self isHardIgnore:propertyInfo.name]) {
            continue;
        }
        
        if (!_kvoPlugin) {
            _kvoPlugin = [KenKVOPlugin managerWithObserver:self];
        }
        
        [_kvoPlugin observe:self keyPath:propertyInfo.name options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                      block:^(id observer, id object, NSString *keypath, NSDictionary *change) {
                          if ([self.kvoDelegate respondsToSelector:@selector(uiModel:kvoPropertyChange:oldValue:newValue:)]) {
                              [self.kvoDelegate uiModel:self kvoPropertyChange:keypath oldValue:change[NSKeyValueChangeOldKey]
                                               newValue:change[NSKeyValueChangeNewKey]];
                          }
                      }];
    }
}

- (void)disableKVOEvent
{
    if (_kvoPlugin) {
        [_kvoPlugin unobserveAll];
    }
}
@end
