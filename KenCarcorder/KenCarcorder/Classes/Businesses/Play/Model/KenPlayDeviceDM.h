//
//  KenPlayDeviceDM.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenPlayDeviceDM : KenDataModel

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *list;

@end


@interface KenPlayDeviceItemDM : KenDataModel

@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, assign) NSInteger category;                   // 分类id
@property (nonatomic, assign) NSInteger seqNumber;
@property (nonatomic, assign) NSInteger serverPort;                 // 设备port
@property (nonatomic, assign) CGFloat pageView;                     // 点击量
@property (nonatomic, assign) CGFloat followCount;                  // 关注数
@property (nonatomic, assign) CGFloat collectCount;                 // 收藏数
@property (nonatomic, assign) CGFloat praiseCount;                  // 点赞数
@property (nonatomic, assign) CGFloat discussCount;                 // 评论数
@property (nonatomic, assign) BOOL isMainStream;                    //是否为主码流，默认为否
@property (nonatomic, strong) NSString *name;                       //设备名
@property (nonatomic, strong) NSString *serverHost;                 // 设备地址
@property (nonatomic, strong) NSString *userName;                   // 设备的用户名
@property (nonatomic, strong) NSString *password;                   // 设备用户名密码
@property (nonatomic, strong) NSString *topDiscuss;                 // 第一条评论
@property (nonatomic, strong) NSString *imageUrl;                   // 图片地址

@end
