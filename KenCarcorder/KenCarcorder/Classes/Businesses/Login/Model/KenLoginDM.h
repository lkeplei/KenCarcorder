//
//  KenLoginDM.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenLoginDM : KenDataModel

@property (nonatomic, assign) NSInteger result;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *list;

@end
