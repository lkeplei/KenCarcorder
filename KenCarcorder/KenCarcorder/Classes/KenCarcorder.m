//
//  KenUtility.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenUtility.h"

#include <arpa/inet.h>
#include <netdb.h>

#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface KenCarcorder ()

@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;

@end

@implementation KenCarcorder
static KenCarcorder *_sharedUtility = nil;

+ (KenCarcorder *)shareCarcorder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtility = [[KenCarcorder alloc] init];
        [_sharedUtility initData];
    });
    return _sharedUtility;
}


- (void)initData {
    //创建缓存目录
    [KenCarcorder createFolderAtPath:[self getAlarmFolder]];
    [KenCarcorder createFolderAtPath:[self getHomeSnapFolder]];
    [KenCarcorder createFolderAtPath:[self getMarketFolder]];
    [KenCarcorder createFolderAtPath:[self getRecorderFolder]];
}

#pragma mark - static method
+ (unsigned long long)getFileSize:(NSString*)filePath {
    unsigned long long fileSize = 0;
#if 1
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
#else
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        fileSize = st.st_size;
    }
#endif
    return fileSize;
}

+ (unsigned long long)getFolderSize:(NSString*)folderPath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    unsigned long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self getFileSize:fileAbsolutePath];
    }
    return folderSize;
}

+ (BOOL)deleteFileWithPath:(NSString*)path {
    if (path) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        return [fileManager removeItemAtPath:path error:nil];
    }
    
    return NO;
}

+ (BOOL)fileExistsAtPath:(NSString*)path {
    if (path) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        return [fileManager fileExistsAtPath:path];
    }
    
    return NO;
}

+ (BOOL)createFolderAtPath:(NSString *)path {
    if ([NSString isNotEmpty:path]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = YES;
        if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
            return NO;
        } else {
            return [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return NO;
}

#pragma mark - 文件目录
- (NSString *)getAlarmFolder {
    return [NSString stringWithFormat:@"%@/Documents/Alarm", NSHomeDirectory()];
}

- (NSString *)getHomeSnapFolder {
    return [NSString stringWithFormat:@"%@/Documents/Home", NSHomeDirectory()];
}

- (NSString *)getMarketFolder {
    return [NSString stringWithFormat:@"%@/Documents/Market", NSHomeDirectory()];
}

- (NSString *)getRecorderFolder {
    return [NSString stringWithFormat:@"%@/Documents/Recorder", NSHomeDirectory()];
}

- (void)deleteCachFolder {
    [KenCarcorder deleteFileWithPath:[NSString stringWithFormat:@"%@/Documents/images/",NSHomeDirectory()]];
    [KenCarcorder deleteFileWithPath:[NSString stringWithFormat:@"%@/Documents/thumbnails/",NSHomeDirectory()]];
    [KenCarcorder deleteFileWithPath:[self getAlarmFolder]];
    [KenCarcorder deleteFileWithPath:[self getRecorderFolder]];
    [KenCarcorder deleteFileWithPath:[self getMarketFolder]];
    [KenCarcorder deleteFileWithPath:[self getHomeSnapFolder]];
}

- (long long)getCachFolderSize {
    long long size = [KenCarcorder getFolderSize:[NSString stringWithFormat:@"%@/Documents/images/",NSHomeDirectory()]];
    size += [KenCarcorder getFolderSize:[NSString stringWithFormat:@"%@/Documents/thumbnails/",NSHomeDirectory()]];
    size += [KenCarcorder getFolderSize: [self getAlarmFolder]];
    size += [KenCarcorder getFolderSize:[self getRecorderFolder]];
    size += [KenCarcorder getFolderSize:[self getMarketFolder]];
    size += [KenCarcorder getFolderSize:[self getHomeSnapFolder]];
    return size;
}

+ (NSString *)getCurrentSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}

+ (BOOL)validateIPCAM:(NSString *)ssid {
    NSString *regex = @"^IPCAM_AP_8[0-9][0-9][0-9][0-9][0-9][0-9][0-9]$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:ssid];
}

+ (NSString *)localIPAddress {
    char baseHostName[256]; // Thanks, Gunnar Larisch
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '/0';
    
    NSString *hostName = @"";
#if TARGET_IPHONE_SIMULATOR
    hostName = [NSString stringWithFormat:@"%s", baseHostName];
#else
    hostName = [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
    
    struct hostent *host = gethostbyname([hostName UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

+ (void)setOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)playVoiceByType:(KenVoiceType)type {
    NSString *string = [[NSBundle mainBundle] pathForResource:@"cap_voice" ofType:@"mp3"];
    if (type == kKenVoiceCapture) {
        string = [[NSBundle mainBundle] pathForResource:@"cap_voice" ofType:@"mp3"];
    }
    //把音频文件转换成url格式
    NSURL *url = [NSURL fileURLWithPath:string];
    //初始化音频类 并且添加播放文件
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //设置音乐播放次数  -1为一直循环
    _avAudioPlayer.numberOfLoops = 0;
    //预播放
    [_avAudioPlayer prepareToPlay];
    [_avAudioPlayer play];
}
@end
