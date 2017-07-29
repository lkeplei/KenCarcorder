//-----------------------------------------------------------------------------
// Author      : …Ó€⁄ –ƒœ∑ΩŒﬁœﬁ÷«ƒ‹ø∆ºº”–œﬁπ´Àæ
// Date        : 2013.04.20
// Version     : V 2.02
// Description : www.southipcam.com
//-----------------------------------------------------------------------------

#include "thSDKlib.h"

#include "common.h"
#include "skt.h"

#define IsP2PNewSDK


//-----------------------------------------------------------------------------
unsigned char encode(short pcm) {
#define MAX_32635 32635
    int exponent = 7;
    int expMask;
    int mantissa;
    unsigned char alaw;
    int sign = (pcm & 0x8000) >> 8;
    if (sign != 0) pcm = -pcm;
    if (pcm > MAX_32635) pcm = MAX_32635;
    for (expMask = 0x4000; (pcm & expMask) == 0 && exponent>0; exponent--, expMask >>= 1) {}
    mantissa = (pcm >> ((exponent == 0) ? 4 : (exponent + 3))) & 0x0f;
    alaw = (unsigned char)(sign | exponent << 4 | mantissa);
    return (unsigned char)(alaw^0xD5);
}

void g711a_encode(const char *src, int srclen, char *dst, int *dstlen) {
    int i;
    short* tmpBuf = (short*)src;
    for(i=0; i<srclen/2; i++) dst[i] = encode(tmpBuf[i]);
    *dstlen = srclen/2;
}
//-----------------------------------------------------------------------------
short decode(unsigned char alaw) {
    int sign, exponent, data;
    alaw ^= 0xD5;
    sign = alaw & 0x80;
    exponent = (alaw & 0x70) >> 4;
    data = alaw & 0x0f;
    data <<= 4;
    data += 8;
    if (exponent != 0) data += 0x100;
    if (exponent > 1) data <<= (exponent - 1);
    return (short)(sign == 0 ? data : -data);
}

void g711a_decode(const char *src, int srclen, char *dst, int *dstlen) {
    int i;
    short* tmpBuf = (short*)dst;
    for(i=0; i<srclen; i++) tmpBuf[i] = decode(src[i]);
    *dstlen = srclen*2;
}
//------------------------------------------------------------------------------
bool thNet_RecordWriteData(int64_t NetHandle, TDataFrameInfo* PInfo, char* Buf, int BufLen);
//-----------------------------------------------------------------------------
bool DevCfg_to_NewDevCfg(TDevCfg* DevCfg, TNewDevCfg* NewDevCfg) {
    int i;
    memset(NewDevCfg, 0, sizeof(TNewDevCfg));
    //DevInfo
    sprintf(NewDevCfg->DevInfo.DevModal, "%s", DevCfg->DevInfoPkt.DevModal);    //sprintf(NewDevCfg->DevInfo.DevModal, DevCfg->DevInfoPkt.DevModal);
    NewDevCfg->DevInfo.SN = DevCfg->DevInfoPkt.SN;
    sprintf(NewDevCfg->DevInfo.SoftVersion,"%s", DevCfg->DevInfoPkt.SoftVersion);  //sprintf(NewDevCfg->DevInfo.SoftVersion, DevCfg->DevInfoPkt.SoftVersion);
    sprintf(NewDevCfg->DevInfo.DevName, "%s", DevCfg->DevInfoPkt.DevName);  //sprintf(NewDevCfg->DevInfo.DevName, DevCfg->DevInfoPkt.DevName);
    NewDevCfg->DevInfo.StandardMask = DevCfg->DevInfoPkt.Info.StandardMask;
    NewDevCfg->DevInfo.SubStandardMask = DevCfg->DevInfoPkt.Info.SubStandardMask;
    NewDevCfg->DevInfo.DevType = DevCfg->DevInfoPkt.DevType;
    NewDevCfg->DevInfo.ExistWiFi = DevCfg->DevInfoPkt.Info.ExistWiFi;
    NewDevCfg->DevInfo.ExistSD = DevCfg->DevInfoPkt.Info.ExistSD;
    NewDevCfg->DevInfo.ExistFlash = DevCfg->DevInfoPkt.Info.ExistFlash;
    NewDevCfg->DevInfo.ethLinkStatus = DevCfg->DevInfoPkt.Info.ethLinkStatus;
    NewDevCfg->DevInfo.wifiStatus = DevCfg->DevInfoPkt.Info.wifiStatus;
    NewDevCfg->DevInfo.upnpStatus = DevCfg->DevInfoPkt.Info.upnpStatus;
    NewDevCfg->DevInfo.WlanStatus = DevCfg->DevInfoPkt.Info.WlanStatus;
    NewDevCfg->DevInfo.p2pStatus = DevCfg->DevInfoPkt.Info.p2pStatus;
    NewDevCfg->DevInfo.HardType = DevCfg->DevInfoPkt.Info.HardType;
    NewDevCfg->DevInfo.TimeZone = DevCfg->DevInfoPkt.TimeZone;
    NewDevCfg->DevInfo.DoubleStream = DevCfg->DevInfoPkt.DoubleStream;
    //NetCfg
    NewDevCfg->NetCfg.DataPort = DevCfg->NetCfgPkt.DataPort;
    NewDevCfg->NetCfg.rtspPort = DevCfg->NetCfgPkt.rtspPort;
    NewDevCfg->NetCfg.HttpPort = DevCfg->NetCfgPkt.HttpPort;
    NewDevCfg->NetCfg.IPType = DevCfg->NetCfgPkt.Lan.IPType;
    NewDevCfg->NetCfg.DevIP = IPToInt(DevCfg->NetCfgPkt.Lan.DevIP);
    NewDevCfg->NetCfg.SubMask = IPToInt(DevCfg->NetCfgPkt.Lan.SubMask);
    NewDevCfg->NetCfg.Gateway = IPToInt(DevCfg->NetCfgPkt.Lan.Gateway);
    NewDevCfg->NetCfg.DNS1 = IPToInt(DevCfg->NetCfgPkt.Lan.DNS1);
    sprintf(NewDevCfg->NetCfg.DevMAC, "%s", DevCfg->NetCfgPkt.Lan.DevMAC);
    NewDevCfg->NetCfg.ActiveuPnP = DevCfg->NetCfgPkt.uPnP.Active;
    NewDevCfg->NetCfg.ActiveDDNS = DevCfg->NetCfgPkt.DDNS.Active;
    NewDevCfg->NetCfg.DDNSType = DevCfg->NetCfgPkt.DDNS.DDNSType;
    sprintf(NewDevCfg->NetCfg.DDNSDomain, "%s", DevCfg->NetCfgPkt.DDNS.DDNSDomain);
    sprintf(NewDevCfg->NetCfg.DDNSServer, "%s", DevCfg->NetCfgPkt.DDNS.DDNSServer);
    //wifiCfg
    NewDevCfg->wifiCfg.ActiveWIFI = DevCfg->WiFiCfgPkt.Active;
    NewDevCfg->wifiCfg.IsAPMode = DevCfg->WiFiCfgPkt.IsAPMode;
    sprintf(NewDevCfg->wifiCfg.SSID_AP, "%s", DevCfg->WiFiCfgPkt.SSID_AP);
    sprintf(NewDevCfg->wifiCfg.Password_AP, "%s", DevCfg->WiFiCfgPkt.Password_AP);
    sprintf(NewDevCfg->wifiCfg.SSID_STA, "%s", DevCfg->WiFiCfgPkt.SSID_STA);
    sprintf(NewDevCfg->wifiCfg.Password_STA, "%s", DevCfg->WiFiCfgPkt.Password_STA);
    NewDevCfg->wifiCfg.Channel = DevCfg->WiFiCfgPkt.Channel;
    NewDevCfg->wifiCfg.EncryptType = DevCfg->WiFiCfgPkt.EncryptType;
    NewDevCfg->wifiCfg.Auth = DevCfg->WiFiCfgPkt.WPA.Auth;
    NewDevCfg->wifiCfg.Enc = DevCfg->WiFiCfgPkt.WPA.Enc;
    //p2pCfg
    NewDevCfg->p2pCfg.ActiveP2P = DevCfg->p2pCfgPkt.Active;
    NewDevCfg->p2pCfg.StreamType = DevCfg->p2pCfgPkt.StreamType;
    NewDevCfg->p2pCfg.p2pType = DevCfg->p2pCfgPkt.p2pType;
    sprintf(NewDevCfg->p2pCfg.UID, "%s", DevCfg->p2pCfgPkt.UID);
    sprintf(NewDevCfg->p2pCfg.Password, "%s", DevCfg->p2pCfgPkt.Password);
    memcpy(NewDevCfg->p2pCfg.SvrIP, DevCfg->p2pCfgPkt.SvrIP, 4*4);
    //VideoCfg
    NewDevCfg->VideoCfg.StandardEx0 = GetStandardFromWidthHeight(DevCfg->VideoCfgPkt.VideoFormat.Width, DevCfg->VideoCfgPkt.VideoFormat.Height);
    NewDevCfg->VideoCfg.FrameRate0 = DevCfg->VideoCfgPkt.VideoFormat.FrameRate;
    NewDevCfg->VideoCfg.BitRate0 = DevCfg->VideoCfgPkt.VideoFormat.BitRate / 1024;
    NewDevCfg->VideoCfg.StandardEx1 = DevCfg->VideoCfgPkt.VideoFormat.Sub.StandardEx;
    NewDevCfg->VideoCfg.FrameRate1 = DevCfg->VideoCfgPkt.VideoFormat.Sub.FrameRate;
    NewDevCfg->VideoCfg.BitRate1 = DevCfg->VideoCfgPkt.VideoFormat.Sub.BitRate / 1024;
    NewDevCfg->VideoCfg.IsMirror = DevCfg->VideoCfgPkt.VideoFormat.IsMirror;
    NewDevCfg->VideoCfg.IsFlip = DevCfg->VideoCfgPkt.VideoFormat.IsFlip;
    NewDevCfg->VideoCfg.IsShowFrameRate = DevCfg->VideoCfgPkt.VideoFormat.IsShowFrameRate;
    //AudioCfg
    NewDevCfg->AudioCfg.ActiveAUDIO = DevCfg->AudioCfgPkt.Active;
    NewDevCfg->AudioCfg.InputTypeAUDIO = DevCfg->AudioCfgPkt.InputType;
    NewDevCfg->AudioCfg.VolumeLineIn = DevCfg->AudioCfgPkt.VolumeLineIn;
    NewDevCfg->AudioCfg.VolumeLineOut = DevCfg->AudioCfgPkt.VolumeLineOut;
    NewDevCfg->AudioCfg.nChannels = DevCfg->AudioCfgPkt.AudioFormat.nChannels;
    NewDevCfg->AudioCfg.wBitsPerSample = DevCfg->AudioCfgPkt.AudioFormat.wBitsPerSample;
    NewDevCfg->AudioCfg.nSamplesPerSec = DevCfg->AudioCfgPkt.AudioFormat.nSamplesPerSec;
    NewDevCfg->AudioCfg.wFormatTag = DevCfg->AudioCfgPkt.AudioFormat.wFormatTag;

    for (i=0; i<3; i++)//DevCfg->UserCfgPkt.Count
    {
        sprintf(NewDevCfg->UserCfg.UserName[i], "%s", DevCfg->UserCfgPkt.Lst[i].UserName);
        sprintf(NewDevCfg->UserCfg.Password[i], "%s", DevCfg->UserCfgPkt.Lst[i].Password);
        NewDevCfg->UserCfg.Authority[i] = DevCfg->UserCfgPkt.Lst[i].Authority;
    }
    //TDIAlm
    NewDevCfg->DIAlm.ActiveDI = DevCfg->AlmCfgPkt.DIAlm.Active;
    NewDevCfg->DIAlm.IsAlmRec = DevCfg->AlmCfgPkt.DIAlm.IsAlmRec;
    NewDevCfg->DIAlm.IsFTPUpload = DevCfg->AlmCfgPkt.DIAlm.IsFTPUpload;
    NewDevCfg->DIAlm.ActiveDO = DevCfg->AlmCfgPkt.DIAlm.ActiveDO;
    NewDevCfg->DIAlm.IsSendEmail = DevCfg->AlmCfgPkt.DIAlm.IsSendEmail;
    NewDevCfg->DIAlm.AlmOutTimeLen = DevCfg->AlmCfgPkt.AlmOutTimeLen;
    //NewDevCfg->DIAlm.hm = DevCfg->;
    //TMDAlm
    NewDevCfg->MDAlm.ActiveMD = DevCfg->MDCfgPkt.Active;
    NewDevCfg->MDAlm.Sensitive = DevCfg->MDCfgPkt.Sensitive;
    NewDevCfg->MDAlm.IsAlmRec = DevCfg->AlmCfgPkt.MDAlm.IsAlmRec;
    NewDevCfg->MDAlm.IsFTPUpload = DevCfg->AlmCfgPkt.MDAlm.IsFTPUpload;
    NewDevCfg->MDAlm.ActiveDO = DevCfg->AlmCfgPkt.MDAlm.ActiveDO;
    NewDevCfg->MDAlm.IsSendEmail = DevCfg->AlmCfgPkt.MDAlm.IsSendEmail;
    NewDevCfg->MDAlm.AlmOutTimeLen = DevCfg->AlmCfgPkt.AlmOutTimeLen;
    //NewDevCfg->MDAlm.hm = DevCfg->MDCfgPkt.hm;
    memcpy(&NewDevCfg->MDAlm.Rect, &DevCfg->MDCfgPkt.NewRect, sizeof(NewDevCfg->MDAlm.Rect));
    //SoundAlm
    NewDevCfg->SoundAlm.ActiveSoundTrigger = DevCfg->AudioCfgPkt.SoundTriggerActive;
    NewDevCfg->SoundAlm.Sensitive = DevCfg->AudioCfgPkt.SoundTriggerSensitive;
    NewDevCfg->SoundAlm.IsAlmRec = DevCfg->AlmCfgPkt.SoundAlm.IsAlmRec;
    NewDevCfg->SoundAlm.IsFTPUpload = DevCfg->AlmCfgPkt.SoundAlm.IsFTPUpload;
    NewDevCfg->SoundAlm.ActiveDO = DevCfg->AlmCfgPkt.SoundAlm.ActiveDO;
    NewDevCfg->SoundAlm.IsSendEmail = DevCfg->AlmCfgPkt.SoundAlm.IsSendEmail;
    NewDevCfg->SoundAlm.AlmOutTimeLen = DevCfg->AlmCfgPkt.AlmOutTimeLen;
    //RecCfg
    NewDevCfg->RecCfg.RecStreamType = DevCfg->RecCfgPkt.RecStreamType;
    NewDevCfg->RecCfg.IsRecAudio = DevCfg->RecCfgPkt.IsRecAudio;
    NewDevCfg->RecCfg.RecStyle = DevCfg->RecCfgPkt.RecStyle;
    NewDevCfg->RecCfg.Plan = DevCfg->RecCfgPkt.Plan;
    NewDevCfg->RecCfg.Rec_AlmTimeLen = DevCfg->RecCfgPkt.Rec_AlmTimeLen;
    NewDevCfg->RecCfg.Rec_NmlTimeLen = DevCfg->RecCfgPkt.Rec_NmlTimeLen;

    return true;
}

