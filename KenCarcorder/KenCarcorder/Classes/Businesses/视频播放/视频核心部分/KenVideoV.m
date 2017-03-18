//
//  KenVideoV.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenVideoV.h"
#import "KenAlertView.h"
#import "KenDeviceDM.h"

//#define kHardDecode                 //是否硬解码

@interface KenVideoV ()<VideoFrameDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceDM;

@property (nonatomic, strong) UIImageView *screenImageV;

@end

@implementation KenVideoV

KenVideoV *retVideoSelf;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        retVideoSelf = self;
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
        if ([_deviceDM isDDNS]) {
//            _videoConnected = YES;
            [self connectFinish:Width0 highH:Height0 highRate:FrameRate0 lowW:Width1 lowH:Height1 lowRate:FrameRate1];
            //调用connectFinish通知子类做相关的视频发送以及一些视频播放与解析的准备工作
        } else {
            if (ken_createThreadP2p(_deviceDM.connectHandle) == 0) {
//                _videoConnected = YES;
                [self connectFinish:Width0 highH:Height0 highRate:FrameRate0 lowW:Width1 lowH:Height1 lowRate:FrameRate1];
                //先创建线程接收p2p的转发回来的数据，ddns的这一步在thNet_Connect的时候就已经做掉了，线程如果创建成功就一样的调用connectFinish进行通知
            } else {
                [KenAlertView showAlertViewWithTitle:@"提示" contentView:nil message:@"视频数据获取失败，请退出重试" buttonTitles:@[@"确定"]
                                  buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                                  
                                  }];
            }
        }
        
//        //如果视频连接上了以后，获取一下设备的信息
//        [self completeDeviceInfo];
    }
    
    //    [_deviceDM setDeviceIsConnecting:NO];
}

- (KenVideoV *)videoCallBack:(int64_t)handle {
    return handle == self.deviceDM.connectHandle ? self : nil;
}

void avConnectCallBack(TDataFrameInfo* PInfo, char* Buf, int Len, void* UserCustom) {
    int64_t handle = (int64_t)UserCustom;
    
    if (retVideoSelf == nil) {
        return;
    }
    
    __weak KenVideoV *baseV = [retVideoSelf videoCallBack:handle];
    if (baseV) {
        if (handle != [baseV.deviceDM connectHandle]) return;
        
        if (PInfo->Head.VerifyCode == Head_VideoPkt) {
            //8.0以上系统走硬解码
#ifdef kHardDecode
            [baseV.h264Decoder decodeFrame:(uint8_t *)Buf withSize:Len]; //硬解码
            if (baseV.video.isRecording || baseV.video._cap) {
                [[baseV video] manageRecorder:Buf len:Len]; //把数据发给video
            }
#else
            [[baseV video] manageData:Buf len:Len];
#endif
        }
        
//        if (PInfo->Head.VerifyCode == Head_AudioPkt && [KenUtils isNotEmpty:[baseV audio]]) {
//            //声音打开
//            if ([baseV playAudio]) {
//                [[baseV audio] playAudio:Buf length:Len]; //发送播放音频数据 Audio.h
//                [[baseV video] manageAudioData:Buf len:Len]; // VideoFrameExtractor.h
//            }
//        }
        
        [baseV pareFrameData:Len frameId:PInfo->Frame.FrameID];
    } else {
//        if ([retVideoSelf isKindOfClass:[YDVedioMiniControlV class]]) {
//            thNet_DisConn(handle);
//        }
    }
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

#pragma mark - 软解数据显示
- (void)updateVideoFrame:(VideoFrame *)frame {
    [self performSelectorOnMainThread:@selector(updateFrame) withObject:nil waitUntilDone:YES];

    if (frame == nil) {
//        if (_videoConnected) {
//            [self performSelectorOnMainThread:@selector(updateFrame) withObject:nil waitUntilDone:YES];
//        } else {
//            [self showLoadingV];
//        }
    } else {
        if (thNet_IsConnect(_deviceDM.connectHandle)) {
//            [_moviceGLView render:frame];
        } else {
//            [self showLoadingV];
        }
    }
}

- (void)updateFrame {
    [self updateFrameWithImage:[_video currentImage]];
}

- (void)updateFrameWithImage:(UIImage *)image {
    if (image) {
        if (_screenImageV == nil) {
            _screenImageV = [[UIImageView alloc] initWithFrame:(CGRect){0,0,self.size}];
            [self addSubview:_screenImageV];
        }
        [_screenImageV setImage:image];
        
//        if ([KenUtils isNotEmpty:_screenVedioV]) {
//            [_screenVedioV setImage:image];
//            if (image !=_screenVedioV.image) {
//                image = nil;
//            }
//        } else {
//            _screenVedioV = [[UIImageView alloc] initWithFrame:(CGRect){_moviceGLView.origin, _moviceGLView.size}];
//            [_screenVedioV setImage:image];
//            if (image !=_screenVedioV.image) {
//                image = nil;
//            }
//            
//            [_zoomScrollView setZoomView:_screenVedioV];
//            
//            [self initRecorderV];
//        }
//        
//        if (self.getImageBlock) {
//            self.getImageBlock(image);
//        }
//        
//        [self hideLodingView];
//        
//        if (self.statusChangeBlock) {
//            self.statusChangeBlock(kYDVedioStatusGetImageData);
//        }
    }
}

#pragma mark - 自定义部分
- (void)connectFinish:(int)highW highH:(int)highH highRate:(int)highRate lowW:(int)lowW lowH:(int)lowH lowRate:(int)lowRate //视频清晰度
{
    self.video = [[KenVideoFrameExtractor alloc] initCnx:highW hei:highH rate:highRate * 4 / 5];
    if (self.video) {
        [self.video set_record:NO];
        [self.video set_recordEnd:NO];
        [self.video set_recordStart:NO];
        
        self.video.delegate = self;
//        [self.moviceGLView set_decoder:self.video];
        
//        self.audio = [[KenAudio alloc] initAudio];
//        UInt32 category = kAudioSessionCategory_PlayAndRecord;
//        OSStatus error;
//        
//        AudioSessionInitialize(NULL, NULL, NULL, NULL);
//        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
//        
//        if (error)
//            DebugLog("couldn't set audio category!");
//        
//        [self.audio initRecordAudio];
//        self.playAudio = YES;
    }
//
//    _stopPlay = NO;
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        BOOL res = thNet_Play(_deviceDM.connectHandle, 1, 1, 0);
        if (res) {
//            _stopPlay = YES;
        } else {
            [self performSelectorOnMainThread:@selector(rePlay) withObject:nil waitUntilDone:YES];
        }
    }
    
//    [self.audio pauseRecord];
}

