//-----------------------------------------------------------------------------
// Author      : ��첨
// Date        : 2012.01.18
// Version     : V 1.00
// Description :   \r�����ס�
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
  struct TNetCfgPkt NetCfgPkt;                            //�豸�������ð�sizeof 372
  struct TWiFiCfgPkt WiFiCfgPkt;                          //�������ð� sizeof 200
  struct TDevInfoPkt DevInfoPkt;                          //�豸��Ϣ��sizeof 180
  struct TUserCfgPkt UserCfgPkt;                          //sizeof 1048
  struct TAlmCfgPkt AlmCfgPkt;                            //�������ð�sizeof 52//
  char Reserved[1024];
  struct TVideoCfgPkt VideoCfgPkt;                        //��Ƶ���ð� sizeof 148
  struct TAudioCfgPkt AudioCfgPkt;                        //��Ƶ���ð� sizeof 48
  struct TMDCfgPkt MDCfgPkt;                              //�ƶ����� sizeof 96
  struct THideAreaCfgPkt HideAreaCfgPkt;                  //����¼Ӱ����� sizeof 72
  struct TDiskCfgPkt DiskCfgPkt;                          //888 -> 60
  struct TwifiCfgLst wifiCfgLst;                          //804  add at 20140927
  char Reserved1[24];
  struct TRecCfgPkt RecCfgPkt;                            //¼Ӱ���ð� sizeof 260
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
