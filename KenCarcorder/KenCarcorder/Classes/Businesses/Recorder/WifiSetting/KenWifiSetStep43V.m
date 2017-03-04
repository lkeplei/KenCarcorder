//
//  KenWifiSetStep43V.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep43V.h"
#import "Masonry.h"
#import "KenWifiSetStep4VC.h"
#import "KenRadarV.h"

#include "VoiceDecoder.h"
#include "voiceEncoder.h"
#include "voiceRecog.h"
#import <AVFoundation/AVFoundation.h>

//重载VoiceDecoder，主要是实现onRecognizerStart，onRecognizerEnd
@interface MyVoiceRecog : VoiceRecog

@property (nonatomic, assign) KenWifiSetStep43V *ui;

- (instancetype)initWithUI:(KenWifiSetStep43V *)_ui vdpriority:(VDPriority)_vdpriority;

@end

@implementation MyVoiceRecog

- (instancetype)initWithUI:(KenWifiSetStep43V *)ui vdpriority:(VDPriority)_vdpriority {
    self = [super init:_vdpriority];
    if (self) {
        _ui = ui;
    }
    return self;
}

- (void) onRecognizerStart {
    [_ui onRecognizerStart];
}

- (void) onRecognizerEnd:(int)result data:(char *)data dataLen:(int)dataLen {
    [_ui onRecognizerEnd:result data:data dataLen:dataLen];
}

@end

int freqs[] = {15000,15200,15400,15600,15800,16000,16200,16400,16600,16800,17000,17200,17400,17600,17800,18000,18200,18400,18600};
dispatch_source_t disTimer;

@interface KenWifiSetStep43V ()

@property (nonatomic, weak) KenWifiSetStep4VC *parentVC;
@property (nonatomic, strong) UILabel *label3;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) NSString *wifiName;
@property (nonatomic, strong) NSString *wifiPwd;
@property (nonatomic, strong) VoiceRecog *recog;
@property (nonatomic, strong) VoicePlayer *player;

@end

@implementation KenWifiSetStep43V

- (instancetype)initWithParentVC:(KenWifiSetStep4VC *)parentVC name:(NSString *)name pwd:(NSString *)pwd frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _parentVC = parentVC;
        _wifiName = name;
        _wifiPwd = pwd;
        
        [_recog start];
        
        [self initView];
    
        //声波初始
        AVAudioSession *mySession = [AVAudioSession sharedInstance];
        [mySession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        int base = 4000;
        for (int i = 0; i < sizeof(freqs)/sizeof(int); i ++) {
            freqs[i] = base + i * 150;
        }
    
        _recog = [[MyVoiceRecog alloc] initWithUI:self vdpriority:VD_MemoryUsePriority];
        [_recog setFreqs:freqs freqCount:sizeof(freqs)/sizeof(int)];
        _player = [[VoicePlayer alloc] init];
        [_player setFreqs:freqs freqCount:sizeof(freqs)/sizeof(int)];
    }
    return self;
}

- (void)dealloc {
    [_recog stop];
}

#pragma mark - private method
- (void)initView {
    UILabel *label1 = [UILabel labelWithTxt:@"长按 '声波发送按钮' 直到声波发送完毕，让行车记录仪连接上WIFI无线网"
                                      frame:(CGRect){20, 100, self.width - 40, 60}
                                       font:[UIFont appFontSize16] color:[UIColor appWhiteTextColor]];
    label1.numberOfLines = 0;
    [self addSubview:label1];
    
    UILabel *label2 = [UILabel labelWithTxt:@"没有听到声波信号？" frame:(CGRect){20, self.height - kKenOffsetY(300), self.width - 40, 20}
                                       font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
    [self addSubview:label2];
    
    _label3 = [UILabel labelWithTxt:@"" frame:(CGRect){20, self.height - kKenOffsetY(220), self.width - 40, 54}
                               font:[UIFont appFontSize15] color:[UIColor colorWithHexString:@"#DAF23F"]];
    _label3.numberOfLines = 0;
    [self addSubview:_label3];

    ////////////////////
    _sendBtn = [UIButton buttonWithImg:@"声波发送" zoomIn:NO image:nil imagesec:nil target:nil action:nil];
    CGFloat width = self.width / 4;
    _sendBtn.frame = (CGRect){(self.width - width) / 2, (self.height - width) / 2, width, width};
    _sendBtn.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:49 / 255.0 blue:71 / 255.0 alpha:1.0];
    _sendBtn.layer.cornerRadius = _sendBtn.width / 2;
    [self addSubview:_sendBtn];
    
    @weakify(self)
    [_sendBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self.player playSSIDWiFi:_wifiName pwd:_wifiPwd playCount:1 muteInterval:200];
        
        CGFloat sw = self.width / 2;
        disTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(disTimer, dispatch_walltime(NULL, 0), 0.5 * NSEC_PER_SEC, 0ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(disTimer, ^{
            KenRadarV *rv = [[KenRadarV alloc] initWithFrame:CGRectMake(0 , 0, sw / 2, sw / 2)];
            [rv animationWithDuraton:4.0];
            rv.center = _sendBtn.center;
            [self addSubview:rv];
        });
        dispatch_source_set_cancel_handler(disTimer, ^{
            _label3.text = @"绿灯已灭，设置成功，等待重启，选择将行车记录仪加入我的APP，进行远程连接";
            _sendBtn.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:49 / 255.0 blue:71 / 255.0 alpha:1.0];
        });
        dispatch_resume(disTimer);
    }];
    /////////////////////
}

#pragma mark - public method
- (void)onRecognizerStart {
    printf("--------recognize start\n");
}

- (void)onRecognizerEnd:(int)result data:(char *)data dataLen:(int)dataLen {
    NSString *msg = nil;
    char s[100];
    if (result == VD_SUCCESS) {
        printf("--------recognized data:%s\n", data);
        //title = @"recognize ok";
        enum InfoType infoType = vr_decodeInfoType(data, dataLen);
        if(infoType == IT_STRING) {
            vr_decodeString(result, data, dataLen, s, sizeof(s));
            printf("string:%s\n", s);
            msg = [NSString stringWithFormat:@"recognized string:%s", s];
        } else {
            printf("--------recognized data:%s\n", data);
            msg = [NSString stringWithFormat:@"recognized data:%s", data];
        }
    } else {
        printf("---------recognize invalid data, errorCode:%d, error:%s\n", result, [[self recorderRecogErrorMsg:result] UTF8String]);
    }
    
    if(msg != nil) {
        [Async main:^{
            dispatch_source_cancel(disTimer);
        }];
    };
}

#pragma mark - private method
//根据错误编号，获得错误信息，该函数不是必需的
- (NSString *)recorderRecogErrorMsg:(NSInteger)recogStatus {
    NSString *r = @"unknow error";
    switch(recogStatus) {
        case VD_ECCError:
            r = @"ecc error";
            break;
        case VD_NotEnoughSignal:
            r = @"not enough signal";
            break;
        case VD_NotHeaderOrTail:
            r = @"signal no header or tail";
            break;
        case VD_RecogCountZero:
            r = @"trial has expires, please try again";
            break;
    }
    return r;
}

@end
