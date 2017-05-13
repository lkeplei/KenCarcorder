//
//  KenCaptureHelper.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

typedef void(^completedBlock)(void) ;
typedef void(^DidOutputSampleBufferBlock)(NSString *result);

@interface KenCaptureHelper : NSObject<AVCaptureMetadataOutputObjectsDelegate>

- (void)setDidOutputSampleBufferHandle:(DidOutputSampleBufferBlock)didOutputSampleBuffer;

- (void)showCaptureOnView:(UIView *)preview;
- (void)showCaptureOnView:(UIView *)preview complete:(completedBlock) didCompletedBlock;

@end
