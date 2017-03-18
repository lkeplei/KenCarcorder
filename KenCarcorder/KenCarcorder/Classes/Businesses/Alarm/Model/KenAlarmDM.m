//
//  KenAlarmDM.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAlarmDM.h"

@implementation KenAlarmDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"list":@[]};
}

+ (NSDictionary *)setContainerPropertyClassMap {
    return @{@"list":[KenAlarmItemDM class]};
}

@end


@implementation KenAlarmItemDM

+ (NSDictionary *)setDefaultValueMap {
    return @{@"alarmId":@0,
             @"alarmReaded":@"",
             @"alarmType":@"",
             @"userId":@"",
             @"deviceSn":@"",
             @"alarmFile":@"",
             @"alarmTime":@0,
             @"sendTime":@0,
             @"recorderFile":@"",
             @"isSelected":@"",};
}

- (BOOL)handleCustomTransformFromDictionary:(NSDictionary *)jsonDict {
    
    _deviceInfo = [KenDeviceDM initWithJsonDictionary:@{}];
    
    
    return [super handleCustomTransformFromDictionary:jsonDict];
}

- (NSString *)getDeviceName {
    if (_deviceInfo) {
        return _deviceInfo.name;
    } else {
        return @"";
    }
}

- (NSString *)getAlarmTimeString {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:_alarmTime];
    if (date) {
        return [date stringWithFormat:@"MM-dd HH:mm:ss"];
    } else {
        return @"";
    }
}

- (NSString *)getAlarmImg {
    if (_deviceInfo) {
        return [NSString stringWithFormat:@"http://%@:%d%@", [_deviceInfo currentIp], (int)[_deviceInfo httpport], _alarmFile];
    } else {
        return @"";
    }
}

- (NSString *)getImageName {
    if ([NSString isNotEmpty:_alarmFile]) {
        if ([_alarmFile length] > 13) {
            return [_alarmFile substringFromIndex:13];
        } else {
            return _alarmFile;
        }
    } else {
        return nil;
    }
}

- (NSString *)getAlarmTypeString {
    if (_alarmType == kKenAlarmMoving) {
        return @"人体";
    } else if (_alarmType == kKenAlarmVoice) {
        return @"声音";
    } else {
        return @"离线";
    }
}

- (UIColor *)getAlarmTextColor {
    if (_alarmType == kKenAlarmMoving) {
        return [UIColor redColor];
    } else if (_alarmType == kKenAlarmVoice) {
        return [UIColor colorWithHexString:@"#419FFF"];
    } else {
        return [UIColor whiteColor];
    }
}

@end
