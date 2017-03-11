//-----------------------------------------------------------------------------
// Author      : ��첨
// Date        : 2012.01.18
// Version     : V 1.00
// Description : 
//-----------------------------------------------------------------------------
#include "skt.h"

//***************************************************************************
//*************************************************************************** udp
//***************************************************************************
/* PS��״̬
D �޷��жϵ�����״̬��ͨ�� IO �Ľ��̣���
R �������п����ڶ����пɹ��еģ�
S ��������״̬��
T ֹͣ��׷�٣�
W �����ڴ潻�������ں�2.6��ʼ��Ч����
X �����Ľ��̣�����û��������
Z ��ʬ���̣�
< ���ȼ��ߵĽ���
N ���ȼ��ϵ͵Ľ���
L ��Щҳ�������ڴ棻
s ���̵��쵼�ߣ�����֮�����ӽ��̣���
l ����̵ģ�ʹ�� CLONE_THREAD, ���� NPTL pthreads����
+ λ�ں�̨�Ľ����飻
*/
#ifndef linux
// Linux Signal
/*
1.SIGHUP���ź����û��ն�����(�����������)����ʱ����,ͨ�������ն˵Ŀ��ƽ��̽���
ʱ,֪ͨͬһsession�ڵĸ�����ҵ,��ʱ����������ն˲��ٹ���.
2.SIGINT������ֹ(interrupt)�ź�,���û�����INTR�ַ�(ͨ����Ctrl-C)ʱ����
3.SIGQUIT��SIGINT����,����QUIT�ַ�(ͨ����Ctrl-)������.���������յ�SIGQUIT�˳�ʱ
�����core�ļ�,�����������������һ����������ź�.
4.SIGILLִ���˷Ƿ�ָ��.ͨ������Ϊ��ִ���ļ�������ִ���,������ͼִ�����ݶ�.��ջ
���ʱҲ�п��ܲ�������ź�.
5.SIGTRAP�ɶϵ�ָ�������trapָ�����.��debuggerʹ��.
6.SIGABRT�����Լ����ִ��󲢵���abortʱ����.
6.SIGIOT��PDP-11����iotָ�����,�����������Ϻ�SIGABRTһ��.
7.SIGBUS�Ƿ���ַ,�����ڴ��ַ����(alignment)����.eg:����һ���ĸ��ֳ�������,����
��ַ����4�ı���.
8.SIGFPE�ڷ��������������������ʱ����.�������������������,���������������Ϊ0
���������е������Ĵ���.
9.SIGKILL���������������������.���źŲ��ܱ�����,����ͺ���.
10.SIGUSR1�����û�ʹ��
11.SIGSEGV��ͼ����δ������Լ����ڴ�,����ͼ��û��дȨ�޵��ڴ��ַд����.
12.SIGUSR2�����û�ʹ��
13.SIGPIPE Broken pipe
14.SIGALRMʱ�Ӷ�ʱ�ź�,�������ʵ�ʵ�ʱ���ʱ��ʱ��.alarm����ʹ�ø��ź�.
15.SIGTERM�������(terminate)�ź�,��SIGKILL��ͬ���Ǹ��źſ��Ա�������
����.ͨ������Ҫ������Լ������˳�.shell����killȱʡ��������ź�.
17.SIGCHLD�ӽ��̽���ʱ,�����̻��յ�����ź�.
18.SIGCONT��һ��ֹͣ(stopped)�Ľ��̼���ִ��.���źŲ��ܱ�����.������һ�� handler
���ó�������stopped״̬��Ϊ����ִ��ʱ����ض��Ĺ���.����,������ʾ��ʾ��
19.SIGSTOPֹͣ(stopped)���̵�ִ��.ע������terminate�Լ�interrupt������:�ý��̻�
δ����,ֻ����ִͣ��.���źŲ��ܱ�����,��������.
20.SIGTSTPֹͣ���̵�����,�����źſ��Ա�����ͺ���.�û�����SUSP�ַ�ʱ(ͨ����Ctrl-Z)
��������ź�
21.SIGTTIN����̨��ҵҪ���û��ն˶�����ʱ,����ҵ�е����н��̻��յ�SIGTTIN�ź�.ȱ
ʡʱ��Щ���̻�ִֹͣ��.
22.SIGTTOU������SIGTTIN,����д�ն�(���޸��ն�ģʽ)ʱ�յ�.
23.SIGURG�н������ݻ�out-of-band���ݵ���socketʱ����.
24.SIGXCPU����CPUʱ����Դ����.������ƿ�����getrlimit/setrlimit����ȡ/�ı�
25.SIGXFSZ�����ļ���С��Դ����.
26.SIGVTALRM����ʱ���ź�.������SIGALRM,���Ǽ�����Ǹý���ռ�õ�CPUʱ��.
27.SIGPROF������SIGALRM/SIGVTALRM,�������ý����õ�CPUʱ���Լ�ϵͳ���õ�ʱ��.
28.SIGWINCH���ڴ�С�ı�ʱ����.
29.SIGIO�ļ�������׼������,���Կ�ʼ��������/�������.
30.SIGPWR Power failure
*/
#define SIGHUP		 1
#define SIGINT		 2
#define SIGQUIT		 3
#define SIGILL		 4
#define SIGTRAP		 5
#define SIGABRT		 6
//#define SIGIOT		 6
//#define SIGBUS		 7
#define SIGFPE		 8
#define SIGKILL		 9
//#define SIGUSR1		10
#define SIGSEGV		11
//#define SIGUSR2		12
#define SIGPIPE		13
#define SIGALRM		14
#define SIGTERM		15
#define SIGSTKFLT	16
//#define SIGCHLD		17
//#define SIGCONT		18
//#define SIGSTOP		19
//#define SIGTSTP		20
#define SIGTTIN		21
#define SIGTTOU		22
//#define SIGURG		23
#define SIGXCPU		24
#define SIGXFSZ		25
#define SIGVTALRM	26
#define SIGPROF		27
#define SIGWINCH	28
//#define SIGIO		  29
#define SIGPOLL		SIGIO
/*
#define SIGLOST		29
*/
#define SIGPWR		30
//#define SIGSYS		31
#define	SIGUNUSED	31

