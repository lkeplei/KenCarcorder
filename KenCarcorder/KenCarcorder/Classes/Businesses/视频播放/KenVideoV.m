//
//  KenVideoV.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenVideoV.h"

#import "KenDeviceDM.h"
#import "thSDKlib.h"

@interface KenVideoV ()

@property (nonatomic, strong) KenDeviceDM *deviceDM;

@end

@implementation KenVideoV

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - public method
- (void)showVideoWithDevice:(KenDeviceDM *)device {
    if (device == nil) {
        return;
    }
    
    _deviceDM = device;
    
    [self startVidthread];
}


#pragma mark - 视频连接与数据回调
- (void)startVidthread {
    if (!thNet_IsConnect(_deviceDM.connectHandle)) {
        int connectTimes = 0;
        int64_t handle = 0;
        if ([_deviceDM isDDNS]) //DDNS方式
        {
            char *IP = (char *)[[_deviceDM currentIp] cStringUsingEncoding:NSASCIIStringEncoding];
            char *usr = (char *)[_deviceDM.usr cStringUsingEncoding:NSASCIIStringEncoding];
            char *pwd = (char *)[_deviceDM.pwd cStringUsingEncoding:NSASCIIStringEncoding];
            int port = (int)_deviceDM.dataport;
            
            thNet_Init(&handle, 11);
            _deviceDM.connectHandle = handle;       //设置句柄和设备序列号
            
            while (!thNet_Connect(_deviceDM.connectHandle, usr, pwd, IP, IP, port, 3000, 1) && connectTimes < 2) {
                // 句柄 用户名 密码 服务器IP 设备IP 端口号 超时时间 开启接收线程
                ++connectTimes ;
            }
        } else {
            char *uid = (char *)[_deviceDM.uid UTF8String];
            char *uidpsd = (char *)[_deviceDM.uidpsd UTF8String];
            
            if (!thNet_IsConnect(_deviceDM.connectHandle)) {
                thNet_Init(&handle, 11);
                _deviceDM.connectHandle = handle;       //设置句柄和设备序列号
                int status = 0;
                while (status != 1 && connectTimes < 1) {
                    //                    status = thNet_Connect_P2P(_deviceInfo.connectHandle, 0, uid, uidpsd, 10000, true);
                    status = ken_Connect_P2P(_deviceDM.connectHandle, 0, uid, uidpsd, 10000, true);
                    
                    ++connectTimes;
                    if (status == -20009) { //密码错误
                        //                        [_deviceDM setDeviceLock:YES];
                        //                        [self showvideo];
                        return;
                    } else if(status == IOTC_ER_NOT_INITIALIZED) {
                        ken_InitializeP2p();
                        connectTimes = 0;
                    } else if (status == AV_ER_NOT_INITIALIZED) {
                        avInitialize(254);
                        connectTimes = 0;
                    } else {
                        //                        [_deviceDM setDeviceLock:NO];
                    }
                }
            }
        }
    }
    
    thNet_SetCallBack(_deviceDM.connectHandle, avConnectCallBack, alarmConnetCallBack, (void*)_deviceDM.connectHandle);
    
    int Standard;
    int VideoType;
    int IsMirror;
    int IsFlip;
    int Width0;
    int Height0;
    int FrameRate0;
    int BitRate0;
    int Width1;
    int Height1;
    int FrameRate1;
    int BitRate1;
    
    thNet_GetVideoCfg1(_deviceDM.connectHandle, &Standard, &VideoType, &IsMirror, &IsFlip,
                       &Width0, &Height0, &FrameRate0, &BitRate0,
                       &Width1, &Height1, &FrameRate1, &BitRate1);
    
    //    _isMirror = IsMirror;
    //    _isFlip = IsFlip;
    
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        //        if ([_deviceDM isDDNS]) {
        //            _videoConnected = YES;
        //            [self connectFinish:Width0 highH:Height0 highRate:FrameRate0 lowW:Width1 lowH:Height1 lowRate:FrameRate1];
        //            //调用connectFinish通知子类做相关的视频发送以及一些视频播放与解析的准备工作
        //        } else {
        //            if (ken_createThreadP2p(_deviceDM.connectHandle) == 0) {
        //                _videoConnected = YES;
        //                [self connectFinish:Width0 highH:Height0 highRate:FrameRate0 lowW:Width1 lowH:Height1 lowRate:FrameRate1];
        //                //先创建线程接收p2p的转发回来的数据，ddns的这一步在thNet_Connect的时候就已经做掉了，线程如果创建成功就一样的调用connectFinish进行通知
        //
        //            } else {
        //                KenCustomAlert *alert = [[KenCustomAlert shareAlert] initWithTitle:@"提示" message:@"视频数据获取失败，请退出重试"
        //                                                                 cancelButtonTitle:nil confirmButtonTitle:@"确定"];
        //                alert.alertBlock = ^(NSInteger index) {
        //
        //                };
        //            }
        //        }
        //        
        //        //如果视频连接上了以后，获取一下设备的信息
        //        [self completeDeviceInfo];
    }
    
    //    [_deviceDM setDeviceIsConnecting:NO];
}