bool NewDevCfg_to_DevCfg(TNewDevCfg* NewDevCfg, TDevCfg* DevCfg) {
    int i;
    //≤ªƒ‹“™ memset(DevCfg, 0, sizeof(DevCfg));
    //DevInfo
    sprintf(DevCfg->DevInfoPkt.DevModal, "%s", NewDevCfg->DevInfo.DevModal);
    DevCfg->DevInfoPkt.SN = NewDevCfg->DevInfo.SN;
    sprintf(DevCfg->DevInfoPkt.SoftVersion, "%s", NewDevCfg->DevInfo.SoftVersion);
    sprintf(DevCfg->DevInfoPkt.DevName, "%s", NewDevCfg->DevInfo.DevName);

    DevCfg->DevInfoPkt.Info.StandardMask = NewDevCfg->DevInfo.StandardMask;
    DevCfg->DevInfoPkt.Info.SubStandardMask = NewDevCfg->DevInfo.SubStandardMask;
    DevCfg->DevInfoPkt.DevType = NewDevCfg->DevInfo.DevType;
    DevCfg->DevInfoPkt.Info.ExistWiFi = NewDevCfg->DevInfo.ExistWiFi;
    DevCfg->DevInfoPkt.Info.ExistSD = NewDevCfg->DevInfo.ExistSD;
    DevCfg->DevInfoPkt.Info.ExistFlash = NewDevCfg->DevInfo.ExistFlash;
    DevCfg->DevInfoPkt.Info.ethLinkStatus = NewDevCfg->DevInfo.ethLinkStatus;
    DevCfg->DevInfoPkt.Info.wifiStatus = NewDevCfg->DevInfo.wifiStatus;
    DevCfg->DevInfoPkt.Info.upnpStatus = NewDevCfg->DevInfo.upnpStatus;
    DevCfg->DevInfoPkt.Info.WlanStatus = NewDevCfg->DevInfo.WlanStatus;
    DevCfg->DevInfoPkt.Info.p2pStatus = NewDevCfg->DevInfo.p2pStatus;
    DevCfg->DevInfoPkt.Info.HardType = NewDevCfg->DevInfo.HardType;
    DevCfg->DevInfoPkt.TimeZone = NewDevCfg->DevInfo.TimeZone;
    DevCfg->DevInfoPkt.DoubleStream = NewDevCfg->DevInfo.DoubleStream;
    //NetCfg
    DevCfg->NetCfgPkt.DataPort = NewDevCfg->NetCfg.DataPort;
    DevCfg->NetCfgPkt.rtspPort = NewDevCfg->NetCfg.rtspPort;
    DevCfg->NetCfgPkt.HttpPort = NewDevCfg->NetCfg.HttpPort;
    DevCfg->NetCfgPkt.Lan.IPType = NewDevCfg->NetCfg.IPType;
    sprintf(DevCfg->NetCfgPkt.Lan.DevIP, "%s", IntToIP(NewDevCfg->NetCfg.DevIP));
    sprintf(DevCfg->NetCfgPkt.Lan.SubMask, "%s", IntToIP(NewDevCfg->NetCfg.SubMask));
    sprintf(DevCfg->NetCfgPkt.Lan.Gateway, "%s", IntToIP(NewDevCfg->NetCfg.Gateway));
    sprintf(DevCfg->NetCfgPkt.Lan.DNS1, "%s", IntToIP(NewDevCfg->NetCfg.DNS1));
    sprintf(DevCfg->NetCfgPkt.Lan.DevMAC, "%s", NewDevCfg->NetCfg.DevMAC);
    DevCfg->NetCfgPkt.uPnP.Active = NewDevCfg->NetCfg.ActiveuPnP;
    DevCfg->NetCfgPkt.DDNS.Active = NewDevCfg->NetCfg.ActiveDDNS;
    DevCfg->NetCfgPkt.DDNS.DDNSType = NewDevCfg->NetCfg.DDNSType;
    sprintf(DevCfg->NetCfgPkt.DDNS.DDNSDomain, "%s", NewDevCfg->NetCfg.DDNSDomain);
    sprintf(DevCfg->NetCfgPkt.DDNS.DDNSServer, "%s", NewDevCfg->NetCfg.DDNSServer);
    //wifiCfg
    DevCfg->WiFiCfgPkt.Active = NewDevCfg->wifiCfg.ActiveWIFI;
    DevCfg->WiFiCfgPkt.IsAPMode = NewDevCfg->wifiCfg.IsAPMode;
    sprintf(DevCfg->WiFiCfgPkt.SSID_AP, "%s", NewDevCfg->wifiCfg.SSID_AP);
    sprintf(DevCfg->WiFiCfgPkt.Password_AP, "%s", NewDevCfg->wifiCfg.Password_AP);
    sprintf(DevCfg->WiFiCfgPkt.SSID_STA, "%s", NewDevCfg->wifiCfg.SSID_STA);
    sprintf(DevCfg->WiFiCfgPkt.Password_STA, "%s", NewDevCfg->wifiCfg.Password_STA);
    DevCfg->WiFiCfgPkt.Channel = NewDevCfg->wifiCfg.Channel;
    DevCfg->WiFiCfgPkt.EncryptType = NewDevCfg->wifiCfg.EncryptType;
    DevCfg->WiFiCfgPkt.WPA.Auth = NewDevCfg->wifiCfg.Auth;
    DevCfg->WiFiCfgPkt.WPA.Enc = NewDevCfg->wifiCfg.Enc;
    //p2pCfg
    DevCfg->p2pCfgPkt.Active = NewDevCfg->p2pCfg.ActiveP2P;
    DevCfg->p2pCfgPkt.StreamType = NewDevCfg->p2pCfg.StreamType;
    DevCfg->p2pCfgPkt.p2pType = NewDevCfg->p2pCfg.p2pType;
    sprintf(DevCfg->p2pCfgPkt.UID, "%s", NewDevCfg->p2pCfg.UID);
    sprintf(DevCfg->p2pCfgPkt.Password, "%s", NewDevCfg->p2pCfg.Password);
    memcpy(DevCfg->p2pCfgPkt.SvrIP, NewDevCfg->p2pCfg.SvrIP, 4*4);
    //VideoCfg
    GetWidthHeightFromStandard(NewDevCfg->VideoCfg.StandardEx0, &DevCfg->VideoCfgPkt.VideoFormat.Width, &DevCfg->VideoCfgPkt.VideoFormat.Height);
    DevCfg->VideoCfgPkt.VideoFormat.FrameRate = NewDevCfg->VideoCfg.FrameRate0;
    DevCfg->VideoCfgPkt.VideoFormat.BitRate = NewDevCfg->VideoCfg.BitRate0 * 1024;
    DevCfg->VideoCfgPkt.VideoFormat.Sub.StandardEx = NewDevCfg->VideoCfg.StandardEx1;
    DevCfg->VideoCfgPkt.VideoFormat.Sub.FrameRate = NewDevCfg->VideoCfg.FrameRate1;
    DevCfg->VideoCfgPkt.VideoFormat.Sub.BitRate = NewDevCfg->VideoCfg.BitRate1 * 1024;
    DevCfg->VideoCfgPkt.VideoFormat.IsMirror = NewDevCfg->VideoCfg.IsMirror;
    DevCfg->VideoCfgPkt.VideoFormat.IsFlip = NewDevCfg->VideoCfg.IsFlip;
    DevCfg->VideoCfgPkt.VideoFormat.IsShowFrameRate = NewDevCfg->VideoCfg.IsShowFrameRate;
    //AudioCfg
    DevCfg->AudioCfgPkt.Active = NewDevCfg->AudioCfg.ActiveAUDIO;
    DevCfg->AudioCfgPkt.InputType = NewDevCfg->AudioCfg.InputTypeAUDIO;
    DevCfg->AudioCfgPkt.VolumeLineIn = NewDevCfg->AudioCfg.VolumeLineIn;
    DevCfg->AudioCfgPkt.VolumeLineOut = NewDevCfg->AudioCfg.VolumeLineOut;
    DevCfg->AudioCfgPkt.AudioFormat.nChannels = NewDevCfg->AudioCfg.nChannels;
    DevCfg->AudioCfgPkt.AudioFormat.wBitsPerSample = NewDevCfg->AudioCfg.wBitsPerSample;
    DevCfg->AudioCfgPkt.AudioFormat.nSamplesPerSec = NewDevCfg->AudioCfg.nSamplesPerSec;
    DevCfg->AudioCfgPkt.AudioFormat.wFormatTag = NewDevCfg->AudioCfg.wFormatTag;

    for (i=0; i<3; i++)//DevCfg->UserCfgPkt.Count
    {
        sprintf(DevCfg->UserCfgPkt.Lst[i].UserName, "%s", NewDevCfg->UserCfg.UserName[i]);
        sprintf(DevCfg->UserCfgPkt.Lst[i].Password, "%s", NewDevCfg->UserCfg.Password[i]);
        DevCfg->UserCfgPkt.Lst[i].Authority = NewDevCfg->UserCfg.Authority[i];
    }
    //TDIAlm
    DevCfg->AlmCfgPkt.DIAlm.Active = NewDevCfg->DIAlm.ActiveDI;
    DevCfg->AlmCfgPkt.DIAlm.IsAlmRec = NewDevCfg->DIAlm.IsAlmRec;
    DevCfg->AlmCfgPkt.DIAlm.IsFTPUpload = NewDevCfg->DIAlm.IsFTPUpload;
    DevCfg->AlmCfgPkt.DIAlm.ActiveDO = NewDevCfg->DIAlm.ActiveDO;
    DevCfg->AlmCfgPkt.DIAlm.IsSendEmail = NewDevCfg->DIAlm.IsSendEmail;
    DevCfg->AlmCfgPkt.AlmOutTimeLen = NewDevCfg->DIAlm.AlmOutTimeLen;
    //NewDevCfg->DIAlm.hm = DevCfg->;
    //TMDAlm
    DevCfg->MDCfgPkt.Active = NewDevCfg->MDAlm.ActiveMD;
    DevCfg->MDCfgPkt.Sensitive = NewDevCfg->MDAlm.Sensitive;
    DevCfg->AlmCfgPkt.MDAlm.IsAlmRec = NewDevCfg->MDAlm.IsAlmRec;
    DevCfg->AlmCfgPkt.MDAlm.IsFTPUpload = NewDevCfg->MDAlm.IsFTPUpload;
    DevCfg->AlmCfgPkt.MDAlm.ActiveDO = NewDevCfg->MDAlm.ActiveDO;
    DevCfg->AlmCfgPkt.MDAlm.IsSendEmail = NewDevCfg->MDAlm.IsSendEmail;
    DevCfg->AlmCfgPkt.AlmOutTimeLen = NewDevCfg->MDAlm.AlmOutTimeLen;
    //NewDevCfg->MDAlm.hm = DevCfg->MDCfgPkt.hm;
    memcpy(&DevCfg->MDCfgPkt.NewRect, &NewDevCfg->MDAlm.Rect, sizeof(NewDevCfg->MDAlm.Rect));
    //SoundAlm
    DevCfg->AudioCfgPkt.SoundTriggerActive = NewDevCfg->SoundAlm.ActiveSoundTrigger;
    DevCfg->AudioCfgPkt.SoundTriggerSensitive = NewDevCfg->SoundAlm.Sensitive;
    DevCfg->AlmCfgPkt.SoundAlm.IsAlmRec = NewDevCfg->SoundAlm.IsAlmRec;
    DevCfg->AlmCfgPkt.SoundAlm.IsFTPUpload = NewDevCfg->SoundAlm.IsFTPUpload;
    DevCfg->AlmCfgPkt.SoundAlm.ActiveDO = NewDevCfg->SoundAlm.ActiveDO;
    DevCfg->AlmCfgPkt.SoundAlm.IsSendEmail = NewDevCfg->SoundAlm.IsSendEmail;
    DevCfg->AlmCfgPkt.AlmOutTimeLen = NewDevCfg->SoundAlm.AlmOutTimeLen;
    //RecCfg
    DevCfg->RecCfgPkt.RecStreamType = NewDevCfg->RecCfg.RecStreamType;
    DevCfg->RecCfgPkt.IsRecAudio = NewDevCfg->RecCfg.IsRecAudio;
    DevCfg->RecCfgPkt.RecStyle = NewDevCfg->RecCfg.RecStyle;
    DevCfg->RecCfgPkt.Plan = NewDevCfg->RecCfg.Plan;
    DevCfg->RecCfgPkt.Rec_AlmTimeLen = NewDevCfg->RecCfg.Rec_AlmTimeLen;
    DevCfg->RecCfgPkt.Rec_NmlTimeLen = NewDevCfg->RecCfg.Rec_NmlTimeLen;

    return true;
}

