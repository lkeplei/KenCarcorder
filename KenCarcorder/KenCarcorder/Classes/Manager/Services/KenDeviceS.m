//
//  KenDeviceS.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceS.h"
#import "KenMobileListDM.h"
#import "KenDeviceDM.h"
#import "KenDeviceShareDM.h"

#import "thSDKlib.h"

@implementation KenDeviceS

- (void)deviceLoad:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"mobile/load.json"]
            requestInfo:nil start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    SafeHandleBlock(success, YES, nil, [KenMobileListDM initWithJsonDictionary:responseData]);
                }
            }];
}

- (void)deviceRemove:(NSString *)token
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"mobile/remove.json"] requestInfo:@{@"tokenOrMac":token}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    SafeHandleBlock(success, YES, nil, [KenMobileListDM initWithJsonDictionary:responseData]);
                }
            }];
}

- (void)deviceGetGroups:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"group/load.json"]
            requestInfo:nil start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                if ([[responseData objectForKey:@"result"] intValue] != 0) {
                    SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                } else {
                    NSMutableArray *groups = [NSMutableArray array];
                    NSArray *array = [responseData objectForKey:@"list"];
                    
                    if ([array count] > 0) {
                        for (int i = 0; i < [array count]; i++) {
                            [groups addObject:[[array objectAtIndex:i] objectForKey:@"name"]];
                        }
                    }
                    
                    SafeHandleBlock(success, YES, nil, groups);
                }
            }];
}

- (void)deviceSaveGroups:(NSArray *)groups
             success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"group/saveAll.json"] requestInfo:@{@"groupNames":[groups toJson]}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      if ([[responseData objectForKey:@"result"] intValue] != 0) {
                          SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                      } else {
                          SafeHandleBlock(success, YES, nil, nil);
                      }
                  }];
}

- (void)deviceSetGroupName:(NSString *)name groupNo:(NSInteger)groupNo
                 success:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed {
    NSDictionary *request = @{@"groupNo":[NSNumber numberWithInteger:groupNo], @"groupName":name};
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"group/save.json"] requestInfo:request
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      if ([[responseData objectForKey:@"result"] intValue] != 0) {
                          SafeHandleBlock(success, NO, [responseData objectForKey:@"message"], nil);
                      } else {
                          SafeHandleBlock(success, YES, nil, nil);
                      }
                  }];
}

- (void)deviceShareRegister:(KenDeviceDM *)device
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSDictionary *request = @{@"sn":device.sn, @"name":device.name, @"pwd":device.pwd, @"videoChlMask":@1,@"audioChlMask":@1};
    
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"plaza/register.json"] requestInfo:request
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      NSMutableArray * respenseListArr = [[NSMutableArray alloc] initWithArray:[responseData objectForKey:@"list"]];
                      SafeHandleBlock(success, YES, nil, [KenDeviceShareDM initWithJsonDictionary:[respenseListArr firstObject]]);
                  }];
}

- (void)deviceRemoveBySn:(NSString *)sn
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"camera/removeInfo.json"] requestInfo:@{@"sn":sn}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, nil);
                  }];
}

- (void)deviceChangeGroup:(NSString *)sn group:(NSInteger)groupNo
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    [self httpAsyncPost:[kAppServerHost stringByAppendingString:@"camera/move.json"]
            requestInfo:@{@"sn":sn, @"groupNo":[NSNumber numberWithInteger:groupNo]}
                  start:start successBlock:success failedBlock:failed responseBlock:^(NSDictionary *responseData) {
                      SafeHandleBlock(success, YES, nil, nil);
                  }];
}

