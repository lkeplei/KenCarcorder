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

//初始化，特定给回放用
- (instancetype)initHistoryWithDevice:(KenDeviceDM *)device frame:(CGRect)frame;

//开始视频
- (void)showVideoWithDevice:(KenDeviceDM *)device;
//结束视频
- (void)finishVideo;
//停止视频播放
- (void)stopVideo;
//开始视频播放
- (void)rePlay;
//拍照
- (void)capture;
//录像
- (void)recordVideo;
//分享视频
- (void)shareVedio;

#pragma mark - 回放相关
//停止回放
- (void)stopRecorder;
//暂停正在播放的历史文件
- (void)pauseRecorder;
//恢复播放
- (NSUInteger)recoverRecorder;
//播放历史文件
- (void)playRecorder:(NSString *)filePath;
//快进
- (NSUInteger)recorderSpeed;
//快退
- (NSUInteger)recorderRewind;
//下载正在播放的文件，如果当前没有播放历史文件，则不下载
- (void)downloadRecorder;

@end