void avConnectCallBack(TDataFrameInfo* PInfo, char* Buf, int Len, void* UserCustom) {
    int64_t handle = (int64_t)UserCustom;
    
//    if (retVideoBaseSelf == nil) {
//        return;
//    }
//    
//    __weak YDVideoBaseV *baseV = [retVideoBaseSelf videoCallBack:handle];
//    YDDeviceInfo *_deviceInfo = baseV.deviceInfo;
//    if ([KenUtils isNotEmpty:baseV]) {
//        if([baseV videoClose] || handle == 0) {
//            return;
//        }
//        
//        if (handle != [baseV.deviceInfo connectHandle]) return;
//        
//        if (PInfo->Head.VerifyCode == Head_VideoPkt) {
//            //8.0以上系统走硬解码
//            if (kIsIOS8) {
//                [baseV.h264Decoder decodeFrame:(uint8_t *)Buf withSize:Len]; //硬解码
//                if (baseV.video.isRecording || baseV.video._cap) {
//                    [[baseV video] manageRecorder:Buf len:Len]; //把数据发给video
//                }
//            } else {
//                [[baseV video] manageData:Buf len:Len];
//            }
//        }
//        
//        if (PInfo->Head.VerifyCode == Head_AudioPkt && [KenUtils isNotEmpty:[baseV audio]]) {
//            if ([baseV playAudio]) //声音打开
//            {
//                [[baseV audio] playAudio:Buf length:Len]; //发送播放音频数据 Audio.h
//                [[baseV video] manageAudioData:Buf len:Len]; // VideoFrameExtractor.h
//            }
//        }
//        
//        [baseV pareFrameData:Len frameId:PInfo->Frame.FrameID];
//    } else {
//        if ([retVideoBaseSelf isKindOfClass:[YDVedioMiniControlV class]]) {
//            thNet_DisConn(handle);
//        }
//    }
//    
//    //****************************// 上传数据包
//    if (hSocketOpen) {
//        SendBuf(hSocketServer, (char *)PInfo, sizeof(TDataFrameInfo));
//        SendBuf(hSocketServer, Buf, Len);
//    }
}

void alarmConnetCallBack(int AlmType, int AlmTime, int AlmChl, void* UserCustom) {
    int64_t handle = (int64_t)UserCustom;
    if (handle == 0) return;
    
//    if (AlmTime == 0 && AlmChl == 0) {
//        DebugLog("Msg_StopPlayRecFile");
//        if (retVideoBaseSelf) {
//            if (retVideoBaseSelf.statusChangeBlock) {
//                retVideoBaseSelf.statusChangeBlock(kYDVedioStatusRecPlayStop);
//            }
//        }
//        //        if (AlmType == Msg_StopPlayRecFile) {
//        
//        //        }
//    }
}

@end
