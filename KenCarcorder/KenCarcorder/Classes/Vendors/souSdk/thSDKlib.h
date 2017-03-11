//-----------------------------------------------------------------------------
// Author      : 深圳市南方无限智能科技有限公司
// Date        : 2013.04.20
// Version     : V 2.02
// Description : www.southipcam.com
//-----------------------------------------------------------------------------
#ifndef thSDK_H
#define thSDK_H

#define AVI
#ifdef AVI
#include "avi.h"
#endif

#include "cm_types.h"
#include "axdll.h"

#include "IOTCAPIs.h"
#include "AVAPIs.h"
#include "AVFRAMEINFO.h"
#include "AVIOCTRLDEFs.h"

#define IsUsedP2P


extern bool IsExit;
//*****************************************************************************
//网络相关函数
#define NET_TIMEOUT               5000  // ms
#define NET_CONNECT_TIMEOUT       3000  // ms

//*****************************************************************************

typedef void(TAVCallBack)(
    TDataFrameInfo* PInfo,    //音视频帧头信息
    char* Buf,                //音视频解码前帧数据
    int Len,                  //数据长度
    void* UserCustom          //用户自定义数据
);

typedef void(TAlmCallBack)(
    int AlmType,             //警报类型，参见TAlmType
    int AlmTime,             //警报时间time_t
    int AlmChl,              //警报通道
    void* UserCustom         //用户自定义数据
);

typedef struct TPlayParam {
    TDevCfg DevCfg;
    TNetCmdPkt loginPkt;
#define MaxBufSize 1024*300
    char RecvBuf[MaxBufSize];
    int RecvLen;
    
    char RecvDownloadBuf[MaxBufSize];
    int RecvDownloadLen;
    
    int DevType;
    
    TAVCallBack* avEvent;
    TAlmCallBack* AlmEvent;
    void* UserCustom;
    
    int IsExit;
    
    DWORD VideoChlMask;
    DWORD AudioChlMask;
    DWORD SubVideoChlMask;
    int IsNewStartPlay;
    
    char40 UserName;
    char40 Password;
    char40 SvrIP;
    char40 DevIP;
    int DataPort;
    DWORD TimeOut;
    
    int Isp2pConn;
    
    byte p2pType;
    byte IsStopHttpGet;
    byte flag[2];
    char40 p2pUID;
    char20 p2pPSD;
    int p2p_SessionID;
    int p2p_avIndex;
    int p2p_talkIndex;
    char20 p2p_SvrIP1;
    char20 p2p_SvrIP2;
    char20 p2p_SvrIP3;
    char20 p2p_SvrIP4;
    
#ifdef AVI
    int FileType;//avi=0 mp4=1
    int recHandle;
    
    int StreamIDvideo;
    int StreamIDaudio;
    char80 RecFileName;
#endif
    
    bool IsConnect;
    
    DWORD Session;
    int hSocket;
    int IsCreateRecvThread;
    
    pthread_t tHandle;
    int StreamType;//0÷˜¬Î¡˜ 1¥Œ¬Î¡˜
    int ImgWidth;
    int ImgHeight;
    
    int RealBitRate_av;
    int RealFrameRate_av;
    int LastSenseTime;
    
    
    bool isPlayRecorder;
    
}TPlayParam;

//-----------------------------------------------------------------------------
typedef void(TSearchDevCallBack)(
    int SN,            //
    int DevType,       //设备类型
    int VideoChlCount, //通道数据
    int DataPort,      //数据端口
    int HttpPort,      //WEB端口
    char* DevName,     //设备名称
    char* DevIP,       //设备IP
    char* DevMAC,      //设备MAC地址
    char* SubMask,     //设备子网掩码
    char* Gateway,     //设备网关
    char* DNS1,        //设备DNS
    char* DDNSHost,    //DDNS域名
    char* UID          //P2P方式UID
);

bool GetWidthHeightFromStandard(int Value, int* w, int* h);
int GetStandardFromWidthHeight(int w, int h);
//-----------------------------------------------------------------------------
bool thNet_Init(int64_t* NetHandle, int DevType);
/*-----------------------------------------------------------------------------
 函数描述：初始化网络播放
 参数说明：
 NetHandle:返回网络句柄
 DevType:设备类型
 X1=dt_Devx1=11
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_SetCallBack(int64_t NetHandle, TAVCallBack avEvent, TAlmCallBack AlmEvent, void* UserCustom);
/*-----------------------------------------------------------------------------
 函数描述：网络播放设置回调函数
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 avEvent:视频音频数据回调函数
 AlmEvent:设备警报回调函数
 UserCustom:用户自定义数据
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_Free(int64_t* NetHandle);
/*-----------------------------------------------------------------------------
 函数描述：播放网络播放
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_Connect(int64_t NetHandle, char* UserName, char* Password, char* SvrIP, char* DevIP, int DataPort, DWORD TimeOut, int IsCreateRecvThread);
/*-----------------------------------------------------------------------------
 函数描述：连接网络设备
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 UserName:连接帐号
 Password:连接密码
 DevIP:设备IP
 SvrIP:转发服务器IP，如果直接连接设备，则与设备IP同
 DataPort:设备或转发服务器端口
 TimeOut:连接超时，单位ms,缺省 3000ms
 IsCreateRecvThread:是否创建数据收取线程
 返 回 值：成功返回true
 失败返回false
 ------------------------------------------------------------------------------*/
