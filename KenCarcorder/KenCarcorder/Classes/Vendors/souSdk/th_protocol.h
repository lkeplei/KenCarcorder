//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description :
//-----------------------------------------------------------------------------
#ifndef th_protocol_H
#define th_protocol_H

#include "cm_types.h"

#pragma pack(4)//n=1,2,4,8,16

#define Port_Ax_Data           2000
#define Port_Ax_http             80
#define Port_Ax_RTSP            554
#define Port_AlarmServer       9001

#define Port_Ax_Multicast      2000
#define Port_Ax_Search_Local   1999
#define Port_onvifSearch       3702
#define IP_Ax_Multicast  "239.255.255.250"//uPnP IP查询 多播对讲IP
#define REC_FILE_EXT           "av"
#define REC_FILE_EXT_DOT      ".av"

//#pragma option push -b //start C++Builder enum 4 Byte
//#pragma option push -b- //start C++Builder enum 1 Byte

typedef enum TDevType {// sizeof 4
    dt_None=0,
    dt_DevX1=11,
    dt_DevOther
}TDevType;

/*网络包*/

//-----------------------------------------------------------------------------
typedef struct TSMTPCfgPkt {//sizeof 500 Byte
    int Active;
    char40 SMTPServer;
    int SMTPPort;
    char40 FromAddress;
    char ToAddress[320];
    char40 Account;
    char40 Password;
    int SSL;
    int Flag;
    int Flag1;
}TSMTPCfgPkt;
//-----------------------------------------------------------------------------
typedef struct TFTPCfgPkt {//sizeof 232 Byte
    int Active;
    char100 FTPServer;
    int FTPPort;
    char40 Account;
    char40 Password;
    char40 UploadPath;
    //  int PASVMode;
    //  int ProxyType;// 0=off 1=http 2=socks
    //  char40 ProxyUserName;
    //  char40 ProxyPassword;
    int Flag;
}TFTPCfgPkt;

typedef struct Tp2pCfgPkt {//sizeof 88 byte
    char40 UID;
    union {
        struct {
            DWORD SvrIP[4];//20130621
            int Reserved1;
        };
        char20 oldAccount;
    };
    
    char20 Password;
    bool Active;
    byte StreamType;//0 主码流 1 次码流
    bool IsNew; //20130621
    byte p2pType;   //tutk=0 self=1
    byte Flag[4];
}Tp2pCfgPkt;

// /usr/sbin/wput ftp://administrator:123456@192.168.1.20:21/ -b -B --proxy=off   --proxy-user=user --proxy-pass=pass  /bin/cp -o cp
// /usr/sbin/wput ftp://administrator:123456@192.168.1.20:21/ -b -B --proxy=http  --proxy-user=user --proxy-pass=pass  /bin/cp -o cp
// /usr/sbin/wput ftp://administrator:123456@192.168.1.20:21/ -b -B --proxy=socks --proxy-user=user --proxy-pass=pass  /bin/cp -o cp
//-----------------------------------------------------------------------------
typedef enum TGroupType{                          //sizeof 4 Byte
    pt_Cmd,
    pt_PlayLive,
    pt_PlayHistory,
    pt_PlayMedia
}TGroupType;
//-----------------------------------------------------------------------------
typedef enum TFontColor {                        //OSD 字体颜色 sizeof 4 Byte
    cl_Black       =0x00,
    cl_Maroon      =0x01,
    cl_Green       =0x02,
    cl_Olive       =0x03,
    cl_Navy        =0x04,
    cl_Purple      =0x05,
    cl_Teal        =0x06,
    cl_Red         =0x07,
    cl_Lime        =0x08,
    cl_Yellow      =0x09,
    cl_Blue        =0x0a,
    cl_Fuchsia     =0x0b,
    cl_Aqua        =0X0c,
    cl_Gray        =0x0d,
    cl_Silver      =0x0e,
    cl_White       =0x0f,
    cl_Transparent =0xff
}TFontColor;

static int FontColors[16+1] =
{
    0x000000,//cl_Black=0,//黑
    0x000080,//cl_Maroon=1,//暗红
    0x008000,//cl_Green=2,//深绿
    0x008080,//cl_Olive=3,//土黄
    0x800000,//cl_Navy=4,//深蓝
    0x800080,//cl_Purple=5,//紫
    0x808000,//cl_Teal=6,//深青
    0x0000FF,//cl_Red=7,//红
    0x00FF00,//cl_Lime=8,//绿
    0x00FFFF,//cl_Yellow=9,//黄
    0xFF0000,//cl_Blue=10,//蓝
    0xFF00FF,//cl_Fuchsia=11,//洋红
    0xFFFF00,//cl_Aqua=12,//青
    0x808080,//cl_Gray=13,//深灰
    0xC0C0C0,//cl_Silver=14,//灰
    0xFFFFFF,//cl_White=15,//白
    0xFFFFFF//cl_Transparent=255//透明
};
//-----------------------------------------------------------------------------
typedef enum TResolution {
    D1    = 0,
    HFD1  = 1,
    CIF   = 2,
    QCIF  = 3
}TResolution;
//-----------------------------------------------------------------------------
typedef enum TStandardEx {
    StandardExMin,
    P720x576,//1
    P720x288,
    P704x576,
    P704x288,
    P352x288,
    P176x144,
    N720x480,
    N720x240,
    N704x480,
    N704x240,
    N352x240,
    N176x120,//11
    
    V160x120,//  QQVGA
    V320x240,//   QVGA
    V640x480,//    VGA
    V800x600,//   SVGA
    V1024x768,//   XGA  //17
    V1280x720,
    V1280x800,//  WXGA
    //  V1280x854,//  WXGA+
    V1280x960,//  _VGA
    V1280x1024,// SXGA
    V1360x768,// WXSGA+ //22
    V1400x1050,// SXGA+
    V1600x1200,// UXGA
    V1920x1080,//1080P
    //V1680x1050,//WSXGA+
    //V2048x1536,// QXGA   //27
    //V2560x1600,//QSXGAW
    //V2560x2048,//QSXGA
    //V3400x2400,//QUXGAW
    StandardExMax
}TStandardEx;
//-----------------------------------------------------------------------------
typedef enum TVideoType {                        //视频格式sizeof 4 Byte
    MPEG4          =0,
    MJPEG          =1,
    H264           =2,
}TVideoType;
//-----------------------------------------------------------------------------
typedef enum TImgFormat {
    if_RGB           =0,
    if_YUV420        =1,
    if_YUV422        =2,
}TImgFormat;
//-----------------------------------------------------------------------------
typedef enum TStandard {
    NTSC           =0,
    PAL            =1,
    VGA            =2,
}TStandard;
//-----------------------------------------------------------------------------
typedef struct TBatchCfgPkt { //批量修改配置 sizeof 16
    int BitRate;                                   //码流 64K 128K 256K 512K 1024K 1536K 2048K 2560K 3072K
    Byte Standard;                                 //TStandard制式 PAL=1, NTSC=0
    Byte Resolution;                               //TResolution
    Byte FrameRate;                                //帧率 1-30 MAX:PAL 25 NTSC 30
    Byte IPInterval;                               //IP帧间隔 1-120 default 30
    int AudioActive;
    int DevTime;
}TBatchCfgPkt;
//-----------------------------------------------------------------------------
/*
 typedef struct TVideoFormatEx {                    //视频格式 sizeof 64 暂未用到
 Byte StandardEx;//TStandardEx
 Byte VideoType;//TVideoType                     //MPEG4=0x00, MJPEG=0x01  H264=0x02
 Byte FrameRate;                                //帧率 1-30 MAX:PAL 25 NTSC 30
 Byte IPInterval;                               //IP帧间隔 1-120 default 30
 
 Byte Brightness;                               //亮度   0-255
 Byte Contrast;                                 //对比度 0-255
 Byte Hue;                                      //色度   0-255
 Byte Saturation;                               //饱和度 0-255
 
 char40 Title;                                  //OSD标题 20个汉字
 
 int  BitRate;                                  //码流 64K 128K 256K 512K 1024K 1536K 2048K 2560K 3072K
 Byte BitRateType;                              //0定码流 1定画质
 bool IsMirror;                           //水平翻转 false or true
 bool IsFlip;                             //垂直翻转 false or true
 bool ShowOsdInDev;
 
 Byte OsdColor;
 bool IsShowTitle;                            //显示时间标题 false or true
 bool IsShowTime;                               //显示水印 false or true
 bool IsShowBitRate;
 
 int Flag;
 }TVideoFormatEx;
 */
