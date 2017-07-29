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
#import "KenDeviceShareDM.h"
#import "KenZoomScrollView.h"

typedef NS_ENUM(NSUInteger, YDRecorderStatusType) {         //录像指令状态
    kYDRecorderStatusNone = 0,                              //未知
    kYDRecorderStatusPlay = 1,                              //播放
    kYDRecorderStatusPause = 2,                              //暂停
    kYDRecorderStatusStop = 3,                              //停止
    kYDRecorderStatusFastBackward = 4,                              //进退
    kYDRecorderStatusFastForward = 5,                              //快进
    kYDRecorderStatusStepBackward = 6,                              //
    kYDRecorderStatusStepForward = 7,                              //未知
    kYDRecorderStatusDragPos = 8,                              //未知
};

//#define kHardDecode                 //是否硬解码

@interface KenVideoV ()<VideoFrameDelegate>

@property (nonatomic, assign) BOOL isAnimation;             //画面是否在动
@property (nonatomic, assign) NSUInteger dataLength;        //数据大小
@property (nonatomic, assign) CGFloat totalLength;          //总大小

@property (nonatomic, strong) KenDeviceDM *deviceDM;
@property (nonatomic, strong) NSMutableArray *dataLengthArray;
@property (nonatomic, strong) UIImageView *screenImageV;
@property (nonatomic, strong) KenZoomScrollView *zoomScrollView;

@property (nonatomic, strong) UIView *recorderBgV;          //录像时的背景框
@property (nonatomic, strong) UILabel *recorderTimeLab;
@property (nonatomic, assign) NSUInteger timeLength;        //录像时长

@property (nonatomic, assign) BOOL isRecorder;              //是否为播放录像状态
@property (nonatomic, assign) BOOL isRecorderPlaying;       //是否正在播放录像
@property (nonatomic, strong) NSString *recorderFileName;   //录像名
@property (nonatomic, assign) NSUInteger vedioPlaySpeed;    //回看视频速度
@property (nonatomic, assign) BOOL isFastForward;           //是否为快进状态，YES为快进状态，NO为快退状态，都只在速度不为1的时候才有效

@end

@implementation KenVideoV

KenVideoV *retVideoSelf;


bool hSocketOpen = false; //连接状态
int hSocketServer; //服务器连接

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        retVideoSelf = self;
        _isRecorderPlaying = NO;
        _isRecorder = NO;
        self.vedioPlaySpeed = 1;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (instancetype)initHistoryWithDevice:(KenDeviceDM *)device frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        retVideoSelf = self;
        _isRecorderPlaying = NO;
        _isRecorder = YES;
        _deviceDM = device;
        _playAudio = YES;
        _vedioPlaySpeed = 1;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - public method
- (void)showVideoWithDevice:(KenDeviceDM *)device {
    if (device == nil && _deviceDM == nil) {
        return;
    }
    
    if (_deviceDM == nil) {
        _deviceDM = device;
        _playAudio = YES;
        
        [self makeToastActivity];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;        //不自动锁屏
    [Async background:^{
        [self startVidthread];
    }];
}

- (void)finishVideo {
    [UIApplication sharedApplication].idleTimerDisabled = NO;        //自动锁屏

    [self finishRecorder];
    
    [self disconnectVideo];
    
    if (self.audio) {
        [self.audio cleanAudio];
    }
}

- (void)finishRecorder {
    if (thNet_IsConnect(_deviceDM.connectHandle) && _video.isRecording) {
        [_video endRecord];
    }
    
    _recorderBgV.hidden = YES;
}

- (void)disconnectVideo {
    [Async background:^{
        thNet_RemoteFileStop(_deviceDM.connectHandle);
        thNet_Stop(_deviceDM.connectHandle);
        
        thNet_DisConn(_deviceDM.connectHandle);
        //    thNet_Free(&_videoConnectHandle);
    }];
    
    _deviceDM.connectHandle = 0;
}

- (void)stopVideo {
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        thNet_Stop(_deviceDM.connectHandle);
    }
}

- (void)rePlay {
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        if (!thNet_Play(_deviceDM.connectHandle, 1, 1, 0)) {
            [Async mainAfter:1 block:^{
                [self rePlay];
            }];
        }
    }
}

- (void)capture {
    [_video capturePhoto];
}

