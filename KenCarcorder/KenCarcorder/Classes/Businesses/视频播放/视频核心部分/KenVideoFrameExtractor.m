//
//  KenVideoFrameExtractor.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenVideoFrameExtractor.h"

#import "Photos.h"

@implementation MovieFrame
@end

@implementation VideoFrame
@end

@implementation VideoFrameYUV
@end

#pragma mark - KenVideoFrameExtractor
@interface KenVideoFrameExtractor (){
    AVFormatContext *pFormatCtx;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPicture picture;
    AVPacket packet;
    struct SwsContext *img_convert_ctx;
}

//录像控制
@property (nonatomic, assign) BOOL record;
@property (nonatomic, assign) BOOL recordStart;
@property (nonatomic, assign) BOOL recordEnd;

@property (nonatomic, readonly) double duration;

@property (nonatomic, assign) int outputWidth;
@property (nonatomic, assign) int outputHeight;

/* Size of video frame */
@property (nonatomic, readonly) int sourceWidth;
@property (nonatomic, readonly) int sourceHeight;

/* Output image size. Set to the source size by default. */
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int width;

@property (nonatomic, readonly) int streamFrameRate;

@property (nonatomic, strong) NSString *filename;

@property (nonatomic, assign) AVFormatContext *ocx;

@property (nonatomic, assign) int audio_outbuf_size;
@property (nonatomic, assign) int audio_input_frame_size;

@end

@implementation KenVideoFrameExtractor

AVOutputFormat *fmt;
AVStream *audio_st, *video_st;
static float t, tincr, tincr2;
static int16_t *samples;
static uint8_t *audio_outbuf;