//-----------------------------------------------------------------------------
#define CBR    0
#define VBR    1
typedef struct TVideoFormat {                    //视频格式 sizeof 128
    int  Standard;                                 //制式 PAL=1, NTSC=0 default=0xff
    int  Width;                                    //宽 720 360 180 704 352 176 640 320 160
    int  Height;                                   //高 480 240 120 576 288 144
    TVideoType VideoType;                          //MPEG4=0x00, MJPEG=0x01  H264=0x02
    Byte  Brightness;                               //亮度   0-255
    Byte  Contrast;                                 //对比度 0-255
    Byte  Hue;                                      //色度   0-255
    Byte  Saturation;                               //饱和度 0-255
    int  FrameRate;                                //帧率 1-30 MAX:PAL 25 NTSC 30
    int  IPInterval;                               //IP帧间隔 1-120 default 30
    Byte BitRateType;                              //0定码流 1定画质
    Byte BitRateQuant;                             //画质  0..4
    //Byte Reserved0[2];
    Byte  BrightnessNight;                          //亮度   0-255
    Byte  ContrastNight;                            //对比度 0-255
    
    
    int  BitRate;                                  //码流 64K 128K 256K 512K 1024K 1536K 2048K 2560K 3072K
    int  IsMirror;                                 //水平翻转 false or true
    int  IsFlip;                                   //垂直翻转 false or true
    char40 Title;                                  //OSD标题 20个汉字
    
    Byte HueNight;
    bool ShowTitleInDev;
    bool IsShowTitle;                            //显示时间标题 false or true
    Byte TitleColor;
    short TitleX;
    short TitleY;
    
    Byte SaturationNight;
    bool ShowTimeInDev;
    bool IsShowTime;                               //显示水印 false or true
    Byte TimeColor;
    short TimeX;
    short TimeY;
    
    Byte DeInterlaceType;
    bool IsDeInterlace;
    bool IsDeInterlaceSub;//add at 2010/12/01
    bool IsWDR;
    Byte  Sharpness;                               //锐度 0-255
    //bool IsWifiAutoBitRate;                        //wifi连接时自适应码流 20130705
    Byte IRCutSensitive;
    Byte Reserved[2];
    
    Byte SharpnessNight;
    bool ShowFrameRateInDev;
    bool IsShowFrameRate;
    Byte FrameRateColor;
    short FrameRateX;
    short FrameRateY;
    
    struct { //add at 2009/09/02
        //    Byte VideoType;//MPEG4=0x0000, MJPEG=0x0001  H264=0x0002
        Byte BitRateQuant;//画质  0..4
        Byte StandardEx;//TStandardEx
        Byte FrameRate;//帧率 1-30 MAX:PAL 25 NTSC 30
        Byte BitRateType;//0定码流 1定画质
        int BitRate;//码流 64K 128K 256K 512K 1024K 1536K 2048K 2560K 3072K
    }Sub;//子码流
    
    int Flag;
}TVideoFormat;
//-----------------------------------------------------------------------------
typedef struct TVideoCfgPkt {                    //视频设置包 sizeof 148 Byte
    int  Chl;                                      //通道 0..15 对应 1..16通道
    int  Active;                                   //是否启动(可能暂时没有用到)
    Byte InputType;                                //输入类型
    Byte Reserved[3];
    struct TVideoFormat VideoFormat;               //视频格式
    int Flag;                                      //立即生效=1
    int Flag1;
}TVideoCfgPkt;
//-----------------------------------------------------------------------------
typedef enum TAudioType {                        //音频格式sizeof 4 Byte
    PCM                   =0x0001,
    G711                  =0x0002,
    MPEGLAYER2            =0x0050,
    MPEGLAYER3            =0x0055,
}TAudioType;
//-----------------------------------------------------------------------------
typedef struct TAudioFormatEx {                    //音频格式 = sizeof 8 暂未用到
    Byte AudioType;                              //PCM=0X0001, ADPCM=0x0011, MP2=0x0050, MP3=0X0055, GSM610=0x0031
    Byte nChannels;                               //单声道=0 立体声=1
    WORD wBitsPerSample;                          //number of bits per sample of mono data
    DWORD nSamplesPerSec;                          //采样率
}TAudioFormatEx;
//-----------------------------------------------------------------------------
typedef struct TAudioFormat {                    //音频格式 = TWaveFormatEx = sizeof 32
    DWORD wFormatTag;                              //PCM=0X0001, ADPCM=0x0011, MP2=0x0050, MP3=0X0055, GSM610=0x0031
    DWORD nChannels;                               //单声道=0 立体声=1
    DWORD nSamplesPerSec;                          //采样率
    DWORD nAvgbytesPerSec;                         //for buffer estimation
    DWORD nBlockAlign;                             //block size of data
    DWORD wBitsPerSample;                          //number of bits per sample of mono data
    DWORD cbSize;                                  //本包大小
    int Flag;
}TAudioFormat;
//-----------------------------------------------------------------------------
typedef struct TAudioCfgPkt {                    //音频设置包 sizeof 48 Byte
    int  Chl;                                      //通道0..15 对应 1..16通道
    int  Active;                                   //是否启动声音
    struct TAudioFormat AudioFormat;               //音频格式
#define MIC_IN  0
#define LINE_IN 1
    Byte InputType;                                 //0 MIC输入, 1 LINE输入
    Byte VolumeMicIn;//不用了
    Byte VolumeLineIn;
    Byte VolumeLineOut;
    
    bool SoundTriggerActive;
    byte SoundTriggerSensitive;
    byte Reserved[2];
}TAudioCfgPkt;
//-----------------------------------------------------------------------------
typedef enum TPlayCtrl {                         //播放控制sizeof 4 Byte
    PS_None               =0,                 //空
    PS_Play               =1,                 //播放
    PS_Pause              =2,                 //暂停
    PS_Stop               =3,                 //停止
    PS_FastBackward       =4,                 //快退
    PS_FastForward        =5,                 //快进
    PS_StepBackward       =6,                 //步退
    PS_StepForward        =7,                 //步进
    PS_DragPos            =8,                 //拖动
}TPlayCtrl;
//-----------------------------------------------------------------------------
typedef struct TPlayCtrlPkt {
    TPlayCtrl PlayCtrl;
    DWORD Speed;//如果PlayCtrl=PS_StepBackward, PS_FastForward ，则保存快进快退倍率 1 2 4 8 16 32倍率
    DWORD Pos;//如果PlayCtrl=PS_DragPos，则保存文件文件位置Pos
}TPlayCtrlPkt;
//-----------------------------------------------------------------------------
typedef struct TRecFilePkt {                     //播放历史包 SizeOf 100
    char20 DevIP;
    byte Chl;
    byte RecType;                               //0:普通录影 1:警报录影 2媒体文件
    byte Reserved[2];
    int StartTime;                              //开始时间
    int EndTime;                                //结束时间
    char64 FileName;                               //文件名
    int Flag;                                      //保留
}TRecFilePkt;
//-----------------------------------------------------------------------------
//  /sd/rec/20091120/20091120_092749_0.ra2
typedef struct TRecFileIdx {                     //录影文件索引包 sizeof 80
    char64 FileName;
    Byte Chl;
    Byte RecType;
    Byte Reserved;
    Byte Flag;
    time_t StartTime;
    time_t EndTime;
    DWORD FileSize;
}TRecFileIdx;

