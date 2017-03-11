//-----------------------------------------------------------------------------
// Author      : ��첨
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
  char DevModal[8];                             //�豸�ͺ�  ='7xxx'
  DWORD SN;
  char16 SoftVersion;                            //����汾
  char20 DevName;                                //�豸��ʶ
  uint64 StandardMask;//16
  uint64 SubStandardMask;//32
  byte DevType;                                   //�豸����
  bool ExistWiFi;
  bool ExistSD;
  bool ethLinkStatus;      //���������Ƿ�����
  bool wifiStatus;
  bool upnpStatus;
  bool WlanStatus;
  bool p2pStatus;
  byte HardType;      //Ӳ������
  byte TimeZone;
  bool DoubleStream;                              //�Ƿ�˫���� add at 2009/09/02
  bool ExistFlash;
  int Reserved;
}TNewDevInfo;//sizeof 80

typedef struct TNewNetCfg{
  word DataPort;                                   //�������ݶ˿�
  word rtspPort;                                  //rtsp�˿�
  word HttpPort;                                  //http��ҳ�˿�
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
  char40 DDNSDomain;                           //��DDNS SERVER IP
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
  byte Channel;//Ƶ��1..14 default 1=Auto
  byte EncryptType;//(Encrypt_None,Encrypt_WEP,Encrypt_WPA);
  byte Auth;//WEP(0=AUTO 1=OPEN 2=SHARED)  WPA(0=AUTO 1=WPA-PSK 2=WPA2-PSK)
  byte Enc;//WPA(0=AUTO 1=TKIP 2=AES)
  int Reserved;
}TNewwifiCfg;//sizeof 92

typedef struct TNewp2pCfg{
  bool ActiveP2P;
  byte StreamType;//0 ������ 1 ������
  byte p2pType;   //tutk=0 self=1
  char UID[21];
  char20 Password;
  int SvrIP[4];
  int Reserved;
}TNewp2pCfg;//sizeof 64

typedef struct TNewVideoCfg {
  Byte StandardEx0;//TStandardEx
  Byte FrameRate0;                                //֡�� 1-30 MAX:PAL 25 NTSC 30
  word BitRate0;
  byte StandardEx1;//TStandardEx
  byte FrameRate1;//֡�� 1-30 MAX:PAL 25 NTSC 30
  word BitRate1;//���� 64K 128K 256K 512K 1024K 1536K 2048K 2560K 3072K
  bool IsMirror;                           //ˮƽ��ת false or true
  bool IsFlip;                             //��ֱ��ת false or true
  bool IsShowFrameRate;
  byte Flag_00008;
  int Reserved;
}TNewVideoCfg;//sizeof 16

typedef struct TNewAudioCfg{
  bool  ActiveAUDIO;                                   //�Ƿ���������
  byte InputTypeAUDIO;                                 //0 MIC����, 1 LINE����
  byte VolumeLineIn;
  byte VolumeLineOut;
  byte nChannels;                               //������=0 ������=1
  byte wBitsPerSample;                          //number of bits per sample of mono data 
  word nSamplesPerSec;                          //������
  int Reserved;
}TNewAudioCfg;//sizeof 12

typedef struct TNewUserCfg {
  char20 UserName[3];                               //�û��� admin���ܸ���
  char20 Password[3];                               //����
  byte Authority[3];                                 //3Ϊadmin
  byte Reserved;
  int Reserved1;
}TNewUserCfg;//sizeof 128

typedef struct TNewDIAlm {
  bool ActiveDI;
  byte Reserved;
  bool IsAlmRec;
  bool IsFTPUpload;
  bool ActiveDO;//DI����DOͨ�� false close
  bool IsSendEmail;
  byte GotoPTZPoint;// >0ΪԤ��λ
  byte AlmOutTimeLen;//�������ʱ��(��) 0 ..255 s
  //struct TTaskhm hm;
  int Reserved1;
}TNewDIAlm;//sizeof 12