- (instancetype)initCnx:(int)width hei:(int)height rate:(int)framerate {
    self = [super init];
    
    if (self) {
        if (![self resetSetting:width height:height rate:framerate]) {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    // Free scaler
    sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    avpicture_free(&picture);
    
    // Free the YUV frame
    av_free(pFrame);
    
    // Close the codec
    if (pCodecCtx) avcodec_close(pCodecCtx);
    
    // Close the video file
    if (pFormatCtx) avformat_close_input(&pFormatCtx);
}

/**************************************************************/
/* video output */

static AVFrame *s_picture, *tmp_picture;
static uint8_t *video_outbuf;
static int video_outbuf_size;

#pragma mark - 视频数据解析与录像、拍照相关
- (int)decodeVideo:(char *)buf len:(int)len {
    packet.data = (uint8_t *)buf;
    packet.size = len;
    
    int gotPicture = 0;
    int Size = 0;
    while (packet.size > 0) {
        Size = avcodec_decode_video2(pCodecCtx, pFrame, &gotPicture, &packet);
        
        if (gotPicture == 0) {
            avcodec_decode_video2(pCodecCtx, pFrame, &gotPicture, &packet);
            break;
        }
        
        packet.data += Size;
        packet.size -= Size;
    }
    
    return gotPicture;
}

- (void)videoRecord:(char *)buf len:(int)len {
    if(_record) {
        if (_recordStart) {
            DebugLog("file path is %@", _filename);
            _recordStart = NO;
            fmt = av_guess_format(NULL, [_filename cStringUsingEncoding:NSASCIIStringEncoding], NULL);
            if (!fmt) {
                fmt = av_guess_format("mpeg", NULL, NULL);
            }
            if (!fmt) {
                fprintf(stderr, "Could not find suitable output format\n");
                exit(1);
            }
            
            self.ocx = avformat_alloc_context();
            if (!self.ocx) {
                fprintf(stderr, "Memory error\n");
                exit(1);
            }
            self.ocx->oformat = fmt;
            snprintf(self.ocx->filename, sizeof(self.ocx->filename), "%s", [_filename cStringUsingEncoding:NSASCIIStringEncoding]);
            
            self.ocx->oformat->video_codec = CODEC_ID_MPEG4;
            //            self.ocx->oformat->audio_codec = CODEC_ID_FLAC;
            
            fmt = self.ocx->oformat;
            video_st = NULL;
            audio_st = NULL;
            
            if (fmt->video_codec != CODEC_ID_NONE) {
                video_st = [self add_video_stream:self.ocx codecId:fmt->video_codec];
            }

            av_dump_format(self.ocx, 0, [_filename cStringUsingEncoding:NSASCIIStringEncoding], 1);
            
            if (video_st) {
                [self openVideo:video_st];
            }
            
            if (!(fmt->flags & AVFMT_NOFILE)) {
                if (avio_open(&self.ocx->pb, [_filename cStringUsingEncoding:NSASCIIStringEncoding], AVIO_FLAG_WRITE) < 0) {
                    fprintf(stderr, "Could not open '%s'\n", [_filename cStringUsingEncoding:NSASCIIStringEncoding]);
                    return;
                }
            }
            
            int xx = avformat_write_header(self.ocx,NULL);
            DebugLog("write header is %d",xx);
            s_picture->pts = 0;
        }
        
        int out_size;
        AVCodecContext *c;
        //static struct SwsContext *img_convert_ctx;
        c = video_st->codec;
        out_size = avcodec_encode_video(c, video_outbuf, video_outbuf_size, pFrame);
        
        if (out_size > 0) {
            AVPacket pkt;
            av_init_packet(&pkt);
            
            if (c->coded_frame->pts != AV_NOPTS_VALUE)
                pkt.pts= av_rescale_q(c->coded_frame->pts, c->time_base, video_st->time_base);
            if(c->coded_frame->key_frame)
                pkt.flags |= AV_PKT_FLAG_KEY;
            pkt.stream_index = video_st->index;
            pkt.data = video_outbuf;
            pkt.size = out_size;
            
            av_interleaved_write_frame(self.ocx, &pkt);
        }
    }
    
    if(_recordEnd) {
        _recordEnd = NO;
        _isRecording = NO;
        av_write_trailer(self.ocx);
        
        if (video_st){
            [self closeVideo:video_st];
        }
        
        if (audio_st) {
            [self closeAudio:audio_st];
        }
        
        for(NSUInteger i = 0; i < self.ocx->nb_streams; i++) {
            av_freep(&self.ocx->streams[i]->codec);
            av_freep(&self.ocx->streams[i]);
        }
        
        if (!(fmt->flags & AVFMT_NOFILE)) {
            avio_close(self.ocx->pb);
            [NSThread detachNewThreadSelector:@selector(saveVideo) toTarget:self withObject:nil];
        }
        av_free(self.ocx);
    }
}

- (AVStream *)add_video_stream:(AVFormatContext *)oc codecId:(int)codecId {
    avcodec_register_all();
    
    AVStream *st = avformat_new_stream(oc, NULL);
    if (!st) {
        fprintf(stderr, "Could not alloc stream\n");
        exit(1);
    }
    
    AVCodecContext *c = st->codec;
    
    /* find the video encoder */
    AVCodec *codec = avcodec_find_encoder(codecId);
    if (!codec) {
        fprintf(stderr, "codec not found\n");
        exit(1);
    }
    avcodec_get_context_defaults3(c, codec);
    
    c->codec_id = codecId;
    
    /* put sample parameters */
    c->bit_rate = /*400000*/3000000;
    /* resolution must be a multiple of two */
    
    c->width = _width;
    c->height = _height;
    c->time_base.den = _streamFrameRate;
    c->time_base.num = 1;
    c->gop_size = 12; /* emit one intra frame every twelve frames at most */
    c->pix_fmt = PIX_FMT_YUV420P;
    if (c->codec_id == CODEC_ID_MPEG2VIDEO) {
        /* just for testing, we also add B frames */
        c->max_b_frames = 2;
    }
    
    if (c->codec_id == CODEC_ID_MPEG1VIDEO){
        c->mb_decision=2;
    }
    // some formats want stream headers to be separate
    if (oc->oformat->flags & AVFMT_GLOBALHEADER)
        c->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    return st;
}

- (void)openVideo:(AVStream *)st {
    AVCodecContext *c = st->codec;
    
    /* find the video encoder */
    AVCodec *codec = avcodec_find_encoder(c->codec_id);
    if (!codec) {
        fprintf(stderr, "codec not found\n");
        exit(1);
    }
    
    /* open the codec */
    int result = avcodec_open2(c, codec, NULL);
    if (result < 0) {
        fprintf(stderr, "could not open codec\n");
        exit(1);
    }
    
    video_outbuf = NULL;
    if (!(_ocx->oformat->flags & AVFMT_RAWPICTURE)) {
        video_outbuf_size = 200000;
        video_outbuf = (uint8_t *)av_malloc(video_outbuf_size);
    }
    
    /* allocate the encoded raw picture */
    s_picture = alloc_picture(c->pix_fmt, c->width, c->height);
    if (!s_picture) {
        fprintf(stderr, "Could not allocate picture\n");
        exit(1);
    }
    
    tmp_picture = NULL;
    if (c->pix_fmt != PIX_FMT_YUV420P) {
        tmp_picture = alloc_picture(PIX_FMT_YUV420P, c->width, c->height);
        if (!tmp_picture) {
            fprintf(stderr, "Could not allocate temporary picture\n");
            exit(1);
        }
    }
}

- (void)closeVideo:(AVStream *)stream {
    avcodec_close(stream->codec);
    av_free(s_picture->data[0]);
    av_free(s_picture);
    if (tmp_picture) {
        av_free(tmp_picture->data[0]);
        av_free(tmp_picture);
    }
    av_free(video_outbuf);
}

//音频部分
- (void)writeAudioFrame:(AVStream *)stream {
    if (stream == nil) return;
    
    AVCodecContext *c;
    AVPacket pkt;
    av_init_packet(&pkt);
    
    c = stream->codec;
    
    get_audio_frame(samples, _audio_input_frame_size, c->channels);
    
    pkt.size = avcodec_encode_audio(c, audio_outbuf, _audio_outbuf_size, samples);
    
    if (c->coded_frame && c->coded_frame->pts != AV_NOPTS_VALUE)
        pkt.pts= av_rescale_q(c->coded_frame->pts, c->time_base, stream->time_base);
    pkt.flags |= AV_PKT_FLAG_KEY;
    pkt.stream_index = stream->index;
    pkt.data = audio_outbuf;
    
    /* write the compressed frame in the media file */
    if (av_interleaved_write_frame(_ocx, &pkt) != 0) {
        fprintf(stderr, "Error while writing audio frame\n");
        exit(1);
    }
}

- (void)closeAudio:(AVStream *)stream {
    avcodec_close(stream->codec);
    
    av_free(samples);
    av_free(audio_outbuf);
}

#pragma mark - event
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        DebugLog("error occured %s",contextInfo);
    } else {
        DebugLog("success saved");
    }
}

