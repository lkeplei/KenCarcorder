#include "thplatform.h"

//-----------------------------------------------------------------------------
int RandomNum(int seed)
{
  int RandSeed;
#ifndef WIN32
  struct timeval tv;
  gettimeofday(&tv, NULL);
  RandSeed = tv.tv_sec + tv.tv_usec;
  srandom(RandSeed);   //srandom(time(NULL));
  return random() % seed;
#else
//  RandSeed = GetTickCount();
  srand(RandSeed);
  return rand() % seed;
#endif
}
//-----------------------------------------------------------------------------
#ifndef WIN32
void GetFileCreateModifyTime(char* fName, time_t* CreateTime, time_t* ModifyTime)
{
  *CreateTime = 0;
  *ModifyTime = 0;
  struct stat s;
  if (stat(fName, &s) == -1) return;
  *CreateTime = s.st_atime;//如果是ext2 ext3分区格式两个时间是一样的
  *ModifyTime = s.st_mtime;
}
#endif
//-----------------------------------------------------------------------------
bool DiskExists(char* Path)
{
  DWORD TotalSpace = 0;
  DWORD FreeSpace = 0;
  GetDiskSpace(Path, &TotalSpace, &FreeSpace);
  return (TotalSpace > 0);
}
//-----------------------------------------------------------------------------
bool GetDiskSpace(char* Path, DWORD* TotalSpace, DWORD* FreeSpace)
{
#ifndef WIN32
//  struct statfs stat;
//  *FreeSpace = 0;
//  *TotalSpace = 0;
//  int Ret = statfs(Path, &stat);
//  if (Ret ==0)
//  {
//    *FreeSpace  = (DWORD)((DWORD)(stat.f_bsize/1024) * (DWORD)(stat.f_bfree/1024));
//    *TotalSpace = (DWORD)((DWORD)(stat.f_bsize/1024) * (DWORD)(stat.f_blocks/1024));
//  }
  //printf(" filetype 0x%x \n", stat.f_type);
  return -1;
#else
#ifdef _MSC_VER
  unsigned __int64 iTotalFree, iTotalSpace;
  bool ret;
  *TotalSpace = 0;
  *FreeSpace  = 0;
  ret = GetDiskSpace(Path, &iTotalFree, &iTotalSpace, NULL);
  if (ret)
  {
    *FreeSpace = iTotalFree    / 1024;
    *TotalSpace  = iTotalSpace / 1024;
  }
  return ret;
#endif
#endif
}

//-----------------------------------------------------------------------------
char* FileExtName(char* FileName)//'.txt'
{
    char* Ext = NULL;
    int i;
    size_t m;
    m = strlen(FileName);
    for (i = (int)(m - 1); i >= 0; i--)
    {
        if (FileName[i] != '.') continue;
        if (i < m - 1) Ext = &FileName[i];
        break;
    }
    return Ext;
}

//-----------------------------------------------------------------------------
char* ExtractFileName(char* FileName)
{
    char* Ext = FileName;
    int i;
    size_t m;
    m = strlen(FileName);
    for (i = (int)(m - 1); i >= 0; i--)
    {
        if ((FileName[i] != '/')&&(FileName[i] != '\\')) continue;
        if (i < m - 1) Ext = &FileName[i+1];
        break;
    }
    return Ext;
}

//-----------------------------------------------------------------------------
bool DirectoryExists(char* Directory)
{
#ifndef WIN32
    struct stat st;
  if(stat(Directory, &st) ==  - 1)
    return false;
  else
    return S_ISDIR(st.st_mode);
#else
  int Code;
  Code = GetFileAttributes(Directory);
  return ((Code != -1) && ((FILE_ATTRIBUTE_DIRECTORY & Code) != 0));
#endif
}

