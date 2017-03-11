//
//  KenDeviceDM.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KenNetworkStatusType) {  //网络连接方式
    kKenNetworkUnkown = 0,
    kKenNetworkDdns = 1,                             //ddns连接
    kKenNetworkP2p = 2,                              //p2p连接
};

@interface KenDeviceDM : KenDataModel

//后台数据带来部分
@property (nonatomic, assign) BOOL alarmOnoff;                      //报警是否开启
@property (nonatomic, assign) BOOL online;                          //设备是否在线
@property (nonatomic, assign) BOOL position;                        //
@property (nonatomic, assign) NSInteger groupNo;                    //设备分组
@property (nonatomic, assign) NSUInteger dataport;                  //数据端口
@property (nonatomic, assign) NSUInteger httpport;                  //Http端口
@property (nonatomic, assign) NSTimeInterval createDate;            //创建时间
@property (nonatomic, assign) NSTimeInterval updateTime;            //修改时间
@property (nonatomic, assign) KenNetworkStatusType netStat;         //网络连接方式
@property (nonatomic, strong) NSString *name;                       //设备名
@property (nonatomic, strong) NSString *sn;                         //设备序列号
@property (nonatomic, strong) NSString *ddns;                       //ddns
@property (nonatomic, strong) NSString *lanIp;                      //局域网ip
@property (nonatomic, strong) NSString *devWanIp;                   //设备外网ip
@property (nonatomic, strong) NSString *devModel;                   //设备类型
@property (nonatomic, strong) NSString *uid;                        //设备uid,p2p所有
@property (nonatomic, strong) NSString *uidpsd;                     //设备uid密码，p2p所有
@property (nonatomic, strong) NSString *createUserId;               //创建者id
@property (nonatomic, strong) NSString *status;

//自身使用部分
@property (nonatomic, assign) int64_t connectHandle;                //设备连接句柄
@property (nonatomic, strong) NSString *usr;                        //设备用户名
@property (nonatomic, strong) NSString *pwd;                        //设备密码

//@property (assign) NSInteger lanDataPort;
//@property (assign) NSInteger lanHttpPort;
//@property (assign) BOOL isSubStream;                //是否为主码流，默认为否
//@property (assign) BOOL deviceLock;                 //设备是否已加密


//获取当前ip
- (NSString *)currentIp;
    
//判断当前是不是DDNS环境
- (BOOL)isDDNS;

@end
