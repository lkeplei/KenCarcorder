//
//  KenVideoFrameExtractor.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenVideoFrameExtractor.h"

#import "Photos.h"

@interface KenVideoFrameExtractor (private)
- (void)convertFrameToRGB;
- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height;
- (void)setupScaler;
@end


@implementation MovieFrame
@end

@implementation VideoFrame
@end

@implementation VideoFrameYUV
@synthesize luma;
@synthesize chromaB;
@synthesize chromaR;
@end


@interface KenVideoFrameExtractor ()

- (void)convertFrameToRGB;
- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height;
- (void)setupScaler;

@end

@implementation KenVideoFrameExtractor

@synthesize outputWidth, outputHeight;
@synthesize _record;
@synthesize _recordStart;
@synthesize _recordEnd;
@synthesize filename;
@synthesize _width,_height;
@synthesize _cap;
@synthesize ocx;

/* 5 seconds stream duration */
#define STREAM_DURATION   5.0
int STREAM_FRAME_RATE = 20; /* 25 images/s */
#define STREAM_NB_FRAMES  ((int)(STREAM_DURATION * STREAM_FRAME_RATE))
#define STREAM_PIX_FMT PIX_FMT_YUV420P /* default pix_fmt */


AVOutputFormat *fmt;
//AVFormatContext *ocx;
AVStream *audio_st, *video_st;
double audio_pts, video_pts;
static float t, tincr, tincr2;
static int16_t *samples;
static uint8_t *audio_outbuf;
static int audio_outbuf_size;
static int audio_input_frame_size;


- (AVStream *)add_audio_stream:(AVFormatContext *)oc codec_id:(int)codec_id {
    AVCodecContext *c;
    AVStream *st;
    
    st = avformat_new_stream(oc, NULL);
    if (!st) {
        fprintf(stderr, "Could not alloc stream\n");
        exit(1);
    }
    st->id = 1;
    
    c = st->codec;
    c->codec_id = codec_id;
    c->codec_type = AVMEDIA_TYPE_AUDIO;
    
    /* put sample parameters */
    c->sample_fmt = AV_SAMPLE_FMT_FLT;
    //    c->bit_rate = 64000;
    c->sample_rate = 8000;
    c->channels = 2;
    
    // some formats want stream headers to be separate
    if (oc->oformat->flags & AVFMT_GLOBALHEADER)
        c->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    return st;
}

static void open_audio(AVFormatContext *oc, AVStream *st)
{
    if (st == NULL) return;
    
    AVCodecContext *c;
    AVCodec *codec;
    
    c = st->codec;
    
    /* find the audio encoder */
    codec = avcodec_find_encoder(c->codec_id);
    if (!codec) {
        fprintf(stderr, "codec not found\n");
        exit(1);
    }
    
    /* open it */
    int result = avcodec_open2(c, codec, NULL);
    if (result < 0) {
        fprintf(stderr, "could not open codec\n");
        exit(1);
    }
    
    /* init signal generator */
    t = 0;
    tincr = 2 * M_PI * 110.0 / c->sample_rate;
    /* increment frequency by 110 Hz per second */
    tincr2 = 2 * M_PI * 110.0 / c->sample_rate / c->sample_rate;
    
    audio_outbuf_size = 10000;
    audio_outbuf = (uint8_t *)av_malloc(audio_outbuf_size);
    
    /* ugly hack for PCM codecs (will be removed ASAP with new PCM
     support to compute the input frame size in samples */
    if (c->frame_size <= 1) {
        audio_input_frame_size = audio_outbuf_size / c->channels;
        switch(st->codec->codec_id) {
            case CODEC_ID_PCM_S16LE:
            case CODEC_ID_PCM_S16BE:
            case CODEC_ID_PCM_U16LE:
            case CODEC_ID_PCM_U16BE:
                audio_input_frame_size >>= 1;
                break;
            default:
                break;
        }
    } else {
        audio_input_frame_size = c->frame_size;
    }
    samples = (int16_t *)av_malloc(audio_input_frame_size * 2 * c->channels);
}

/* prepare a 16 bit dummy audio frame of 'frame_size' samples and
 'nb_channels' channels */
