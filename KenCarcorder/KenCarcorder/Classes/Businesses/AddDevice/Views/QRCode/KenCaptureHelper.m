//
//  KenCaptureHelper.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenCaptureHelper.h"

@interface KenCaptureHelper ()

@property (nonatomic, copy) DidOutputSampleBufferBlock didOutputSampleBuffer;

@property (nonatomic, strong) dispatch_queue_t captureSessionQueue;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;


@end

@implementation KenCaptureHelper

- (void)setDidOutputSampleBufferHandle:(DidOutputSampleBufferBlock)didOutputSampleBuffer {
    self.didOutputSampleBuffer = didOutputSampleBuffer;
}

- (void)showCaptureOnView:(UIView *)preview {
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureVideoPreviewLayer.frame = preview.bounds;
            [preview.layer addSublayer:self.captureVideoPreviewLayer];
        });
    });
}

- (void)showCaptureOnView:(UIView *)preview complete:(completedBlock)didCompletedBlock {
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureVideoPreviewLayer.frame = preview.bounds;
            [preview.layer addSublayer:self.captureVideoPreviewLayer];
            if(didCompletedBlock){
                didCompletedBlock();
            }
        });
    });
}

#pragma mark - Propertys
- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        
        AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
        if ([_captureSession canAddInput:self.captureInput])
            [self.captureSession addInput:self.captureInput];
        
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:captureMetadataOutput];
        
        
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:self.captureSessionQueue];
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer {
    if (!_captureVideoPreviewLayer) {
        _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _captureVideoPreviewLayer;
}

#pragma mark - Life Cycle
- (id)init {
    self = [super init];
    if (self) {
        _captureSessionQueue = dispatch_queue_create("com.HUAJIE.captureSessionQueue", 0);
    }
    return self;
}

- (void)dealloc {
    _captureSessionQueue = nil;
    _captureVideoPreviewLayer = nil;

    [_captureSession stopRunning];
    _captureSession = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBuffer Delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        NSString *urlString = [metadataObj stringValue];
        DebugLog("get url %@", urlString);
        
        [_captureSession stopRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.didOutputSampleBuffer) {
                self.didOutputSampleBuffer(urlString);
            }
        });
        
    }
}

@end