- (void)recordVideo {
    if(thNet_IsConnect(_deviceDM.connectHandle)) {
        if (_video.isRecording) {
            [_video endRecord];
            self.recorderBgV.hidden = YES;
            
            [[KenGCDTimerManager sharedInstance] cancelTimerWithName:@"videoRecord"];
        } else {
            NSString *filePath = [[[KenCarcorder shareCarcorder] getRecorderFolder] stringByAppendingFormat:@"/1.mp4"];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            
            _video.filename = filePath;
            [_video startRecord];
            
            self.recorderBgV.hidden = NO;
            _timeLength = 0;
            
            @weakify(self)
            [[KenGCDTimerManager sharedInstance] scheduledTimerWithName:@"videoRecord" timeInterval:1 queue:nil repeats:YES
                                                           actionOption:kKenGCDTimerAbandon action:^{
                @strongify(self)
                [Async main:^{
                    self.timeLength++;
                    self.recorderTimeLab.text = [self getTimeString:self.timeLength];
                }];
            }];
        }
    }
}

- (void)speakStart {
    self.playAudio = NO;
    [self.audio setNetHandle:_deviceDM.connectHandle];
    [self.audio reStartRecord];
    
    if (self.audio) {
        self.playAudio = NO;
    }
}

- (void)speakEnd {
    if (self.audio) {
        self.playAudio = YES;
    }
    
    [self.audio pauseRecord];
}

#pragma mark - 回放相关
- (void)stopRecorder {
    _isRecorderPlaying = NO;
    
    if (thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusPlay, 0, 0)) {
        [self reStopRecorder];
    } else {
        sleep(1);
        [self stopRecorder];
    }
}

- (BOOL)reStopRecorder {
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        if (!thNet_RemoteFileStop(_deviceDM.connectHandle)) {
            sleep(1);
            return [self reStopRecorder];
        } else {
            return YES;
        }
    }
    
    return NO;
}

- (NSUInteger)recoverRecorder {
    _isRecorderPlaying = YES;
    
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        self.vedioPlaySpeed = 1;
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusPlay, 0, 0);
    }
    
    return self.vedioPlaySpeed;
}

- (void)pauseRecorder {
    _isRecorderPlaying = NO;
    
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusPause, 1, 0);
    }
}

- (void)resumeRecorder {
    _isRecorderPlaying = YES;
    
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusPlay, 1, 0);
    }
}

- (void)playRecorder:(NSString *)filePath {
    if ([NSString isNotEmpty:filePath]) {
        if (thNet_IsConnect(_deviceDM.connectHandle) && self.video) {
            if (_isRecorderPlaying) {
                if ([filePath isEqualToString:_recorderFileName]) {
                    [self pauseRecorder];
                } else {
                    [self stopRecorder];
                    
                    [self playRecorder:filePath];
                }
            } else {
                if ([filePath isEqualToString:_recorderFileName]) {
                    [self resumeRecorder];
                } else {
                    _recorderFileName = filePath;
                    _isRecorderPlaying = YES;
                    [self rePlayRecorder];
                    
                    [self makeToastActivity];
                }
            }
        } else {
            _recorderFileName = filePath;
            [Async background:^{
                [self startVidthread];
            }];
        }
    } else {
        DebugLog("文件名不能为空");
    }
}

- (NSUInteger)recorderSpeed {
    if (_isFastForward) {
        _isFastForward = NO;
        self.vedioPlaySpeed = 1;
    } else {
        self.vedioPlaySpeed = _vedioPlaySpeed >= 32 ? 1 : _vedioPlaySpeed * 2;
    }
    
    if (_vedioPlaySpeed == 1) {
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusPlay, 0, 0);
    } else {
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusFastForward, (int)_vedioPlaySpeed, 0);
    }
    
    return _vedioPlaySpeed;
}

- (NSUInteger)recorderRewind {
    if (!_isFastForward) {
        _isFastForward = YES;
        self.vedioPlaySpeed = 1;
    } else {
        self.vedioPlaySpeed = _vedioPlaySpeed >= 32 ? 1 : _vedioPlaySpeed * 2;
    }
    
    if (_vedioPlaySpeed == 1) {
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusPlay, 0, 0);
    } else {
        thNet_RemoteFilePlayControl(_deviceDM.connectHandle, kYDRecorderStatusFastBackward, (int)_vedioPlaySpeed, 0);
    }
    
    return _vedioPlaySpeed;
}