static void get_audio_frame(int16_t *samples, int frame_size, int nb_channels)
{
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

static void write_audio_frame(AVFormatContext *oc, AVStream *st)
{
    if (st == NULL) return;
    
    AVCodecContext *c;
    AVPacket pkt;
    av_init_packet(&pkt);
    
    c = st->codec;
    
    get_audio_frame(samples, audio_input_frame_size, c->channels);
    
    pkt.size = avcodec_encode_audio(c, audio_outbuf, audio_outbuf_size, samples);
    
    if (c->coded_frame && c->coded_frame->pts != AV_NOPTS_VALUE)
        pkt.pts= av_rescale_q(c->coded_frame->pts, c->time_base, st->time_base);
    pkt.flags |= AV_PKT_FLAG_KEY;
    pkt.stream_index = st->index;
    pkt.data = audio_outbuf;
    
    /* write the compressed frame in the media file */
    if (av_interleaved_write_frame(oc, &pkt) != 0) {
        fprintf(stderr, "Error while writing audio frame\n");
        exit(1);
    }
}

static void close_audio(AVFormatContext *oc, AVStream *st)
{
    avcodec_close(st->codec);
    
    av_free(samples);
    av_free(audio_outbuf);
}

/**************************************************************/
/* video output */

static AVFrame *s_picture, *tmp_picture;
static uint8_t *video_outbuf;
static int video_outbuf_size;

KenVideoFrameExtractor * v_self;

static AVFrame *alloc_picture(enum PixelFormat pix_fmt, int width, int height)
{
    AVFrame *picture;
    uint8_t *picture_buf;
    int size;
    
    //    width = 1280;
    //    height = 720;
    
    picture = av_frame_alloc();
    if (!picture)
        return NULL;
    size = avpicture_get_size(pix_fmt, width, height);
    picture_buf = (uint8_t *)av_malloc(size);
    if (!picture_buf) {
        av_free(picture);
        return NULL;
    }
    
    //    int TEXTURE_WIDTH = 1280;
    //    int TEXTURE_HEIGHT = 720;
    //    avpicture_fill((AVPicture *)picture, sizeof(uint16_t)*TEXTURE_WIDTH*TEXTURE_HEIGHT,
    //                   pix_fmt, width, height);
    
    avpicture_fill((AVPicture *)picture, picture_buf,
                   pix_fmt, width, height);
    return picture;
}

static void open_video(AVFormatContext *oc, AVStream *st)
{
    AVCodec *codec;
    AVCodecContext *c;
    
    c = st->codec;
    
    /* find the video encoder */
    codec = avcodec_find_encoder(c->codec_id);
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
    if (!(oc->oformat->flags & AVFMT_RAWPICTURE)) {
        /* allocate output buffer */
        /* XXX: API change will be done */
        /* buffers passed into lav* can be allocated any way you prefer,
         as long as they're aligned enough for the architecture, and
         they're freed appropriately (such as using av_free for buffers
         allocated with av_malloc) */
        video_outbuf_size = 200000;
        video_outbuf = (uint8_t *)av_malloc(video_outbuf_size);
    }
    
    /* allocate the encoded raw picture */
    s_picture = alloc_picture(c->pix_fmt, c->width, c->height);
    if (!s_picture) {
        fprintf(stderr, "Could not allocate picture\n");
        exit(1);
    }
    
    /* if the output format is not YUV420P, then a temporary YUV420P
     picture is needed too. It is then converted to the required
     output format */
    tmp_picture = NULL;
    if (c->pix_fmt != PIX_FMT_YUV420P) {
        tmp_picture = alloc_picture(PIX_FMT_YUV420P, c->width, c->height);
        if (!tmp_picture) {
            fprintf(stderr, "Could not allocate temporary picture\n");
            exit(1);
        }
    }
}

static void close_video(AVFormatContext *oc, AVStream *st) {
    avcodec_close(st->codec);
    av_free(s_picture->data[0]);
    av_free(s_picture);
    if (tmp_picture) {
        av_free(tmp_picture->data[0]);
        av_free(tmp_picture);
    }
    av_free(video_outbuf);
}

- (void)setOutputWidth:(int)newValue {
    if (outputWidth == newValue) return;
    outputWidth = newValue;
    
    v_self = self;
}

-(void)setOutputHeight:(int)newValue {
    if (outputHeight == newValue) return;
    outputHeight = newValue;
    v_self = self;
    [self setupScaler];
}

-(UIImage *)currentImage {
    if (pFrame->data[0] == NULL) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:outputWidth height:outputHeight];
}

