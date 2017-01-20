//
//  CWUserInfoDM.h
//  CWC
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KenUserInfoDM : KenDataModel

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPwd;
@property (nonatomic, strong) NSArray *deviceGroups;
@property (nonatomic, strong) NSMutableArray *deviceArray;


+ (KenUserInfoDM *)sharedInstance;

- (BOOL)updateUserInfo:(NSDictionary *)dic;
- (void)emptyAllUserdata;

@end

NS_ASSUME_NONNULL_END
