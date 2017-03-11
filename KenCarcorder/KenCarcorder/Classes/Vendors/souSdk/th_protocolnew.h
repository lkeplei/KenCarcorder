//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description :
//-----------------------------------------------------------------------------
#ifndef th_protocolnew_H
#define th_protocolnew_H 

#include "cm_types.h"

#pragma pack(4)//n=1,2,4,8,16

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
  int Reserved;
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
  byte GotoPTZPoint;// >0为预设位
  byte AlmOutTimeLen;//报警输出时长(秒) 0 ..255 s
  //struct TTaskhm hm;
  int Reserved1;
}TNewDIAlm;//sizeof 12

typedef struct TNewMDAlm {                       //移动侦测包 sizeof 96
  bool ActiveMD;
  byte Sensitive;                              //侦测灵敏度 0-255
  bool IsAlmRec;
  bool IsFTPUpload;
  bool ActiveDO;//DI关联DO通道 false close
  bool IsSendEmail;
  byte GotoPTZPoint;// >0为预设位
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
  byte GotoPTZPoint;// >0为预设位
  byte AlmOutTimeLen;                    //报警输出时长(秒) 0 ..255 s
  //struct TTaskhm hm;
  int Reserved;
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
  DWORD VerifyCode;//校验码 = 0xAAAAAAAA
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
    struct TDiDoCfgPkt DiDoCfgPkt;               //DIDO配置包
    struct TDoControlPkt DoControlPkt;           //DO控制包    
    struct THideAreaCfgPkt HideAreaCfgPkt;       //隐藏录影区域包--单通道
    struct TAlmCfgPkt AlmCfgPkt;                 //警报配置包
    struct TVideoCfgPkt VideoCfgPkt;             //视频配置包--单通道
    struct TAudioCfgPkt AudioCfgPkt;             //音频配置包--单通道    
    struct TRecFileHead FileHead;                //取得设备文件文件头信息
    struct TFilePkt FilePkt;                     //上传文件包
    struct TRS485CfgPkt RS485CfgPkt;             //485通信包--单通道
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

#endif