#define RECFILELSTCOUNT 16
typedef struct TRecFileLst { //sizeof 1288
    int Total;
    int SubTotal;
    TRecFileIdx Lst[RECFILELSTCOUNT];
}TRecFileLst;
//-----------------------------------------------------------------------------
typedef struct TRecFileHead {                    //录影文件头格式 sizeof 256 Byte
    DWORD DevType;                                 //设备类型 = DEV_Ax
    DWORD FileSize;                                //文件大小
    int StartTime;                              //开始时间
    int EndTime;                                //停止时间
    char20 DevName;                                //设备ID
    char20 DevIP;                                  //设备IP
    DWORD VideoChannel;                            //视频通道数统计
    DWORD AudioChannel;                            //音频通道数统计
    struct TVideoFormat VideoFormat;               //视频格式
    struct TAudioFormat AudioFormat;               //音频格式
    int Flag;                                      //保留
    int Flag1;                                      //保留
    int Flag2;                                      //保留
    int Flag3;                                      //保留
    int Flag4;                                      //保留
    int Flag5;                                      //保留
    int Flag6;                                      //保留
    int Flag7;                                      //保留
}TRecFileHead;
//-----------------------------------------------------------------------------
typedef struct TFilePkt {                        //上传文件包 sizeof 528+4
#define FILETYPE_X1PTZ     1 //x1 ptz
#define FILETYPE_X1BURNIN  7 //x1 burn in
    //#define FILETYPE_X1IMG     8 //x1 img升级用
#define FILETYPE_BIN       2 //x1 x2 bin 升级用
    //#define FILETYPE_X2WIFICFG 6 //x2 WIFI 配置文件
#define FILETYPE_X4ISP     3
    int FileType;
    DWORD FileSize;
    char256 FileName;
    int Handle;
    
#define UPGRAD_UPLOAD_FAIL      0
#define UPGRAD_UPLOAD_OVER_ING  1
#define UPGRAD_UPLOAD_OVER_OK   2
#define UPGRAD_UPLOAD_FLASHING  3
#define UPGRAD_UPLOAD_ING       4
    int Flag;//0=上传文件失败 1=上传文件完毕,正在升级,请不要断电  2=上传文件成功 (3=正在上传文件 x5add)
    char256 DstFile;
    DWORD crc;//2012-02-10
}TFilePkt;
//-----------------------------------------------------------------------------
typedef enum TAlmType {
    Alm_None             =0,//空
    Alm_MotionDetection  =1,//位移报警Motion Detection
    Alm_DigitalInput     =2,//DI报警
    Alm_SoundTrigger       =3,////声音触发报警
    Net_Disconn          =4,//网络断线
    Net_ReConn           =5,//网络重连
    Alm_HddFill          =6,//磁满
    Alm_VideoBlind       =7,//视频遮挡
    Alm_VideoLost        =8,//视频丢失
    Alm_Other3           =9,//其它报警3
    Alm_Other4           =10,//其它报警4
    Alm_RF               =11,
    Alm_OtherMax         =12,
}TAlmType;

typedef struct TAlmSendPkt {                     //警报上传包sizeof 36
    TAlmType AlmType;                              //警报类型
    int AlmTime;                                   //警报时间
    int AlmPort;                                   //警报端口
    char20 DevIP;
    int Flag;                                      //MD 区域索引
}TAlmSendPkt;
//-----------------------------------------------------------------------------
typedef struct TDoControlPkt {                 //do控制包　sizeof 16
    int Chl;
    int Value;                                   // 0 关　1 开
    int Reserved;
}TDoControlPkt;
//-----------------------------------------------------------------------------
typedef enum TTaskDayType{w_close,w_1,w_2,w_3,w_4,w_5,w_6,w_7,w_1_5,w_1_6,w_6_7,w_1_7,w_Interval} TTaskDayType;
typedef struct TTaskhm {
    Byte w;
    Byte Days;
    Byte Reserved[2];
    Byte start_h;//时 0-23
    Byte start_m;//分 0-59
    Byte stop_h;//时 0-23
    Byte stop_m;//分 0-59
}TTaskhm;
//-----------------------------------------------------------------------------
typedef struct THideAreaCfgPkt {                 //隐藏录影区域包 sizeof 72
    int Reserved0;
    int Reserved1;
    int Active;                                    //false or true
    TRect Rect;
    
    int IsFloatNewRect;
    struct {
        float left,top,right,bottom;
    }NewRect;
    
    char20 Reserved2;
    int Flag;
}THideAreaCfgPkt;
//-----------------------------------------------------------------------------
typedef struct TMDCfgPkt {                       //移动侦测包 sizeof 96
    byte Reserved1[8];
    bool Active;
    byte Reserved2;
    byte Sensitive;                              //侦测灵敏度 0-255
    bool IsFloatNewRect;
    TRect Rect;                        //侦测区域 sizeof 8
    char40 Reserved3;
    struct TTaskhm hm;
    
    struct {
        float left, top, right, bottom;
    }NewRect;
    
    int SettingStandard;//设置时的分辨率 20130403
}TMDCfgPkt;
//-----------------------------------------------------------------------------
typedef struct TAlmCfgItem {
    Byte AlmType;//Byte(TAlmType)
    Byte Channel;
    byte Active;//only di
    bool IsAlmRec;
    bool IsFTPUpload;//NetSend
    bool ActiveDO;//DI关联DO通道 false close
    bool IsSendEmail;//Byte DOChannel;
    Byte Reserved2;//
}TAlmCfgItem;

