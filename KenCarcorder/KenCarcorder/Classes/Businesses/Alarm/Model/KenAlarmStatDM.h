//
//  KenAlarmStatDM.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenAlarmStatDM : KenDataModel

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, assign) NSUInteger total;

@end

@interface KenAlarmStatItemDM : KenDataModel

@property (nonatomic, strong) NSString *sn;
@property (nonatomic, assign) NSUInteger count;             //总数
@property (nonatomic, assign) NSUInteger unreads;           //未读数

@end
