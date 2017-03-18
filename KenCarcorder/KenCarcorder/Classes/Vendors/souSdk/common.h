//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description :
//-----------------------------------------------------------------------------
#ifndef common_H
#define common_H

#include "cm_types.h"
#include "thplatform.h"

#ifdef __cplusplus
extern "C" {
#endif


//-----------------------------------------------------------------------------
//数学函数
//int RandomNum(int seed);//ok
//-----------------------------------------------------------------------------
//文件函数
//文件IO操作函数
#ifdef linux
//void GetFileCreateModifyTime(char* fName, time_t* CreateTime, time_t* ModifyTime);
#endif
//bool DiskExists(char* Path);
//bool GetDiskSpace(char* Path, DWORD* TotalSpace, DWORD* FreeSpace);
//char* FileExtName(char* FileName); //取得文件扩展名//'.txt'
//char* ExtractFileName(char* FileName);
//bool DirectoryExists(char* Directory);
//bool FileExists(char* FileName);
//int FileGetSize(char* FileName);
//bool FileDelete(char* FileName);
//HANDLE FileCreate(char* FileName);
//HANDLE FileOpen(char* FileName);
//bool FileClose(HANDLE f);
//int FileGetPos(HANDLE f);
//int FileSeek(HANDLE f, int Offset, int Origin); //Origin=0 1 2
//bool FileRead(HANDLE f, void* Buf, int Len);
//bool FileWrite(HANDLE f, void* Buf, int Len);
//-----------------------------------------------------------------------------
//时间函数
//void Time_tToSystemTime(int t, LPSYSTEMTIME pst);
//int SystemTimeToTime_t(LPSYSTEMTIME pst);
//int GetTime();
//Int64 getutime(); //取得微秒级时间 tv.tv_sec*1000000 + tv.tv_usec
#ifdef linux
//DWORD GetTickCount();
//TNetTime GetNetTime();
//TDateTime GetDateTime();
//TDateTime Now();
//TDateTime time_tToDateTime(time_t iTime);
//time_t DateTimeTotime_t(TDateTime dt);
#endif

extern bool IsExit;
//*****************************************************************************
void Reboot();
//*****************************************************************************
//网络相关函数
#define NET_TIMEOUT               5000  // ms
#define NET_CONNECT_TIMEOUT       3000  // ms

char* GetLocalIP();

int FastConnect(char* aIP, WORD aPort, DWORD TimeOut);//返回SocketHandle
bool SendBuf(int hSocket, char* Buf, int BufLen);
bool RecvBuf(int hSocket, char* RecvBuf, int BufLen);
bool WaitForData(int hSocket);//有问题
int ReceiveLength(int hSocket);

int IsLANIP(const char* IP);
int IPToInt(char* IP);
char* IntToIP(int IP);
int httpget1(const char* url, char* Buf, int* BufLen, int IsShowHead, unsigned int TimeOut);
int httpget(const char* url, char* Buf);

#ifdef __cplusplus
}
#endif

#endif