//-----------------------------------------------------------------------------
bool GetWidthHeightFromStandard(int Value, int* w, int* h) {
    switch (Value) {
        case P720x576: *w = 720; *h = 576; break;
        case P720x288: *w = 720; *h = 288; break;
        case P704x576: *w = 704; *h = 576; break;
        case P704x288: *w = 704; *h = 288; break;
        case P352x288: *w = 352; *h = 288; break;
        case P176x144: *w = 176; *h = 144; break;
        case N720x480: *w = 720; *h = 480; break;
        case N720x240: *w = 720; *h = 240; break;
        case N704x480: *w = 704; *h = 480; break;
        case N704x240: *w = 704; *h = 240; break;
        case N352x240: *w = 352; *h = 240; break;
        case N176x120: *w = 176; *h = 120; break;
        case V160x120: *w = 160; *h = 120; break;
        case V320x240: *w = 320; *h = 240; break;
        case V640x480: *w = 640; *h = 480; break;
        case V800x600: *w = 800; *h = 600; break;
        case V1024x768: *w = 1024; *h = 768; break;
        case V1280x720:  *w = 1280; *h = 720;  break;
        case V1280x800: *w = 1280; *h = 800; break;
        case V1280x960: *w = 1280; *h = 960; break;
        case V1280x1024: *w = 1280; *h = 1024; break;
        case V1360x768: *w = 1360; *h = 768; break;
        case V1400x1050: *w = 1400; *h = 1050; break;
        case V1600x1200: *w = 1600; *h = 1200; break;
        //case V1680x1050: *w = 1680; *h = 1050; break;
        case V1920x1080: *w = 1920; *h = 1080; break;
        //case V2048x1536: *w = 2048; *h = 1536; break;
        //case V2560x1600: *w = 2560; *h = 1600; break;
        //case V2560x2048: *w = 2560; *h = 2048; break;
        //case V3400x2400: *w = 3400; *h = 2400; break;
        default: return false;
    }
    return true;
}
//-----------------------------------------------------------------------------
int GetStandardFromWidthHeight(int w, int h) {
    if ((w == 720)&&(h == 576)) return P720x576;
    else if ((w == 720)&&(h == 288)) return P720x288;
    else if ((w == 704)&&(h == 576)) return P704x576;
    else if ((w == 704)&&(h == 288)) return P704x288;
    else if ((w == 352)&&(h == 288)) return P352x288;
    else if ((w == 176)&&(h == 144)) return P176x144;
    else if ((w == 720)&&(h == 480)) return N720x480;
    else if ((w == 720)&&(h == 240)) return N720x240;
    else if ((w == 704)&&(h == 480)) return N704x480;
    else if ((w == 704)&&(h == 240)) return N704x240;
    else if ((w == 352)&&(h == 240)) return N352x240;
    else if ((w == 176)&&(h == 120)) return N176x120;
    else if ((w == 160)&&(h == 120)) return V160x120;
    else if ((w == 320)&&(h == 240)) return V320x240;
    else if ((w == 640)&&(h == 480)) return V640x480;
    else if ((w == 800)&&(h == 600)) return V800x600;
    else if ((w == 1024)&&(h == 768)) return V1024x768;
    else if ((w == 1280)&&(h == 720)) return V1280x720;
    else if ((w == 1280)&&(h == 800)) return V1280x800;
    //else if ((w == 1280)&&(h == 854)) return V1280x854;
    else if ((w == 1280)&&(h == 960)) return V1280x960;
    else if ((w == 1280)&&(h == 1024)) return V1280x1024;
    else if ((w == 1360)&&(h == 768)) return V1360x768;
    else if ((w == 1400)&&(h == 1050)) return V1400x1050;
    else if ((w == 1600)&&(h == 1200)) return V1600x1200;
    else if ((w == 1920)&&(h == 1080)) return V1920x1080;
    //else if ((w == 2048)&&(h == 1536)) return V2048x1536;
    //else if ((w == 2560)&&(h == 1600)) return V2560x1600;
    //else if ((w == 2560)&&(h == 2048)) return V2560x2048;
    //else if ((w == 3400)&&(h == 2400)) return V3400x2400;
    else return StandardExMin;
}
//-----------------------------------------------------------------------------
struct TudpParam udp;
DWORD SearchIPLst[512];

