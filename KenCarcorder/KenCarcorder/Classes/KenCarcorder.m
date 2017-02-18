//
//  KenUtility.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenUtility.h"

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

@end