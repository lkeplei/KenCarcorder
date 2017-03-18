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


@interface KenAudio : NSObject 

- (instancetype)initAudio;
- (void)playAudio:(char*)Buf length:(int)len;
- (void)cleanAudio;

- (void)initRecordAudio;
- (void)pauseRecord;
- (void)reStartRecord;
- (void)stopRecord;

@end
