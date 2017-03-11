//-----------------------------------------------------------------------------
// Author      : ÉîÛÚÊÐÄÏ·½ÎÞÏÞÖÇÄÜ¿Æ¼¼ÓÐÏÞ¹«Ë¾
// Date        : 2013.04.20
// Version     : V 2.00
// Description : www.southipcam.com
//-----------------------------------------------------------------------------
#ifndef thSDK_H
#define thSDK_H
#ifndef WIN32
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/timeb.h>
#include <dirent.h>
#include <sys/stat.h>
#include <stddef.h>
#include <ctype.h>
#include <time.h>
#include <getopt.h>
#include <termios.h>
#include <signal.h>
#include <stdbool.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/socket.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <netinet/in.h>


#include <netdb.h>

#include <sys/shm.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/msg.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <string.h>
#include <stdbool.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif
#include <stdarg.h>
#else
#include <Windows.h>
#include <winsock.h>
#ifndef __cplusplus
#define bool unsigned char
#define true  1
#define false 0
#endif
#endif

#ifndef WIN32
#define Byte unsigned char
#define byte Byte
#define BYTE Byte
#define word unsigned short
#define WORD word
#define DWORD unsigned int
#define uint  unsigned int
#define dword DWORD
#define int16 short
#define uint16 word
#define uint32_t DWORD
#define int64 long long
#define Int64 int64
#define uint64 unsigned long long
#define pchar char*
#define pChar pchar
#else
#define Byte byte
#define word unsigned short
#define DWORD unsigned int
#define uint  unsigned int
#define int16 short
#define uint16 word
#define uint32_t DWORD
#define int64 DWORD64
#define Int64 int64
#define uint64 DWORD64
#define pchar char*
#define pChar pchar
#define time_t int
#define dword DWORD
#endif

typedef char char20[20];
typedef char char40[40];

#pragma pack(4)//n=1,2,4,8,16
//-----------------------------------------------------------------------------
#define Port_th_CmdData        2000                        //TCP È±Ê¡ÃüÁîÊý¾Ý¶Ë¿Ú ¶Ô½²¶Ë¿Ú
#define Port_th_http             80
#define Port_th_RTSP            554

#define Port_th_Multicast      2000
#define Port_th_Search_Local   1999
#define IP_th_Multicast  "239.255.255.250"//uPnP IP²éÑ¯ ¶à²¥¶Ô½²IP
#define REC_FILE_EXT           "av"
#define REC_FILE_EXT_DOT       ".av"

//-----------------------------------------------------------------------------
#define Head_CmdPkt           0xAAAAAAAA         //ÃüÁî°ü°üÍ·
#define Head_VideoPkt         0xBBBBBBBB         //ÊÓÆµ°ü°üÍ·
#define Head_AudioPkt         0xCCCCCCCC         //ÒôÆµ°ü°üÍ·
#define Head_TalkPkt          0xDDDDDDDD         //¶Ô½²°ü°üÍ·
#define Head_UploadPkt        0xEEEEEEEE         //ÉÏ´«°ü
#define Head_DownloadPkt      0xFFFFFFFF         //ÏÂÔØ°ü
#define Head_CfgPkt           0x99999999         //ÅäÖÃ°ü
#define Head_SensePkt         0x88888888         //Õì²â°ü
//-----------------------------------------------------------------------------
typedef struct THeadPkt{                         //sizeof 8
    DWORD VerifyCode;                              //Ð£ÑéÂë = 0xAAAAAAAA 0XBBBBBBBB 0XCCCCCCCC 0XDDDDDDDD 0XEEEEEEEE
    DWORD PktSize;                                 //±¾°ü´óÐ¡=1460-8
}THeadPkt;
//-----------------------------------------------------------------------------
typedef struct TFrameInfo { //Â¼Ó°ÎÄ¼þÊý¾ÝÖ¡Í·  16 Byte
    Int64 FrameTime;                               //Ö¡Ê±¼ä£¬time_t*1000000 +us
    Byte Chl;                                      //Í¨µÀ 0..15 ¶ÔÓ¦ 1..16Í¨µÀ
    bool IsIFrame;                                 //ÊÇ·ñIÖ¡
    WORD FrameID;                                  //Ö¡Ë÷Òý,´Ó0 ¿ªÊ¼,µ½65535£¬ÖÜ¶ø¸´Ê¼
    union {
        DWORD PrevIFramePos;                         //Ç°Ò»¸öIÖ¡ÎÄ¼þÖ¸Õë£¬ÓÃÓÚÎÄ¼þÖÐ´¦Àí»òÍøÂç°ü·¢ËÍ
        int StreamType;                              //Èç¹ûÊÇË«ÂëÁ÷£¬ÏÖ³¡°ü 0ÎªÖ÷ÂëÁ÷ 1Îª´ÎÂëÁ÷ add at 2009/09/02
        DWORD DevID;                                 //µ¥Á¬½Ó¶àÉè±¸Ê±ÓÃµ½£¬ÔÝ±£Áô
    };
}TFrameInfo;

