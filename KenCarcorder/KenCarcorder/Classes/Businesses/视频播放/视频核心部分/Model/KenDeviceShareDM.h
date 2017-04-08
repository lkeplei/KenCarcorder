//
//  KenDeviceShareDM.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/4/8.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"

@interface KenDeviceShareDM : KenDataModel

@property (nonatomic, assign) NSInteger serverPort;
@property (nonatomic, assign) NSInteger clientPort;
@property (nonatomic, assign) NSInteger downPortStart;
@property (nonatomic, assign) NSInteger upPort;
@property (nonatomic, assign) NSInteger nodeId;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, assign) NSInteger shareId;        //id
@property (nonatomic, assign) NSInteger audioChlMask;
@property (nonatomic, assign) NSInteger recordChlMask;
@property (nonatomic, assign) NSInteger result;
@property (nonatomic, assign) NSInteger videoChlMask;
@property (nonatomic, assign) NSInteger online;

@property (nonatomic, strong) NSString *serverHost;
@property (nonatomic, strong) NSString *sn;
@property (nonatomic, strong) NSString *clientAddress;
@property (nonatomic, strong) NSString *p2pUid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pwd;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *userName;

@end
