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
            if ([responseData isEqualToString:@"OK"]) {
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