typedef struct TDataFrameInfo { //Â¼Ó°ÎÄ¼þÊý¾ÝÖ¡Í·  24 Byte
    THeadPkt Head;
    TFrameInfo Frame;
}TDataFrameInfo;
//-----------------------------------------------------------------------------
typedef enum TAlmType {
    Alm_None             =0,//¿Õ
    Alm_MotionDetection  =1,//Î»ÒÆ±¨¾¯Motion Detection
    Alm_DigitalInput     =2,//DI±¨¾¯
    Alm_SoundTouch       =3,////ÉùÒô´¥·¢±¨¾¯
    Net_Disconn          =4,//ÍøÂç¶ÏÏß
    Net_ReConn           =5,//ÍøÂçÖØÁ¬
    Alm_HddFill          =6,//´ÅÂú
    Alm_VideoBlind       =7,//ÊÓÆµÕÚµ²
    Alm_VideoLost        =8,//ÊÓÆµ¶ªÊ§
    Alm_Other3           =9,//ÆäËü±¨¾¯3
    Alm_Other4           =10,//ÆäËü±¨¾¯4
    Alm_RF               =11,
    Alm_OtherMax         =12,
}TAlmType;
//-----------------------------------------------------------------------------
typedef void(TSearchDevCallBack)(
int SN,            //
int DevType,       //Éè±¸ÀàÐÍ
int VideoChlCount, //Í¨µÀÊý¾Ý
int DataPort,      //Êý¾Ý¶Ë¿Ú
int HttpPort,      //WEB¶Ë¿Ú
char* DevName,     //Éè±¸Ãû³Æ
char* DevIP,       //Éè±¸IP
char* DevMAC,      //Éè±¸MACµØÖ·
char* SubMask,     //Éè±¸×ÓÍøÑÚÂë
char* Gateway,     //Éè±¸Íø¹Ø
char* DNS1,        //Éè±¸DNS
char* DDNSHost,    //DDNSÓòÃû
char* UID          //P2P·½Ê½UID
);

typedef void(TAVCallBack)(
TDataFrameInfo* PInfo,    //ÒôÊÓÆµÖ¡Í·ÐÅÏ¢
char* Buf,                //ÒôÊÓÆµ½âÂëÇ°Ö¡Êý¾Ý
int Len,                  //Êý¾Ý³¤¶È
void* UserCustom          //ÓÃ»§×Ô¶¨ÒåÊý¾Ý
);

typedef void(TAlmCallBack)(
int AlmType,             //¾¯±¨ÀàÐÍ£¬²Î¼ûTAlmType
int AlmTime,             //¾¯±¨Ê±¼ätime_t
int AlmChl,              //¾¯±¨Í¨µÀ
void* UserCustom         //ÓÃ»§×Ô¶¨ÒåÊý¾Ý
);