void OnUDPRecvEvent(char* Buf, int BufLen) {
    TSearchDevCallBack* SearchEvent;
    if (strstr(Buf, "M-SEARCH") != NULL) return;

    if (BufLen != sizeof(TNetCmdPkt)) return;
    TNetCmdPkt* PPkt = (TNetCmdPkt*)Buf;
    if (PPkt->HeadPkt.VerifyCode != Head_CmdPkt) return;
    if (PPkt->HeadPkt.PktSize != sizeof(TCmdPkt)) return;

    if (PPkt->CmdPkt.MsgID == Msg_GetMulticastInfo) {
        SearchEvent = udp.Flag;
        if (SearchEvent) {
            SearchEvent(PPkt->CmdPkt.MulticastInfo.DevInfo.SN,
                        PPkt->CmdPkt.MulticastInfo.DevInfo.DevType,
                        PPkt->CmdPkt.MulticastInfo.DevInfo.VideoChlCount,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.DataPort,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.HttpPort,
                        PPkt->CmdPkt.MulticastInfo.DevInfo.DevName,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.Lan.DevIP,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.Lan.DevMAC,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.Lan.SubMask,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.Lan.Gateway,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.Lan.DNS1,
                        PPkt->CmdPkt.MulticastInfo.NetCfg.DDNS.DDNSDomain,
                        PPkt->CmdPkt.MulticastInfo.p2pCfg.UID);
        }
    }
}
//-----------------------------------------------------------------------------
bool thSearch_Init(TSearchDevCallBack SearchEvent) {
    memset(&udp, 0, sizeof(TudpParam));

    udp.Port = Port_Ax_Search_Local;
    udp.OnRecvEvent = OnUDPRecvEvent;

    udp.IsMulticast = true;
    udp.TTL = 32;
    udp.LocalIP = GetLocalIP();
    udp.MultiIP = IP_Ax_Multicast;
    udp.Flag = SearchEvent;
    return udp_Init(&udp);
}
//-----------------------------------------------------------------------------
bool thSearch_SearchDevice(char* LocalIP) {
    if (LocalIP) udp.LocalIP = GetLocalIP();
    memset(SearchIPLst, 0, sizeof(SearchIPLst));
    TNetCmdPkt Pkt;
    memset(&Pkt, 0, sizeof(Pkt));

    Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
    Pkt.HeadPkt.PktSize = sizeof(TCmdPkt);
    Pkt.CmdPkt.MsgID = Msg_GetMulticastInfo;
    struct sockaddr_in Addr;
    memset(&Addr,0,sizeof(struct sockaddr_in));
    Addr.sin_family = AF_INET;
    //inet_aton(IP_Ax_Multicast, &Addr.sin_addr);
    //Addr.sin_port = htons(Port_Ax_Multicast);
    //sendto(udp.SocketHandle, &Pkt, sizeof(Pkt), 0, (struct sockaddr*)&Addr, sizeof(Addr));

    int flag = 1;
    setsockopt(udp.SocketHandle, SOL_SOCKET, SO_BROADCAST, &flag, sizeof(flag));
    inet_aton("255.255.255.255", &Addr.sin_addr);
    Addr.sin_port = htons(Port_Ax_Multicast);
    sendto(udp.SocketHandle, &Pkt, sizeof(Pkt), 0, (struct sockaddr*)&Addr, sizeof(Addr));
    return true;
}
//-----------------------------------------------------------------------------
bool thSearch_Free(void) {
    return udp_Free(&udp);
}
//-----------------------------------------------------------------------------
bool thNet_Init(int64_t* NetHandle, int DevType)
{
    if (*NetHandle != 0) return true;
    TPlayParam* Play = (TPlayParam*)malloc(sizeof(TPlayParam));
    if (!Play) return false;

    memset(Play, 0, sizeof(TPlayParam));
    Play->DevType = DevType;
    *NetHandle = (int64_t)Play;
    Play->p2p_avIndex = -1;
    Play->p2p_SessionID = -1;
    Play->p2p_talkIndex = -1;
    Play->isPlayRecorder = false;

    return (Play != NULL);
}
//-----------------------------------------------------------------------------
bool thNet_SetCallBack(int64_t NetHandle, TAVCallBack avEvent, TAlmCallBack AlmEvent, void* UserCustom) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    Play->avEvent = avEvent;
    Play->AlmEvent = AlmEvent;
    Play->UserCustom = UserCustom;
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_Free(int64_t* NetHandle) {
    if (*NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)(*NetHandle);
    if (Play == NULL) return false;
    //zhb  thNet_StopNmlRec(*NetHandle, 0);
    thNet_DisConn(*NetHandle);
    free(Play);
    *NetHandle = 0;
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_Login(int64_t NetHandle)//not export
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;

    if (!Play->Isp2pConn) {
        TNetCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.MsgID = Msg_Login;
          
        if (Play->UserName[0] != 0) {
            sprintf(Pkt.CmdPkt.LoginPkt.UserName, "%s", Play->UserName);
        }
        if (Play->Password[0] != 0) {
            sprintf(Pkt.CmdPkt.LoginPkt.Password, "%s", Play->Password);
        }
        if (Play->DevIP[0] != 0) {
            sprintf(Pkt.CmdPkt.LoginPkt.DevIP, "%s", Play->DevIP);
        }

        Pkt.CmdPkt.LoginPkt.SendSensePkt = true;

        SendBuf(Play->hSocket, (char*)&Pkt, sizeof(Pkt));
        memset(&Pkt, 0, sizeof(Pkt));
        RecvBuf(Play->hSocket, (char*)&Pkt, sizeof(Pkt));
        if (Pkt.CmdPkt.Value ==0) return false;
        
        Play->loginPkt = Pkt;

        Play->Session = Pkt.CmdPkt.Session;
        Play->DevCfg.DevInfoPkt = Pkt.CmdPkt.LoginPkt.DevInfoPkt;
        Play->DevCfg.VideoCfgPkt.VideoFormat = Pkt.CmdPkt.LoginPkt.v[0];
        Play->DevCfg.AudioCfgPkt.AudioFormat = Pkt.CmdPkt.LoginPkt.a[0];
        TVideoFormat* fmtv = &Play->DevCfg.VideoCfgPkt.VideoFormat;
        Play->ImgWidth  = fmtv->Width;
        Play->ImgHeight = fmtv->Height;
        return true;
    }
    
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_GetAllCfg(int64_t NetHandle)//not export
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;

    if (!Play->Isp2pConn) {
        THeadPkt Head;
        int ret, i;
        TNetCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Head_CmdPkt;
        Pkt.CmdPkt.MsgID = Msg_GetAllCfg;
        Pkt.CmdPkt.Session = Play->Session;
        SendBuf(Play->hSocket, (char*)&Pkt, sizeof(TNetCmdPkt));

        for (i=0; i<5; i++) {
          RecvBuf(Play->hSocket, (char*)&Head, sizeof(THeadPkt));
          if (Head.VerifyCode == Head_CfgPkt) break;
        }

        if (Head.VerifyCode != Head_CfgPkt) return false;
        if (Head.PktSize != sizeof(TDevCfg)) return false;
        ret = RecvBuf(Play->hSocket, (char*)&Play->DevCfg, sizeof(TDevCfg));

        return ret;
    } else {
#ifdef IsUsedP2P
        unsigned int ioType;
        int ret;
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(TNewCmdPkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = Msg_GetAllCfg;
        Pkt.Result = 0;
        Pkt.PktSize = 0;

        ioType = Head_CmdPkt;
        ret = avSendIOCtrl(Play->p2p_avIndex, ioType, (char*)&Pkt, 8 + Pkt.PktSize);
        if (ret < 0) return false;
        ret = avRecvIOCtrl(Play->p2p_avIndex, &ioType, (char*)&Pkt, sizeof(Pkt), 3000);
        if (ret < 0) return false;
        if (Pkt.VerifyCode == Head_CmdPkt && Pkt.MsgID == Msg_GetAllCfg) {
          NewDevCfg_to_DevCfg(&Pkt.NewDevCfg, &Play->DevCfg);
          return true;
        }
#endif
        return false;
    }
}
//-----------------------------------------------------------------------------
char dataBuf[60][MaxBufSize];       //数据缓存
int bufWriteIndex = -1;             //缓存写入指标
int bufReadIndex = -1;              //缓存读指标
bool bufReset = false;

void th_ReadData_TCP(int64_t NetHandle) {
    if (NetHandle == 0) return;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (!Play) return;
    
    for (;;) {
        if (Play->IsExit) return;
        
        if (bufReset) {
            bufReset = false;
            bufReadIndex = 0;
        }

        if (bufWriteIndex < 0 || bufReadIndex >= bufWriteIndex) {
            usleep(10 * 1000);
            continue;
        }
        
        char* RecvBuffer = dataBuf[bufReadIndex];
        THeadPkt* PHead = (THeadPkt*) (RecvBuffer);
        int HEADPKTSIZE = sizeof(THeadPkt);
        
        TDataFrameInfo* PInfo = (TDataFrameInfo*) RecvBuffer;
        char* Buf = &RecvBuffer[sizeof(TDataFrameInfo)];
        int BufLen = PHead->PktSize - 16;
        
        Play->RealBitRate_av = Play->RealBitRate_av + PHead->PktSize + HEADPKTSIZE;
        Play->RealFrameRate_av++;
        
        if (Play->avEvent)
            Play->avEvent(PInfo, Buf, BufLen, Play->UserCustom);
        
        bufReadIndex++;
    }  //end for (;;)
}

void th_RecvData_TCP(int64_t NetHandle) //视频连接后在这里接收数据
{
    if (NetHandle == 0) return;
    TPlayParam* Play = (TPlayParam*)NetHandle; //play -- 播放参数
    if (!Play) return;

    char* RecvBuffer = Play->RecvBuf;
    THeadPkt* PHead = (THeadPkt*)(RecvBuffer);
    int HEADPKTSIZE = sizeof(THeadPkt);
    bool ret = false;
    time_t t, t1;

    starts:
    t = time(NULL);
    t1 = t;
#ifndef WIN32
    fcntl(Play->hSocket, F_SETFL, O_NONBLOCK);//∑«◊Ë»˚∑Ω Ω
#else
    int optsize = 1;//0
    ioctlsocket(Play->hSocket, FIONBIO, &optsize);//∑«◊Ë»˚∑Ω Ω
#endif
    Play->LastSenseTime = 0;

    for (;;) {
        if (Play->IsExit) {
            free(Play);
            return;
        }
        //1 auto conn
        t1 = time(NULL);
        Play->LastSenseTime = (int)(t1 - t);
        if (Play->LastSenseTime >= 20) {
            close(Play->hSocket);
            Play->hSocket = 0;
            Play->IsConnect = false;
            if (Play->AlmEvent) Play->AlmEvent(Net_Disconn, (int)t1, 0, Play->UserCustom);

            ret = thNet_Connect(NetHandle, Play->UserName,Play->Password, Play->SvrIP, Play->DevIP, Play->DataPort, Play->TimeOut, 0); //是否连接

            if (ret) {
                if (Play->AlmEvent)
                    Play->AlmEvent(Net_ReConn, (int)t1, 0, Play->UserCustom);
                if (!Play->isPlayRecorder) {
                    thNet_Play(NetHandle, Play->VideoChlMask, Play->AudioChlMask, Play->SubVideoChlMask);  // 播放?????
                }
            }
            Play->LastSenseTime = 0;
            t = t1;
            goto starts;
        }
        //2
        if (Play->hSocket <= 0) {
            usleep(100*1000);
            continue;
        }
        //3
        
        ret = RecvBuf(Play->hSocket, (char*)PHead, HEADPKTSIZE); //是否收到数据?
        if (!ret) continue;

        if (PHead->VerifyCode != Head_VideoPkt      &&
            PHead->VerifyCode != Head_AudioPkt      &&
            PHead->VerifyCode != Head_SensePkt      &&
            PHead->VerifyCode != Head_TalkPkt       &&
            PHead->VerifyCode != Head_UploadPkt     &&
            PHead->VerifyCode != Head_DownloadPkt   &&
            PHead->VerifyCode != Head_CfgPkt        &&
            PHead->VerifyCode != Head_MotionInfoPkt &&  //add at 20130506
            PHead->VerifyCode != Head_CmdPkt)
        {
            continue; 
        }

        if (PHead->PktSize + HEADPKTSIZE > sizeof(Play->RecvBuf)) continue;

        ret = RecvBuf(Play->hSocket, RecvBuffer + HEADPKTSIZE, PHead->PktSize);//PktSize==0 return true
        if (!ret) continue;

        //Play->IsConnect = true;
        Play->LastSenseTime = 0;//◊Ó∫Û’Ï≤‚ ±º‰
        t = t1;
        
        switch (PHead->VerifyCode) { //获取到校验码
            case Head_VideoPkt:
            case Head_AudioPkt:
            {
                //收到音频视频包头处理
                
                TDataFrameInfo * PInfo=(TDataFrameInfo*)RecvBuffer; //录影文件数据帧头  24 Byte
                
                char* Buf = &RecvBuffer[sizeof(TDataFrameInfo)];
                int BufLen = PHead->PktSize - 16;

                if (PHead->VerifyCode == Head_VideoPkt) //视频包包头
                {
                    if (Play->IsNewStartPlay)
                    if (PInfo->Frame.IsIFrame) Play->IsNewStartPlay = false;
                    if (Play->IsNewStartPlay) break;//“—∞¸∫¨œ¬√ÊµƒPlay->avEvent 

                    Play->RealBitRate_av = Play->RealBitRate_av + PHead->PktSize + HEADPKTSIZE;
                    Play->RealFrameRate_av++;
                    
                    thNet_RecordWriteData(NetHandle, PInfo, Buf, BufLen);
                    if (Play->avEvent) Play->avEvent(PInfo, Buf, BufLen, Play->UserCustom);
                    
//                    TDataFrameInfo* PInfo     //音视频帧头信息
//                    char* Buf,                //音视频解码前帧数据
//                    int Len,                  //数据长度
//                    void* UserCustom          //用户自定义数据
                    
            
                    //这里为读取的线程做数据缓存
//                    if (PInfo->Frame.IsIFrame) {
//                        //LOGD("th_RecvData  synchro writeIndex = %d,readIndex=%d",writeIndex,readIndex);
//                        bufWriteIndex = 0;
//                        bufReset = true;
//                    }
//                    if (bufWriteIndex >= 0) {
//                        memcpy(dataBuf[bufWriteIndex], RecvBuffer, MaxBufSize);
//                        bufWriteIndex++;
//                    }
                }

                if (PHead->VerifyCode == Head_AudioPkt)
                {
                    if (Play->DevCfg.AudioCfgPkt.AudioFormat.wFormatTag == G711) {
                        char dstBuf[4096];
                        int dstBufLen;
                        g711a_decode(Buf, BufLen, dstBuf, &dstBufLen);
                        thNet_RecordWriteData(NetHandle, PInfo, dstBuf, dstBufLen);
                        if (Play->avEvent) Play->avEvent(PInfo, dstBuf, dstBufLen, Play->UserCustom);
                    } else {          //PCM
                        thNet_RecordWriteData(NetHandle, PInfo, Buf, BufLen);
                        if (Play->avEvent) Play->avEvent(PInfo, Buf, BufLen, Play->UserCustom);
                    }
                }
            }
                break;
            case Head_CmdPkt://Õ¯¬Á√¸¡Ó∞¸ // 命令包包头
            {
                TNetCmdPkt* PPkt = (TNetCmdPkt*)RecvBuffer; //网络发送包
                if (PPkt->CmdPkt.MsgID == Msg_Alarm)
                {
                    if (Play->AlmEvent) //收到回调信息?
                    {
                        Play->AlmEvent(PPkt->CmdPkt.AlmSendPkt.AlmType, PPkt->CmdPkt.AlmSendPkt.AlmTime,
                                       PPkt->CmdPkt.AlmSendPkt.AlmPort, Play->UserCustom);
                    }
                }
                else if (PPkt->CmdPkt.MsgID == Msg_StopPlayRecFile) //停止播放录影文件
                {
                    if (Play->AlmEvent)
                        Play->AlmEvent(PPkt->CmdPkt.MsgID, 0, 0, Play->UserCustom);
                }
            }
                break;
        }//end switch
    }//end for (;;)
}
//-----------------------------------------------------------------------------
bool thNet_Connect(int64_t NetHandle, char* UserName, char* Password, char* SvrIP, char* DevIP, int DataPort, DWORD TimeOut, int IsCreateRecvThread)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (Play->IsConnect) return true;
    Play->IsConnect = false;
    bool ret = false;
    
    if (UserName != NULL) {
        sprintf(Play->UserName, "%s", UserName);
    }
    if (Password != NULL) {
        sprintf(Play->Password, "%s", Password);
    }
    if (SvrIP != NULL) {
        sprintf(Play->SvrIP, "%s", SvrIP);
    }
    if (DevIP != NULL) {
        sprintf(Play->DevIP, "%s", DevIP);
    }

    Play->DataPort = DataPort;
    Play->TimeOut = TimeOut;
    if (Play->TimeOut == 0) Play->TimeOut = 3000;
    Play->IsCreateRecvThread = IsCreateRecvThread;
    Play->Isp2pConn = false;

    Play->hSocket = FastConnect(SvrIP, DataPort, TimeOut);
    Play->IsConnect = (Play->hSocket > 0);

    if (Play->IsConnect) {
        ret = thNet_Login(NetHandle);
        if (ret == false) {
            thNet_DisConn(NetHandle);
            return false;
        }

//        ret = thNet_GetAllCfg(NetHandle);
//        if (ret == false) {
//            thNet_DisConn(NetHandle);
//            return false;
//        }

        //thNet_Stop(NetHandle);//÷√Œ™œ÷≥°◊È

        if (Play->IsCreateRecvThread)
        {
            Play->IsExit = false;
            if (Play->tHandle == 0)
            {
                pthread_create(&Play->tHandle, NULL, (void *(*)(void*))th_RecvData_TCP, (void*)NetHandle);
//                pthread_create(&Play->tHandle, NULL, (void *(*)(void*))th_ReadData_TCP, (void*)NetHandle);
                
//                第一个参数为指向线程标识符的指针。 
//                第二个参数用来设置线程属性。
//                第三个参数是线程运行函数的起始地址。
//                最后一个参数是运行函数的参数。
            }
        }

        Play->IsConnect = ret;
    }

    return Play->IsConnect;
}
//-----------------------------------------------------------------------------
#ifdef IsUsedP2P
int64 currentFrame = 0;
void th_RecvData_P2P(int64_t NetHandle)
{
    FRAMEINFO_t frameInfo;
    unsigned int frmNo;

    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return;
    TNewCmdPkt* PPkt;
    TDataFrameInfo* PInfo;
    int BufLen;
    BufLen = 0;
    Play->RecvLen = 0;

    while(1) {
        if (Play->IsExit) break;
//        if (Play->VideoChlMask == 0 && Play->AudioChlMask == 0 && Play->SubVideoChlMask == 0) {
//            usleep(1000 * 1);
//            continue;
//        }

#ifdef IsP2PNewSDK
        int outBufSize = 0;
        int outFrmSize = 0;
        int outFrmInfoSize = 0;
        BufLen = avRecvFrameData2(Play->p2p_avIndex, Play->RecvBuf, MaxBufSize, 
          &outBufSize, &outFrmSize, (char*)&frameInfo, sizeof(FRAMEINFO_t), &outFrmInfoSize, &frmNo);
#else
        BufLen = avRecvFrameData(Play->p2p_avIndex, Play->RecvBuf, MaxBufSize, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
#endif
        if(BufLen == AV_ER_DATA_NOREADY) {usleep(1000*1); continue;}
        else if(BufLen == AV_ER_LOSED_THIS_FRAME) continue;
        else if(BufLen == AV_ER_INCOMPLETE_FRAME) continue;
        else if(BufLen == AV_ER_SESSION_CLOSE_BY_REMOTE) break;
        else if(BufLen == AV_ER_REMOTE_TIMEOUT_DISCONNECT)break;
        else if(BufLen == IOTC_ER_INVALID_SID || BufLen == AV_ER_INVALID_SID) break;
        else if(BufLen == IOTC_ER_NOT_INITIALIZED) {
            ken_InitializeP2p();
            break;
        } else if (BufLen == AV_ER_NOT_INITIALIZED) {
            avInitialize(254);
            break;
        }
        if (BufLen <= 0) continue;
        
        Play->RecvLen = BufLen;
        PPkt = (TNewCmdPkt*)(Play->RecvBuf);
        if (PPkt->VerifyCode == Head_CmdPkt) {
            if (PPkt->MsgID == Msg_Alarm) {
                if (Play->AlmEvent)
                    Play->AlmEvent(PPkt->AlmSendPkt.AlmType, PPkt->AlmSendPkt.AlmTime, PPkt->AlmSendPkt.AlmPort, Play->UserCustom);
                continue;
            } else if (PPkt->MsgID == Msg_StopPlayRecFile) {
                if (Play->AlmEvent)
                    Play->AlmEvent(PPkt->MsgID, 0, 0, Play->UserCustom);
                continue;
            }
        }

        PInfo = (TDataFrameInfo*)(Play->RecvBuf);

        if (PInfo->Head.VerifyCode == Head_VideoPkt) {
            thNet_RecordWriteData(NetHandle, PInfo, Play->RecvBuf+24, Play->RecvLen-24);
            
            if (PInfo->Frame.FrameID - currentFrame > 15) {
                if (!PInfo->Frame.IsIFrame)
                    continue;
            }
            
            currentFrame = PInfo->Frame.FrameID;

            //thNet_RecordWriteData(NetHandle, PInfo, Play->RecvBuf+24, Play->RecvLen-24);
            if (Play->avEvent) Play->avEvent(PInfo, Play->RecvBuf+24, Play->RecvLen-24, Play->UserCustom);
            continue;
        }

        if (PInfo->Head.VerifyCode == Head_AudioPkt) {
            if (Play->DevCfg.AudioCfgPkt.AudioFormat.wFormatTag == G711) {
                char dstBuf[4096];
                int dstBufLen;
                g711a_decode(Play->RecvBuf+24, Play->RecvLen-24, dstBuf, &dstBufLen);
                thNet_RecordWriteData(NetHandle, PInfo, dstBuf, dstBufLen);
                Play->avEvent(PInfo, dstBuf, dstBufLen, Play->UserCustom);
            } else {              //PCM
                thNet_RecordWriteData(NetHandle, PInfo, Play->RecvBuf+24, Play->RecvLen-24);
                if (Play->avEvent) Play->avEvent(PInfo, Play->RecvBuf+24, Play->RecvLen-24, Play->UserCustom);
            }
            continue;
        }
        
        if (PInfo->Head.VerifyCode == Head_DownloadPkt)//zhb20150906add
        {
            memcpy(Play->RecvDownloadBuf, Play->RecvBuf + sizeof(PInfo->Head), PInfo->Head.PktSize);
            Play->RecvDownloadLen = PInfo->Head.PktSize;
            continue;
        }
    }

    Play->IsConnect = false;
}

//-----------------------------------------------------------------------------
unsigned int _getTickCount() {
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (unsigned int)(tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

static bool Isp2pIOTCInit = false;
static bool Isp2pAVInit = false;
static bool p2pConnectting = false;
int thNet_Connect_P2P(int64_t NetHandle, int p2pType, char* p2pUID, char* p2pPSD, DWORD TimeOut, int IsCreateRecvThread)
{
    if (NetHandle == 0) return 0;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return 0;
    if (Play->IsConnect) return 1;
    Play->IsConnect = false;
    int ret = 0;
    
    if (p2pUID != NULL) {
        sprintf(Play->p2pUID, "%s", p2pUID);
    }
    if (p2pPSD != NULL) {
        sprintf(Play->p2pPSD, "%s", p2pPSD);
    }

    Play->TimeOut = TimeOut;
    if (Play->TimeOut == 0) Play->TimeOut = 5000*2;
    Play->IsCreateRecvThread = IsCreateRecvThread;
    Play->Isp2pConn = true;

    Play->p2pType = p2pType;
    
    p2pConnectting = true;
    //todo
//    if (!Isp2pIOTCInit)
//    {
        ret = IOTC_Initialize2(0);
        if(ret != IOTC_ER_NoERROR) goto exits;
//        Isp2pIOTCInit = YES;
//
//    }
//    if (!Isp2pAVInit) {
        ret = avInitialize(254);        //32 4
        if(ret < AV_ER_NoERROR) goto exits;
//        Isp2pAVInit = YES;
//    }

////////////////////////////////////////////////////////
//  这里是打出当前版本号
//    unsigned int iotcVer;
//    IOTC_Get_Version(&iotcVer);
//    int avVer = avGetAVApiVer();
//    unsigned char *p = (unsigned char *)&iotcVer;
//    unsigned char *p2 = (unsigned char *)&avVer;
//    char szIOTCVer[16], szAVVer[16];
//    sprintf(szIOTCVer, "%d.%d.%d.%d", p[3], p[2], p[1], p[0]);
//    sprintf(szAVVer, "%d.%d.%d.%d", p2[3], p2[2], p2[1], p2[0]);
//    printf("[thNet_Connect_P2P_async]IOTCAPI version[%s] AVAPI version[%s]\n", szIOTCVer, szAVVer);
////////////////////////////////////////////////////////
    
    
#if 0
    Play->p2p_SessionID = IOTC_Connect_ByUID(Play->p2pUID);
    if (Play->p2p_SessionID == IOTC_ER_NOT_INITIALIZED) {
        Isp2pIOTCInit = NO;
        Isp2pAVInit = NO;
    }
    
    if (Play->p2p_SessionID < 0) goto exits;
#else
    Play->p2p_SessionID = IOTC_Get_SessionID();
    if (Play->p2p_SessionID == IOTC_ER_NOT_INITIALIZED) {
        Isp2pIOTCInit = true;
        Isp2pAVInit = true;
    }
    
    ret = Play->p2p_SessionID;
    if (Play->p2p_SessionID < 0) goto exits;
    
    ret = IOTC_Connect_ByUID_Parallel(Play->p2pUID, Play->p2p_SessionID);
    
    if (ret < 0) goto exits;
#endif

    unsigned int nServType;
#ifdef IsP2PNewSDK
    int nResend = -1;
    Play->p2p_avIndex = avClientStart2(Play->p2p_SessionID, "admin", Play->p2pPSD, 20, &nServType, 0, &nResend);
#else
    Play->p2p_avIndex = avClientStart(Play->p2p_SessionID, "admin", Play->p2pPSD, 20, &nServType, 0);
#endif

    ret = Play->p2p_avIndex;
    
    if(Play->p2p_avIndex < 0) goto exits;

//    ret = thNet_GetAllCfg(NetHandle);
//    if (!ret) {
//        p2pConnectting = NO;
//        return 0;
//    }

    Play->IsExit = false;
    Play->tHandle = 0;

    if (IsCreateRecvThread) {
        if (Play->tHandle == 0) {
          pthread_create(&Play->tHandle, NULL, (void *(*)(void*))th_RecvData_P2P, (void*)NetHandle);
          //pthread_detach(Play->tHandle);
        }
    }
    
    Play->IsConnect = true;
    p2pConnectting = false;
    return 1;

    exits:
    p2pConnectting = false;
    thNet_DisConn(NetHandle);
    return ret;
}
#endif

//-----------------------------------------------------------------------------
bool thNet_DisConn(int64_t NetHandle)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;

    if (!Play->Isp2pConn) {
        if (Play->Session == 0) return false;
        Play->IsExit = true;
        if (Play->hSocket > 0) {
            close(Play->hSocket);
            Play->hSocket = 0;
        }
        Play->IsConnect = false;
        if (Play->tHandle > 0) {
            //pthread_join(Play->tHandle, NULL);
            close((int)Play->tHandle);
            Play->tHandle = 0;
        }
#ifndef WIN32
//        close(Play->tHandle);
//        Play->tHandle = 0;
#endif
    } else {
#ifdef IsUsedP2P
        Play->IsExit = true;
        
        if (Play->p2p_avIndex >= 0)
        {
            avClientStop(Play->p2p_avIndex);
            Play->p2p_avIndex = -1;
        } else {
            avClientExit(Play->p2p_avIndex, 0);
        }
        
        if (Play->p2p_talkIndex >=0)
        {
            avServStop(Play->p2p_talkIndex);
            Play->p2p_talkIndex = -1;
        }
        
        if (Play->p2p_SessionID >= 0)
        {
            IOTC_Session_Close(Play->p2p_SessionID);
            Play->p2p_SessionID = -1;
        }
        
        Play->IsConnect = false;
        if (Play->tHandle > 0)
        {
            //            pthread_join(Play->tHandle, NULL);
            close((int)Play->tHandle);
            Play->tHandle = 0;
        }
        
        if (!p2pConnectting) {
            //如果p2p正在连接中，不在做断开操作
            avDeInitialize();
            IOTC_DeInitialize();
        }
#endif
    }
    return true;
}

void thNet_DeInitializeP2p() {
    if (!p2pConnectting) {
        if (Isp2pAVInit) {
            Isp2pAVInit = false;
            avDeInitialize();
        }
        
        if (Isp2pIOTCInit) {
            Isp2pIOTCInit = false;
            IOTC_DeInitialize();
        }
    }
}
//-----------------------------------------------------------------------------
bool thNet_IsConnect(int64_t NetHandle)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    return Play->IsConnect;
}
//-----------------------------------------------------------------------------
bool thNet_Play(int64_t NetHandle, DWORD VideoChlMask, DWORD AudioChlMask, DWORD SubVideoChlMask)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    Play->isPlayRecorder = false;

    if (!Play->IsConnect) return false;
    if (!Play->Isp2pConn) {
        if (Play->Session == 0) return false;

        TNetCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.MsgID = Msg_PlayLive;
        Pkt.CmdPkt.Session = Play->Session;

        Play->VideoChlMask = VideoChlMask;
        Play->AudioChlMask = AudioChlMask;
        Play->SubVideoChlMask = SubVideoChlMask;
        Play->IsNewStartPlay = true;

        Pkt.CmdPkt.LivePkt.VideoChlMask = VideoChlMask;//÷˜¬Î¡˜
        Pkt.CmdPkt.LivePkt.AudioChlMask = AudioChlMask;
        Pkt.CmdPkt.LivePkt.SubVideoChlMask = SubVideoChlMask;
        
        return (SendBuf(Play->hSocket, (char*)&Pkt, sizeof(Pkt))>0);
    }
    else
    {
#ifdef IsUsedP2P
        TNewCmdPkt Pkt;
        int ret;
        Play->VideoChlMask = VideoChlMask;
        Play->AudioChlMask = AudioChlMask;
        Play->SubVideoChlMask = SubVideoChlMask;
        Play->IsNewStartPlay = true;

        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.PktSize = sizeof(Pkt.LivePkt);
        Pkt.MsgID = Msg_PlayLive;
        Pkt.Result = 0;

        Pkt.LivePkt.VideoChlMask = VideoChlMask;//÷˜¬Î¡˜
        Pkt.LivePkt.AudioChlMask = AudioChlMask;
        Pkt.LivePkt.SubVideoChlMask = SubVideoChlMask;

        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char *)&Pkt, 8 + Pkt.PktSize);
        if(ret < 0) return 0;
