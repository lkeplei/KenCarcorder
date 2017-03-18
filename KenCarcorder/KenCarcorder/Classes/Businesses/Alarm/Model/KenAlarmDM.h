//
//  KenAlarmDM.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDataModel.h"
#import "KenDeviceDM.h"

typedef NS_ENUM(NSUInteger, KenAlarmType) {
    kKenAlarmMoving = 1,             //移动报警
    kKenAlarmOffLine,                //离线报警
    kKenAlarmVoice,                  //声音报警
};

@interface KenAlarmDM : KenDataModel

@property (nonatomic, strong) NSArray *list;

@end


@interface KenAlarmItemDM : KenDataModel

@property (nonatomic, assign) NSInteger alarmId;
@property (nonatomic, assign) BOOL alarmReaded;
@property (nonatomic, assign) KenAlarmType alarmType;
@property (nonatomic, assign) NSTimeInterval alarmTime;
@property (nonatomic, assign) NSTimeInterval sendTime;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *deviceSn;
@property (nonatomic, strong) NSString *alarmFile;
@property (nonatomic, strong) NSString *recorderFile;

//以下数据只作为中间数据，不保存
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) KenDeviceDM *deviceInfo;         //这个不保存，只作为中间数据

- (NSString *)getDeviceName;
- (NSString *)getAlarmTimeString;
- (NSString *)getAlarmImg;
- (NSString *)getImageName;
- (NSString *)getAlarmTypeString;
- (UIColor *)getAlarmTextColor;

@end
