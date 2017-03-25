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
             @"readed":@NO,
             @"almType":@1,
             @"userId":@"",
             @"sn":@"",
             @"almFile":@"",
             @"almTime":@0,
             @"sendTime":@0,
             @"recfilename":@"",
             @"isSelected":@"",};
}

+ (NSDictionary *)setCustomPropertyMap {
    return @{@"alarmId":@"id"};
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
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:_almTime];
    if (date) {
        return [date stringWithFormat:@"MM-dd HH:mm:ss"];
    } else {
        return @"";
    }
}

- (NSString *)getAlarmImg {
    if (_deviceInfo) {
        return [NSString stringWithFormat:@"http://%@:%d%@", [_deviceInfo currentIp], (int)[_deviceInfo httpport], _almFile];
    } else {
        return @"";
    }
}

- (NSString *)getImageName {
    if ([NSString isNotEmpty:_almFile]) {
        if ([_almFile length] > 13) {
            return [_almFile substringFromIndex:13];
        } else {
            return _almFile;
        }
    } else {
        return nil;
    }
}

- (NSString *)getAlarmTypeString {
    if (_almType == kKenAlarmMoving) {
        return @"人体";
    } else if (_almType == kKenAlarmVoice) {
        return @"声音";
    } else {
        return @"离线";
    }
}

- (UIColor *)getAlarmTextColor {
    if (_almType == kKenAlarmMoving) {
        return [UIColor redColor];
    } else if (_almType == kKenAlarmVoice) {
        return [UIColor colorWithHexString:@"#419FFF"];
    } else {
        return [UIColor whiteColor];
    }
}

@end