#pragma mark - public method
- (void)manageData:(char *)buf len:(int)len {
    if ([self decodeVideo:buf len:len] > 0) {
        if (self.delegate) {
            [self.delegate updateVideoFrame:nil];
        }
        
        [self videoRecord:buf len:len];
    }
    
    av_free_packet(&packet);
}

- (void)manageRecorder:(char *)buf len:(int)len {
    if ([self decodeVideo:buf len:len] > 0) {
        [self videoRecord:buf len:len];
    }
    
    av_free_packet(&packet);
}

- (void)manageAudioData:(char *)buf len:(int)len {
    if (_record && !_recordStart) {
        [self writeAudioFrame:audio_st];
    }
}

- (BOOL)resetSetting:(int)width height:(int)height rate:(int)frameRate {
    _isRecording = NO;
    _streamFrameRate = frameRate;
    _record = NO;
    _recordEnd = NO;
    _recordStart = NO;
    
    self.width = width;
    self.height = height;
    
    av_register_all();
    
    AVCodec * pCodec = avcodec_find_decoder(CODEC_ID_H264);
    
    pCodecCtx = avcodec_alloc_context3(pCodec);
    if (pCodecCtx == nil) {
        return NO;
    }
    
    pCodecCtx->time_base.num = 1; //这两行：一秒钟25帧
    pCodecCtx->time_base.den = 50;
    pCodecCtx->bit_rate = 0; //初始化为0
    pCodecCtx->frame_number = 1; //每包一个视频帧
    pCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
    pCodecCtx->width = width; //这两行：视频的宽度和高度
    pCodecCtx->height = height;
    pCodecCtx->pix_fmt=PIX_FMT_YUV420P;
    
    if(avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        return NO;
    }
    
    pFrame = av_frame_alloc();
    
    self.outputWidth = pCodecCtx->width;
    self.outputHeight = pCodecCtx->height;
    
    return YES;
}

