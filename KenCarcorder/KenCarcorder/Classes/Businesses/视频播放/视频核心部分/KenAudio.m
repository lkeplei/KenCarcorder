//
//  KenAudio.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAudio.h"

typedef struct _circular_buffer {
    char *buffer;
    int wp;
    int rp;
    int size;
} circular_buffer;

@interface KenAudio (){
    uint8_t *inbuf;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    AudioQueueBufferRef audioRecordQueueBuffers[NUM_RECBUFFERS];//音频缓存
}

@property (nonatomic, assign) UInt32 bufferByteSize;
@property (nonatomic, assign) int64_t NetHandle;                //用于对讲的句柄

//播放
@property (nonatomic, assign) AudioQueueRef queue;
@property (nonatomic, assign) AudioStreamBasicDescription dataFormat;

//录音
@property (nonatomic, assign) AudioQueueRef audioRecordQueue;
@property (nonatomic, assign) AudioStreamBasicDescription audioRecordDescription;
@property (nonatomic, assign) AudioFileID fileId;

@end

@implementation KenAudio

static UInt32 gBufferSizeBytes = 0x800;

circular_buffer *outrb;
short *nextBuffer;
unsigned nextSize;
bool _isplay[NUM_BUFFERS];

circular_buffer *inrb;
bool audioset;

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
    KenAudio * player = (__bridge KenAudio*)inUserData;
    if (!audioset) {
        audioset = true;
        [player resetOutputTarget];
    }
    
    //写进buffer
    int index = 0;
    for(int i = 0; i < NUM_BUFFERS; i++) {
        if(player->buffers[i] == buffer)
            index = i;
    }
    
    //    int len = read_circular_buffer_bytes(outrb, (char *)nextBuffer,nextSize);
    int len = -1;
    if (checkspace_circular_buffer(outrb, 0) > 1024) {
        len = read_circular_buffer_bytes(outrb, (char *)nextBuffer,nextSize);
    }
    
    if (len > 0) {
        memcpy(buffer->mAudioData, nextBuffer, nextSize);
        buffer->mAudioDataByteSize = len;
        AudioQueueEnqueueBuffer(inAQ, buffer, 0, NULL);
    } else {
        _isplay[index] = false;
        int cnt = 0;
        for (int i=0; i<NUM_BUFFERS; i++) {
            if (!_isplay[i]) {
                cnt++;
            }
        }
        
        if (cnt == NUM_BUFFERS) {
            AudioQueueStop(inAQ, true);
        }
    }
}

- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        DebugLog("AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        DebugLog("AudioRoute: %@", routeStr);
        
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}

- (void)resetOutputTarget {
    // BOOL hasHeadset = [self hasHeadset];
    BOOL hasHeadset = NO;
    
    UInt32 audioRouteOverride = hasHeadset ? kAudioSessionOverrideAudioRoute_None:kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

#pragma mark - audio
//音频播放方法的实现
- (instancetype)initAudio {
    self = [super init];
    if (self) {
        audioset = false;
        
        //取得音频数据格式
        //    {
        //        dataFormat.mSampleRate=8000;//采样频率
        //        dataFormat.mFormatID=kAudioFormatLinearPCM;
        //        dataFormat.mFormatFlags=kLinearPCMFormatFlagIsBigEndian
        //        | kAudioFormatFlagIsPacked;;
        //        dataFormat.mBytesPerFrame=2;
        //        dataFormat.mBytesPerPacket=2;
        //        dataFormat.mFramesPerPacket=1;//wav 通常为1
        //        dataFormat.mChannelsPerFrame=1;//通道数
        //        dataFormat.mBitsPerChannel=16;//采样的位数
        //        dataFormat.mReserved=1;
        //    }
        
        _dataFormat.mSampleRate = 8000.0f;
        _dataFormat.mFormatID = kAudioFormatLinearPCM;
        _dataFormat.mFramesPerPacket = 1;
        _dataFormat.mChannelsPerFrame = 1;
        _dataFormat.mBytesPerFrame = 2;
        _dataFormat.mBytesPerPacket = 2;
        _dataFormat.mBitsPerChannel = 16;
        _dataFormat.mReserved = 0;
        _dataFormat.mFormatFlags =
        kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //创建播放用的音频队列
        AudioQueueNewOutput(&_dataFormat, BufferCallback, (__bridge void *)(self),nil, nil, 0, &_queue);
        
        //初始化音频缓冲区
        for (NSUInteger i = 0; i < NUM_BUFFERS; i++) {
            AudioQueueAllocateBuffer(_queue, gBufferSizeBytes, &buffers[i]);
            //创建buffer区，MIN_SIZE_PER_FRAME(2048)为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
            _isplay[i] = false;
        }
        
        [self resetOutputTarget];
        Float32 gain=2.0;
        //设置音量
        AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, gain);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //        [KenUtils setSysVOlueVoice:0.7];
        });
        
        //队列处理开始，此后系统开始自动调用回调(Callback)函数
        outrb = create_circular_buffer(2048 * sizeof(int) * 2000);
        nextBuffer = (short *) malloc (sizeof(short) * 2048);
        
        nextSize = 2048;
    }
    
    return self;
}

