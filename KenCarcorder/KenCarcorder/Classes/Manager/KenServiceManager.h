//
//  KenServiceManager.h
//
//
//  Created by Ken.Liu on 2016/11/23.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppServerHost              @"http://www.7cyun.com.cn:80/"
#define kConnectP2pHost             @"http://192.168.0.67/"

@class KenDeviceDM;

typedef void (^RequestStartBlock)(void);
typedef void (^ResponsedBlock)(id _Nullable responseData);
typedef void (^ResponsedSuccessBlock)(BOOL successful, NSString * _Nullable errMsg, id _Nullable responseData);
typedef void (^RequestFailureBlock)(NSInteger status, NSString * _Nullable errMsg);

@interface KenServiceManager : NSObject

@property (nonatomic, assign) NSUInteger alarmNumbers;              //报警总条数
@property (nonatomic, assign) NSString *phoneWanIp;

+ (KenServiceManager *)sharedServiceManager;

//获取所有服务
- (NSArray *)servicesArray;

//获取分发配置路径
- (NSString *)dispathPath;

- (void)getAarmStat;
- (void)updateAarmStat;
- (void)getWanIp;

#pragma mark - account
- (void)accountLogout;

- (void)accountLoginWithName:(NSString *)name pwd:(NSString *)pwd verCode:(NSString *)verCode
                       start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)accountGetVerCode:(NSString *)phone start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
              failedBlock:(RequestFailureBlock)failed;

- (void)accountRegist:(NSString *)phone pwd:(NSString *)pwd verCode:(NSString *)verCode reset:(BOOL)reset
                start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)accountWanIp:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

#pragma mark - device
- (void)deviceLoad:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceRemove:(NSString *)token
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceGetGroups:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceSaveGroups:(NSArray *)groups
                 success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceSetGroupName:(NSString *)name groupNo:(NSInteger)groupNo
                   success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)deviceShareRegister:(KenDeviceDM *)device
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceRemoveBySn:(NSString *)sn
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceChangeGroup:(NSString *)sn group:(NSInteger)groupNo
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceRenameToServer:(KenDeviceDM *)device name:(NSString *)name
                       start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSaveInfo:(NSDictionary *)params
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

#pragma mark - device setting
- (void)deviceLoadInfo:(KenDeviceDM *)device
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetLed:(KenDeviceDM *)device isOn:(BOOL)isOn
               start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetIrcut:(KenDeviceDM *)device isOn:(BOOL)isOn
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetAlarm:(KenDeviceDM *)device isOn:(BOOL)isOn
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetMove:(KenDeviceDM *)device isOn:(BOOL)isOn sensitive:(NSInteger)sensitive
                start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetAudio:(KenDeviceDM *)device isOn:(BOOL)isOn sensitive:(NSInteger)sensitive
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetRecordType:(KenDeviceDM *)device type:(NSInteger)type
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetAlarmTime:(KenDeviceDM *)device startH:(NSString *)startH startM:(NSString *)startM endH:(NSString *)endH endM:(NSString *)endM
                     start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceClearSDCard:(KenDeviceDM *)device
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetTime:(KenDeviceDM *)device 
                start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceReboot:(KenDeviceDM *)device
               start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceRename:(KenDeviceDM *)device name:(NSString *)name
               start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceRepwd:(KenDeviceDM *)device pwd:(NSString *)pwd
              start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceValidatePwd:(KenDeviceDM *)device finish:(void(^)(BOOL))finish;

- (void)deviceLoadHistory:(KenDeviceDM *)device url:(NSString *)url
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

#pragma mark - wifi setting
- (void)deviceGetWifiInfo:(KenDeviceDM *)device
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceGetWifiNode:(KenDeviceDM *)device
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceCloseWifi:(KenDeviceDM *)device
                  start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceSetWifi:(KenDeviceDM *)device name:(NSString *)name pwd:(NSString *)pwd
                start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

#pragma mark - device control get
- (void)deviceScanStop:(KenDeviceDM *)device
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceScanUpDown:(KenDeviceDM *)device
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceScanLeftRight:(KenDeviceDM *)device
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceTurnUpDown:(KenDeviceDM *)device flip:(BOOL)flip
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

- (void)deviceTurnLeftRight:(KenDeviceDM *)device mirror:(BOOL)mirror
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed;

#pragma mark - alarm
- (void)alarmWithCondition:(NSInteger)alarmId sn:(NSString *)sn readed:(NSString *)readed groupNo:(NSInteger)groupNo
                   success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmDeleteWithId:(NSArray *)alarmIdArr
                  success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmAtat:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmDeleteWithType:(NSString *)type
                    success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmReadWithId:(NSArray *)alarmIdArr
                success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)alarmSetOnOff:(BOOL)on sn:(NSString *)sn
              success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

#pragma mark - play
- (void)playBanner:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)playBannerDevice:(NSInteger)bannerId
                   start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

@end