typedef struct TAlmCfgPkt {                   //警报配置包 sizeof 268 -> 52 20140928
    int AlmOutTimeLen;                    //报警输出时长(秒) 0 ..600 s
    int AutoClearAlarm;
    int Flag;
    TAlmCfgItem DIAlm;
    TAlmCfgItem MDAlm;
    TAlmCfgItem SoundAlm;
    TAlmCfgItem Reserved[2];
}TAlmCfgPkt;
//-----------------------------------------------------------------------------
#define USER_GUEST     1
#define USER_OPERATOR  2
#define USER_ADMIN     3
#define GROUP_GUEST    1
#define GROUP_OPERATOR 2
#define GROUP_ADMIN    3

#define MAXUSERCOUNT             20              //最大用户数量
typedef struct TUserCfgPkt {                     //sizeof 1048
    int Count;
    struct {
        int UserGroup;                                 //Guest=1 Operator=2 Administrator=3
        int Authority;                                 //3为admin ,
        char20 UserName;                               //用户名 admin不能更改
        char20 Password;                               //密码
        int Flag;
    }Lst[MAXUSERCOUNT];
    int Flag;
}TUserCfgPkt;
//-----------------------------------------------------------------------------
typedef enum TPTZCmd {                           //sizeof 4 Byte
    PTZ_None,
    PTZ_Up,//上
    PTZ_Up_Stop,//上停止
    PTZ_Down,//下
    PTZ_Down_Stop,//下停止
    PTZ_Left,//左
    PTZ_Left_Stop,//左停止
    PTZ_Right,//右
    PTZ_Right_Stop,//右停止
    
    PTZ_LeftUp,//左上
    PTZ_LeftUp_Stop,//左上停止
    PTZ_RightUp,//右上
    PTZ_RightUp_Stop,//右上停止
    PTZ_LeftDown,//左下
    PTZ_LeftDown_Stop,//左下停止
    PTZ_RightDown,//右下
    PTZ_RightDown_Stop,//右下停止
    
    PTZ_IrisIn,//光圈小
    PTZ_IrisInStop,//光圈停止
    PTZ_IrisOut,//光圈大
    PTZ_IrisOutStop,//光圈停止
    
    PTZ_ZoomIn,//倍率小
    PTZ_ZoomInStop,//倍率停止
    PTZ_ZoomOut,//倍率大
    PTZ_ZoomOutStop,//倍率停止
    
    PTZ_FocusIn,//焦距小
    PTZ_FocusInStop,//焦距停止
    PTZ_FocusOut,//焦距大
    PTZ_FocusOutStop,//焦距停止
    
    PTZ_LightOn,//灯光小
    PTZ_LightOff,//灯光大
    PTZ_RainBrushOn,//雨刷开
    PTZ_RainBrushOff,//雨刷开
    PTZ_AutoOn,//自动开始  //Rotation
    PTZ_AutoOff,//自动停止
    
    PTZ_TrackOn,
    PTZ_TrackOff,
    PTZ_IOOn,
    PTZ_IOOff,
    
    PTZ_ClearPoint,//云台复位
    PTZ_SetPoint,//设定云台定位
    PTZ_GotoPoint,//云台定位
    PTZ_SetPointRotation,
    PTZ_SetPoint_Left,
    PTZ_GotoPoint_Left,
    PTZ_SetPoint_Right,
    PTZ_GotoPoint_Right,
    PTZ_DayNightMode,//白天、夜光模式 0白天 1夜光
    PTZ_Max
}TPTZCmd;
//-----------------------------------------------------------------------------
typedef enum TPTZProtocol {                      //云台协议 sizeof 4
    Pelco_P               =0,
    Pelco_D               =1,
    Protocol_Custom       =2,
}TPTZProtocol;

typedef struct TPTZPkt {                         //PTZ 云台控制  sizeof 108
    TPTZCmd PTZCmd;                                    //=PTZ_None 为透明传输
    union {
        struct {
            TPTZProtocol Protocol;                         //云台协议
            int Address;                                   //云台地址
            int PanSpeed;                                  //云台速度
            int Value;                                     //保留或预设位
            int Flag;
            int sleepms;//20140722 x3 ptz add
        };
        struct {
            char100 TransBuf;
            int TransBufLen;
        };
    };
}TPTZPkt;
//-----------------------------------------------------------------------------
typedef struct TPlayLivePkt {                    //播放现场包//sizeof 20
    DWORD VideoChlMask;//通道掩码
    //  31 .. 19 18 17 16   15 .. 03 02 01 00
    //         0  0  0  0          0  0  0  1
    DWORD AudioChlMask;
    //  31 .. 19 18 17 16   15 .. 03 02 01 00
    //         0  0  0  0          0  0  0  1
    int Value;                                     //Value=0发送所有帧，Value=1只发送视频I帧
    //begin add at 2009/09/02
    DWORD SubVideoChlMask;
    //11  int IsRecvAlarm;                               //0接收设备警报 1不接收设备警报
    //end add
    int Flag;                                      //保留
}TPlayLivePkt;
//-----------------------------------------------------------------------------
typedef struct TPlayBackPkt {                    //sizeof 20
    int Chl;
    int FileType;                                  //0:普通录影 1:警报录影 2媒体文件
    int StartTime;                                 //开始时间
    int EndTime;                                   //结束时间
    int Flag;
}TPlayBackPkt;
//-----------------------------------------------------------------------------
typedef enum TMsgID {
    Msg_None,
    Msg_Login,//用户登录
    Msg_PlayLive,//开始播放现场           2
    Msg_StartPlayRecFile,//播放录影文件
    Msg_StopPlayRecFile,//停止播放录影文件
    Msg_GetRecFileLst,//取得录影文件列表
    Msg_GetDevRecFileHead,//取得设备文件文件头信息
    Msg_StartUploadFile,//开始上传文件
    Msg_AbortUploadFile,//取消上传文件
    Msg_StartUploadFileEx,//开始上传文件tftp
    
    Msg_StartTalk,//开始对讲    10
    Msg_StopTalk,//停止对讲
    Msg_PlayControl,//播放控制
    Msg_PTZControl,//云台控制
    Msg_Alarm,//警报
    Msg_ClearAlarm,//关闭警报
    Msg_GetTime,//取得时间      16
    Msg_SetTime,//设置时间
    Msg_SetDevReboot,//重启设备
    Msg_SetDevLoadDefault,//系统回到缺省配置 Pkt.Value= 0 不恢复IP, Pkt.Value= 1 恢复IP
    
    Msg_DevSnapShot,//设备拍照      20
    Msg_DevStartRec,//设备开始录像
    Msg_DevStopRec,//设备停止录象
    
    Msg_GetColors,//取得亮度、对比度、色度、饱和度     23
    Msg_SetColors,//设置亮度、对比度、色度、饱和度
    Msg_SetColorDefault,
    
    Msg_GetMulticastInfo,//           26
    Msg_SetMulticastInfo,
    
    Msg_GetAllCfg,//取得所有配置          28
    Msg_SetAllCfg,//设置所有配置          29
    Msg_GetDevInfo,//取得设备信息         30
    Msg_SetDevInfo,//设置设备信息
    Msg_GetUserLst,//取得用户列表
    Msg_SetUserLst,//设置用户列表
    Msg_GetNetCfg,//取得网络配置
    Msg_SetNetCfg,//设置网络配置
    Msg_WiFiSearch,
    Msg_GetWiFiCfg,//取得WiFi配置
    Msg_SetWiFiCfg,//设置WiFi配置
    Msg_GetVideoCfg,//取得视频配置
    Msg_SetVideoCfg,//设置视频配置
    Msg_GetAudioCfg,//取得音频配置
    Msg_SetAudioCfg,//设置音频配置
    Msg_GetHideArea,//秘录
    Msg_SetHideArea,//秘录
    Msg_GetMDCfg,//移动侦测配置
    Msg_SetMDCfg,//移动侦测配置
    Msg_GetDiDoCfg__Disable,
    Msg_SetDiDoCfg__Disable,
    Msg_GetAlmCfg,//取得Alarm配置
    Msg_SetAlmCfg,//设置Alarm配置
    Msg_GetRS485Cfg__Disable,
    Msg_SetRS485Cfg__Disable,
    Msg_GetDiskCfg,//设置Disk配置
    Msg_SetDiskCfg,//设置Disk配置
    Msg_GetRecCfg,//取得录影配置
    Msg_SetRecCfg,//设置录影配置
    Msg_GetFTPCfg,
    Msg_SetFTPCfg,
    Msg_GetSMTPCfg,
    Msg_SetSMTPCfg,
    Msg_GetP2PCfg,
    Msg_SetP2PCfg,
    Msg_Ping,
    //begin add 2013-03-07
    Msg_GetRFCfg__Disable,
    Msg_SetRFCfg__Disable,
    Msg_RFControl__Disable,
    Msg_RFPanic__Disable,//67
    //end add 2013-03-07
    Msg_EmailTest,
    Msg_FTPTest,//69
    Msg_GetWiFiSTALst,//70
    Msg_DeleteFromWiFiSTALst,//71
    Msg_IsExistsAlarm,//72
    Msg_DOControl,//73
    Msg_GetDOStatus,//74
    Msg_ReSerialNumber,//75 20130808
    Msg_HttpGet,//76
    Msg_DeleteFile,//77
    
    Msg_HIISPCfg_Save,// 78
    Msg_HIISPCfg_Download,// 79
    Msg_HIISPCfg_Load,// 80
    Msg_HIISPCfg_Default,// 81
    
    Msg_GetAllCfgEx,//82
    Msg_______
}TMsgID;
//-----------------------------------------------------------------------------
#define RECPLANLST 4
typedef struct TPlanRecPkt {                        //排程录影结构 sizeof 224
    struct {
        bool Active;
        Byte start_h;    //时 0-23
        Byte start_m;    //分 0-59
        Byte stop_h;     //时 0-23获取设备是否有警报发生
        Byte stop_m;     //分 0-59
        bool IsRun;      //当前计划是否启动
        Byte Flag1;
        Byte Flag2;
    }Week[7][RECPLANLST];                                 //日一二三四五六 每天最多4个任务
}TPlanRecPkt;
//-----------------------------------------------------------------------------
typedef enum TRecStyle {
    rs_RecManual,
    rs_RecAuto,
    rs_RecPlan,
    rs_RecAlarm
}TRecStyle;