//-----------------------------------------------------------------------------
bool thNet_Init(int64_t* NetHandle, int DevType);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º³õÊ¼»¯ÍøÂç²¥·Å
 ²ÎÊýËµÃ÷£º
 NetHandle:·µ»ØÍøÂç¾ä±ú
 DevType:Éè±¸ÀàÐÍ
 X1=dt_Devx1=11
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_SetCallBack(int64_t NetHandle, TAVCallBack avEvent, TAlmCallBack AlmEvent, void* UserCustom);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÍøÂç²¥·ÅÉèÖÃ»Øµ÷º¯Êý
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 avEvent:ÊÓÆµÒôÆµÊý¾Ý»Øµ÷º¯Êý
 AlmEvent:Éè±¸¾¯±¨»Øµ÷º¯Êý
 UserCustom:ÓÃ»§×Ô¶¨ÒåÊý¾Ý
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_GetDevChlName(int64_t NetHandle, int Chl, char* ChlName);
/*-------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º»ñÈ¡Éè±¸Í¨µÀÃû³Æ
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 -------------------------------------------------------------------------------*/
bool thNet_Free(int64_t* NetHandle);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º²¥·ÅÍøÂç²¥·Å
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_Connect(int64_t NetHandle, char* UserName, char* Password, char* SvrIP, char* DevIP, int DataPort, DWORD TimeOut, int IsCreateRecvThread);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÁ¬½ÓÍøÂçÉè±¸
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 UserName:Á¬½ÓÕÊºÅ
 Password:Á¬½ÓÃÜÂë
 DevIP:Éè±¸IP
 SvrIP:×ª·¢·þÎñÆ÷IP£¬Èç¹ûÖ±½ÓÁ¬½ÓÉè±¸£¬ÔòÓëÉè±¸IPÍ¬
 DataPort:Éè±¸»ò×ª·¢·þÎñÆ÷¶Ë¿Ú
 TimeOut:Á¬½Ó³¬Ê±£¬µ¥Î»ms,È±Ê¡ 3000ms
 IsCreateRecvThread:ÊÇ·ñ´´½¨Êý¾ÝÊÕÈ¡Ïß³Ì
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_Connect_P2P(int64_t NetHandle, int p2pType, char* p2pUID, char* p2pPSD, DWORD TimeOut, int IsCreateRecvThread);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÁ¬½ÓÍøÂçÉè±¸£¬P2P·½Ê½
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 p2pType: tutk=0
 UID:Éè±¸ID
 TimeOut:Á¬½Ó³¬Ê±£¬µ¥Î»ms,È±Ê¡ 3000ms
 IsCreateRecvThread:ÊÇ·ñ´´½¨Êý¾ÝÊÕÈ¡Ïß³Ì
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue
 Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_DisConn(int64_t NetHandle);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º¶Ï¿ªÍøÂçÉè±¸Á¬½Ó
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_IsConnect(int64_t NetHandle);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÉè±¸ÊÇ·ñÁ¬½Ó
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_Play(int64_t NetHandle, DWORD VideoChlMask, DWORD AudioChlMask, DWORD SubVideoChlMask);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º¿ªÊ¼²¥·Å
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 VideoChlMask:Í¨µÀÑÚÂë£¬
 bit: 31 .. 19 18 17 16   15 .. 03 02 01 00
 0  0  0  0          0  0  0  1
 AudioChlMask:Í¨µÀÑÚÂë£¬
 bit: 31 .. 19 18 17 16   15 .. 03 02 01 00
 0  0  0  0          0  0  0  1
 SubVideoChlMask:´ÎÂëÁ÷Í¨µÀÑÚÂë
 bit: 31 .. 19 18 17 16   15 .. 03 02 01 00
 0  0  0  0          0  0  0  1
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_Stop(int64_t NetHandle);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÍ£Ö¹²¥·Å
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
//-----------------------------------------------------------------------------
typedef enum TPTZCmd {                           //sizeof 4 Byte
    PTZ_None,
    PTZ_Up,//ÉÏ
    PTZ_Up_Stop,//ÉÏÍ£Ö¹
    PTZ_Down,//ÏÂ
    PTZ_Down_Stop,//ÏÂÍ£Ö¹
    PTZ_Left,//×ó
    PTZ_Left_Stop,//×óÍ£Ö¹
    PTZ_Right,//ÓÒ
    PTZ_Right_Stop,//ÓÒÍ£Ö¹
    
    PTZ_LeftUp,//×óÉÏ
    PTZ_LeftUp_Stop,//×óÉÏÍ£Ö¹
    PTZ_RightUp,//ÓÒÉÏ
    PTZ_RightUp_Stop,//ÓÒÉÏÍ£Ö¹
    PTZ_LeftDown,//×óÏÂ
    PTZ_LeftDown_Stop,//×óÏÂÍ£Ö¹
    PTZ_RightDown,//ÓÒÏÂ
    PTZ_RightDown_Stop,//ÓÒÏÂÍ£Ö¹
    
    PTZ_IrisIn,//¹âÈ¦Ð¡
    PTZ_IrisInStop,//¹âÈ¦Í£Ö¹
    PTZ_IrisOut,//¹âÈ¦´ó
    PTZ_IrisOutStop,//¹âÈ¦Í£Ö¹
    
    PTZ_ZoomIn,//±¶ÂÊÐ¡
    PTZ_ZoomInStop,//±¶ÂÊÍ£Ö¹
    PTZ_ZoomOut,//±¶ÂÊ´ó
    PTZ_ZoomOutStop,//±¶ÂÊÍ£Ö¹
    
    PTZ_FocusIn,//½¹¾àÐ¡
    PTZ_FocusInStop,//½¹¾àÍ£Ö¹
    PTZ_FocusOut,//½¹¾à´ó
    PTZ_FocusOutStop,//½¹¾àÍ£Ö¹
    
    PTZ_LightOn,//µÆ¹âÐ¡
    PTZ_LightOff,//µÆ¹â´ó
    PTZ_RainBrushOn,//ÓêË¢¿ª
    PTZ_RainBrushOff,//ÓêË¢¿ª
    PTZ_AutoOn,//×Ô¶¯¿ªÊ¼  //Rotation
    PTZ_AutoOff,//×Ô¶¯Í£Ö¹
    
    PTZ_TrackOn,
    PTZ_TrackOff,
    PTZ_IOOn,
    PTZ_IOOff,
    
    PTZ_ClearPoint,//ÔÆÌ¨¸´Î»
    PTZ_SetPoint,//Éè¶¨ÔÆÌ¨¶¨Î»
    PTZ_GotoPoint,//ÔÆÌ¨¶¨Î»
    PTZ_SetPointRotation,
    PTZ_SetPoint_Left,
    PTZ_GotoPoint_Left,
    PTZ_SetPoint_Right,
    PTZ_GotoPoint_Right,
    PTZ_DayNightMode,//°×Ìì¡¢Ò¹¹âÄ£Ê½ 0°×Ìì 1Ò¹¹â
    PTZ_Max
}TPTZCmd;
//-----------------------------------------------------------------------------
bool thNet_PTZControl(int64_t NetHandle, int Cmd, int Chl, int Speed, int SetPoint);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÉè±¸ÔÆÌ¨(¸ßËÙÇò)¿ØÖÆ
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 Cmd:ÔÆÌ¨ÃüÁî£¬²Î¼ûTPTZCmd
 aChl:Í¨µÀ IPCAM = 0
 Speed:ÔÆÌ¨ËÙ¶È£¬»òÇò»úÔ¤ÉèÎ»Öµ
 SetPoint:Çò»úÔ¤ÉèÎ»Öµ
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_GetVideoCfg1(int64_t NetHandle, int* Standard, int* VideoType, int* IsMirror, int* IsFlip,
                        int* Width0, int* Height0, int* FrameRate0, int* BitRate0,
                        int* Width1, int* Height1, int* FrameRate1, int* BitRate1);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£º»ñÈ¡ÊÓÆµÅäÖÃ1
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 Standard :NTSC=0 PAL=1  60HZ=0 50HZ=1
 VideoType:MPEG4=0 MJPEG=1 H264=2
 IsMirror :Í¼ÏñÊÇ·ñ¾µÏñ
 IsFlip   :Í¼ÏñÊÇ·ñ·´×ª
 Width0   :Ö÷ÂëÁ÷¿í
 Height0  :Ö÷ÂëÁ÷¸ß
 FrameRate0:Ö÷ÂëÁ÷Ö¡ÂÊ
 BitRate0:Ö÷ÂëÁ÷ÂëÁ÷
 Width1   :´ÎÂëÁ÷¿í
 Height1  :´ÎÂëÁ÷¸ß
 FrameRate1:´ÎÂëÁ÷Ö¡ÂÊ
 BitRate1:´ÎÂëÁ÷ÂëÁ÷
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_SetVideoCfg1(int64_t NetHandle, int Standard, int VideoType, int IsMirror, int IsFlip,
                        int Width0, int Height0, int FrameRate0, int BitRate0,
                        int Width1, int Height1, int FrameRate1, int BitRate1);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÉèÖÃÊÓÆµÅäÖÃ1
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 Standard :NTSC=0 PAL=1  60HZ=0 50HZ=1
 VideoType:MPEG4=0 MJPEG=1 H264=2
 IsMirror :Í¼ÏñÊÇ·ñ¾µÏñ
 IsFlip   :Í¼ÏñÊÇ·ñ·´×ª
 Width0   :Ö÷ÂëÁ÷¿í
 Height0  :Ö÷ÂëÁ÷¸ß
 FrameRate0:Ö÷ÂëÁ÷Ö¡ÂÊ
 BitRate0:Ö÷ÂëÁ÷ÂëÁ÷
 Width1   :´ÎÂëÁ÷¿í
 Height1  :´ÎÂëÁ÷¸ß
 FrameRate1:´ÎÂëÁ÷Ö¡ÂÊ
 BitRate1:´ÎÂëÁ÷ÂëÁ÷
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_GetAudioCfg1(int64_t NetHandle, int* wFormatTag, int* nChannels, int* nSamplesPerSec, int* wBitsPerSample);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£º»ñÈ¡ÒôÆµÅäÖÃ1
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 wFormatTag: PCM=1
 nChannels :µ¥ÉùµÀ=0 Á¢ÌåÉù=1
 nSamplesPerSec:²ÉÑùÂÊ
 wBitsPerSample: 8Î» 16Î»
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_SetAudioCfg1(int64_t NetHandle, int wFormatTag, int nChannels, int nSamplesPerSec, int wBitsPerSample);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÉèÖÃÒôÆµÅäÖÃ1
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 wFormatTag: PCM=1
 nChannels :µ¥ÉùµÀ=0 Á¢ÌåÉù=1
 nSamplesPerSec:²ÉÑùÂÊ
 wBitsPerSample: 8Î» 16Î»
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_SetTalk(int64_t NetHandle, char* Buf, int BufLen);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º·¢ËÍ¶Ô½²ÒôÆµÊý¾Ý
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ÒôÆµ²É¼¯¸ñÊ½£¬´ÓthNet_GetAudioCfg»ñÈ¡
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thSearch_Init(TSearchDevCallBack SearchEvent);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º³õÊ¼»¯²éÑ¯Éè±¸
 ²ÎÊýËµÃ÷£º
 SearchEvent:²éÑ¯Éè±¸»Øµ÷º¯Êý
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thSearch_SearchDevice(char* LocalIP);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£º¿ªÊ¼²éÑ¯Éè±¸
 LocalIP:´«ÈëµÄ±¾µØIP£¬È±Ê¡ÎªNULL
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thSearch_Free(void);
/*------------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÊÍ·Å²éÑ¯Éè±¸
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_CreateRecvThread(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£º´´½¨ÊÕÈ¡Êý¾ÝÏß³Ì
 ²ÎÊýËµÃ÷£ºÖ»ÄÜÔÚthNet_ConnectÖÐIsCreateRecvThreadÎªfalseÊ±Ê¹ÓÃ
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_RemoteFilePlay(int64_t NetHandle, char* FileName);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£º¿ªÊ¼²¥·ÅÔ¶³ÌÎÄ¼þ
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 FileName:´«ÈëµÄÔ¶³ÌÂ¼ÏñÎÄ¼þÃû
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_RemoteFileStop(int64_t NetHandle);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÍ£Ö¹²¥·ÅÔ¶³ÌÎÄ¼þ
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_RemoteFilePlayControl(int64_t NetHandle, int PlayCtrl, int Speed, int Pos);
/*-----------------------------------------------------------------------------
 º¯ÊýÃèÊö£ºÔ¶³ÌÎÄ¼þ²¥·Å¿ØÖÆ
 ²ÎÊýËµÃ÷£º
 NetHandle:ÍøÂç¾ä±ú£¬ÓÉthNet_Init·µ»Ø
 PlayCtrl:   PS_None               =0,                 //¿Õ
 PS_Play               =1,                 //²¥·Å
 PS_Pause              =2,                 //ÔÝÍ£
 PS_Stop               =3,                 //Í£Ö¹
 PS_FastBackward       =4,                 //¿ìÍË
 PS_FastForward        =5,                 //¿ì½ø
 PS_StepBackward       =6,                 //²½ÍË
 PS_StepForward        =7,                 //²½½ø
 PS_DragPos            =8,                 //ÍÏ¶¯
 Speed:Èç¹ûPlayCtrl=PS_StepBackward, PS_FastForward £¬Ôò±£´æ¿ì½ø¿ìÍË±¶ÂÊ 1 2 4 8 16 32±¶ÂÊ
 Pos:Èç¹ûPlayCtrl=PS_DragPos£¬Ôò±£´æÎÄ¼þÎÄ¼þÎ»ÖÃPos
 ·µ »Ø Öµ£º³É¹¦·µ»Øtrue£¬Ê§°Ü·µ»Øfalse
 ------------------------------------------------------------------------------*/
bool thNet_HttpGet(int64_t NetHandle, char* url, char* Buf, int* BufLen);

bool thNet_IsRecord(int64_t NetHandle);
bool thNet_RecordStop(int64_t NetHandle);
bool thNet_RecordStart(int64_t NetHandle,
                       int FileType, char* FileName,
                       int VideoType, int Width, int Height, int FrameRate, int BitRate,
                       int AudioType, int nChannels, int wBitsPerSample, int nSamplesPerSec);


#endif