#endif
        return true;
    }
}
//-----------------------------------------------------------------------------
bool thNet_Stop(int64_t NetHandle)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    
    if (!Play->Isp2pConn) {

    } else {
#ifdef IsUsedP2P
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(TNewCmdPkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = IOTYPE_USER_IPCAM_STOP;
        Pkt.Result = 0;
        Pkt.PktSize = 0;
        int ret = avSendIOCtrl(Play->p2p_avIndex, IOTYPE_USER_IPCAM_STOP, (char*)&Pkt, 8 + Pkt.PktSize);
        
        printf("before stop send ret = %d", ret);
#endif
    }
    return thNet_Play(NetHandle, 0, 0, 0);
}
//-----------------------------------------------------------------------------
bool thNet_SendCmdPkt(int64_t NetHandle, TNetCmdPkt* sendPkt, TNetCmdPkt* recvPkt) //TCP
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    //if (!Play->IsConnect) return false;
    if (!Play->Isp2pConn)
    {
        int hSocket, ret, Session;
        TNetCmdPkt Pkt;

        hSocket = FastConnect(Play->SvrIP, Play->DataPort, Play->TimeOut);
        if (hSocket == 0 || hSocket == -1) return false;

        memset(&Pkt, 0, sizeof(Pkt));
//        void * memset(void *s, int ch, size_t n);
//        函数解释：将s中当前位置后面的n个字节 （typedef unsigned int size_t ）用 ch 替换并返回 s 。
//        memset：作用是在一段内存块中填充某个给定的值，它是对较大的结构体或数组进行清零操作的一种最快方法。
        
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.MsgID = Msg_Login;
        sprintf(Pkt.CmdPkt.LoginPkt.UserName, "%s", Play->UserName);
        sprintf(Pkt.CmdPkt.LoginPkt.Password, "%s", Play->Password);

        sprintf(Pkt.CmdPkt.LoginPkt.DevIP, "%s", Play->DevIP);//字符串格式化命令，主要功能是把格式化的数据写入某个字符串中。sprintf 是个变参函数。

        SendBuf(hSocket, (char*)&Pkt, sizeof(TNetCmdPkt));
        memset(&Pkt, 0, sizeof(Pkt));
        RecvBuf(hSocket, (char*)&Pkt, sizeof(TNetCmdPkt));
        if (Pkt.CmdPkt.Value == 0) {
            close(hSocket);
            return false;
        }

        Session = Pkt.CmdPkt.Session;

        sendPkt->HeadPkt.VerifyCode = Head_CmdPkt;
        sendPkt->HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        sendPkt->CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        sendPkt->CmdPkt.Session = Session;
        ret = SendBuf(hSocket, (char*)sendPkt, sizeof(TNetCmdPkt));
        if (recvPkt)
        {
            ret = RecvBuf(hSocket, (char*)recvPkt, sizeof(TNetCmdPkt));
        }
        close(hSocket);
        return ret;
    }
    
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_PTZControl(int64_t NetHandle, int Cmd, int Chl, int Speed, int SetPoint)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    if (!Play->Isp2pConn) {
        TNetCmdPkt S;
        memset(&S, 0, sizeof(S));
        S.CmdPkt.MsgID = Msg_PTZControl;
        S.CmdPkt.PTZPkt.PTZCmd = Cmd;
        S.CmdPkt.PTZPkt.Protocol = 0;
        S.CmdPkt.PTZPkt.PanSpeed = Speed;
        S.CmdPkt.PTZPkt.Value = SetPoint;
        return thNet_SendCmdPkt(NetHandle, &S, NULL);
    } else {
#ifdef IsUsedP2P
        TNewCmdPkt Pkt;
        int ret;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.PktSize = sizeof(Pkt.PTZPkt);
        Pkt.MsgID = Msg_PTZControl;
        Pkt.Result = 0;
        Pkt.PTZPkt.PTZCmd = Cmd;
        Pkt.PTZPkt.Protocol = 0;
        Pkt.PTZPkt.PanSpeed = Speed;
        Pkt.PTZPkt.Value = SetPoint;
        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char *)&Pkt, 8 + Pkt.PktSize);
        if(ret < 0) return 0;