typedef struct TRecCfgPkt {                      //录影配置包 sizeof 260
    int ID;
    int DevID;//PC端管理软件只用于存储数据库中设备编号　设备端保留
    int Chl;
    bool IsLoseFrameRec;//是否丢帧录影
    byte RecStreamType;//0 主码流 1 次码流
    byte Reserved;
    bool IsRecAudio;//录制音频 暂没有用到
    DWORD Rec_AlmPrevTimeLen;//警前录影时长     5 s
    DWORD Rec_AlmTimeLen;//警后录影时长        10 s
    DWORD Rec_NmlTimeLen;//一般录影分割时长   600 s
    TRecStyle RecStyle;//录影类型
    TPlanRecPkt Plan;
    int bFlag;
}TRecCfgPkt;
//-----------------------------------------------------------------------------
/*
 typedef struct TDiskCfgPkt_old {   //sizeof 888
 int IsFillOverlay;      // 是否覆盖早期文件(false或true,false为不覆盖,true为覆盖,缺省为false)
 char20 CurrentDiskName; // 当前正在录影的磁盘索引 0..7, ReadOnly
 struct {
 char20 DiskName;      // 磁盘
 int Active;           // 是否做为录影磁盘 false or true
 DWORD DiskSize;       // M ReadOnly
 DWORD FreeSize;       // M
 DWORD MinFreeSize;    // M
 }Disk[24];
 }TDiskCfgPkt_old;
 */
//-----------------------------------------------------------------------------
typedef struct TDiskCfgPkt {   //sizeof 60
    char Reserved1[24];
    char20 DiskName;      // 磁盘
    int Active;           // 是否做为录影磁盘 false or true
    DWORD DiskSize;       // M ReadOnly
    DWORD FreeSize;       // M
    DWORD MinFreeSize;    // M
}TDiskCfgPkt;
//-----------------------------------------------------------------------------
typedef enum TLanguage {
    cn = 0,
    tw = 1,
    en = 2
}TLanguage;
//static char* DevLanguage[3] = {"cn","tw","en"};
//-----------------------------------------------------------------------------
typedef struct TAxInfo {//sizeof 40
    union {
        char40 BufValue;
        struct {
            bool ExistWiFi;
            bool ExistSD;
            
            bool ethLinkStatus;      //有线网络是否连接
            
            byte HardType;      //硬件类型
            DWORD VideoTypeMask;// 8
            uint64 StandardMask;//16
            //DWORD AutioTypeMask;//20暂未用到
            bool ExistFlash;
            
            
            byte PlatformType;//TPlatFormType
            byte Reserved[2];
            
            bool wifiStatus;
            bool upnpStatus;
            bool WlanStatus;
            bool p2pStatus;
            uint64 SubStandardMask;//32
            //2011-04-06 add
            struct {
                int FirstDate;
                WORD TrialDays;
                WORD RunDays;
            } Sys;
        };
    };
}TAxInfo;

