//
//  KenVideoV.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KenAudio.h"
#import "KenVideoFrameExtractor.h"

@class KenDeviceDM;

@interface KenVideoV : UIView

@property (nonatomic, assign) BOOL playAudio;               //是否开启声音，默认开启
@property (nonatomic, assign) BOOL isMirror;                //是否为左右翻转状态
@property (nonatomic, assign) BOOL isFlip;                  //是否为上下翻转状态
@property (nonatomic, strong) NSString *speed;              //速度描述

@property (nonatomic, strong) KenVideoFrameExtractor *video;
@property (nonatomic, strong) KenAudio *audio;

//开始视频
- (void)showVideoWithDevice:(KenDeviceDM *)device;
//结束视频
- (void)finishVideo;
//结束录像
- (void)finishRecorder;
//断开与镜头的连接
- (void)disconnectVideo;
//拍照
- (void)capture;
//录像
- (void)recordVideo;

@end