#endif
        return true;
    }
}
//-----------------------------------------------------------------------------
bool thNet_SetTalk(int64_t NetHandle, char* Buf, int BufLen)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;

    if (!Play->Isp2pConn) {
        bool ret;
        if (Play->Session == 0) return false;
        TTalkHeadPkt Head;
        Head.VerifyCode = Head_TalkPkt;
        Head.PktSize = BufLen + 24;
        ret = SendBuf(Play->hSocket, (char*)&Head, sizeof(TTalkHeadPkt));
        if (ret) return (SendBuf(Play->hSocket, Buf, BufLen)>0);
    } else {
#ifdef IsUsedP2P
        int i, idiv, imod, iMaxSize;
        FRAMEINFO_t framInfo;

        if (Play->p2p_SessionID < 0) return false;
        if (Play->p2p_talkIndex < 0) {
#define AUDIO_SPEAKER_CHANNEL 5
            Play->p2p_talkIndex = avServStart(Play->p2p_SessionID, NULL, NULL, 5000, 0, AUDIO_SPEAKER_CHANNEL);
        }
        if (Play->p2p_talkIndex < 0) return false;

        memset(&framInfo, 0, sizeof(FRAMEINFO_t));
        framInfo.timestamp = 0;
        framInfo.codec_id = MEDIA_CODEC_AUDIO_PCM;
        framInfo.cam_index = 0;
        framInfo.flags = (AUDIO_SAMPLE_8K << 2) | (AUDIO_DATABITS_16 << 1) | AUDIO_CHANNEL_MONO;
        framInfo.onlineNum = 1;//online;

        iMaxSize = 1024;
        idiv = BufLen / iMaxSize;
        imod = (BufLen % iMaxSize);
        for (i=0; i<idiv; i++) {
            avSendAudioData(Play->p2p_talkIndex, &Buf[i*iMaxSize], iMaxSize, &framInfo, sizeof(FRAMEINFO_t));
        }
        if (imod > 0) avSendAudioData(Play->p2p_talkIndex, &Buf[i*iMaxSize], imod, &framInfo, sizeof(FRAMEINFO_t));
#endif
        return true;
    }
    
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_GetVideoCfg1(int64_t NetHandle, int* Standard, int* VideoType, int* IsMirror, int* IsFlip,
                        int* Width0, int* Height0, int* FrameRate0, int* BitRate0,
                        int* Width1, int* Height1, int* FrameRate1, int* BitRate1)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    TVideoFormat* fmt = &Play->DevCfg.VideoCfgPkt.VideoFormat;

    *Standard = fmt->Standard;
    *VideoType = fmt->VideoType;
    *IsMirror = fmt->IsMirror;
    *IsFlip = fmt->IsFlip;
    *Width0 = fmt->Width;
    *Height0 = fmt->Height;
    *FrameRate0 = fmt->FrameRate;
    *BitRate0 = fmt->BitRate;
    GetWidthHeightFromStandard(fmt->Sub.StandardEx, Width1, Height1);
    *FrameRate1 = fmt->Sub.FrameRate;
    *BitRate1 = fmt->Sub.BitRate;
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_SetVideoCfg1(int64_t NetHandle, int Standard, int VideoType, int IsMirror, int IsFlip,
                        int Width0, int Height0, int FrameRate0, int BitRate0,
                        int Width1, int Height1, int FrameRate1, int BitRate1)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;
    TVideoFormat* fmt = &Play->DevCfg.VideoCfgPkt.VideoFormat;
    fmt->Standard = Standard;
    fmt->VideoType = VideoType;
    fmt->IsMirror = IsMirror;
    fmt->IsFlip = IsFlip;
    fmt->Width = Width0;
    fmt->Height = Height0;
    fmt->FrameRate = FrameRate0;
    fmt->BitRate = BitRate0;
    fmt->Sub.StandardEx = GetStandardFromWidthHeight(Width1, Height1);
    fmt->Sub.FrameRate = FrameRate1;
    fmt->Sub.BitRate = BitRate1;

    if (!Play->Isp2pConn) {
        TNetCmdPkt S;
        memset(&S, 0, sizeof(S));
        S.CmdPkt.MsgID = Msg_SetVideoCfg;
        S.CmdPkt.VideoCfgPkt.VideoFormat = *fmt;
        if (thNet_SendCmdPkt(NetHandle, &S, &S))
        {
            *fmt = S.CmdPkt.VideoCfgPkt.VideoFormat;
            return true;
        }
    } else {
#ifdef IsUsedP2P
        unsigned int ioType;
        int ret = false;
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = Msg_SetAllCfg;
        Pkt.Result = false;
        Pkt.PktSize = sizeof(Pkt.NewDevCfg);
        DevCfg_to_NewDevCfg(&Play->DevCfg, &Pkt.NewDevCfg);
        Pkt.NewDevCfg.VideoCfg.StandardEx0 = GetStandardFromWidthHeight(Width0, Height0);
        Pkt.NewDevCfg.VideoCfg.IsMirror = IsMirror;
        Pkt.NewDevCfg.VideoCfg.IsFlip = IsFlip;
        Pkt.NewDevCfg.VideoCfg.FrameRate0 = FrameRate0;
        Pkt.NewDevCfg.VideoCfg.BitRate0 = BitRate0 / 1024;
        Pkt.NewDevCfg.VideoCfg.StandardEx1 = GetStandardFromWidthHeight(Width1, Height1);
        Pkt.NewDevCfg.VideoCfg.FrameRate1 = FrameRate1;
        Pkt.NewDevCfg.VideoCfg.BitRate1 = BitRate1 / 1024;

        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char*)&Pkt, 8 + Pkt.PktSize);
        if (ret < 0) return false;
        ret = avRecvIOCtrl(Play->p2p_avIndex, &ioType, (char*)&Pkt, sizeof(Pkt), 1000*15);
        if (ret < 0) return false;
        if (!(Pkt.VerifyCode == Head_CmdPkt && Pkt.MsgID == Msg_SetAllCfg)) return false;
        return Pkt.Result;