- (void)downloadRecorder {
    
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
                    //status = thNet_Connect_P2P(_deviceDM.connectHandle, 0, uid, uidpsd, 10000, true);
                    status = ken_Connect_P2P(_deviceDM.connectHandle, 0, uid, uidpsd, 10000, true);
                    
                    ++connectTimes;
                    if (status == -20009) { //密码错误
                        [_deviceDM setDeviceLock:YES];
                        [[KenUserInfoDM sharedInstance] setDeviceLock:_deviceDM];
//                        [self showvideo];
                        return;
                    } else if(status == IOTC_ER_NOT_INITIALIZED) {
                        ken_InitializeP2p();
                        connectTimes = 0;
                    } else if (status == AV_ER_NOT_INITIALIZED) {
                        avInitialize(254);
                        connectTimes = 0;
                    } else {
                        [_deviceDM setDeviceLock:NO];
                        [[KenUserInfoDM sharedInstance] setDeviceLock:_deviceDM];
                    }
                }
            }
        }
    }
    
    thNet_SetCallBack(_deviceDM.connectHandle, avConnectCallBack, alarmConnetCallBack, (void*)_deviceDM.connectHandle);
    
    int Standard, VideoType, IsMirror, IsFlip, Width0, Height0, FrameRate0, BitRate0, Width1, Height1, FrameRate1, BitRate1;
    
    thNet_GetVideoCfg1(_deviceDM.connectHandle, &Standard, &VideoType, &IsMirror, &IsFlip, &Width0, &Height0,
                       &FrameRate0, &BitRate0, &Width1, &Height1, &FrameRate1, &BitRate1);
    
    _isMirror = IsMirror;
    _isFlip = IsFlip;
    
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        if ([_deviceDM isDDNS]) {
            [self connectFinish:Width0 highH:Height0 highRate:FrameRate0 lowW:Width1 lowH:Height1 lowRate:FrameRate1];
        } else {
            if (ken_createThreadP2p(_deviceDM.connectHandle) == 0) {
                {
                    NSString *param = [NSString stringWithFormat:@"cfg.cgi?User=%@&Psd=%@&MsgID=28", _deviceDM.usr, _deviceDM.pwd];
                    NSString *info = [self p2pMessageSendUrl:[kConnectP2pHost stringByAppendingString:param] device:_deviceDM];
                    DebugLog("info = %@", info);
                    
                    NSArray *array = [info componentsSeparatedByString:@"\r\n"];
                    
                    NSString *deviceWidth0 = @"";
                    NSString *deviceHeight0 = @"";
                    NSString *deviceFrameRate0 = @"";
                    
                    for (int i = 0; i< [array count]; i++) {
                        NSString * tmp = [array objectAtIndex:i];
                        if ([tmp rangeOfString:@"VIDEO_Width0"].length > 0) {
                            deviceWidth0 = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
                        }
                        if ([tmp rangeOfString:@"VIDEO_Height0"].length > 0) {
                            deviceHeight0 = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
                        }
                        if ([tmp rangeOfString:@"VIDEO_FrameRate0"].length > 0) {
                            deviceFrameRate0 = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
                        }
                    }
                    
                    deviceWidth0 = [deviceWidth0 stringByReplacingOccurrencesOfString:@";" withString:@""];
                    deviceWidth0 = [deviceWidth0 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    
                    deviceHeight0 = [deviceHeight0 stringByReplacingOccurrencesOfString:@";" withString:@""];
                    deviceHeight0 = [deviceHeight0 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    
                    deviceFrameRate0 = [deviceFrameRate0 stringByReplacingOccurrencesOfString:@";" withString:@""];
                    deviceFrameRate0 = [deviceFrameRate0 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    
                    Width0 = [deviceWidth0 intValue];
                    Height0 = [deviceHeight0 intValue];
                    FrameRate0 = [deviceFrameRate0 intValue];
                }
                
                [self connectFinish:Width0 highH:Height0 highRate:FrameRate0 lowW:Width1 lowH:Height1 lowRate:FrameRate1];
            } else {
                [KenAlertView showAlertViewWithTitle:@"提示" contentView:nil message:@"视频数据获取失败，请退出重试" buttonTitles:@[@"确定"]
                                  buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                                  
                                  }];
            }
        }
    }
}

- (NSString *)p2pMessageSendUrl:(NSString *)url device:(KenDeviceDM *)device {
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
        
        if (PInfo->Head.VerifyCode == Head_AudioPkt && baseV.audio) {
            if (baseV.playAudio) {
                [[baseV audio] playAudio:Buf length:Len]; //发送播放音频数据 Audio.h
                [[baseV video] manageAudioData:Buf len:Len]; // VideoFrameExtractor.h
            }
        }
        
        [baseV pareFrameData:Len frameId:PInfo->Frame.FrameID];
    }

    //****************************// 上传数据包
    if (hSocketOpen) {
        SendBuf(hSocketServer, (char *)PInfo, sizeof(TDataFrameInfo));
        SendBuf(hSocketServer, Buf, Len);
    }
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
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        if (frame) {
//            [_moviceGLView render:frame];
        } else {
            [Async main:^{
                [self updateFrameWithImage:[_video currentImage]];
            }];
        }
    } else {
//            [self showLoadingV];
    }
}