/* These should not be considered constants from userland.  */
#define SIGRTMIN	32
#define SIGRTMAX	_NSIG

#define SIGSWI		32

//Linux Error Code
#define  EPERM              1  //Operation not permitted
#define  ENOENT             2  //No such file or directory
#define  ESRCH              3  //No such process
#define  EINTR              4  //Interrupted system call
#define  EIO                5  //I/O error
#define  ENXIO              6  //No such device or address
#define  E2BIG              7  //Argument list too long
#define  ENOEXEC            8  //Exec format error
#define  EBADF              9  //Bad file number
#define  ECHILD            10  //No child processes
//#define  EAGAIN            11  //Try again
#define  ENOMEM            12  //Out of memory
#define  EACCES            13  //Permission denied
#define  EFAULT            14  //Bad address
#define  ENOTBLK           15  //Block device required
#define  EBUSY             16  //Device or resource busy
#define  EEXIST            17  //File exists
#define  EXDEV             18  //Cross-device link
#define  ENODEV            19  //No such device
#define  ENOTDIR           20  //Not a directory
#define  EISDIR            21  //Is a directory
#define  EINVAL            22  //Invalid argument
#define  ENFILE            23  //File table overflow
#define  EMFILE            24  //Too many open files
#define  ENOTTY            25  //Not a typewriter
#define  ETXTBSY           26  //Text file busy
#define  EFBIG             27  //File too large
#define  ENOSPC            28  //No space left on device
#define  ESPIPE            29  //Illegal seek
#define  EROFS             30  //Read-only file system
#define  EMLINK            31  //Too many links
#define  EPIPE             32  //Broken pipe
#define  EDOM              33  //Math argument out of domain of func
#define  ERANGE            34  //Math result not representable
//#define  EDEADLK           35  //Resource deadlock would occur
//#define  ENAMETOOLONG      36  //File name too long
//#define  ENOLCK            37  //No record locks available
//#define  ENOSYS            38  //Function not implemented
//#define  ENOTEMPTY         39  //Directory not empty
//#define  ELOOP             40  //Too many symbolic links encountered
#define  EWOULDBLOCK   EAGAIN  //Operation would block
//#define  ENOMSG            42  //No message of desired type
//#define  EIDRM             43  //Identifier removed
#define  ECHRNG            44  //Channel number out of range
#define  EL2NSYNC          45  //Level 2 not synchronized
#define  EL3HLT            46  //Level 3 halted
#define  EL3RST            47  //Level 3 reset
#define  ELNRNG            48  //Link number out of range
#define  EUNATCH           49  //Protocol driver not attached
#define  ENOCSI            50  //No CSI structure available
#define  EL2HLT            51  //Level 2 halted
#define  EBADE             52  //Invalid exchange
#define  EBADR             53  //Invalid request descriptor
#define  EXFULL            54  //Exchange full
#define  ENOANO            55  //No anode
#define  EBADRQC           56  //Invalid request code
#define  EBADSLT           57  //Invalid slot
#define  EDEADLOCK    EDEADLK
#define  EBFONT            59  //Bad font file format
//#define  ENOSTR            60  //Device not a stream
//#define  ENODATA           61  //No data available
//#define  ETIME             62  //Timer expired
//#define  ENOSR             63  //Out of streams resources
#define  ENONET            64  //Machine is not on the network
#define  ENOPKG            65  //Package not installed
//#define  EREMOTE           66  //Object is remote
//#define  ENOLINK           67  //Link has been severed
#define  EADV              68  //Advertise error
#define  ESRMNT            69  //Srmount error
#define  ECOMM             70  //Communication error on send
//#define  EPROTO            71  //Protocol error
//#define  EMULTIHOP         72  //Multihop attempted
#define  EDOTDOT           73  //RFS specific error
//#define  EBADMSG           74  //Not a data message
//#define  EOVERFLOW         75  //Value too large for defined data type
#define  ENOTUNIQ          76  //Name not unique on network
#define  EBADFD            77  //File descriptor in bad state
#define  EREMCHG           78  //Remote address changed
#define  ELIBACC           79  //Can not access a needed shared library
#define  ELIBBAD           80  //Accessing a corrupted shared library
#define  ELIBSCN           81  //.lib section in a.out corrupted
#define  ELIBMAX           82  //Attempting to link in too many shared libraries
#define  ELIBEXEC          83  //Cannot exec a shared library directly
//#define  EILSEQ            84  //Illegal byte sequence
#define  ERESTART          85  //Interrupted system call should be restarted
#define  ESTRPIPE          86  //Streams pipe error
//#define  EUSERS            87  //Too many users
//#define  ENOTSOCK          88  //Socket operation on non-socket
//#define  EDESTADDRREQ      89  //Destination address required
//#define  EMSGSIZE          90  //Message too long
//#define  EPROTOTYPE        91  //Protocol wrong type for socket
//#define  ENOPROTOOPT       92  //Protocol not available
//#define  EPROTONOSUPPORT   93  //Protocol not supported
//#define  ESOCKTNOSUPPORT   94  //Socket type not supported
//#define  EOPNOTSUPP        95  //Operation not supported on transport endpoint
//#define  EPFNOSUPPORT      96  //Protocol family not supported
//#define  EAFNOSUPPORT      97  //Address family not supported by protocol
//#define  EADDRINUSE        98  //Address already in use
//#define  EADDRNOTAVAIL     99  //Cannot assign requested address
//#define  ENETDOWN         100  //Network is down
//#define  ENETUNREACH      101  //Network is unreachable
//#define  ENETRESET        102  //Network dropped connection because of reset
//#define  ECONNABORTED     103  //Software caused connection abort
//#define  ECONNRESET       104  //Connection reset by peer
//#define  ENOBUFS          105  //No buffer space available
//#define  EISCONN          106  //Transport endpoint is already connected
//#define  ENOTCONN         107  //Transport endpoint is not connected
//#define  ESHUTDOWN        108  //Cannot send after transport endpoint shutdown
//#define  ETOOMANYREFS     109  //Too many references: cannot splice
//#define  ETIMEDOUT        110  //Connection timed out
//#define  ECONNREFUSED     111  //Connection refused
//#define  EHOSTDOWN        112  //Host is down
//#define  EHOSTUNREACH     113  //No route to host
//#define  EALREADY         114  //Operation already in progress
//#define  EINPROGRESS      115  //Operation now in progress
//#define  ESTALE           116  //Stale NFS file handle
#define  EUCLEAN          117  //Structure needs cleaning
#define  ENOTNAM          118  //Not a XENIX named type file
#define  ENAVAIL          119  //No XENIX semaphores available
#define  EISNAM           120  //Is a named type file
#define  EREMOTEIO        121  //Remote I/O error
//#define  EDQUOT           122  //Quota exceeded
#define  ENOMEDIUM        123  //No medium found
#define  EMEDIUMTYPE      124  //Wrong medium type