#endif
    //todo
    }
    
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_GetAudioCfg1(int64_t NetHandle, int* wFormatTag, int* nChannels, int* nSamplesPerSec, int* wBitsPerSample)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    TAudioFormat* fmt = &Play->DevCfg.AudioCfgPkt.AudioFormat;
    *wFormatTag = fmt->wFormatTag;
    *nChannels = fmt->nChannels;
    *nSamplesPerSec = fmt->nSamplesPerSec;
    *wBitsPerSample = fmt->wBitsPerSample;
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_SetAudioCfg1(int64_t NetHandle, int wFormatTag, int nChannels, int nSamplesPerSec, int wBitsPerSample)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    TAudioFormat* fmt = &Play->DevCfg.AudioCfgPkt.AudioFormat;
    fmt->wFormatTag = wFormatTag;
    fmt->nChannels = nChannels;
    fmt->nSamplesPerSec = nSamplesPerSec;
    fmt->wBitsPerSample = wBitsPerSample;

    if (!Play->Isp2pConn) {
        TNetCmdPkt S;
        memset(&S, 0, sizeof(S));
        S.CmdPkt.MsgID = Msg_SetAudioCfg;
        S.CmdPkt.AudioCfgPkt.AudioFormat = *fmt;
        if (thNet_SendCmdPkt(NetHandle, &S, &S)) {
          *fmt = S.CmdPkt.AudioCfgPkt.AudioFormat;
          return true;
        }
    } else {
#ifdef IsUsedP2P
        unsigned int ioType;
        int ret = false;
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = Msg_SetAllCfg;
        Pkt.Result = false;
        Pkt.PktSize = sizeof(Pkt.NewDevCfg);
        DevCfg_to_NewDevCfg(&Play->DevCfg, &Pkt.NewDevCfg);
        Pkt.NewDevCfg.AudioCfg.nChannels = nChannels;
        Pkt.NewDevCfg.AudioCfg.nSamplesPerSec = nSamplesPerSec;
        Pkt.NewDevCfg.AudioCfg.wBitsPerSample = wBitsPerSample;

        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char*)&Pkt, 8 + Pkt.PktSize);
        if (ret < 0) return false;
        ret = avRecvIOCtrl(Play->p2p_avIndex, &ioType, (char*)&Pkt, sizeof(Pkt), 1000*15);
        if (ret < 0) return false;
        if (!(Pkt.VerifyCode == Head_CmdPkt && Pkt.MsgID == Msg_SetAllCfg)) return false;
        return Pkt.Result;
#endif
    }

    return true;
}
//-----------------------------------------------------------------------------
bool thNet_CreateRecvThread(int64_t NetHandle)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    Play->IsExit = false;

//  if (Play->tHandle == 0)
    {
        if (!Play->Isp2pConn) {
            if (Play->Session == 0) return false;
            pthread_create(&Play->tHandle, NULL, (void *(*)(void*))th_RecvData_TCP, (void*)NetHandle);
            //pthread_detach(Play->tHandle);
        } else {
#ifdef IsUsedP2P
            pthread_create(&Play->tHandle, NULL, (void *(*)(void*))th_RecvData_P2P, (void*)NetHandle);
            //pthread_detach(Play->tHandle);
#endif
        }
    }
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_RemoteFilePlay(int64_t NetHandle, char* FileName) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    Play->isPlayRecorder = true;
    if (!Play->IsConnect) return false;

    if (!Play->Isp2pConn) {
        if (Play->Session == 0) return false;
        Play->VideoChlMask = 0;
        Play->AudioChlMask = 1;
        Play->SubVideoChlMask = 1;

        bool ret = false;

        TNetCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.MsgID = Msg_StartPlayRecFile;
        Pkt.CmdPkt.Session = Play->Session;
        sprintf(Pkt.CmdPkt.RecFilePkt.FileName, "%s", FileName);
        ret = SendBuf(Play->hSocket, (char*)&Pkt, sizeof(Pkt));
        return ret;
    } else {
#ifdef IsUsedP2P
        Play->VideoChlMask = 0;
        Play->AudioChlMask = 1;
        Play->SubVideoChlMask = 1;

        int ret = false;
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = Msg_StartPlayRecFile;
        Pkt.Result = false;
        Pkt.PktSize = sizeof(Pkt.RecFilePkt);
        sprintf(Pkt.RecFilePkt.FileName, "%s", FileName);
        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char*)&Pkt, 8 + Pkt.PktSize);
        if (ret < 0) return false;
#endif
        return true;
    }
}
//-----------------------------------------------------------------------------
bool thNet_RemoteFileStop(int64_t NetHandle) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    if (!Play->Isp2pConn) {
        if (Play->Session == 0) return false;
        Play->VideoChlMask = 0;
        Play->AudioChlMask = 0;
        Play->SubVideoChlMask = 0;
        int ret;
        TNetCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.Session = Play->Session;
        Pkt.CmdPkt.MsgID = Msg_StopPlayRecFile;
        ret = SendBuf(Play->hSocket, (char*)&Pkt, sizeof(Pkt));
        return ret;
    } else {
#ifdef IsUsedP2P
        Play->VideoChlMask = 0;
        Play->AudioChlMask = 0;
        Play->SubVideoChlMask = 0;
        int ret = false;
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = Msg_StopPlayRecFile;
        Pkt.Result = false;
        Pkt.PktSize = 0;
        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char*)&Pkt, 8 + Pkt.PktSize);
        if (ret < 0) return false;
#endif
        return true;
    }
}
//-----------------------------------------------------------------------------
bool thNet_RemoteFilePlayControl(int64_t NetHandle, int PlayCtrl, int Speed, int Pos) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    if (!Play->Isp2pConn) {
        if (Play->Session == 0) return false;

        int ret;
        TNetCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.Session = Play->Session;
        Pkt.CmdPkt.MsgID = Msg_PlayControl;
        Pkt.CmdPkt.PlayCtrlPkt.PlayCtrl = PlayCtrl;
        Pkt.CmdPkt.PlayCtrlPkt.Speed = Speed;
        Pkt.CmdPkt.PlayCtrlPkt.Pos = Pos;
        ret = SendBuf(Play->hSocket, (char*)&Pkt, sizeof(Pkt));
        return ret;
    } else {
#ifdef IsUsedP2P
        int ret = false;
        TNewCmdPkt Pkt;
        memset(&Pkt, 0, sizeof(Pkt));
        Pkt.VerifyCode = Head_CmdPkt;
        Pkt.MsgID = Msg_PlayControl;
        Pkt.Result = false;
        Pkt.PktSize = sizeof(Pkt.PlayCtrlPkt);
        Pkt.PlayCtrlPkt.PlayCtrl = PlayCtrl;
        Pkt.PlayCtrlPkt.Speed = Speed;
        Pkt.PlayCtrlPkt.Pos = Pos;
        ret = avSendIOCtrl(Play->p2p_avIndex, Head_CmdPkt, (char*)&Pkt, 8 + Pkt.PktSize);
        if (ret < 0) return false;
        return true;
#endif
    }
}
//-----------------------------------------------------------------------------
bool thNet_HttpGetStop(int64_t NetHandle) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    Play->IsStopHttpGet = true;

    return true;
}
//-----------------------------------------------------------------------------
bool thNet_HttpGet(int64_t NetHandle, char* url, char* Buf, int* BufLen)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (!Play->IsConnect) return false;

    int ret;
    time_t dt;
    
    if (!Play->Isp2pConn) {
        if (Play->Session == 0) return false;
        ret = httpget1(url, Buf, BufLen, false, 1000*15);
        return true;
    } else {
        #ifdef IsUsedP2P
        char128 SvrName, HostName, UserNamePassword;
        char PageName[1024];
        int port, ret;
        unsigned int ioType;
        TNewCmdPkt SendPkt;

        Play->IsStopHttpGet = false;

        ret = sscanf(url, "http://%[^@]@%[^/]%s", UserNamePassword, SvrName, PageName);
        if (ret != 3) {
            ret = sscanf(url, "http://%[^/]%s", SvrName, PageName);
            if (ret != 2) sprintf(PageName, "/");
        }

        if (sscanf(SvrName, "%[^:]:%d", HostName, &port) == 2) {
            if ((strlen(HostName) == 0) || (port <= 0) || (port >0xffff)) return 0;
        } else {
            strcpy(HostName, SvrName);
            port = 80;
        }

        *BufLen = 0;
        memset(&SendPkt, 0, sizeof(TNewCmdPkt));
        SendPkt.VerifyCode = Head_CmdPkt;
        SendPkt.MsgID = Msg_HttpGet;
        SendPkt.Result = 0;
        sprintf(SendPkt.Buf, "http://localhost:%d%s", port, PageName);
        SendPkt.PktSize = strlen(SendPkt.Buf);

        Play->RecvDownloadLen = 0;
        ioType = Head_CmdPkt;
        
        ret = avSendIOCtrl(Play->p2p_avIndex, ioType, (char*)&SendPkt, 8 + SendPkt.PktSize);
        if (ret < 0) return false;

#if 1
        dt = time(NULL);
        while(1)
        {
            if (time(NULL) - dt >= 10) return false;//10s
            if (Play->IsStopHttpGet == true) return false;
            if (Play->RecvDownloadLen > 0)
            {
                memcpy(Buf, Play->RecvDownloadBuf, Play->RecvDownloadLen);
                *BufLen = Play->RecvDownloadLen;
                Play->RecvDownloadLen = 0;
                break;
            }
            usleep(1000*100);
        }
#else
        while(1) {
            if (Play->IsStopHttpGet == true) break;
            ret = avRecvIOCtrl(Play->p2p_avIndex, &ioType, (char*)&recvPkt, sizeof(recvPkt), 1000*15);
            if (ret < 0) return false;
            if (!(recvPkt.VerifyCode == Head_CmdPkt && recvPkt.MsgID == Msg_HttpGet)) return false;

            memcpy(&Buf[*BufLen], recvPkt.Buf, recvPkt.PktSize);
            *BufLen = *BufLen + recvPkt.PktSize;
            if (recvPkt.Result == 1) break;
        }
#endif
        #endif
        return true;
    }
}