- (void)updateFrameWithImage:(UIImage *)image {
    if (image) {
        if (_screenImageV == nil) {
            //初始图像层
            _screenImageV = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, self.size}];
            
            _zoomScrollView = [[KenZoomScrollView alloc] initWithBlock:(CGRect){0, 0, self.size}
                                                                 block:^(CGRect rect) {
                                                                     _screenImageV.frame = rect;
                                                                 }];
            [_zoomScrollView setZoomView:_screenImageV];
            [self addSubview:_zoomScrollView];
        }
        [_screenImageV setImage:image];
        
        [self hideToastActivity];
    }
}

#pragma mark - 自定义部分
- (void)connectFinish:(int)highW highH:(int)highH highRate:(int)highRate lowW:(int)lowW lowH:(int)lowH lowRate:(int)lowRate {
    self.video = [[KenVideoFrameExtractor alloc] initCnx:highW hei:highH rate:highRate * 4 / 5];
    if (self.video) {
        self.video.delegate = self;
//        [self.moviceGLView set_decoder:self.video];
        
        self.audio = [[KenAudio alloc] initAudio];
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        OSStatus error;
        
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);

        if (error)
            DebugLog("couldn't set audio category!");
        
        [self.audio initRecordAudio];
    }
    
    if (_isRecorder) {
        [self rePlayRecorder];
    } else {
        [self rePlay];
    }
    
    [self.audio pauseRecord];
}

#pragma -- mark 视频分享
- (void)shareVedio {
    @weakify(self)
    [[KenServiceManager sharedServiceManager] deviceShareRegister:_deviceDM start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, KenDeviceShareDM *shareDM) {
        @strongify(self)
        if (shareDM) {
            [self sendCfgUnit:shareDM.serverHost upPort:shareDM.upPort];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
    }];
}

- (void)stopShareVedio {
    hSocketOpen = false;
}

- (BOOL)isSharing {
    return hSocketOpen;
}

//发送配置包
- (void)sendCfgUnit:(NSString *)IPAddress upPort:(NSInteger)upPort {
    if ([NSString isEmpty:IPAddress]) {
        return;
    }
    
    [Async background:^{
        hSocketServer = FastConnect((char *)[IPAddress UTF8String], upPort, 3000); //服务器链接
        if (hSocketServer > 0) {
            // 耗时的操作
            TNetCmdPkt Pkt;
            memset(&Pkt, 0, sizeof(Pkt));
            Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
            Pkt.HeadPkt.PktSize    = 1452;
            Pkt.CmdPkt.PktHead     = Head_CmdPkt;  //0xAAAAAAAA
            Pkt.CmdPkt.MsgID       = Msg_StartUploadFile;  //7
            Pkt.CmdPkt.Session     = 0;
            Pkt.CmdPkt.Value       = [_deviceDM.sn intValue];
            
            if (SendBuf(hSocketServer, (char*)&Pkt, sizeof(TNetCmdPkt))) {      //发送分享请求 msgID = 7
                memset(&Pkt, 0, sizeof(Pkt));
                if (RecvBuf1(hSocketServer, (char*)&Pkt, sizeof(TNetCmdPkt))) {      //接收登录请求包
                    TPlayParam* Play = (TPlayParam*)_deviceDM.connectHandle;
                    SendBuf(hSocketServer, (char*)&Play->loginPkt, sizeof(TNetCmdPkt)); //转发登录获取包
                    if (RecvBuf1(hSocketServer, (char*)&Pkt, sizeof(TNetCmdPkt))) {      //接收配置请求包
                        THeadPkt head;
                        head.VerifyCode = Head_CfgPkt;
                        head.PktSize    = sizeof(TDevCfg);
                        SendBuf(hSocketServer, (char*)&head, sizeof(THeadPkt)); //发送配置包头
                        
                        if (SendBuf(hSocketServer, (char*)&Play->DevCfg, sizeof(TDevCfg))) { //转发配置获取包
                            if (RecvBuf(hSocketServer, (char*)&Pkt, sizeof(Pkt))) {     //接收播放请求包
                                hSocketOpen = true;
                            }
                        }
                    }
                }
            }
        }
    }];
}