- (void)startRecord {
    _record = YES;
    _recordStart = YES;
    
    _isRecording = YES;
}

- (void)endRecord {
    _record = NO;
    _recordEnd = YES;
    
    _isRecording = NO;
}

- (void)capturePhoto {
    UIImage *img  = [self currentImage];
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString* str = [formatter stringFromDate:date];
    Photos *myPhotos_ = [[Photos alloc] init] ;
//        [myPhotos_ setDelegate:self];
    [myPhotos_ savePhoto:img  withName:str addToPhotoAlbum:false];
}

#pragma mark - private method
- (void)convertFrameToRGB {
    if (pFrame->pict_type != AV_PICTURE_TYPE_NONE) {
        if (pFrame->width != _outputWidth || pFrame->height != _outputHeight) {
            return;
        }
    }
    
    if (pFrame->linesize[0] <= 0 || pFrame->linesize[1] <= 0 || pFrame->linesize[2] <= 0) {
        return;
    }
    
    sws_scale(img_convert_ctx, pFrame->data, pFrame->linesize, 0, pCodecCtx->height, picture.data, picture.linesize);
}

- (void)setupScaler {
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, _outputWidth, _outputHeight);
    
    // Setup scaler
    static int sws_flags = SWS_POINT; //SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                     _outputWidth, _outputHeight, PIX_FMT_RGB24, sws_flags, NULL, NULL, NULL);
}

- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width, height, 8, 24, pict.linesize[0], colorSpace,
                                       bitmapInfo, provider, NULL, NO, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

- (void)saveVideo {
    bool compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_filename);
    if(compatible) {
        UISaveVideoAtPathToSavedPhotosAlbum (_filename, self, nil, nil);
    }
}

#pragma mark - getter setter
- (void)setOutputWidth:(int)newValue {
    if (_outputWidth == newValue) return;
    _outputWidth = newValue;
}

- (void)setOutputHeight:(int)newValue {
    if (_outputHeight == newValue) return;
    _outputHeight = newValue;
    [self setupScaler];
}

- (UIImage *)currentImage {
    if (pFrame->data[0] == NULL) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:_outputWidth height:_outputHeight];
}

- (double)duration {
    return (double)pFormatCtx->duration / AV_TIME_BASE;
}

- (int)sourceWidth {
    return pCodecCtx->width;
}

- (int)sourceHeight {
    return pCodecCtx->height;
}

#pragma mark - C 代码部分 ffmpeg 解析视频
static AVFrame *alloc_picture(enum PixelFormat pix_fmt, int width, int height) {
    AVFrame *picture = av_frame_alloc();
    if (!picture)
        return NULL;
    
    int size = avpicture_get_size(pix_fmt, width, height);
    uint8_t *picture_buf = (uint8_t *)av_malloc(size);
    if (!picture_buf) {
        av_free(picture);
        return NULL;
    }

    avpicture_fill((AVPicture *)picture, picture_buf, pix_fmt, width, height);
    return picture;
}

#pragma mark - C 代码部分 音频解析
static void get_audio_frame(int16_t *samples, int frame_size, int nb_channels) {
    int j, i, v;
    int16_t *q;
    
    q = samples;
    for (j = 0; j < frame_size; j++) {
        v = (int)(sin(t) * 10000);
        for(i = 0; i < nb_channels; i++)
            *q++ = v;
        t += tincr;
        tincr += tincr2;
    }
}

@end
