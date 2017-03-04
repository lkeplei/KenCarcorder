

#ifdef VOICE_RECOG_DLL
#define VOICERECOGNIZEDLL_API __declspec(dllexport)
#else
#define VOICERECOGNIZEDLL_API
#endif

#ifndef VOICE_PLAY_H
#define VOICE_PLAY_H

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef void (*vp_pPlayerStartListener)(void *_listener);
    typedef void (*vp_pPlayerEndListener)(void *_listener);
    
    /************************************************************************/
    /* 创建编码端发送对象
     /************************************************************************/
    VOICERECOGNIZEDLL_API void * vp_createVoicePlayer();
    
    /************************************************************************/
    /* 发送端编码并发送数据
     /* 该函数以异步的形式工作，不阻塞主线程，判断是否发送完成由下面的vp_isStopped
     /* _data为任意数据，以十六进制的形式发送
     /* _dataLen为需发送的数据内容长度
     /************************************************************************/
    VOICERECOGNIZEDLL_API void vp_play(void *_player, char *_data, int _dataLen, int _playCount, int _muteInterval);
    
    //设置播放监听器
    VOICERECOGNIZEDLL_API void vp_setPlayerListener(void *_player, void *_listener, vp_pPlayerStartListener _startListener, vp_pPlayerEndListener _endListener);
    
    /************************************************************************/
    /* 设置声波发送端音量
     /* _volume为0-1之间的浮点数，0为无声，1为最大
     /************************************************************************/
    VOICERECOGNIZEDLL_API void vp_setVolume(void *_player, double _volume);
    
    /************************************************************************/
    /* 设置声波发送端频段
     /************************************************************************/
    VOICERECOGNIZEDLL_API void vp_setFreqs(void *_player, int *_freqs, int _freqCount);
    
    /************************************************************************/
    /* play函数以异步的方式播放并发送，在销毁对象之前需确保播放已经完成
     /************************************************************************/
    VOICERECOGNIZEDLL_API int vp_isStopped(void *_player);
    
    /************************************************************************/
    /* 销毁声波发送端对象
     /************************************************************************/
    VOICERECOGNIZEDLL_API void vp_destoryVoicePlayer(void *_player);
    
    
    
    
    
    //应用层发送方接口
    
    //返回4bit个数
    int vp_encodeData(char *_data, int _dataLen, char *_result);
    
    VOICERECOGNIZEDLL_API void vp_playString(void *_player, char *_str, int _playCount, int _muteInterval);
    
//    /************************************************************************/
//    /* 发送端编码并发送wifi信息，以mac,pwd的形式
//     /************************************************************************/
//    VOICERECOGNIZEDLL_API void vp_playWiFi(void *_player, char *_mac, int _macLen, char *_pwd, int _pwdLen, int _playCount, int _muteInterval);
//    
//    /************************************************************************/
//    /* 发送端编码并发送wifi信息，以ssid,pwd的形式
//     /************************************************************************/
//    VOICERECOGNIZEDLL_API void vp_playSSIDWiFi(void *_player, char *_ssid, int _ssidLen, char *_pwd, int _pwdLen, int _playCount, int _muteInterval);
//    
//    /************************************************************************/
//    /* 发送端编码并发送手机标志信息，（imei,手机名字）
//     /************************************************************************/
//    VOICERECOGNIZEDLL_API void vp_playPhone(void *_player, char *_imei, int _imeiLen, char *_phoneName, int _nameLen, int _playCount, int _muteInterval);
//    
    
#ifdef __cplusplus
}
#endif


#endif
