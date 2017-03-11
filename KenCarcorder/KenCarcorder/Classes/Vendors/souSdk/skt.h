//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description : 
//-----------------------------------------------------------------------------
#ifndef TSSkt_H
#define TSSkt_H

#include "axdll.h"
#include "list.h"
#include "common.h"
#include "th_protocol.h"
#include "thSDKlib.h"

typedef struct TSktConnPkt{
  char RecvBuf[1024*16];//要放在第一
  int RecvLen;
  bool IsRecvVerifyCode;
  bool IsRecvPktSize;
  int SktHandle;
  struct sockaddr_in CltAddr;
  time_t LoginTime;
  int Session;//标注为登录与否
  struct TPlayLivePkt LivePkt; 
  int GroupType;//分组
  int SendSensePkt;
  struct TFilePkt FilePkt;//上传文件结构
  int UserGroup;//用户权限组
  int tDelay;

  struct TRecFilePkt RecFilePkt;
  struct TPlayCtrlPkt PlayCtrlPkt;
}TSktConnPkt;
//*****************************************************************************
TSktConnPkt* IndexOfSktHandle(TList* lst, int SocketHandle);

typedef void(*TOnConnectEvent)(TSktConnPkt* SktConnPkt); //连接事件
typedef void(*TOnRecvEvent)(TSktConnPkt* SktConnPkt); //收取事件
typedef void(*TOnDisConnEvent)(TSktConnPkt* SktConnPkt); //断开事件

typedef struct TSSktParam
{
  TOnConnectEvent OnConnectEvent;
  TOnDisConnEvent OnDisConnEvent;
  TOnRecvEvent OnRecvEvent;
  int LocalPort;

  TList* SktConnLst;
  int SocketHandle;
  fd_set fdset;
  pthread_t tHandle;

}TSSktParam;

bool sskt_Init(TSSktParam* Param);
bool sskt_Free(TSSktParam* Param);
//-----------------------------------------------------------------------------
typedef void(*TOnUDPRecvEvent)(char* Buf, int BufLen);//must
typedef struct TudpParam
{
  TOnUDPRecvEvent OnRecvEvent;
  int Port;
//multicast param
  bool IsMulticast;
  int TTL;
  char* LocalIP;
  char* MultiIP;
//multicast param
  struct sockaddr_in FromAddr;
  pthread_t tHandle; //SSkt线程句柄
  int SocketHandle;
  TSearchDevCallBack* Flag;
}TudpParam;

bool udp_Init(TudpParam* Param);
bool udp_Free(TudpParam* Param);

#endif
