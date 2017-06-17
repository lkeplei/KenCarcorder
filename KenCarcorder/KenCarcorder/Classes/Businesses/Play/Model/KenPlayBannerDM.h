//
//  KenPlanBannerDM.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenPlayBannerDM : KenDataModel

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *list;

@end


@interface KenPlayBannerItemDM : KenDataModel

@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, strong) NSString *activeImageUrl;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;

@end
