//
//  CWUserInfoDM.h
//  CWC
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@class KenDeviceDM;

NS_ASSUME_NONNULL_BEGIN

@interface KenUserInfoDM : KenDataModel

@property (nonatomic, assign) BOOL rememberPwd;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPwd;
@property (nonatomic, strong) NSArray *deviceGroups;                    //设备的分组
@property (nonatomic, strong) NSMutableArray *deviceArray;


+ (KenUserInfoDM *)sharedInstance;

- (BOOL)updateUserInfo:(NSDictionary *)dic;
- (void)emptyAllUserdata;

- (KenDeviceDM *)deviceWithSN:(NSString *)sn;

@end

NS_ASSUME_NONNULL_END