typedef struct TNewMDAlm {                       //�ƶ����� sizeof 96
  bool ActiveMD;
  byte Sensitive;                              //��������� 0-255
  bool IsAlmRec;
  bool IsFTPUpload;
  bool ActiveDO;//DI����DOͨ�� false close
  bool IsSendEmail;
  byte GotoPTZPoint;// >0ΪԤ��λ
  byte AlmOutTimeLen;                    //�������ʱ��(��) 0 ..255 s
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
  bool ActiveDO;//DI����DOͨ�� false close
  bool IsSendEmail;
  byte GotoPTZPoint;// >0ΪԤ��λ
  byte AlmOutTimeLen;                    //�������ʱ��(��) 0 ..255 s
  //struct TTaskhm hm;
  int Reserved;
}TNewSoundAlm;//sizeof 12

typedef struct TNewRecCfg{                      //¼Ӱ���ð� sizeof 260
  byte RecStreamType;//0 ������ 1 ������
  bool IsRecAudio;//¼����Ƶ ��û���õ�
  byte RecStyle;//¼Ӱ����
  byte Reserved;
  TPlanRecPkt Plan;
  word Rec_AlmTimeLen;//����¼Ӱʱ��        10 s
  word Rec_NmlTimeLen;//һ��¼Ӱ�ָ�ʱ��   600 s
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
  DWORD VerifyCode;//У���� = 0xAAAAAAAA
  byte MsgID;//TMsgID
  byte Result;
  word PktSize;
  union {
    int Value;
    char Buf[1000];
    struct TNewDevCfg NewDevCfg;

    struct TLoginPkt LoginPkt;                   //��¼�� 892
    struct TPlayLivePkt LivePkt;                 //�����ֳ���
    struct TRecFilePkt RecFilePkt;               //�ط�¼Ӱ��
    struct TPTZPkt PTZPkt;                       //��̨����̨
    struct TPlayCtrlPkt PlayCtrlPkt;             //�ط�¼Ӱ���ư�

    struct TAlmSendPkt AlmSendPkt;               //�����ϴ���
    struct TDevInfoPkt DevInfoPkt;               //�豸��Ϣ��
    struct TNetCfgPkt NetCfgPkt;                 //�豸�������ð�
    struct TWiFiCfgPkt WiFiCfgPkt;               //�����������ð�
    struct TDiskCfgPkt DiskCfgPkt;               //�������ð� 888
    struct TRecCfgPkt RecCfgPkt;                 //¼Ӱ���ð�
    struct TMDCfgPkt MDCfgPkt;                   //�ƶ�����--��ͨ��
    struct TDiDoCfgPkt DiDoCfgPkt;               //DIDO���ð�
    struct TDoControlPkt DoControlPkt;           //DO���ư�    
    struct THideAreaCfgPkt HideAreaCfgPkt;       //����¼Ӱ�����--��ͨ��
    struct TAlmCfgPkt AlmCfgPkt;                 //�������ð�
    struct TVideoCfgPkt VideoCfgPkt;             //��Ƶ���ð�--��ͨ��
    struct TAudioCfgPkt AudioCfgPkt;             //��Ƶ���ð�--��ͨ��    
    struct TRecFileHead FileHead;                //ȡ���豸�ļ��ļ�ͷ��Ϣ
    struct TFilePkt FilePkt;                     //�ϴ��ļ���
    struct TRS485CfgPkt RS485CfgPkt;             //485ͨ�Ű�--��ͨ��
    struct TColorsPkt Colors;                    //����ȡ�����ȡ��Աȶȡ�ɫ�ȡ����Ͷ�
    struct TFTPCfgPkt FTPCfgPkt;
    struct TSMTPCfgPkt SMTPCfgPkt;
    struct Tp2pCfgPkt p2pCfgPkt;
    //struct TRecFileLst RecFileLst;
    //struct TUserCfgPkt UserCfgPkt;               //�û����ð�
    //struct TMulticastInfoPkt MulticastInfo;      //�ಥ��Ϣ
    //struct TBatchCfgPkt BatchCfgPkt;             //�����޸�����
    //struct TWiFiSearchPkt WiFiSearchPkt[30];

  };  
}TNewCmdPkt;

#endif