//解析播放音频
- (void)playAudio:(char *)Buf length:(int)len {
    NSUInteger cnt = 0;
    for (NSUInteger i = 0; i < NUM_BUFFERS; i++) {
        if (!_isplay[i]) {
            cnt++;
        }
    }
    
    if (NUM_BUFFERS == cnt) {
        write_circular_buffer_bytes(outrb, Buf,len);
        if ( checkspace_circular_buffer(outrb, 0) >= 0x1800) {
            AudioQueueStart(_queue, nil);
            
            for (NSUInteger i = 0; i < NUM_BUFFERS; i++) {
                _isplay[i] = true;
            }
            
            for (NSUInteger i = 0; i < NUM_BUFFERS; i++) {
                BufferCallback((__bridge void *)(self), _queue, buffers[i]);
            }
        }
    } else {
        write_circular_buffer_bytes(outrb, Buf,len);
    }
}

#pragma mark - record
- (void)initRecordAudio {
    _audioRecordDescription.mSampleRate = 8000;//采样频率
    _audioRecordDescription.mFormatID = kAudioFormatLinearPCM;
    _audioRecordDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    _audioRecordDescription.mBytesPerFrame = 2;
    _audioRecordDescription.mBytesPerPacket = 2;
    _audioRecordDescription.mFramesPerPacket = 1;//wav 通常为1
    _audioRecordDescription.mChannelsPerFrame = 1;//通道数
    _audioRecordDescription.mBitsPerChannel = 16;//采样的位数
    
    ///设置音频参数
    //    audioRecordDescription.mSampleRate = 8000;//采样率
    //    audioRecordDescription.mFormatID = kAudioFormatLinearPCM;
    //    audioRecordDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    //    audioRecordDescription.mChannelsPerFrame = 1;///单声道
    //    audioRecordDescription.mFramesPerPacket = 1;//每一个packet一侦数据
    //    audioRecordDescription.mBitsPerChannel = 16;//每个采样点16bit量化
    //    audioRecordDescription.mBytesPerFrame = (audioRecordDescription.mBitsPerChannel/8) * audioRecordDescription.mChannelsPerFrame;
    //    audioRecordDescription.mBytesPerPacket = audioRecordDescription.mBytesPerFrame ;
    
    AudioQueueNewInput(&_audioRecordDescription, MyInputBufferHandler, (__bridge void *)(self), nil, nil, 0, &_audioRecordQueue);
    ////添加buffer区
    for(int i = 0; i < NUM_RECBUFFERS; i++) {
        ///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小
        AudioQueueAllocateBuffer(_audioRecordQueue, MIN_SIZE_PER_FRAME, &audioRecordQueueBuffers[i]);
    }
    
    AudioQueueStart(_audioRecordQueue, NULL);
    
    for(int i = 0; i < NUM_RECBUFFERS; i++) {
        AudioQueueEnqueueBuffer(_audioRecordQueue, audioRecordQueueBuffers[i], 0, NULL);
    }
    
    inrb = create_circular_buffer(2048 * sizeof(short) * 2000);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *soundOneNew = [documentsDirectory stringByAppendingPathComponent:@"record.mp4"];
    // create the url for the combined file
    CFURLRef out_url = (__bridge CFURLRef)[NSURL fileURLWithPath:soundOneNew];
    
    AudioFileCreateWithURL(out_url, kAudioFileMPEG4Type, &_audioRecordDescription, kAudioFileFlags_EraseFile, &_fileId);
}

