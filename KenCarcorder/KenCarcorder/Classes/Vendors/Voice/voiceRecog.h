
#ifdef VOICE_RECOG_DLL
#define VOICERECOGNIZEDLL_API __declspec(dllexport)
//#else
//#ifdef WIN32
//#define VOICERECOGNIZEDLL_API __declspec(dllimport)
#else
#define VOICERECOGNIZEDLL_API
//#endif
#endif


#ifndef VOICE_RECOG_H
#define VOICE_RECOG_H

#ifdef __cplusplus
extern "C" {
#endif
	enum VRErrorCode
	{
		VR_SUCCESS = 0, VR_NoSignal = -1, VR_ECCError = -2, VR_NotEnoughSignal = 100
		, VR_NotHeaderOrTail = 101, VR_RecogCountZero = 102
	};
    
	enum DecoderPriority
	{
		CPUUsePriority = 1//不占内存，但CPU消耗比较大一些
		, MemoryUsePriority = 2//不占CPU，但内存消耗大一些
	};
    
	typedef enum {vr_false = 0, vr_true = 1} vr_bool;
    
	typedef void (*vr_pRecognizerStartListener)(void *_listener, float _soundTime);
	//_result如果为VR_SUCCESS，则表示识别成功，否则为错误码，成功的话_data才有数据
	typedef void (*vr_pRecognizerEndListener)(void *_listener, float _soundTime, int _result, char *_data, int _dataLen);
    
	//创建声波识别器
	VOICERECOGNIZEDLL_API void *vr_createVoiceRecognizer(enum DecoderPriority _decoderPriority);
    
	//销毁识别器
	VOICERECOGNIZEDLL_API void vr_destroyVoiceRecognizer(void *_recognizer);
    
	//设置解码频率
	//总共需16+3个频率，依次为1个开始字符， 0-f的16进制字符，1个重复标志字符，1个结束字符
	//_freqs数组是静态的，整个解码过程中不能释放
	VOICERECOGNIZEDLL_API void vr_setRecognizeFreqs(void *_recognizer, int *_freqs, int _freqCount);
    
	//设置识别到信号的监听器
	VOICERECOGNIZEDLL_API void vr_setRecognizerListener(void *_recognizer, void *_listener, vr_pRecognizerStartListener _startListener, vr_pRecognizerEndListener _endListener);
    
	//开始识别
	//这里一般是线程，这个函数在停止识别之前不会返回
	VOICERECOGNIZEDLL_API void vr_runRecognizer(void *_recognizer);
    
	//暂停信号分析
	VOICERECOGNIZEDLL_API void vr_pauseRecognize(void *_recognizer, int _microSeconds);
    
	//停止识别，该函数调用后vr_runRecognizer会返回
	//该函数只是向识别线程发出退出信号，判断识别器是否真正已经退出要使用以下的vr_isRecognizerStopped函数
	VOICERECOGNIZEDLL_API void vr_stopRecognize(void *_recognizer);
    
	//判断识别器线程是否已经退出
	VOICERECOGNIZEDLL_API vr_bool vr_isRecognizerStopped(void *_recognizer);
    
	//要求输入数据要求为44100，单声道，16bits采样精度，小端编码的音频数据
	//小端编码不用特别处理，一般你录到的数据都是小端编码的
	VOICERECOGNIZEDLL_API int vr_writeData(void *_recognizer, char *_data, int _dataLen);
    
    
    
    
	//应用层解码接口
    
	int vr_decodeData(char *_hexs, int _hexsLen, int *_hexsCostLen, char *_result, int _resultLen);
	
	VOICERECOGNIZEDLL_API vr_bool vr_decodeString(int _recogStatus, char *_data, int _dataLen, char *_result, int _resultLen);
    
	//传输层中数据类型标志
	enum InfoType
	{
		IT_WIFI = 0//说明传输的数据为WiFi
		, IT_SSID_WIFI = 1//ssid编码的WIFI
		, IT_PHONE = 2//说明传输的数据为手机注册信息
		, IT_STRING = 3//任意字符串
	};
    
	VOICERECOGNIZEDLL_API enum InfoType vr_decodeInfoType(char *_data, int _dataLen);
    
	//wifi解码
	struct WiFiInfo
	{
		char mac[8];
		int macLen;
		char pwd[80];
		int pwdLen;
	};
    
	VOICERECOGNIZEDLL_API vr_bool vr_decodeWiFi(int _result, char *_data, int _dataLen, struct WiFiInfo *_wifi);
    
	struct SSIDWiFiInfo
	{
		char ssid[32];
		int ssidLen;
		char pwd[80];
		int pwdLen;
	};
    
	VOICERECOGNIZEDLL_API vr_bool vr_decodeSSIDWiFi(int _result, char *_data, int _dataLen, struct SSIDWiFiInfo *_wifi);
    
	struct PhoneInfo
	{
		char imei[18];
		int imeiLen;
		char phoneName[20];
		int nameLen;
	};
    
	VOICERECOGNIZEDLL_API vr_bool vr_decodePhone(int _result, char *_data, int _dataLen, struct PhoneInfo *_phone);
    
    
#ifdef __cplusplus
}
#endif

#endif