#endif

//*****************************************************************************
//***************************************************************************** tcp server
//*****************************************************************************
bool IsExit;



void Signal_proc(int sig)
{
  printf("SIGNAL:%d \n", sig);
  switch (sig)
  {
  case SIGPIPE:
    break;

  case SIGIO:
    break;

  case SIGSEGV:
    Reboot();//    exit(0);
    break;
  }
  return;
}
//-----------------------------------------------------------------------------
void th_SSkt(TSSktParam* Param)
{
  fd_set Newfdset;
  int Ret, i, AddrLen, opt;
  struct sockaddr_in SvrAddr, CltAddr;
  int CSktHandle;
  socklen_t optsize;
  char* tmpIP;

  signal(SIGPIPE, Signal_proc);
  signal(SIGSEGV, Signal_proc);

  AddrLen = sizeof(struct sockaddr_in);
  memset(&SvrAddr, 0, AddrLen);
  SvrAddr.sin_family = AF_INET;
  SvrAddr.sin_addr.s_addr = htonl(INADDR_ANY);
  SvrAddr.sin_port = htons(Param->LocalPort);
  Param->SocketHandle = socket(SvrAddr.sin_family, SOCK_STREAM, 0);
  fcntl(Param->SocketHandle, F_SETFD, 1);

  optsize = sizeof(int);
  opt = 1;
  setsockopt(Param->SocketHandle, SOL_SOCKET, SO_REUSEADDR, &opt, optsize);

  bind(Param->SocketHandle, (struct sockaddr*) &SvrAddr, AddrLen);
  listen(Param->SocketHandle, 1024);
  FD_ZERO(&Param->fdset);
  FD_SET(Param->SocketHandle, &Param->fdset);
  int fd_max = Param->SocketHandle;

  for (;;)
  {
    if (IsExit) break;

    Newfdset = Param->fdset;
    select(fd_max + 1, &Newfdset, NULL, NULL, NULL);
    if (FD_ISSET(Param->SocketHandle, &Newfdset))
    {
      CSktHandle = accept(Param->SocketHandle, (struct sockaddr*)&CltAddr, (socklen_t*)&AddrLen);

      TSktConnPkt* PPkt = (TSktConnPkt*)malloc(sizeof(TSktConnPkt));
      memset(PPkt, 0, sizeof(TSktConnPkt));
      PPkt->SktHandle = CSktHandle;
      memcpy(&PPkt->CltAddr, &CltAddr, AddrLen);
      lst_Add(Param->SktConnLst, PPkt);
      if (Param->OnConnectEvent) Param->OnConnectEvent(PPkt);//�����¼�
      FD_SET(CSktHandle, &Param->fdset);
      optsize = sizeof(int);
      fcntl(CSktHandle, F_SETFL, O_NONBLOCK);//��������ʽ
      tmpIP = inet_ntoa(PPkt->CltAddr.sin_addr);
      if (IsLANIP(tmpIP))//modify at 2010/08/21 ������������
      {
        opt =1024*1024*1;// 1024*1024*4;//real max: 131070  minsend 2048 maxrecv 256
        setsockopt(CSktHandle, SOL_SOCKET, SO_SNDBUF, &opt, optsize);
        setsockopt(CSktHandle, SOL_SOCKET, SO_RCVBUF, &opt, optsize);
        //opt = 1;
        //Ret = setsockopt(CSktHandle, IPPROTO_TCP, TCP_NODELAY, &opt, optsize);
//#warning " 1024*1024*1 SO_SNDBUF disable TCP_NODELAY 11 "
        //printf(" 1024*1024*1 SO_SNDBUF disable TCP_NODELAY \n");
      }

      if (fd_max < CSktHandle) fd_max = CSktHandle;
    }//end if (FD_ISSET(SSktHandle, &Newfdset))

    for (i = Param->SocketHandle + 1; i <= fd_max; i++)
    {
      if (!FD_ISSET(i, &Newfdset)) continue;

      ioctl(i, FIONREAD, &Ret);
      if (Ret == 0)
      {
        CSktHandle = i;
        TSktConnPkt* PPkt = IndexOfSktHandle(Param->SktConnLst, CSktHandle);
        if (PPkt)
        {
          if (Param->OnDisConnEvent) Param->OnDisConnEvent(PPkt);//�Ͽ������¼�
          PPkt->SktHandle = NULLHANDLE;
          lst_Remove(Param->SktConnLst, PPkt);
          free(PPkt);

          close(CSktHandle);
          FD_CLR(CSktHandle, &Param->fdset);
        }
      }//end (Ret==0)
      else
      {
        CSktHandle = i;
        TSktConnPkt* PPkt = IndexOfSktHandle(Param->SktConnLst, CSktHandle);
        if (PPkt)
        {
          if (Param->OnRecvEvent) Param->OnRecvEvent(PPkt);//��ȡ�����¼�
        }
      }//end if (Ret == 0)
    }//end for (i = SSktHandle + 1; i <= fd_max; i++)
  }//end for (;;)
  close(Param->SocketHandle);
  close(Param->tHandle);
}
//-----------------------------------------------------------------------------
bool sskt_Init(TSSktParam* Param)
{
  if (!Param) return false;
  pthread_create(&Param->tHandle, NULL, (void *(*)(void*))th_SSkt, Param);
  pthread_detach(Param->tHandle);
  return true;
}
//-----------------------------------------------------------------------------
bool sskt_Free(TSSktParam* Param)
{
  if (!Param) return false;
  //pthread_join(Param->tHandle, NULL);
  //close(Param->tHandle);
  //Param->tHandle = 0;
  shutdown(Param->SocketHandle, 2);
  close(Param->SocketHandle);
  Param->SocketHandle = 0;
  memset(Param, 0, sizeof(TSSktParam));
  return true;
}
//-----------------------------------------------------------------------------
TSktConnPkt* IndexOfSktHandle(TList* lst, int SocketHandle)
{
  TSktConnPkt* Result = NULL;
  TSktConnPkt* tmp;
  int i;
  for (i=0; i<lst_Count(lst); i++)
  {
    tmp = (TSktConnPkt*)lst_Items(lst, i);
    if (tmp->SktHandle == SocketHandle)
    {
      Result = tmp;//(TSktConnPkt*)lst_Items(lst, i);
      break;
    }
  }
  return Result;
}
//-----------------------------------------------------------------------------
void th_udp(TudpParam* Param)
{
  char RecvBuf[1024*64];
  int RecvSize;
  fd_set fd_read;
  int ret;

  struct timeval tv;
  tv.tv_sec = 1;
  tv.tv_usec = 0;

  if (!Param) return;

  while (true)
  {
    if (IsExit) break;

    FD_ZERO(&fd_read);
    FD_SET(Param->SocketHandle, &fd_read);
    ret = select(Param->SocketHandle + 1, &fd_read, NULL, NULL, &tv);
    //1
    if (ret < 0)
    {
      if (errno == EINTR )
      {
        usleep(10*1000);
        continue;
      }
      else break;
    }
    //2
    if (ret == 0)
    {
      usleep(10*1000);
      continue;
    }
    //3
    if (ret > 0)
    {
      if (FD_ISSET(Param->SocketHandle, &fd_read))
      {
        int AddrLen = sizeof(Param->FromAddr);
        RecvSize = recvfrom(Param->SocketHandle, RecvBuf, sizeof(RecvBuf), 0,
          (struct sockaddr*)&Param->FromAddr,(socklen_t*)&AddrLen);
        //3.1
        if (RecvSize < 0)
        {
          if ( errno == EINTR)
          {
            usleep(10*1000);
            continue;
          }
          else break;
        }
        //3.2
        if (RecvSize == 0)
        {
          usleep(10*1000);
          continue;
        }
        //3.3
        if (RecvSize > 0)
        {
          if (Param->OnRecvEvent)
          {
            Param->OnRecvEvent(RecvBuf, RecvSize);
          }
        }
      }
    }
  }
}
//-----------------------------------------------------------------------------
bool udp_Init(TudpParam* Param)
{
  struct sockaddr_in SvrAddr;
  int flag, ret;
  struct timeval lvtimeout;
  struct ip_mreq mcast;

  Param->SocketHandle = socket(AF_INET, SOCK_DGRAM, 0);
  if (Param->SocketHandle <= 0) return false;
  memset(&SvrAddr,0,sizeof(struct sockaddr_in));
  SvrAddr.sin_family = AF_INET;
  SvrAddr.sin_port = htons(Param->Port);
  SvrAddr.sin_addr.s_addr = htonl(INADDR_ANY);
  ret = bind(Param->SocketHandle, (struct sockaddr*)&SvrAddr, sizeof(SvrAddr));
  if (ret != 0)
  {
    udp_Free(Param);
    return false;
  }
//#warning " yyyyyyyyyyyyyyyyyy "
  //���ö���̿��Թ����ַ
  flag = 1;
  setsockopt(Param->SocketHandle, SOL_SOCKET, SO_REUSEADDR, &flag, sizeof(flag));
  if (ret != 0)
  {
    udp_Free(Param);
    return false;
  }
  //struct in_addr addr;
  //setsockopt(Param->SocketHandle, IPPROTO_IP, IP_MULTICAST_IF, &addr,sizeof(addr));

  lvtimeout.tv_usec = 0;
  lvtimeout.tv_sec = 1;
  setsockopt(Param->SocketHandle,SOL_SOCKET,SO_RCVTIMEO,&lvtimeout,sizeof(lvtimeout));

  if (Param->IsMulticast)
  {
    //�������淶Χ
    setsockopt(Param->SocketHandle,IPPROTO_IP,IP_MULTICAST_TTL,(char*)&Param->TTL,sizeof(int));
    //�����Ƿ����
    flag = 1;
    setsockopt(Param->SocketHandle, IPPROTO_IP, IP_MULTICAST_LOOP, &flag, sizeof(flag));
    //������
    memset(&mcast,0,sizeof(mcast));
    //inet_aton(Param->LocalIP,&mcast.imr_interface);
    inet_aton("0.0.0.0", &mcast.imr_interface);
//#warning "0.0.0.00.0.0.00.0.0.00.0.0.00.0.0.0"
    inet_aton(Param->MultiIP, &mcast.imr_multiaddr);
    ret = setsockopt(Param->SocketHandle, IPPROTO_IP,IP_ADD_MEMBERSHIP,&mcast,sizeof(mcast));
    printf("********** IP_ADD_MEMBERSHIP ret:%d \n", ret);
    if (ret != 0)
    {
      udp_Free(Param);
      return false;
    }

    //�˳���
    //setsockopt(SocketHandle,IPPROTO_IP,IP_DROP_MEMBERSHIP,&mcast,sizeof(mcast));//LeaveGroup
  }
  pthread_create(&Param->tHandle, NULL, (void*(*)(void*))th_udp, Param);  
  pthread_detach(Param->tHandle);
  return true;
}
//-----------------------------------------------------------------------------
bool udp_Free(TudpParam* Param)
{
  if (!Param) return false;
  //pthread_join(Param->tHandle, NULL);
  //close(Param->tHandle);
  //Param->tHandle = 0;
  shutdown(Param->SocketHandle, 2);
  close(Param->SocketHandle);
  Param->SocketHandle = 0;
  memset(Param, 0, sizeof(TudpParam));
  return true;
}
//-----------------------------------------------------------------------------
