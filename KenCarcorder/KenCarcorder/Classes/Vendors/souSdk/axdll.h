//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description :   \r到行首　
//-----------------------------------------------------------------------------
#ifndef axdll_H
#define axdll_H

#include "th_protocol.h"
#include "common.h"

#ifdef __cplusplus
extern "C" {
#endif
#pragma pack(4)//n=1,2,4,8,16

//-----------------------------------------------------------------------------
typedef struct Twifi_sta_item {//sizeof 100
  byte EncryptType;//(Encrypt_None,Encrypt_WEP,Encrypt_WPA);
  byte wepAuth;
  byte wpaAuth;
  byte wpaEnc;
  char32 SSID;
  char64 Password;
}Twifi_sta_item;
//-----------------------------------------------------------------------------
#define MAX_WIFICFG_LST_COUNT  8
typedef struct TwifiCfgLst {//sizeof 804
    int Count;
    struct Twifi_sta_item Lst[MAX_WIFICFG_LST_COUNT];
}TwifiCfgLst;
//-----------------------------------------------------------------------------
typedef struct TDevCfg {//sizeof x1 5216
  struct TNetCfgPkt NetCfgPkt;                            //设备网络配置包sizeof 372
  struct TWiFiCfgPkt WiFiCfgPkt;                          //无线配置包 sizeof 200
  struct TDevInfoPkt DevInfoPkt;                          //设备信息包sizeof 180
  struct TUserCfgPkt UserCfgPkt;                          //sizeof 1048
  struct TAlmCfgPkt AlmCfgPkt;                            //警报配置包sizeof 52//
  char Reserved[1024];
  struct TVideoCfgPkt VideoCfgPkt;                        //视频设置包 sizeof 148
  struct TAudioCfgPkt AudioCfgPkt;                        //音频设置包 sizeof 48
  struct TMDCfgPkt MDCfgPkt;                              //移动侦测包 sizeof 96
  struct THideAreaCfgPkt HideAreaCfgPkt;                  //隐藏录影区域包 sizeof 72
  struct TDiskCfgPkt DiskCfgPkt;                          //888 -> 60
  struct TwifiCfgLst wifiCfgLst;                          //804  add at 20140927
  char Reserved1[24];
  struct TRecCfgPkt RecCfgPkt;                            //录影配置包 sizeof 260
  struct TFTPCfgPkt FTPCfgPkt;                            //sizeof 232
  struct Tp2pCfgPkt p2pCfgPkt;                            //sizeof 88
  struct TSMTPCfgPkt SMTPCfgPkt;                          //sizeof 500
  int Flag;
  int Flag1;
}TDevCfg;

#ifdef __cplusplus
}
#endif

#endif