int getlen(char *result) {
    int i=0;
    while(result[i]!='\0'){
        i++;
    }
    return i;
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

- (void)resetSetting:(int)width height:(int)height rate:(int)frameRate {
    _cap = false;
    _needSaveImg = YES;
    STREAM_FRAME_RATE = frameRate;
    [self set_width:width];
    [self set_height:height];
    
    av_register_all();
    
    AVCodec * pCodec = avcodec_find_decoder(CODEC_ID_H264);
    
    pCodecCtx = avcodec_alloc_context3(pCodec);
    if (pCodecCtx == nil) {
        return ;
    }
    
    pCodecCtx->time_base.num = 1; //这两行：一秒钟25帧
    pCodecCtx->time_base.den = 50;
    pCodecCtx->bit_rate = 0; //初始化为0
    pCodecCtx->frame_number = 1; //每包一个视频帧
    pCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
    pCodecCtx->width = width; //这两行：视频的宽度和高度
    pCodecCtx->height = height;
    pCodecCtx->pix_fmt=PIX_FMT_YUV420P;
    
    if(avcodec_open2(pCodecCtx, pCodec, NULL)<0) {
        return ;
    }
    
    pFrame = av_frame_alloc();
    
    self.outputWidth = pCodecCtx->width;
    self.outputHeight = pCodecCtx->height;
    
    bytesDecoded = 0;
}

- (id)initCnx:(int)width hei:(int)height rate:(int)framerate {
    if (!(self=[super init])) return nil;
    
    _isRecording = NO;
    
    _cap = false;
    _needSaveImg = YES;
    STREAM_FRAME_RATE = framerate;
    [self set_width:width];
    [self set_height:height];
    
    av_register_all();
    
    AVCodec * pCodec = avcodec_find_decoder(CODEC_ID_H264);
    
    pCodecCtx = avcodec_alloc_context3(pCodec);
    if (pCodecCtx == nil) {
        return nil;
    }
    
    pCodecCtx->time_base.num = 1; //这两行：一秒钟25帧
    pCodecCtx->time_base.den = 50;
    pCodecCtx->bit_rate = 0; //初始化为0
    pCodecCtx->frame_number = 1; //每包一个视频帧
    pCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
    pCodecCtx->width = width; //这两行：视频的宽度和高度
    pCodecCtx->height = height;
    pCodecCtx->pix_fmt=PIX_FMT_YUV420P;
    
    if(avcodec_open2(pCodecCtx, pCodec, NULL)<0) {
        return nil;
    }
    
    pFrame=av_frame_alloc();
    
    self.outputWidth = pCodecCtx->width;
    self.outputHeight = pCodecCtx->height;
    
    bytesDecoded = 0;
    
    return self;
}

- (void)setupScaler {
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, outputWidth, outputHeight);
    
    // Setup scaler
    static int sws_flags = SWS_POINT; //SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     outputWidth,
                                     outputHeight,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // Was there an error?
    if (error != NULL) {
        DebugLog("error occured %s",contextInfo);
    } else {
        DebugLog("success saved");
        // Show message image successfully saved
    }
}

- (AVStream *)add_video_stream:(AVFormatContext *)oc codecId:(int)codecId {
    AVCodecContext *c;
    AVStream *st;
    AVCodec *codec;
    
    avcodec_register_all();
    st = avformat_new_stream(oc, NULL);
    if (!st) {
        fprintf(stderr, "Could not alloc stream\n");
        exit(1);
    }
    
    c = st->codec;
    
    /* find the video encoder */
    codec = avcodec_find_encoder(codecId);
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
    
    /* time base: this is the fundamental unit of time (in seconds) in terms
     of which frame timestamps are represented. for fixed-fps content,
     timebase should be 1/framerate and timestamp increments should be
     identically 1. */
    c->time_base.den = STREAM_FRAME_RATE;
    c->time_base.num = 1;
    c->gop_size = 12; /* emit one intra frame every twelve frames at most */
    c->pix_fmt = STREAM_PIX_FMT;
    if (c->codec_id == CODEC_ID_MPEG2VIDEO) {
        /* just for testing, we also add B frames */
        c->max_b_frames = 2;
    }
    if (c->codec_id == CODEC_ID_MPEG1VIDEO){
        /* Needed to avoid using macroblocks in which some coeffs overflow.
         This does not happen with normal video, it just happens here as
         the motion of the chroma plane does not match the luma plane. */
        c->mb_decision=2;
    }
    // some formats want stream headers to be separate
    if (oc->oformat->flags & AVFMT_GLOBALHEADER)
        c->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    return st;
}

- (void)manageAudioData:(char *)buf len:(int)len {
    if (_record && !_recordStart) {
        write_audio_frame(ocx, audio_st);
    }
    
}

#pragma mark - 视频数据解析与录像、拍照相关
- (int)decodeVideo:(char *)buf len:(int)len
{
    rawData = (uint8_t*)buf;
    packet.data = rawData;
    packet.size = len;
    
    int gotPicture = 0;
    int Size = 0;
    while (packet.size > 0)
    {
        Size = avcodec_decode_video2(pCodecCtx, pFrame, &gotPicture, &packet);
        
        if (gotPicture==0)
        {
            avcodec_decode_video2(pCodecCtx, pFrame, &gotPicture, &packet);
            break;
        }
        
        packet.data += Size;
        packet.size -= Size;
    }
    
    return gotPicture;
}