typedef struct TDevInfoPkt {                     //设备信息包sizeof 180
    char DevModal[12];                             //设备型号  ='7xxx'
    DWORD SN;
    int DevType;                                   //设备类型
    char20 SoftVersion;                            //软件版本
    char20 FileVersion;                            //文件版本
    char20 DevName;                                //设备标识
    char40 DevDesc;                                //设备备注
    struct TAxInfo Info;
    
    int VideoChlCount;
    Byte AudioChlCount;
    Byte DiChlCount;
    Byte DoChlCount;
    Byte RS485DevCount;
    signed char TimeZone;
    Byte MaxUserConn;                               //最大用户连接数 default 10
    Byte OEMType;
    bool DoubleStream;                              //是否双码流 add at 2009/09/02
    struct {
        Byte w;//TTaskDayType;
        Byte start_h;//时 0-23
        Byte start_m;//分 0-59
        Byte Days;
    }RebootHM;
    //int Flag;
    int ProcRunningTime;
}TDevInfoPkt;
//-----------------------------------------------------------------------------
typedef struct TWiFiSearchPkt {//sizeof 40
    char32 SSID;
    byte Siganl;//信号 0..100 极好 好 一般 差 极差
    byte Channel;
    byte EncryptType; //0=None 1=WEP 2=WPA
    byte NetworkType;//0=Infra 1=Adhoc
    union {
        struct {
            byte Auth;//0=AUTO 1=OPEN 2=SHARED
            byte tag[3];
        }WEP;
        struct {
            byte Auth;//0=AUTO 1=WPA-PSK 2=WPA2-PSK
            byte Enc;//0=AUTO 1=TKIP 2=AES
            byte tag[2];
        }WPA;
    };
}TWiFiSearchPkt;
//-----------------------------------------------------------------------------
typedef struct TWiFiCfgPkt {                     //无线配置包 sizeof 200
    bool Active;
    bool IsAPMode;//sta=0  ap=1
    byte Reserved[2];
    char SSID_AP[30];
    char Password_AP[30];
    
    char32 SSID_STA;
    int Channel;//频道1..14 default 1=Auto
#define Encrypt_None   0
#define Encrypt_WEP    1
#define Encrypt_WPA    2
    int EncryptType;//(Encrypt_None,Encrypt_WEP,Encrypt_WPA);
    char64 Password_STA;
    int NetworkType;//0=Infra 1=Adhoc
    union {
        struct {
            char ValueStr[28];
        };
#define AUTH_AUTO      0
#define AUTH_OPEN      1
#define AUTH_SHARED    2
#define AUTH_TKIP      1
#define AUTH_AES       2
        struct {
            int Auth;//0=AUTO 1=OPEN 2=SHARED
        }WEP;
        struct {
            int Auth;//0=AUTO 1=WPA-PSK 2=WPA2-PSK
            int Enc;//0=AUTO 1=TKIP 2=AES
        }WPA;
    };
}TWiFiCfgPkt;
//-----------------------------------------------------------------------------
typedef struct TNetCfgPkt {                      //设备网络配置包sizeof 372
    int DataPort;                                   //命令数据端口
    int rtspPort;                                  //rtsp端口
    int HttpPort;                                  //http网页端口
    struct {
#define IP_STATIC   0
#define IP_DYNAMIC  1
        
        int IPType;
        char20 DevIP;
        char20 DevMAC;
        char20 SubMask;
        char20 Gateway;
        char20 DNS1;
        char20 DNS2;
        //bool IsActiveDHCPServer; //是否启动DHCPServer
        char Flag[4];
    }Lan;
    struct {
        int Active;
#define DDNS_3322     0
#define DDNS_dynDNS   1
#define DDNS_MyDDNS   2
#define DDNS_9299     3
        int DDNSType;                               //0=3322.ORG 1=dynDNS.ORG 2=MyDDNS 3=9299.org
        char40 DDNSDomain;                           //或DDNS SERVER IP
        union {
            struct {
                char40 HostAccount;                          //DDNS帐号
                char40 HostPassword;                         //DDNS密码
                int Flag;
            };
            struct {
                char40 DDNSServer;
            };
        };
    }DDNS;
    struct {
        int Active;
        char40 Account;
        char40 Password;
        int Flag;
    }PPPOE;
    struct {
        int Active;
        int Flag;
    }uPnP;
    int Flag;
}TNetCfgPkt;
//-----------------------------------------------------------------------------
typedef enum TBaudRate{
    BaudRate_1200  =    1200,
    BaudRate_2400  =    2400,
    BaudRate_4800  =    4800,
    BaudRate_9600  =    9600,
    BaudRate_19200  =  19200,
    BaudRate_38400  =  38400,
    BaudRate_57600  =  57600,
    BaudRate_115200 = 115200
}TBaudRate;

typedef enum TDataBit{
    DataBit_5 = 5,
    DataBit_6 = 6,
    DataBit_7 = 7,
    DataBit_8 = 8
}TDataBit;

typedef enum TParityCheck{
    ParityCheck_None  = 0,
    ParityCheck_Odd   = 1,
    ParityCheck_Even  = 2,
    ParityCheck_Mask  = 3,
    ParityCheck_Space = 4
}TParityCheck;

typedef enum TStopBit{
    StopBit_1   = 0,
    StopBit_1_5 = 1,
    StopBit_2   = 2
}TStopBit;

typedef struct TRS485CfgPkt__Disable {                       //485通信包 sizeof 280
    int Chl;
    TBaudRate BPS;//波特率
    TDataBit DataBit;//数据位
    TParityCheck ParityCheck;//奇偶校验
    TStopBit StopBit;//停止位
    struct {
        Byte Address;
        Byte PTZProtocol;//云台协议
        Byte PTZSpeed;
        Byte Reserved;
    }Lst[32];//对应相应的视频通道
    
    //char PTZNameLst[128];//暂时未用到 format "Pelco_P\nPelco_D\nProtocol_Custom"
    
    int PTZCount;
    char20 PTZNameLst[6];
    int Reserved;
    
    int Flag;
}TRS485CfgPkt__Disable;

//-----------------------------------------------------------------------------
typedef struct TColorsPkt {
    int Chl;
    Byte  Brightness;                               //亮度   0-255
    Byte  Contrast;                                 //对比度 0-255
    Byte  Hue;                                      //色度   0-255
    Byte  Saturation;                               //饱和度 0-255
    Byte  Sharpness;                                //饱和度 0-255
    Byte Reserved[3];
}TColorsPkt;
//-----------------------------------------------------------------------------
typedef struct TMulticastInfoPkt {               //多播发送信息包sizeof 556->588
    TDevInfoPkt DevInfo;
    TNetCfgPkt NetCfg;
    int Flag;// sendfrom client=0 sendfrom device=1
    TWiFiCfgPkt WiFiCfg;
    Tp2pCfgPkt p2pCfg;
    TVideoCfgPkt VideoCfg;
    TAudioCfgPkt AudioCfg;
}TMulticastInfoPkt;
//-----------------------------------------------------------------------------
#define Head_CmdPkt           0xAAAAAAAA         //命令包包头
#define Head_VideoPkt         0xBBBBBBBB         //视频包包头
#define Head_AudioPkt         0xCCCCCCCC         //音频包包头
#define Head_TalkPkt          0xDDDDDDDD         //对讲包包头
#define Head_UploadPkt        0xEEEEEEEE         //上传包
#define Head_DownloadPkt      0xFFFFFFFF         //下载包//未用
#define Head_CfgPkt           0x99999999         //配置包
#define Head_SensePkt         0x88888888         //侦测包//未用
#define Head_MotionInfoPkt    0x77777777         //移动侦测阀值包头
//-----------------------------------------------------------------------------
typedef struct THeadPkt{                         //sizeof 8
    DWORD VerifyCode;                              //校验码 = 0xAAAAAAAA 0XBBBBBBBB 0XCCCCCCCC 0XDDDDDDDD 0XEEEEEEEE
    DWORD PktSize;                                 //本包大小=1460-8
}THeadPkt;
//-----------------------------------------------------------------------------
typedef struct TTalkHeadPkt {                    //对讲包包头  sizeof 32
    DWORD VerifyCode;                              //校验码 = 0XDDDDDDDD
    DWORD PktSize;
    char20 TalkIP;
    DWORD TalkPort;
}TTalkHeadPkt;
//-----------------------------------------------------------------------------
typedef struct TFrameInfo { //录影文件数据帧头  16 Byte
    Int64 FrameTime;                               //帧时间，time_t*1000000 +us
    Byte Chl;                                      //通道 0..15 对应 1..16通道
    bool IsIFrame;                                 //是否I帧
    WORD FrameID;                                  //帧索引,从0 开始,到65535，周而复始
    union {
        DWORD PrevIFramePos;                         //前一个I帧文件指针，用于文件中处理或网络包发送
        int StreamType;                              //如果是双码流，现场包 0为主码流 1为次码流 add at 2009/09/02
        DWORD DevID;                                 //单连接多设备时用到，暂保留
    };
}TFrameInfo;

