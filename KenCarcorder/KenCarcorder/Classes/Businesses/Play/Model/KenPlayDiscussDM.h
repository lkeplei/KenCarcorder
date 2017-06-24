//
//  KenPlayDiscussDM.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/24.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenPlayDiscussDM : KenDataModel

@property (nonatomic, assign) BOOL haveMore;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *list;

@end

@interface KenPlayDiscussItemDM : KenDataModel

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) double createDate;

- (NSDate *)timeDate;

@end
