//
//  VoiceDecoder.h
//  VoiceDecoder
//
//  Created by godliu on 14-11-5.
//  Copyright (c) 2014年 godliu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VDPriority)
{
    VD_CPUUsePriority//不占内存，但CPU消耗比较大一些
    , VD_MemoryUsePriority//不占CPU，但内存消耗大一些
};

typedef NS_ENUM(NSInteger, VDErrorCode)
{
    VD_SUCCESS = 0, VD_NoSignal = -1, VD_ECCError = -2, VD_NotEnoughSignal = 100
    , VD_NotHeaderOrTail = 101, VD_RecogCountZero = 102
};

@interface VoiceRecog : NSObject
{
    void *recognizer;
    void *recorder;
    NSThread *recogThread;
}

- (id)init:(VDPriority)_vdpriority;

- (void) start;
- (void) stop;
- (void) pause:(int)_ms;
- (bool) isStopped;

//- (void) sendWave:(NSString *)_wavePath;

- (void) setFreqs:(int *)_freqs freqCount:(int)_freqCount;

- (void) onRecognizerStart;
- (void) onRecognizerEnd:(int)_result data:(char *)_data dataLen:(int)_dataLen;

- (NSString *) bytes2String:(char *)_bytes bytesLen:(int)_bytesLen;

+ (int) infoType:(char *)_data dataLen:(int)_dataLen;

@end