typedef struct TDataFrameInfo { //录影文件数据帧头  24 Byte
    THeadPkt Head;  //sizeof 8
    TFrameInfo Frame; //录影文件数据帧头  16 Byte
}TDataFrameInfo;
//-----------------------------------------------------------------------------
typedef struct TMotionInfoPkt { //移动侦测阀值  sizeof 4
    Byte AreaIndex;
    Byte ActiveNum;
    Byte Sensitive;
    Byte Tag;
}TMotionInfoPkt;
//-----------------------------------------------------------------------------
//错误代码
#define ERR_FAIL           0
#define ERR_OK             1
#define ERR_MAXUSERCONN    10001//连接用户数超过最大设定
//-----------------------------------------------------------------------------
typedef struct TLoginPkt {                       //用户登录包 sizeof 252->892
    char20 UserName;                               //用户名称
    char20 Password;                               //用户密码
    char20 DevIP;                                  //要连接的设备IP,或 host
    int UserGroup;                                 //Guest=1 Operator=2 Administrator=3
    int SendSensePkt;                              //是否发送侦测包 0不发送 1发送
    TDevInfoPkt DevInfoPkt;
    //2009-05-12 add begin
    TVideoFormat v[4];
    TAudioFormat a[4];
    //2009-05-12 add end
    //int Flag;//返回是否在线　0不在线　1在线
#define SENDFROM_CLIENT    1
#define SENDFROM_NVRMOBILE 0
    int SendFrom;// (x2 0=手机NVR 1=客户端 )
}TLoginPkt;
//-----------------------------------------------------------------------------
typedef struct TCmdPkt {                         //sizeof 1460-8
    DWORD PktHead;                                 //包头校验码 =Head_CmdPkt 0xAAAAAAAA
    TMsgID MsgID;                                  //消息
    DWORD Session;                                 //网络用户许可，当发送网络登录包时此值为0，等于返回登录包的Session  //当包为程序内部通讯包时，此值忽略
    DWORD Value;                                   //属性或返回值 0 or 1 or ErrorCode
    union {
        char ValueStr[1460 - 4*4 - 8];
        struct TLoginPkt LoginPkt;                   //登录包
        struct TPlayLivePkt LivePkt;                 //播放现场包
        struct TRecFilePkt RecFilePkt;               //回放录影包
        struct TPTZPkt PTZPkt;                       //云台控制台
        struct TRecFileLst RecFileLst;
        struct TPlayCtrlPkt PlayCtrlPkt;             //回放录影控制包
        
        struct TAlmSendPkt AlmSendPkt;               //警报上传包
        struct TDevInfoPkt DevInfoPkt;               //设备信息包
        struct TNetCfgPkt NetCfgPkt;                 //设备网络配置包
        struct TWiFiCfgPkt WiFiCfgPkt;               //无线网络配置包
        struct TDiskCfgPkt DiskCfgPkt;               //磁盘配置包
        struct TUserCfgPkt UserCfgPkt;               //用户配置包
        struct TRecCfgPkt RecCfgPkt;                 //录影配置包
        struct TMDCfgPkt MDCfgPkt;                   //移动侦测包--单通道
        //    struct TDiDoCfgPkt DiDoCfgPkt;               //DIDO配置包 528
        struct TDoControlPkt DoControlPkt;           //DO控制包
        struct THideAreaCfgPkt HideAreaCfgPkt;       //隐藏录影区域包--单通道
        struct TAlmCfgPkt AlmCfgPkt;                 //警报配置包
        struct TVideoCfgPkt VideoCfgPkt;             //视频配置包--单通道
        struct TAudioCfgPkt AudioCfgPkt;             //音频配置包--单通道
        struct TRecFileHead FileHead;                //取得设备文件文件头信息
        struct TFilePkt FilePkt;                     //上传文件包
        //struct TRS485CfgPkt RS485CfgPkt;             //485通信包--单通道
        struct TColorsPkt Colors;                    //设置取得亮度、对比度、色度、饱和度
        
        struct TMulticastInfoPkt MulticastInfo;      //多播信息
        
        struct TFTPCfgPkt FTPCfgPkt;
        struct TSMTPCfgPkt SMTPCfgPkt;
        struct TBatchCfgPkt BatchCfgPkt;             //批量修改配置
        struct TWiFiSearchPkt WiFiSearchPkt[30];
        struct Tp2pCfgPkt p2pCfgPkt;
    };
}TCmdPkt;
//-----------------------------------------------------------------------------
typedef struct TNetCmdPkt {                      //网络发送包 sizeof 1460
    struct THeadPkt HeadPkt;
    struct TCmdPkt CmdPkt;
}TNetCmdPkt;
//-----------------------------------------------------------------------------

//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************
typedef struct TNewDevInfo {
    char DevModal[8];                             //设备型号  ='7xxx'
    DWORD SN;
    char16 SoftVersion;                            //软件版本
    char20 DevName;                                //设备标识
    uint64 StandardMask;//16
    uint64 SubStandardMask;//32
    byte DevType;                                   //设备类型
    bool ExistWiFi;
    bool ExistSD;
    bool ethLinkStatus;      //有线网络是否连接
    bool wifiStatus;
    bool upnpStatus;
    bool WlanStatus;
    bool p2pStatus;
    byte HardType;      //硬件类型
    byte TimeZone;
    bool DoubleStream;                              //是否双码流 add at 2009/09/02
    bool ExistFlash;
    int Reserved;
}TNewDevInfo;//sizeof 80

typedef struct TNewNetCfg{
    word DataPort;                                   //命令数据端口
    word rtspPort;                                  //rtsp端口
    word HttpPort;                                  //http网页端口
    byte IPType;
    byte Flag_00001;
    int DevIP;
    int SubMask;
    int Gateway;
    int DNS1;
    char20 DevMAC;
    bool ActiveuPnP;
    bool ActiveDDNS;
    byte DDNSType;                               //0=3322.ORG 1=dynDNS.ORG 2=MyDDNS 3=9299.org
    byte Flag_00002;
    char40 DDNSDomain;                           //或DDNS SERVER IP
    char40 DDNSServer;
    int Reserved;
}TNewNetCfg;//sizeof 132

typedef struct TNewwifiCfg{
    bool ActiveWIFI;
    bool IsAPMode;//sta=0  ap=1
    byte Flag_00003;
    byte Flag_00004;
    char20 SSID_AP;
    char20 Password_AP;
    char20 SSID_STA;
    char20 Password_STA;
    byte Channel;//频道1..14 default 1=Auto
    byte EncryptType;//(Encrypt_None,Encrypt_WEP,Encrypt_WPA);
    byte Auth;//WEP(0=AUTO 1=OPEN 2=SHARED)  WPA(0=AUTO 1=WPA-PSK 2=WPA2-PSK)
    byte Enc;//WPA(0=AUTO 1=TKIP 2=AES)
    int Reserved;
}TNewwifiCfg;//sizeof 92

