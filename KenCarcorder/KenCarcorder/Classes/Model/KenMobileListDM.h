//
//  KenMobileListDM.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenMobileListDM : KenDataModel

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *list;

@end

#pragma mark - mobile item

@interface KenMobileItemDM : KenDataModel

@property (nonatomic, assign) NSUInteger updateDate;
@property (nonatomic, assign) NSUInteger createDate;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *onlyId;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *releaseVersion;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *tokenOrMac;

@end