#ifdef IsUsedP2P
int thNet_Connect_P2P(int64_t NetHandle, int p2pType, char* p2pUID, char* p2pPSD, DWORD TimeOut, int IsCreateRecvThread);
#endif
/*-----------------------------------------------------------------------------
 函数描述：连接网络设备，P2P方式
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 UID:设备ID
 TimeOut:连接超时，单位ms,缺省 3000ms
 IsCreateRecvThread:是否创建数据收取线程
 返 回 值：成功返回true
 失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_DisConn(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 函数描述：断开网络设备连接
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
void thNet_DeInitializeP2p();
/*-----------------------------------------------------------------------------
 函数描述：断开p2p连接的初始状态
 ------------------------------------------------------------------------------*/
bool thNet_IsConnect(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 函数描述：设备是否连接
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_Play(int64_t NetHandle, DWORD VideoChlMask, DWORD AudioChlMask, DWORD SubVideoChlMask);
/*-----------------------------------------------------------------------------
 函数描述：开始播放
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 VideoChlMask:通道掩码，
 bit: 31 .. 19 18 17 16   15 .. 03 02 01 00
 0  0  0  0          0  0  0  1
 AudioChlMask:通道掩码，
 bit: 31 .. 19 18 17 16   15 .. 03 02 01 00
 0  0  0  0          0  0  0  1
 SubVideoChlMask:次码流通道掩码
 bit: 31 .. 19 18 17 16   15 .. 03 02 01 00
 0  0  0  0          0  0  0  1
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_Stop(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 函数描述：停止播放
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_PTZControl(int64_t NetHandle, int Cmd, int Chl, int Speed, int SetPoint);
/*-----------------------------------------------------------------------------
 函数描述：设备云台(高速球)控制
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 Cmd:云台命令，参见TPTZCmd
 aChl:通道 IPCAM = 0
 Speed:云台速度，或球机预设位值
 SetPoint:球机预设位值
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_GetVideoCfg1(int64_t NetHandle, int* Standard, int* VideoType, int* IsMirror, int* IsFlip,
                        int* Width0, int* Height0, int* FrameRate0, int* BitRate0,
                        int* Width1, int* Height1, int* FrameRate1, int* BitRate1);
/*-----------------------------------------------------------------------------
 函数描述：获取视频配置1
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 Standard :NTSC=0 PAL=1  60HZ=0 50HZ=1
 VideoType:MPEG4=0 MJPEG=1 H264=2
 IsMirror :图像是否镜像
 IsFlip   :图像是否反转
 Width0   :主码流宽
 Height0  :主码流高
 FrameRate0:主码流帧率
 BitRate0:主码流码流
 Width1   :次码流宽
 Height1  :次码流高
 FrameRate1:次码流帧率
 BitRate1:次码流码流
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_SetVideoCfg1(int64_t NetHandle, int Standard, int VideoType, int IsMirror, int IsFlip,
                        int Width0, int Height0, int FrameRate0, int BitRate0,
                        int Width1, int Height1, int FrameRate1, int BitRate1);
/*-----------------------------------------------------------------------------
 函数描述：设置视频配置1
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 Standard :NTSC=0 PAL=1  60HZ=0 50HZ=1
 VideoType:MPEG4=0 MJPEG=1 H264=2
 IsMirror :图像是否镜像
 IsFlip   :图像是否反转
 Width0   :主码流宽
 Height0  :主码流高
 FrameRate0:主码流帧率
 BitRate0:主码流码流
 Width1   :次码流宽
 Height1  :次码流高
 FrameRate1:次码流帧率
 BitRate1:次码流码流
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_GetAudioCfg1(int64_t NetHandle, int* wFormatTag, int* nChannels, int* nSamplesPerSec, int* wBitsPerSample);
/*-----------------------------------------------------------------------------
 函数描述：获取音频配置1
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 wFormatTag: PCM=1
 nChannels :单声道=0 立体声=1
 nSamplesPerSec:采样率
 wBitsPerSample: 8位 16位
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_SetAudioCfg1(int64_t NetHandle, int wFormatTag, int nChannels, int nSamplesPerSec, int wBitsPerSample);
/*-----------------------------------------------------------------------------
 函数描述：设置音频配置1
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 wFormatTag: PCM=1
 nChannels :单声道=0 立体声=1
 nSamplesPerSec:采样率
 wBitsPerSample: 8位 16位
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_SetTalk(int64_t NetHandle, char* Buf, int BufLen);
/*-----------------------------------------------------------------------------
 函数描述：发送对讲音频数据
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 音频采集格式，从thNet_GetAudioCfg获取
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thSearch_Init(TSearchDevCallBack SearchEvent);
/*-----------------------------------------------------------------------------
 函数描述：初始化查询设备
 参数说明：
 SearchEvent:查询设备回调函数
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thSearch_SearchDevice(char* LocalIP);
/*-----------------------------------------------------------------------------
 函数描述：开始查询设备
 LocalIP:传入的本地IP，缺省为NULL
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thSearch_Free(void);
/*-----------------------------------------------------------------------------
 函数描述：释放查询设备
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/

//*****************************************************************************
bool thNet_CreateRecvThread(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 函数描述：创建收取数据线程
 参数说明：只能在thNet_Connect中IsCreateRecvThread为false时使用
 NetHandle:网络句柄，由thNet_Init返回
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_RemoteFilePlay(int64_t NetHandle, char* FileName);
/*-----------------------------------------------------------------------------
 函数描述：开始播放远程文件
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 FileName:传入的远程录像文件名
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_RemoteFileStop(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 函数描述：停止播放远程文件
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_RemoteFilePlayControl(int64_t NetHandle, int PlayCtrl, int Speed, int Pos);
/*-----------------------------------------------------------------------------
 函数描述：远程文件播放控制
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 PlayCtrl:   PS_None               =0,                 //空
 PS_Play               =1,                 //播放
 PS_Pause              =2,                 //暂停
 PS_Stop               =3,                 //停止
 PS_FastBackward       =4,                 //快退
 PS_FastForward        =5,                 //快进
 PS_StepBackward       =6,                 //步退
 PS_StepForward        =7,                 //步进
 PS_DragPos            =8,                 //拖动
 Speed:如果PlayCtrl=PS_StepBackward, PS_FastForward ，则保存快进快退倍率 1 2 4 8 16 32倍率
 Pos:如果PlayCtrl=PS_DragPos，则保存文件文件位置Pos
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/
bool thNet_HttpGet(int64_t NetHandle, char* url, char* Buf, int* BufLen);
bool thNet_HttpGetStop(int64_t NetHandle);
/*------------------------------------------------------------------------------
 ------------------------------------------------------------------------------*/
bool thNet_IsRecord(int64_t NetHandle);
bool thNet_RecordStop(int64_t NetHandle);
bool thNet_RecordStart(int64_t NetHandle,
                       int FileType, char* FileName,
                       int VideoType, int Width, int Height, int FrameRate, int BitRate,
                       int AudioType, int nChannels, int wBitsPerSample, int nSamplesPerSec);
/*-----------------------------------------------------------------------------
 函数描述：是否正在录像
 参数说明：
 NetHandle:网络句柄，由thNet_Init返回
 Chl:通道
 返 回 值：成功返回true，失败返回false
 ------------------------------------------------------------------------------*/

#pragma mark - 新的p2p连接方案
/**
 *  新的p2p连接，这里不再做p2p的初始操作
 *
 *  @param NetHandle          句柄
 *  @param p2pType            类型
 *  @param p2pUID             uid
 *  @param p2pPSD             pwd
 *  @param TimeOut            超时时间
 *  @param IsCreateRecvThread 是否需要创建线程接收数据
 *
 *  @return 连接结果状态，1为成功，-200009为视频已加密，其他都是失败
 */
int ken_Connect_P2P(int64_t NetHandle, int p2pType, char* p2pUID, char* p2pPSD, DWORD TimeOut, int IsCreateRecvThread);

/**
 *  新的p2p断开连接，不再做p2p初始的反向操作
 *
 *  @param NetHandle 句柄
 *
 *  @return 成功或者失败状态
 */
bool ken_DisConnP2p(int64_t NetHandle);

/**
 *  创建p2p的数据接收线程
 *
 *  @return 创建结果状态，0为成功
 */
int ken_createThreadP2p(int64_t NetHandle);

/**
 *  关闭p2p的数据接收线程
 *
 *  @return 关闭结果状态，0为成功
 */
int ken_closeThreadP2p(int64_t NetHandle);
    
/**
 *  直接做p2p初始的反向操作
 */
void ken_DeInitializeP2p();

/**
 *  p2p的初始化操作
 */
int ken_InitializeP2p();
#endif

