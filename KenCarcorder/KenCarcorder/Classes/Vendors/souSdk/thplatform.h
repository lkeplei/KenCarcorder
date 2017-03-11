#ifndef thplatform
#define thplatform 

#include <string.h>
#include "cm_types.h"


//-----------------------------------------------------------------------------
//数学函数
int RandomNum(int seed);//ok
//-----------------------------------------------------------------------------
//文件函数
//文件IO操作函数
#ifndef WIN32
void GetFileCreateModifyTime(char* fName, time_t* CreateTime, time_t* ModifyTime);
#endif
bool DiskExists(char* Path);
bool GetDiskSpace(char* Path, DWORD* TotalSpace, DWORD* FreeSpace);
char* FileExtName(char* FileName); //取得文件扩展名//'.txt'
char* ExtractFileName(char* FileName);
bool DirectoryExists(char* Directory);
bool FileExists(char* FileName);
int FileGetSize(char* FileName);
bool FileDelete(char* FileName);
HANDLE FileCreate(char* FileName);
HANDLE FileOpen(char* FileName);
bool FileClose(HANDLE f);
int FileGetPos(HANDLE f);
int FileSeek(HANDLE f, int Offset, int Origin); //Origin=0 1 2
bool FileRead(HANDLE f, void* Buf, int Len);
bool FileWrite(HANDLE f, void* Buf, int Len);
//-----------------------------------------------------------------------------
//时间函数
void Time_tToSystemTime(int t, LPSYSTEMTIME pst);
int SystemTimeToTime_t(LPSYSTEMTIME pst);
int GetTime();
Int64 getutime(); //取得微秒级时间 tv.tv_sec*1000000 + tv.tv_usec
#ifndef WIN32
DWORD GetTickCount();
TNetTime GetNetTime();
TDateTime GetDateTime();
TDateTime Now();
TDateTime time_tToDateTime(time_t iTime);
time_t DateTimeTotime_t(TDateTime dt);
#endif

//-----------------------------------------------------------------------------
//#ifdef __cplusplus
//}
//#endif

#endif