//-----------------------------------------------------------------------------
bool thNet_IsRecord(int64_t NetHandle) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    return (Play->recHandle>0);
}
//-----------------------------------------------------------------------------
bool thNet_RecordStop(int64_t NetHandle) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (Play->recHandle == 0) return false;

    if (Play->FileType == 0) {
        GMAVIClose(Play->recHandle);
        Play->StreamIDvideo = 0;
        Play->StreamIDaudio = 0;
        Play->recHandle = 0;
        char80 idxFileName;
        sprintf(idxFileName, "%s_idx", Play->RecFileName);
        unlink(idxFileName);
    }

    if (Play->FileType == 1) {
        return true;
    }
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_RecordStart(int64_t NetHandle,
                       int FileType, char* FileName,                       
                       int VideoType, int Width, int Height, int FrameRate, int BitRate,
                       int AudioType, int nChannels, int wBitsPerSample, int nSamplesPerSec)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    Play->FileType = FileType;

    if (Play->FileType == 0)
    {
        int recHandle;
        int StreamIDvideo, StreamIDaudio;
        AviMainHeader main_header;
        AviStreamHeader stream_header;
        GmAviStreamFormat stream_format;
        sprintf(Play->RecFileName, "%s", FileName);

        recHandle = GMAVIOpen(Play->RecFileName, GMAVI_FILEMODE_CREATE, 0);
        if (recHandle == 0) return false;
        GMAVIFillAviMainHeaderValues(&main_header, Width,  Height, FrameRate, BitRate, 256);
        GMAVIFillVideoStreamHeaderValues(&stream_header, &stream_format, GMAVI_TYPE_H264, Width, Height, FrameRate, BitRate, 256);
        GMAVISetAviMainHeader(recHandle, &main_header);
        GMAVISetStreamHeader(recHandle, &stream_header, &stream_format, &StreamIDvideo);
        Play->StreamIDvideo = StreamIDvideo;
        Play->StreamIDaudio = StreamIDaudio;
        Play->recHandle = recHandle;
        return true;
    }

    if (Play->FileType == 1) {
        return true;
    }
    
    return true;
}
//-----------------------------------------------------------------------------
bool thNet_RecordWriteData(int64_t NetHandle, TDataFrameInfo* PInfo, char* Buf, int BufLen) {
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    if (Play->recHandle == 0) return false;
    if (Play->FileType == 0) //avi=0 mp4=1
    {
        int IsIFrame = PInfo->Frame.IsIFrame; //是否I帧
        GMAVISetStreamDataAndIndex(Play->recHandle, Play->StreamIDvideo, (unsigned char*)Buf, BufLen, IsIFrame, NULL, 0);
        return true;
    }

    if (Play->FileType == 1) {
        return true;
    }
    
    return true;
}

#pragma mark - 新的p2p连接方案
int ken_Connect_P2P(int64_t NetHandle, int p2pType, char* p2pUID, char* p2pPSD, DWORD TimeOut, int IsCreateRecvThread)
{
    if (NetHandle == 0) return 0;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return 0;
    if (Play->IsConnect) return 1;
    Play->IsConnect = false;
    int ret = 0;
    
    if (p2pUID != NULL) {
        sprintf(Play->p2pUID, "%s", p2pUID);
    }
    if (p2pPSD != NULL) {
        sprintf(Play->p2pPSD, "%s", p2pPSD);
    }
    
    Play->TimeOut = TimeOut;
    if (Play->TimeOut == 0) Play->TimeOut = 5000*2;
    Play->IsCreateRecvThread = IsCreateRecvThread;
    Play->Isp2pConn = true;
    
    Play->p2pType = p2pType;
    
    Play->p2p_SessionID = IOTC_Get_SessionID();
    if (Play->p2p_SessionID == IOTC_ER_NOT_INITIALIZED) {
        Isp2pIOTCInit = false;
        Isp2pAVInit = false;
    }
    
    ret = Play->p2p_SessionID;
    if (Play->p2p_SessionID < 0) goto exits;
    
    ret = IOTC_Connect_ByUID_Parallel(Play->p2pUID, Play->p2p_SessionID);
    
    if (ret < 0) goto exits;
    
    unsigned int nServType;
#ifdef IsP2PNewSDK
    int nResend = -1;
    Play->p2p_avIndex = avClientStart2(Play->p2p_SessionID, "admin", Play->p2pPSD, 20, &nServType, 0, &nResend);
#else
    Play->p2p_avIndex = avClientStart(Play->p2p_SessionID, "admin", Play->p2pPSD, 20, &nServType, 0);
#endif
    
    ret = Play->p2p_avIndex;
    
    if(Play->p2p_avIndex < 0) goto exits;

    Play->IsExit = false;
    Play->tHandle = 0;
    
    if (IsCreateRecvThread) {
        ken_createThreadP2p(NetHandle);
    }
    
    Play->IsConnect = true;
    p2pConnectting = false;
    return 1;
    
exits:
    p2pConnectting = false;
    ken_DisConnP2p(NetHandle);
    return ret;
}

//-----------------------------------------------------------------------------
bool ken_DisConnP2p(int64_t NetHandle)
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;

#ifdef IsUsedP2P
    Play->IsExit = true;
    
    if (Play->p2p_avIndex >= 0)
    {
        avClientStop(Play->p2p_avIndex);
        Play->p2p_avIndex = -1;
    } else {
        avClientExit(Play->p2p_avIndex, 0);
    }
    
    if (Play->p2p_talkIndex >= 0)
    {
        avServStop(Play->p2p_talkIndex);
        Play->p2p_talkIndex = -1;
    }

    if (Play->p2p_SessionID >= 0)
    {
        IOTC_Session_Close(Play->p2p_SessionID);
        Play->p2p_SessionID = -1;
    }
    
    Play->IsConnect = false;
    ken_closeThreadP2p(NetHandle);
#endif

    return true;
}

int ken_createThreadP2p(int64_t NetHandle) {
    int result = -1;
    if (NetHandle == 0) return result;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return result;
     
    if (Play->tHandle == 0) {
        result = pthread_create(&Play->tHandle, NULL, (void *(*)(void*))th_RecvData_P2P, (void*)NetHandle);
    } else {
        result = 0;
    }
    
    return result;
}

int ken_closeThreadP2p(int64_t NetHandle) {
    int result = -1;
    if (NetHandle == 0) return result;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return result;
    
    if (Play->tHandle > 0) {
        result = close((int)Play->tHandle);
        Play->tHandle = 0;
    }
    
    return result;
}

void ken_DeInitializeP2p() {
    avDeInitialize();
    IOTC_DeInitialize();
}

int ken_InitializeP2p() {
    int ret = IOTC_Initialize2(0);
    if (ret == IOTC_ER_NoERROR) {
        ret = avInitialize(254); 
    }
    return ret;
}

#pragma mark -- 上传视频
//-----------------------------------------------------------------------------
bool thNet_SendVideoCmdPkt(int64_t NetHandle, TNetCmdPkt* sendPkt, TNetCmdPkt* recvPkt) //TCP
{
    if (NetHandle == 0) return false;
    TPlayParam* Play = (TPlayParam*)NetHandle;
    if (Play == NULL) return false;
    //if (!Play->IsConnect) return false;
    if (!Play->Isp2pConn)
    {
        int hSocket, ret, Session;
        TNetCmdPkt Pkt;
        WORD port = 8000;
         hSocket = FastConnect("120.26.131.85", port, Play->TimeOut); //15
       // hSocket = FastConnect(Play->SvrIP, Play->DataPort, Play->TimeOut); //-1  192.168.1.170 7802
        if (hSocket == 0 || hSocket == -1) return false;
        
        memset(&Pkt, 0, sizeof(Pkt));
        //        void * memset(void *s, int ch, size_t n);
        //        函数解释：将s中当前位置后面的n个字节 （typedef unsigned int size_t ）用 ch 替换并返回 s 。
        //        memset：作用是在一段内存块中填充某个给定的值，它是对较大的结构体或数组进行清零操作的一种最快方法。
        
        Pkt.HeadPkt.VerifyCode = Head_CmdPkt;
        Pkt.HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        Pkt.CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        Pkt.CmdPkt.MsgID = Msg_Login;
        sprintf(Pkt.CmdPkt.LoginPkt.UserName, "%s", Play->UserName);
        sprintf(Pkt.CmdPkt.LoginPkt.Password, "%s", Play->Password);
        
        sprintf(Pkt.CmdPkt.LoginPkt.DevIP, "%s", Play->DevIP);//字符串格式化命令，主要功能是把格式化的数据写入某个字符串中。sprintf 是个变参函数。
        
        SendBuf(hSocket, (char*)&Pkt, sizeof(TNetCmdPkt));
        memset(&Pkt, 0, sizeof(Pkt));
        RecvBuf(hSocket, (char*)&Pkt, sizeof(TNetCmdPkt));
        if (Pkt.CmdPkt.Value == 0) {
            close(hSocket);

            return false;
        }
        
        Session = Pkt.CmdPkt.Session;
        
        sendPkt->HeadPkt.VerifyCode = Head_CmdPkt;
        sendPkt->HeadPkt.PktSize = sizeof(Pkt.CmdPkt);
        sendPkt->CmdPkt.PktHead = Pkt.HeadPkt.VerifyCode;
        sendPkt->CmdPkt.Session = Session;
        ret = SendBuf(hSocket, (char*)sendPkt, sizeof(TNetCmdPkt));

        if (ret) {
        }
        if (recvPkt)
        {
            ret = RecvBuf(hSocket, (char*)recvPkt, sizeof(TNetCmdPkt));
        }
        close(hSocket);
        return ret;
    }
    
    return true;
}
//-----------------------------------------------------------------------------
