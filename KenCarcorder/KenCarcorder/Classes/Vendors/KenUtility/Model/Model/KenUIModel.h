//
//  KenUIModel.h
//
//  Created by Ken.Liu on 16/1/11.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@class KenUIModel;

@protocol KVOUIModelDelegate <NSObject>
@optional
- (void)uiModel:(KenUIModel *)uiModel kvoPropertyChange:(NSString *)propertyName oldValue:(id)oldValue newValue:(id)newValue;
@end

@interface KenUIModel : KenDataModel

@property (nonatomic, strong) __kindof UIViewController *viewController;
@property (nonatomic, weak) id <KVOUIModelDelegate> kvoDelegate;

- (void)bindVCKVOEvent;
- (void)enableKVOEvent;
- (void)disableKVOEvent;

+ (NSArray *)getIgnoreList;

@end

NS_ASSUME_NONNULL_END
