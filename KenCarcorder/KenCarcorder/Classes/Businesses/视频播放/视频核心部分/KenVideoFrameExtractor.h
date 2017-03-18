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

@interface KenVideoFrameExtractor : NSObject {
    AVFormatContext *pFormatCtx;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPicture picture;
    AVPacket packet;
    int videoStream;
    struct SwsContext *img_convert_ctx;
    int sourceWidth, sourceHeight;
    //int outputWidth, outputHeight;
    UIImage *currentImage;
    NSString *currentImagePath;
    double duration;
    uint8_t  *rawData;
    int bytesDecoded;
    
    bool _record;
    bool _recordStart;
    bool _recordEnd;
    NSString * filename;
    int _height;
    int _width;
    AVFormatContext *ocx;
}

/* Last decoded picture as UIImage */
@property (nonatomic, readonly) UIImage *currentImage;

/* Size of video frame */
@property (nonatomic, readonly) int sourceWidth, sourceHeight;

/* Output image size. Set to the source size by default. */
@property (nonatomic) int outputWidth, outputHeight;
@property int _height,_width;

/* Length of video in seconds */
@property (nonatomic, readonly) double duration;
@property Boolean _cap;
@property bool _record;
@property bool _recordStart;
@property bool _recordEnd;
@property (nonatomic , strong)NSString * filename;
@property (nonatomic , readonly)AVFormatContext *ocx;

- (int)bytesDecoded;

/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
- (id)initCnx:(int)width hei:(int)height rate:(int)framerate;
- (void)resetSetting:(int)width height:(int)height rate:(int)frameRate;
- (void)manageData:(char *)buf len:(int)len;
- (void)manageRecorder:(char *)buf len:(int)len;
- (void)manageAudioData:(char *)buf len:(int)len;

/* Seek to closest keyframe near specified time */
//-(void)saveVideo;
//-(void)writeVidBuffer;
//-(void)writeAudBuffer;
//-(void)writeTrailer;

@property(assign) id <VideoFrameDelegate>delegate;

@property (assign) BOOL needSaveImg;

@property (atomic, assign) BOOL isRecording;            //是否正在录音

@end