- (void)videoRecord:(char *)buf len:(int)len
{
    if(_record) {
        if (_recordStart) {
            DebugLog("file path is %@",filename);
            _recordStart = false;
            fmt = av_guess_format(NULL, [filename cStringUsingEncoding:NSASCIIStringEncoding], NULL);
            if (!fmt) {
                fmt = av_guess_format("mpeg", NULL, NULL);
            }
            if (!fmt) {
                fprintf(stderr, "Could not find suitable output format\n");
                exit(1);
            }
            
            ocx = avformat_alloc_context();
            if (!ocx) {
                fprintf(stderr, "Memory error\n");
                exit(1);
            }
            ocx->oformat = fmt;
            snprintf(ocx->filename, sizeof(ocx->filename), "%s", [filename cStringUsingEncoding:NSASCIIStringEncoding]);
            
            ocx->oformat->video_codec = CODEC_ID_MPEG4;
            //            ocx->oformat->audio_codec = CODEC_ID_FLAC;
            
            fmt = ocx->oformat;
            video_st = NULL;
            audio_st = NULL;
            
            if (fmt->video_codec != CODEC_ID_NONE) {
                video_st = [self add_video_stream:ocx codecId:fmt->video_codec];
            }
            
            //            if (fmt->audio_codec != CODEC_ID_NONE) {
            //                audio_st = [self add_audio_stream:ocx codec_id:fmt->audio_codec];
            //            }
            
            av_dump_format(ocx, 0, [filename cStringUsingEncoding:NSASCIIStringEncoding], 1);
            
            if (video_st) {
                open_video(ocx, video_st);
            }
            
            //            if (audio_st) {
            //                open_audio(ocx, audio_st);
            //            }
            
            if (!(fmt->flags & AVFMT_NOFILE)) {
                if (avio_open(&ocx->pb, [filename cStringUsingEncoding:NSASCIIStringEncoding], AVIO_FLAG_WRITE) < 0) {
                    fprintf(stderr, "Could not open '%s'\n", [filename cStringUsingEncoding:NSASCIIStringEncoding]);
                    return;
                }
            }
            
            int xx = avformat_write_header(ocx,NULL);
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
            
            av_interleaved_write_frame(ocx, &pkt);
        }
    }
    
    if(_recordEnd) {
        _recordEnd = NO;
        _isRecording = NO;
        av_write_trailer(ocx);
        
        if (video_st)
            close_video(ocx, video_st);
        
        if (audio_st) {
            close_audio(ocx, audio_st);
        }
        
        int i = 0;
        for(i = 0; i < ocx->nb_streams; i++) {
            av_freep(&ocx->streams[i]->codec);
            av_freep(&ocx->streams[i]);
        }
        
        if (!(fmt->flags & AVFMT_NOFILE)) {
            avio_close(ocx->pb);
            [NSThread detachNewThreadSelector:@selector(saveVideo) toTarget:self withObject:nil];
        }
        av_free(ocx);
    }
    
    if (_cap) {
        _cap = false;
        UIImage *img  = [self currentImage];
        if (_needSaveImg) {
            UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString* str = [formatter stringFromDate:date];
        Photos *myPhotos_ = [[Photos alloc] init] ;
        //            [myPhotos_ setDelegate:self];
        [myPhotos_ savePhoto:img  withName:str addToPhotoAlbum:false];
    }
}

- (void)manageRecorder:(char *)buf len:(int)len {
    if ([self decodeVideo:buf len:len] > 0) {
        [self videoRecord:buf len:len];
    }
    
    av_free_packet(&packet);
}

- (void)manageData:(char *)buf len:(int)len {
    if ([self decodeVideo:buf len:len] > 0) {
        if (self.delegate) {
            [self.delegate updateVideoFrame:nil];
        }
        
        [self videoRecord:buf len:len];
    }
    
    av_free_packet(&packet);
}

- (int)bytesDecoded {
    return bytesDecoded;
}

-(void)convertFrameToRGB {
    if (pFrame->pict_type != AV_PICTURE_TYPE_NONE) {
        if (pFrame->width != outputWidth || pFrame->height != outputHeight) {
            return;
        }
    }
    
    if (pFrame->linesize[0] <= 0 || pFrame->linesize[1] <= 0 || pFrame->linesize[2] <= 0) {
        return;
    }
    //    DebugLog("pFrame->data[0] = %ld", strlen((char *)pFrame->data[0]));
    
    sws_scale (img_convert_ctx, pFrame->data, pFrame->linesize,
               0, pCodecCtx->height,
               picture.data, picture.linesize);
}

- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

- (void)saveVideo {
    bool compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filename);
    if(compatible) {
        UISaveVideoAtPathToSavedPhotosAlbum (filename, self, nil, nil);
    }
}

@end