#pragma mark - setting
- (void)deviceLoadInfo:(KenDeviceDM *)device
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=28", device.usr, device.pwd];
    [self deviceSettingWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetLed:(KenDeviceDM *)device isOn:(BOOL)isOn
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=87&INFO_Led_Onoff=%d", device.usr, device.pwd, isOn];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetIrcut:(KenDeviceDM *)device isOn:(BOOL)isOn
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=89&INFO_IRCut_Onoff=%d", device.usr, device.pwd, isOn ? 40 : 1];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetAlarm:(KenDeviceDM *)device isOn:(BOOL)isOn
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=88&INFO_Alarm_Sound_Onoff=%d", device.usr, device.pwd, isOn];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetMove:(KenDeviceDM *)device isOn:(BOOL)isOn sensitive:(NSInteger)sensitive
                start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=46&MD_Active=%d&MD_Sensitive=%zd", device.usr, device.pwd, isOn, sensitive];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetAudio:(KenDeviceDM *)device isOn:(BOOL)isOn sensitive:(NSInteger)sensitive
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=42&AUDIO_SoundTriggerActive=%d&AUDIO_SoundTriggerSensitive=%zd", device.usr, device.pwd, isOn, sensitive];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetRecordType:(KenDeviceDM *)device type:(NSInteger)type
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=56&Rec_RecStyle=%zd", device.usr, device.pwd, type];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetAlarmTime:(KenDeviceDM *)device startH:(NSString *)startH startM:(NSString *)startM endH:(NSString *)endH endM:(NSString *)endM
                     start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=90&start_time_hour=%@&start_time_min=%@&end_time_hour=%@&end_time_min=%@", device.usr, device.pwd, startH, startM, endH, endM];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceClearSDCard:(KenDeviceDM *)device
                    start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=77", device.usr, device.pwd];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceSetTime:(KenDeviceDM *)device
                start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=17&time=%@", device.usr, device.pwd, [[NSDate date] stringWithFormat:@"yyyyMMddHHmmss"]];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceReboot:(KenDeviceDM *)device
               start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=18", device.usr, device.pwd];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

#pragma mark - device control get
- (void)deviceScanStop:(KenDeviceDM *)device
                 start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=13&cmd=2&sleep=400", device.usr, device.pwd];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceScanUpDown:(KenDeviceDM *)device
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=13&cmd=33&autotype=2", device.usr, device.pwd];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceScanLeftRight:(KenDeviceDM *)device
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=13&cmd=33&autotype=1", device.usr, device.pwd];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceTurnUpDown:(KenDeviceDM *)device flip:(BOOL)flip
                   start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=40&VIDEO_IsFlip=%d", device.usr, device.pwd, flip ? 0 : 1];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

- (void)deviceTurnLeftRight:(KenDeviceDM *)device mirror:(BOOL)mirror
                      start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    NSString *param = [NSString stringWithFormat:@"?User=%@&Psd=%@&MsgID=40&VIDEO_IsMirror=%d", device.usr, device.pwd, mirror ? 0 : 1];
    [self deviceControlWithParam:param device:device start:start success:success failed:failed];
}

#pragma mark - prvate method
- (void)deviceControlWithParam:(NSString *)param device:(KenDeviceDM *)device
                         start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    if (device.isDDNS) {
        NSString *host = [NSString stringWithFormat:@"http://%@:%zd/cfg.cgi", device.currentIp, [device httpport]];
        
        [self asyncGet:[host stringByAppendingString:param] queryParams:nil startBlock:^{
        } responsedBlock:^(NSString *responseData) {
            if ([responseData equalsIgnoreCase:@"OK"] || [responseData equalsIgnoreCase:@"YES"]) {
                SafeHandleBlock(success, YES, nil, nil);
            } else {
                SafeHandleBlock(success, NO, nil, nil);
            }
        } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    } else {
        NSString *responseData = [self p2pMessageSend:param device:device];
        if ([responseData isKindOfClass:[NSString class]] && [responseData isEqualToString:@"OK"]) {
            SafeHandleBlock(success, YES, nil, nil);
        } else {
            SafeHandleBlock(success, NO, nil, nil);
        }
    }
}

- (void)deviceSettingWithParam:(NSString *)param device:(KenDeviceDM *)device
                         start:(RequestStartBlock)start success:(ResponsedSuccessBlock)success failed:(RequestFailureBlock)failed {
    if (device.isDDNS) {
        NSString *host = [NSString stringWithFormat:@"http://%@:%zd/cfg.cgi", device.currentIp, [device httpport]];
        
        [self asyncGet:[host stringByAppendingString:param] queryParams:nil startBlock:^{
        } responsedBlock:^(NSString *responseData) {
            SafeHandleBlock(success, YES, nil, responseData);
        } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    } else {
        NSString *responseData = [self p2pMessageSend:param device:device];
        if ([responseData isKindOfClass:[NSString class]]) {
            SafeHandleBlock(success, YES, nil, responseData);
        }
    }
}

- (NSString *)p2pMessageSend:(NSString *)param device:(KenDeviceDM *)device {
    NSString *url = [kConnectP2pHost stringByAppendingString:param];
    
    bool ret;
    char Buf[65536];
    int BufLen;
    
    if(!thNet_IsConnect(device.connectHandle)) {
        int64_t handle;
        thNet_Init(&handle, 11);
        ret = thNet_Connect_P2P(handle, 0, (char *)[device.uid UTF8String], (char *)[device.uidpsd UTF8String], 10000, YES);
        device.connectHandle = handle;
        if (!ret) return nil;
    }
    
    thNet_HttpGet(device.connectHandle, (char *)[url UTF8String], Buf, &BufLen);
    
    return [NSString stringWithFormat:@"%s" , Buf];
}

@end