typedef struct TNewp2pCfg{
    bool ActiveP2P;
    byte StreamType;//0 主码流 1 次码流
    byte p2pType;   //tutk=0 self=1
    char UID[21];
    char20 Password;
    int SvrIP[4];
    int Reserved;
}TNewp2pCfg;//sizeof 64

typedef struct TNewVideoCfg {
    Byte StandardEx0;//TStandardEx
    Byte FrameRate0;                                //帧率 1-30 MAX:PAL 25 NTSC 30
    word BitRate0;
    byte StandardEx1;//TStandardEx
    byte FrameRate1;//帧率 1-30 MAX:PAL 25 NTSC 30
    word BitRate1;//码流 64K 128K 256K 512K 1024K 1536K 2048K 2560K 3072K
    bool IsMirror;                           //水平翻转 false or true
    bool IsFlip;                             //垂直翻转 false or true
    bool IsShowFrameRate;
    byte Flag_00008;
    int Reserved;
}TNewVideoCfg;//sizeof 16

typedef struct TNewAudioCfg{
    bool  ActiveAUDIO;                                   //是否启动声音
    byte InputTypeAUDIO;                                 //0 MIC输入, 1 LINE输入
    byte VolumeLineIn;
    byte VolumeLineOut;
    byte nChannels;                               //单声道=0 立体声=1
    byte wBitsPerSample;                          //number of bits per sample of mono data
    word nSamplesPerSec;                          //采样率
    byte wFormatTag;
    byte Reserved[3];
}TNewAudioCfg;//sizeof 12

typedef struct TNewUserCfg {
    char20 UserName[3];                               //用户名 admin不能更改
    char20 Password[3];                               //密码
    byte Authority[3];                                 //3为admin
    byte Reserved;
    int Reserved1;
}TNewUserCfg;//sizeof 128

typedef struct TNewDIAlm {
    bool ActiveDI;
    byte Reserved;
    bool IsAlmRec;
    bool IsFTPUpload;
    bool ActiveDO;//DI关联DO通道 false close
    bool IsSendEmail;
    byte Reserved1;// >0为预设位
    byte AlmOutTimeLen;//报警输出时长(秒) 0 ..255 s
    //struct TTaskhm hm;
    int Reserved2;
}TNewDIAlm;//sizeof 12

typedef struct TNewMDAlm {                       //移动侦测包 sizeof 96
    bool ActiveMD;
    byte Sensitive;                              //侦测灵敏度 0-255
    bool IsAlmRec;
    bool IsFTPUpload;
    bool ActiveDO;//DI关联DO通道 false close
    bool IsSendEmail;
    byte Reserved2;
    byte AlmOutTimeLen;                    //报警输出时长(秒) 0 ..255 s
    //struct TTaskhm hm;
    struct {
        float left,top,right,bottom;
    }Rect;
    int Reserved;
}TNewMDAlm;//sizeof 28

typedef struct TNewSoundAlm{
    bool ActiveSoundTrigger;
    byte Sensitive;
    bool IsAlmRec;
    bool IsFTPUpload;
    bool ActiveDO;//DI关联DO通道 false close
    bool IsSendEmail;
    byte Reserved1;// >0为预设位
    byte AlmOutTimeLen;                    //报警输出时长(秒) 0 ..255 s
    //struct TTaskhm hm;
    int Reserved2;
}TNewSoundAlm;//sizeof 12

typedef struct TNewRecCfg{                      //录影配置包 sizeof 260
    byte RecStreamType;//0 主码流 1 次码流
    bool IsRecAudio;//录制音频 暂没有用到
    byte RecStyle;//录影类型
    byte Reserved;
    TPlanRecPkt Plan;
    word Rec_AlmTimeLen;//警后录影时长        10 s
    word Rec_NmlTimeLen;//一般录影分割时长   600 s
    int Reserved1;
}TNewRecCfg;//sizeof 236

typedef struct TNewDevCfg {//812->1000
    union {
        char ValueStr[1000];
        struct {
            struct TNewDevInfo DevInfo;
            struct TNewNetCfg NetCfg;
            struct TNewwifiCfg wifiCfg;
            struct TNewp2pCfg p2pCfg;
            struct TNewVideoCfg VideoCfg;
            struct TNewAudioCfg AudioCfg;
            struct TNewUserCfg UserCfg;
            struct TNewDIAlm DIAlm;
            struct TNewMDAlm MDAlm;
            struct TNewSoundAlm SoundAlm;
            struct TNewRecCfg RecCfg;
        };
    };
}TNewDevCfg;

typedef struct TNewCmdPkt {//maxsize sizeof 1008
    dword VerifyCode;//校验码 = 0xAAAAAAAA
    byte MsgID;//TMsgID
    byte Result;
    word PktSize;
    union {
        int Value;
        char Buf[1000];
        struct TNewDevCfg NewDevCfg;
        
        struct TLoginPkt LoginPkt;                   //登录包 892
        struct TPlayLivePkt LivePkt;                 //播放现场包
        struct TRecFilePkt RecFilePkt;               //回放录影包
        struct TPTZPkt PTZPkt;                       //云台控制台
        struct TPlayCtrlPkt PlayCtrlPkt;             //回放录影控制包
        
        struct TAlmSendPkt AlmSendPkt;               //警报上传包
        struct TDevInfoPkt DevInfoPkt;               //设备信息包
        struct TNetCfgPkt NetCfgPkt;                 //设备网络配置包
        struct TWiFiCfgPkt WiFiCfgPkt;               //无线网络配置包
        struct TDiskCfgPkt DiskCfgPkt;               //磁盘配置包 888
        struct TRecCfgPkt RecCfgPkt;                 //录影配置包
        struct TMDCfgPkt MDCfgPkt;                   //移动侦测包--单通道
        //struct TDiDoCfgPkt DiDoCfgPkt;               //DIDO配置包528
        struct TDoControlPkt DoControlPkt;           //DO控制包    
        struct THideAreaCfgPkt HideAreaCfgPkt;       //隐藏录影区域包--单通道
        struct TAlmCfgPkt AlmCfgPkt;                 //警报配置包
        struct TVideoCfgPkt VideoCfgPkt;             //视频配置包--单通道
        struct TAudioCfgPkt AudioCfgPkt;             //音频配置包--单通道    
        struct TRecFileHead FileHead;                //取得设备文件文件头信息
        struct TFilePkt FilePkt;                     //上传文件包
        //struct TRS485CfgPkt RS485CfgPkt;             //485通信包--单通道
        struct TColorsPkt Colors;                    //设置取得亮度、对比度、色度、饱和度
        struct TFTPCfgPkt FTPCfgPkt;
        struct TSMTPCfgPkt SMTPCfgPkt;
        struct Tp2pCfgPkt p2pCfgPkt;
        //struct TRecFileLst RecFileLst;
        //struct TUserCfgPkt UserCfgPkt;               //用户配置包
        //struct TMulticastInfoPkt MulticastInfo;      //多播信息
        //struct TBatchCfgPkt BatchCfgPkt;             //批量修改配置
        //struct TWiFiSearchPkt WiFiSearchPkt[30];
        
    };  
}TNewCmdPkt;

//#pragma option pop //end C++Builder enum 4 Byte

#endif //end Ax_protocol_H


