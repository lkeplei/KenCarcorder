#ifndef __GM_AVI_API_H__
#define __GM_AVI_API_H__

#ifdef __cplusplus
extern "C"
{
#endif 

#pragma pack(4)//n=1,2,4,8,16

#define AVIF_HASINDEX        0x00000010 // Index at end of file?
#define AVIF_MUSTUSEINDEX    0x00000020
#define AVIF_ISINTERLEAVED   0x00000100
#define AVIF_TRUSTCKTYPE     0x00000800 // Use CKType to find key frames
#define AVIF_WASCAPTUREFILE  0x00010000
#define AVIF_COPYRIGHTED     0x00020000

#define GM_FRAME_TYPE_KEYFRAME  0x1
#define GM_FRAME_TYPE_NO_TIME   0x2


/* FOURCC */
#define GM_MAKE_FOURCC(a,b,c,d)         (int)((a)|(b)<<8|(c)<<16|(d)<<24)
#define GM_GET_NUM_FROM_FOURCC(x)       (int)((x&0xFF000000)>>24|(x&0x00FF0000)>>16)
//video
#define GMAVI_TYPE_H264     GM_MAKE_FOURCC('H','2','6','4')
#define GMAVI_TYPE_MPEG4    GM_MAKE_FOURCC('D','I','V','X')
#define GMAVI_TYPE_MJPEG    GM_MAKE_FOURCC('M','J','P','G')
#define GMAVI_TYPE_GMTAG    GM_MAKE_FOURCC('G','M','T','G')
//audio
#define GMAVI_TYPE_PCM      GM_MAKE_FOURCC('P','C','M',' ')
#define GMAVI_TYPE_MP3      GM_MAKE_FOURCC('M','P','E','G')


  typedef struct GMSearchIndex
  {
    int offset; //movi offset
    int index; //idx1 offset
  } GMSearchIndex;

  typedef struct GMFMChannelProfile
  {
//video
    int video_type;
    int width;
    int height;
    int framerate;
    union
    {
      int cbr_bitrate;
      int vbr_level;
    } quality;
    int ip_interval;
    int has_audio;

//audio
    int au_type;
    int au_channel_num; //mono or stereo
    int au_sample_rate;
    int au_bitrate;

  }
  GMFMChannelProfile;


  typedef struct GMEventData
  {
    int type;
  } GMEventData;

#define GMTAG_TYPE_CH_START     0
#define GMTAG_TYPE_CH_STOP      1
#define GMTAG_TYPE_CH_CONTINUE  2
#define GMTAG_TYPE_EVENT        3
  typedef struct GMStreamTag
  {
    int type;
    int timestamp;
    union
    {
      GMFMChannelProfile ch_prof;
      GMEventData gm_event;
    } data;
  }
  GMStreamTag;


/* this structure is appending following each packet (tag as JUNK) */
  typedef struct GMExtraInfo
  {
    int timestamp;
    int profile_index;
    int flag;
  } GMExtraInfo;


/* Status Code */
  typedef enum GmAviStatus
  {
    GMSTS_OK = 0, GMSTS_VARIANT_FORMAT = 1, GMSTS_END_OF_DATA = 2, GMSTS_READ_MESSAGE_DATA = 3, 

//error
    GMSTS_OPEN_FAILED =  - 1, GMSTS_INVALID_INPUT =  - 2, GMSTS_WRONG_STATE =  - 3, GMSTS_INVALID_FORAMT =  - 4, GMSTS_DATA_FULL =  - 5, GMSTS_NOT_ENOUGH_SPACE =  - 6, GMSTS_INTERNAL_ERROR =  - 7, GMSTS_SEEK_FAILED =  - 8, GMSTS_RECORD_NOT_FOUND =  - 9, GMSTS_WRITE_FAILED =  - 10, GMSTS_READ_FAILED =  - 11, GMSTS_FILE_SYSTEM_INEXISTENT =  - 100, GMSTS_FILE_SYSTEM_BROKEN =  - 101 

  } GmAviStatus;


#ifndef TRUE
#define TRUE (1==1)
#endif 
#ifndef FALSE
#define FALSE (1==0)
#endif 



//typedef void* HANDLE;

#define GMAVI_FILEMODE_CREATE       0X1
#define GMAVI_FILEMODE_READ         0X2
#define GMAVI_FILEMODE_WRITE        0X4
#define GMAVI_FILEMODE_FIXED_SIZE   0X8

#define GMAVI_SECTION_AVI_HEADER      0x1
#define GMAVI_SECTION_STREAM_HEADER   0x2
#define GMAVI_SECTION_STREAM_DATA     0x4
#define GMAVI_SECTION_INDEX           0x8


/* Only for GM function: GMAVIConditionIndexSearch() */
#define GMAVI_SEARCH_GivenTime          1
#define GMAVI_SEARCH_StartTag           2


//======================================================//
  typedef struct AviMainHeader
  {
    unsigned char fcc[4];
    int cb;
    int dwMicroSecPerFrame;
    int dwMaxBytesPerSec;
    int dwPaddingGranularity;
    int dwFlags;
    int dwTotalFrames;
    int dwInitialFrames;
    int dwStreams;
    int dwSuggestedBufferSize;
    int dwWidth;
    int dwHeight;
    int dwReserved[4];
  } AviMainHeader;

  typedef struct AviStreamHeader
  {
    unsigned char fcc[4];
    int cb;
    unsigned char fccType[4];
    unsigned char fccHandler[4];
    int dwFlags;
    unsigned char wPriority;
    unsigned char wLanguage;
    int dwInitialFrames;
    int dwScale;
    int dwRate;
    int dwStart;
    int dwLength;
    int dwSuggestedBufferSize;
    int dwQuality;
    int dwSampleSize;
    struct 
    {
      short int left;
      short int top;
      short int right;
      short int bottom;
    } rcFrame;
  }
  AviStreamHeader;

  typedef struct BitMapInfoHeader
  {
    int biSize;
    int biWidth;
    int biHeight;
    short int biPlanes;
    short int biBitCount;
    int biCompression;
    int biSizeImage;
    int biXPelsPerMeter;
    int biYPelsPerMeter;
    int biClrUsed;
    int biClrImportant;
  } BitMapInfoHeader;

  typedef struct RGBQuad
  {
    unsigned char rgbBlue;
    unsigned char rgbGreen;
    unsigned char rgbRed;
    unsigned char rgbReserved;
  } RGBQuad;

  typedef struct BitmapInfo
  {
    BitMapInfoHeader bmiHeader;
//RGBQuad          bmiColors[1]; 
  } BitmapInfo;

  typedef struct WaveFormateX
  {
    short int wFormatTag;
    short int nChannels;
    int nSamplesPerSec;
    int nAvgBytesPerSec;
    short int nBlockAlign;
    short int wBitsPerSample;
    short int cbSize;
  } WaveFormateX;

  typedef struct AviIndex
  {
    int dwChunkId;
    int dwFlags;
    int dwOffset;
    int dwSize;
  } AviIndex;

/* for GM only (START) */
  typedef struct GMTagStreamFormat
  {
    int total_channels;
    int channel;
    int start;
    int end;
    int fragment_count;
  } GMTagStreamFormat;
/* for GM only (END) */

  typedef union GmAviStreamFormat
  {
    BitmapInfo video_format;
    WaveFormateX audio_format;

/* for GM only (START) */
    GMTagStreamFormat gmtag_format;
/* for GM only (END) */

  } GmAviStreamFormat;

//======================================================//


  typedef struct GmAviChunkSize
  {
    int stream_header_size;
    int stream_data_size;
    int index_size;
  } GmAviChunkSize;

  typedef struct GmAviChunkOffset
  {
    int stream_data_offset;
    int index_offset;
  } GmAviChunkOffset;


  typedef enum GmAviFilePosition
  {
// general
/*
GMAVI_SEEK_SET, // start of file
GMAVI_SEEK_CUR,
GMAVI_SEEK_END,
GMAVI_SEEK_STREAM_HEADER_OFFSET,
GMAVI_SEEK_STREAM_DATA_OFFSET,
GMAVI_SEEK_INDEX_OFFSET,
*/
// special for GM
    GMAVI_SEEK_TO_BEGINNING, GMAVI_SEEK_TO_END, GMAVI_SEEK_GIVEN_INDEX
  } GmAviFilePosition;

  typedef enum GmAviFileTell
  {
// general
    GMAVI_TELL_CUR,  //current position
// special for GM
    GMAVI_TELL_STREAM_HEADER_OFFSET, GMAVI_TELL_STREAM_DATA_OFFSET, GMAVI_TELL_INDEX_OFFSET
  } GmAviFileTell;

  int GMAVIOpen(char* filename, int mode, int size);//
  int GMAVISetAviMainHeader(int handle, AviMainHeader* avi_main_header);
  int GMAVISetStreamHeader(int handle, AviStreamHeader* avi_stream_header, GmAviStreamFormat* avi_stream_format, int* out_streamid);
  int GMAVISetStreamDataAndIndex(int handle, int streamid, unsigned char* data, int length, int indx_flag, unsigned char* extra_data, int extra_length);
  int GMAVIFillVideoStreamHeaderValues(AviStreamHeader* header, GmAviStreamFormat* format, int type, int width, int height, int framerate, int bitrate, int framecount);//
  int GMAVIClose(int handle);

  int GMAVISetChunkSize(int handle, GmAviChunkSize* chunk_size);
  int GMAVISeek(int handle, int whence, GMSearchIndex* offset);
  int GMAVITell(int handle, int tell_what, GMSearchIndex* offset);
  int GMAVIReset(int handle, int items);
  
  
  int GMAVIGetAviMainHeader(int handle, AviMainHeader* avi_main_header);
  int GMAVIGetStreamHeaderNum(int handle, int* count);
  int GMAVIGetStreamHeader(int handle, int num, AviStreamHeader* avi_stream_header, GmAviStreamFormat* avi_stream_format, int* out_streamid);
  int GMAVIGetStreamDataAndIndex(int handle, int* streamid, unsigned char* data, int* length, int* indx_flag, unsigned char* extra_data, int* extra_length, int frame_no, int reverse, int* pos);
  int GMAVIConditionIndexSearch(int handle, GMSearchIndex* out_value, int mode, int value1, int value2);
  int GMAVIUpdateStreamHeader(int handle, int num, AviStreamHeader* avi_stream_header, GmAviStreamFormat* avi_stream_format);
  int GMAVIFillAviMainHeaderValues(AviMainHeader* header, int width, int height, int framerate, int bitrate, int framecount);
  

  int GMAVIFillAudioStreamHeaderValues(AviStreamHeader* header, GmAviStreamFormat* format, int type, int channels, int sample_rate, int bitrate);


#ifdef __cplusplus
}

//-------------------------------------------------------------------------

#endif 

#endif /* __GM_AVI_API_H__ */