#pragma mark - event
- (void)rePlay {
//    if (!_stopPlay) {
        if (thNet_IsConnect(_deviceDM.connectHandle)) {
            BOOL res = thNet_Play(_deviceDM.connectHandle, 1, 1, 0);//
            if (res) {
//                _stopPlay = YES;
            } else {
                [self performSelector:@selector(rePlay) withObject:nil afterDelay:2];
            }
        }
//    }
}

#pragma mark - private method
- (void)pareFrameData:(int)length frameId:(int)frameId {
//    BOOL moving = frameId == 17 ? YES : NO;
//    _isAnimation = moving;
//    _dataLength += length;
//    
//    if (self.lengthStatusBlock) {
//        self.lengthStatusBlock(length, moving);
//    }
}

//计算平均速度
- (void)calculatAverageSpeed {
//    NSUInteger length = self.dataLength / 1024 + (self.dataLength % 1024 > 512 ? 1 : 0);
//    NSUInteger speed = length;
//    if (_dataLengthArray == nil) {
//        _dataLengthArray = [NSMutableArray array];
//    }
//    
//    if ([_dataLengthArray count] >= 5) {
//        for (NSInteger i = 0; i < [_dataLengthArray count]; i++) {
//            if (i == [_dataLengthArray count] - 1) {
//                [_dataLengthArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:length]];
//            } else {
//                [_dataLengthArray replaceObjectAtIndex:i withObject:[_dataLengthArray objectAtIndex:i + 1]];
//                speed += [[_dataLengthArray objectAtIndex:i + 1] integerValue];
//            }
//        }
//        
//    } else {
//        [_dataLengthArray addObject:[NSNumber numberWithInteger:length]];
//        for (NSInteger i = 0; i < [_dataLengthArray count] - 1; i++) {
//            speed += [[_dataLengthArray objectAtIndex:i] integerValue];
//        }
//    }
//    
//    _averageSpeed = speed / [_dataLengthArray count];
}

@end