//-----------------------------------------------------------------------------
bool FileExists(char* FileName)
{
#ifndef WIN32
  struct stat st;
  return (stat(FileName, &st) != -1);
#else
  WIN32_FIND_DATAA FindData;
  HANDLE Handle = FindFirstFile(FileName, &FindData);
  if (Handle == INVALID_HANDLE_VALUE) return false;
  FindClose(Handle);
  return true;
#endif
}
//-----------------------------------------------------------------------------
int FileGetSize(char* FileName)
{
#ifndef WIN32
  struct stat statbuf;
  int i = stat(FileName, &statbuf);
  if(i<0) return 0;
  S_ISDIR(statbuf.st_mode);
  S_ISREG(statbuf.st_mode);
  return statbuf.st_size;
#else
  WIN32_FIND_DATAA FindData;
  HANDLE Handle = FindFirstFile(FileName, &FindData);
  if (Handle == INVALID_HANDLE_VALUE) return -1;
  FindClose(Handle);
  return FindData.nFileSizeLow;
#endif
}
//-----------------------------------------------------------------------------
HANDLE FileCreate(char* FileName)
{
#ifndef WIN32
  return fopen(FileName, "w+b");
#else
  return CreateFile(FileName, GENERIC_READ | GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
#endif
}
//-----------------------------------------------------------------------------
HANDLE FileOpen(char* FileName)
{
#ifndef WIN32
  return fopen(FileName, "r+");
#else
  return CreateFile(FileName, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
#endif
}
//-----------------------------------------------------------------------------
bool FileClose(HANDLE f)
{
#ifndef WIN32
  return (fclose(f) == 0);
#else
  return CloseHandle(f);
#endif
}
//-----------------------------------------------------------------------------
bool FileWrite(HANDLE f, void* Buf, int Len)
{
#ifndef WIN32
  return (fwrite(Buf, Len, 1, f) != 0);
#else
  int Result;
  WriteFile(f, Buf, Len, &Result, NULL);
  return (Result == Len);
#endif
}
//-----------------------------------------------------------------------------
bool FileRead(HANDLE f, void* Buf, int Len)
{
#ifndef WIN32
  return (fread(Buf, Len, 1, f) != 0);
#else
  int Result;
  ReadFile(f, Buf, Len, &Result, NULL);
  return (Result == Len);
#endif
}
//-----------------------------------------------------------------------------
int FileSeek(HANDLE f, int Offset, int Origin)
{
#ifndef WIN32
  fpos_t pos;  //memset(&pos, 0, sizeof(pos));
  if (fseek(f, Offset, Origin) == 0)
  {
    fgetpos(f, &pos);
    return -1;
  }
  else
    return -1;
#else
  return SetFilePointer(f, Offset, NULL, Origin);
#endif
}
//-----------------------------------------------------------------------------
int FileGetPos(HANDLE f)
{
#ifndef WIN32
  fpos_t pos;
  memset(&pos, 0, sizeof(pos));
  fgetpos(f, &pos);
  return -1;
#else
  return FileSeek(f, 0, 1);
#endif
}
//-----------------------------------------------------------------------------
bool FileDelete(char* FileName)
{
#ifndef WIN32
  return (unlink(FileName) != -1);
#else
  return DeleteFile(FileName);
#endif
}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
void Time_tToSystemTime(int t, LPSYSTEMTIME pst)
{
#ifndef WIN32
  struct timeval tv;
  struct tm* m;
  gettimeofday(&tv, NULL);
  m = localtime(&tv.tv_sec);
  pst->wYear   = m->tm_year + 1900;
  pst->wMonth  = m->tm_mon + 1;
  pst->wDay    = m->tm_mday;
  pst->wHour   = m->tm_hour;
  pst->wMinute = m->tm_min;
  pst->wSecond = m->tm_sec;
  pst->wMilliseconds = tv.tv_usec / 1000;
  pst->wDayOfWeek =m->tm_wday;
  printf("pst->wYear:%d,pst->wMonth:%d,pst->wMilliseconds:%d, pst->wDayOfWeek:%d pst->wHour:%d\n",
    pst->wYear,pst->wMonth,pst->wMilliseconds, pst->wDayOfWeek, pst->wHour);
#else
  FILETIME ft; 
  LONGLONG ll = Int32x32To64(t, 10000000) + 116444736000000000;
  ft.dwLowDateTime = (DWORD) ll;
  ft.dwHighDateTime = (DWORD)(ll >> 32);
  FileTimeToSystemTime(&ft, pst);
#endif
}
//-----------------------------------------------------------------------------
int SystemTimeToTime_t(LPSYSTEMTIME pst)
{
#ifndef WIN32
  struct tm m;
  m.tm_year = pst->wYear - 1900;
  m.tm_mon = pst->wMonth -1;
  m.tm_mday = pst->wDay;
  m.tm_hour = pst->wHour;
  m.tm_min = pst->wMinute;
  m.tm_sec = pst->wSecond;
  m.tm_wday = pst->wDayOfWeek;
  return mktime(&m);
#else//#ifdef WIN32
  FILETIME ft;
  LONGLONG ll;
  ULARGE_INTEGER ui;
  SystemTimeToFileTime(pst, &ft );
  ui.LowPart = ft.dwLowDateTime;
  ui.HighPart = ft.dwHighDateTime;
  ll = (ft.dwHighDateTime << 32) + ft.dwLowDateTime;
  return (int)((LONGLONG)(ui.QuadPart - 116444736000000000) / 10000000);
#endif
}
//-----------------------------------------------------------------------------
int GetTime() //取得系统时间
{
#ifndef WIN32
  return time(NULL);
#else
  SYSTEMTIME st;
  GetLocalTime(&st);
  return SystemTimeToTime_t(&st);
#endif
}
//-----------------------------------------------------------------------------
Int64 getutime() //取得微秒级时间
{
#ifndef WIN32
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return (Int64)(tv.tv_sec)* 1000000+tv.tv_usec;
#else
  struct timeval tv;
  SYSTEMTIME st;
  GetLocalTime(&st);
  tv.tv_sec = SystemTimeToTime_t(&st);
  tv.tv_usec = st.wMilliseconds * 1000;
  return (Int64)(tv.tv_sec)* 1000000+tv.tv_usec;
#endif
}
//-----------------------------------------------------------------------------
#ifndef WIN32
//DWORD GetTickCount()
//{
//  static int t = 0;
//  struct timeval tv;
//  gettimeofday(&tv, NULL);
//  if (t == 0)
//  {
//#define FROM_PROC_UPTIME
//#ifdef FROM_PROC_UPTIME
//    char buf[40];
//    float a, b;
//    FILE* f = fopen("/proc/uptime", "r+");
//    if (f) 
//    {
//      fgets(buf, sizeof(buf), f);
//      fclose(f);
//      sscanf(buf, "%f %f", &a, &b);
//      t = tv.tv_sec - (int)a;
//    } 
//    else
//    {
//      t = tv.tv_sec;
//    }
//#else
//    t = tv.tv_sec;
//#endif
//  }
//  return (DWORD)(tv.tv_sec - t)*1000 + tv.tv_usec/1000;
//}
//-----------------------------------------------------------------------------
TNetTime GetNetTime()
{
  struct TNetTime nt;
  struct timeval tv;
  struct tm* m;
  gettimeofday(&tv, NULL);
  m = localtime(&tv.tv_sec);
  nt.Year = m->tm_year - 100;
  nt.Month = m->tm_mon + 1;
  nt.Day = m->tm_mday;
  nt.Hour = m->tm_hour;
  nt.Minute = m->tm_min;
  nt.Second = m->tm_sec;
  nt.MilliSecond = tv.tv_usec / 1000;
//  printf("GetNetTime:%3d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %0.3d\n", nt.Year,nt.Month,nt.Day,nt.Hour,nt.Minute,nt.Second,nt.MilliSecond);
  return nt;
}
//-----------------------------------------------------------------------------
TDateTime time_tToDateTime(time_t iTime)
{
  return (iTime / 86400.0 + 25569);
}
//-----------------------------------------------------------------------------
time_t DateTimeTotime_t(TDateTime dt)
{
  return (time_t)((dt - 25569.0) * 86400);
}
//-----------------------------------------------------------------------------
TDateTime GetDateTime()
{
  return Now();
}
//-----------------------------------------------------------------------------
TDateTime Now()
{
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return (TDateTime)(tv.tv_sec / 86400.0 + 25569.0 + tv.tv_usec /(86400.0 * 1000000));
}
#endif
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
/*
int main()
{
  SYSTEMTIME st;
  time_t t;
  t = GetTime();
  printf("gettime %d \n", t);
  Time_tToSystemTime(t, &st);
  t = SystemTimeToTime_t(&st);
  printf("gettime %d \n", t);

}
*/
//-----------------------------------------------------------------------------