static void MyInputBufferHandler(void *inUserData,
                                 AudioQueueRef inAQ,
                                 AudioQueueBufferRef inBuffer,
                                 const AudioTimeStamp *inStartTime,
                                 UInt32 inNumPackets,
                                 const AudioStreamPacketDescription *inPacketDesc)
{
    KenAudio* player=(__bridge KenAudio*)inUserData;
    
    int len = inBuffer->mAudioDataByteSize;
    char *data = (char*) inBuffer->mAudioData;
    
    if (thNet_SetTalk([player NetHandle], data,len)) {
        write_circular_buffer_bytes(inrb, data,len);
        
        static SInt64 i = 0;
        AudioFileWritePackets(player.fileId, FALSE, inBuffer->mAudioDataByteSize, inPacketDesc, i++, &inNumPackets, inBuffer->mAudioData);
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void)pauseRecord {
    AudioQueuePause(_audioRecordQueue);
}

- (void)reStartRecord {
    AudioQueueStart(_audioRecordQueue, NULL);
}

- (void)stopRecord {
    AudioQueueStop(_audioRecordQueue, true);
}

- (void)cleanAudio {
    AudioQueueStop(_queue, true);
    if (nextBuffer != NULL) {
        free(nextBuffer);
    }
    //  AudioQueueStop(audioRecordQueue, true);
    free_circular_buffer(outrb);
}

//创建循环缓冲区
#pragma mark - c 部分
circular_buffer* create_circular_buffer(int bytes) {
    circular_buffer *p;
    if ((p = calloc(1, sizeof(circular_buffer))) == NULL) {
        return NULL;
    }
    p->size = bytes;
    p->wp = p->rp = 0;
    
    if ((p->buffer = calloc(bytes, sizeof(char))) == NULL) {
        free (p);
        return NULL;
    }
    return p;
}

int checkspace_circular_buffer(circular_buffer *p, int writeCheck) {
    if (p == NULL) {
        return 0;
    }
    int wp = p->wp, rp = p->rp, size = p->size;
    if(writeCheck) {
        if (wp > rp) return rp - wp + size - 1;
        else if (wp < rp) return rp - wp - 1;
        else return size - 1;
    } else {
        if (wp > rp) return wp - rp;
        else if (wp < rp) return wp - rp + size;
        else return 0;
    }
}

int read_circular_buffer_bytes(circular_buffer *p, char *out, int bytes) {
    if (p == NULL) {
        return 0;
    }
    int remaining;
    int bytesread, size = p->size;
    int rp = p->rp;
    char *buffer = p->buffer;
    if ((remaining = checkspace_circular_buffer(p, 0)) == 0) {
        return 0;
    }
    
    if (rp < 0 || p->size < 1 || rp > p->size) {
        return -1;
    }
    
    if (buffer[0] == 0 && buffer[1] == 0) {
        return -1;
    }
    
    bytesread = bytes > remaining ? remaining : bytes;
    for(int i = 0; i < bytesread; i++) {
        out[i] = buffer[rp++];
        if(rp == size) rp = 0;
    }
    p->rp = rp;
    return bytesread;
}

int write_circular_buffer_bytes(circular_buffer *p, const char *in, int bytes) {
    if (p == NULL) {
        return 0;
    }
    int remaining;
    int size = p->size;
    int wp = p->wp;
    char *buffer = p->buffer;
    if ((remaining = checkspace_circular_buffer(p, 1)) == 0) {
        return 0;
    }
    int byteswrite = bytes > remaining ? remaining : bytes;
    for(int i = 0; i < byteswrite; i++) {
        buffer[wp++] = in[i];
        if(wp == size) wp = 0;
    }
    p->wp = wp;
    return byteswrite;
}

void free_circular_buffer (circular_buffer *p) {
    if(p == NULL) return;
    
    if (p->buffer != NULL) {
        free(p->buffer);
    }
    free(p);
}

@end
