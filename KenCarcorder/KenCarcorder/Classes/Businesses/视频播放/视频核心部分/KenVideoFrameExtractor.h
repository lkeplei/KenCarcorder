//
//  KenVideoFrameExtractor.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libavcodec/avcodec.h"

@class VideoFrame;

@protocol VideoFrameDelegate <NSObject>

- (void)updateVideoFrame:(VideoFrame*)frame;

@end

@interface MovieFrame : NSObject

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) CGFloat duration;

@end

@interface VideoFrame : MovieFrame

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

@end

@interface VideoFrameYUV : VideoFrame

@property (nonatomic, strong) NSData *luma;
@property (nonatomic, strong) NSData *chromaB;
@property (nonatomic, strong) NSData *chromaR;

@end

#pragma mark - KenVideoFrameExtractor
@interface KenVideoFrameExtractor : NSObject 

@property (nonatomic, readonly) UIImage *currentImage;      //当前图片
@property (atomic, assign) BOOL isRecording;                //是否正在录音

@property (nonatomic, assign) id <VideoFrameDelegate>delegate;

/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
- (instancetype)initCnx:(int)width hei:(int)height rate:(int)framerate;
- (BOOL)resetSetting:(int)width height:(int)height rate:(int)frameRate;
- (void)manageData:(char *)buf len:(int)len;
- (void)manageRecorder:(char *)buf len:(int)len;
- (void)manageAudioData:(char *)buf len:(int)len;

- (void)startRecord;            //开始录像
- (void)endRecord;              //结束录像
- (void)capturePhoto;           //拍照

@end