bool RecvBuf1(int hSocket, char* Buf, int BufLen) {
    if (!Buf) return false;
    if (BufLen == 0) return true;
    ssize_t Len, RecvLen;
    DWORD t, t1;
    RecvLen = 0;
    //  if not WaitForData(TimeOut) then exit;
    t = GetTickCount();
    while (true) {
#ifdef __cplusplus
        if (hSocket <=0) return false;
#endif
        Len = recv(hSocket, &Buf[RecvLen], BufLen - RecvLen, 0);
        if (Len != -1) {
            RecvLen = RecvLen + Len;
        } else {
            if (errno == EINTR || errno == EAGAIN) {
                t1 = GetTickCount();
                if (t1 - t >= NET_TIMEOUT) {
                    return false;
                }
                errno = 0;
                usleep(1000*10);
                continue;
            } else {
                if (errno != 0 ) {
                    errno = 0;
                }
                return false;
            }
        }
        if (RecvLen == BufLen) return true;
    }
}

#pragma mark - private method
- (void)pareFrameData:(int)length frameId:(int)frameId {
    BOOL moving = frameId == 17 ? YES : NO;
    _isAnimation = moving;
    _dataLength += length;
}

//计算平均速度
- (void)calculatAverageSpeed {
    NSUInteger length = self.dataLength / 1024 + (self.dataLength % 1024 > 512 ? 1 : 0);
    self.dataLength = 0;
    NSUInteger speed = length;
    if (_dataLengthArray == nil) {
        _dataLengthArray = [NSMutableArray array];
    }
    
    if ([_dataLengthArray count] >= 5) {
        for (NSInteger i = 0; i < [_dataLengthArray count]; i++) {
            if (i == [_dataLengthArray count] - 1) {
                [_dataLengthArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:length]];
            } else {
                [_dataLengthArray replaceObjectAtIndex:i withObject:[_dataLengthArray objectAtIndex:i + 1]];
                speed += [[_dataLengthArray objectAtIndex:i + 1] integerValue];
            }
        }
        
    } else {
        [_dataLengthArray addObject:[NSNumber numberWithInteger:length]];
        for (NSInteger i = 0; i < [_dataLengthArray count] - 1; i++) {
            speed += [[_dataLengthArray objectAtIndex:i] integerValue];
        }
    }
    
    NSUInteger averageSpeed = speed / [_dataLengthArray count];
    _totalLength += length;
    
    if (_totalLength > 1024) {
        _speed = [NSString stringWithFormat:@"%zd KB/S\n%.2f MB", averageSpeed, _totalLength / 1024];
    } else {
        _speed = [NSString stringWithFormat:@"%zd KB/S\n%.0f KB", averageSpeed, _totalLength];
    }
}

- (NSString *)getTimeString:(NSInteger)length {
    NSString *time = @"";
    
    if (length > 3600) {
        time = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", length / 3600, length % 3600 / 60, length % 3600 % 60];
    } else if (length > 60) {
        time = [NSString stringWithFormat:@"00:%02zd:%02zd", length / 60, length % 60];
    } else {
        time = [NSString stringWithFormat:@"00:00:%02zd", length];
    }
    
    return time;
}

#pragma mark - 视频控制相关
- (void)rePlayRecorder {
    if (thNet_IsConnect(_deviceDM.connectHandle)) {
        if (!thNet_RemoteFilePlay(_deviceDM.connectHandle, (char *)[_recorderFileName cStringUsingEncoding:NSASCIIStringEncoding])) {
            [Async mainAfter:1 block:^{
                [self rePlayRecorder];
            }];
        } else {
            _isRecorderPlaying = YES;
        }
    }
}

#pragma mark - getter setter 
- (NSString *)speed {
    [self calculatAverageSpeed];
    
    return _speed;
}

- (UIView *)recorderBgV {
    if (_recorderBgV == nil) {
        _timeLength = 0;
        _recorderBgV = [[UIView alloc] initWithFrame:(CGRect){(self.width - 200) / 2, 0, 200, 40}];
        [self addSubview:_recorderBgV];
        
        UIImageView *leftTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_rec_left_top"]]; //录像框
        leftTop.origin = CGPointMake((_recorderBgV.width - leftTop.width - 80) / 2, 10);
        [_recorderBgV addSubview:leftTop];
        
        _recorderTimeLab = [UILabel labelWithTxt:@"00:00:00"
                                           frame:(CGRect){CGRectGetMaxX(leftTop.frame) + 10, leftTop.originY, 70, leftTop.height}
                                            font:[UIFont appFontSize14] color:[UIColor colorWithHexString:@"#FF643B"]]; //录像时间计时器
        [_recorderBgV addSubview:_recorderTimeLab];
    }
    return _recorderBgV;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [_zoomScrollView resetFrame:(CGRect){0, 0, frame.size}];
}

@end
