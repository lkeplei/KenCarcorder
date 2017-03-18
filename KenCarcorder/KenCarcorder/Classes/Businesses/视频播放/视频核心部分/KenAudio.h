//
//  KenAudio.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <MediaPlayer/MPMusicPlayerController.h>

#import "thSDKlib.h"

#define NUM_BUFFERS 3
#define NUM_RECBUFFERS 2
#define MIN_SIZE_PER_FRAME 1024*4 //每侦最小数据长度
typedef struct _circular_buffer {
    char *buffer;
    int  wp;
    int rp;
    int size;
} circular_buffer;

@interface KenAudio : NSObject{
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;
    UInt32 bufferByteSize;
    uint8_t *inbuf;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    
    AudioStreamBasicDescription audioRecordDescription;///音频参数
    AudioQueueRef audioRecordQueue;//音频播放队列
    AudioQueueBufferRef audioRecordQueueBuffers[NUM_RECBUFFERS];//音频缓存
    AudioFileID fileId;
}


@property AudioQueueRef queue;
@property AudioQueueRef audioRecordQueue;
@property int64_t NetHandle;

- (instancetype)initAudio;
- (void)playAudio:(char*)Buf length:(int)len;
- (int)readbuf:(char*)Buf length:(int)len;
- (void)cleanAudio;

- (void)initRecordAudio;
- (void)pauseRecord;
- (void)reStartRecord;
- (void)stopRecord;

circular_buffer* create_circular_buffer(int bytes);
int checkspace_circular_buffer(circular_buffer *p, int writeCheck);
int read_circular_buffer_bytes(circular_buffer *p, char *out, int bytes);
int write_circular_buffer_bytes(circular_buffer *p, const char *in, int bytes);
void free_circular_buffer (circular_buffer *p);

@end
