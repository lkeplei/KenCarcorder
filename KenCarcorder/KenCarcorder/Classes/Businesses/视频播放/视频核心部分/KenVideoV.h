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

@property (nonatomic, strong) KenVideoFrameExtractor *video;
@property (nonatomic, strong) KenAudio *audio;

- (void)showVideoWithDevice:(KenDeviceDM *)device;

@end
