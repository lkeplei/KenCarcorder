//
//  KenFileManager.m
//  achr
//
//  Created by Ken.Liu on 16/5/13.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenFileManager.h"

@implementation KenFileManager

+ (NSString *)fullDocumentFileName:(NSString *)shortFileName {
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *file = [documentDirectory stringByAppendingPathComponent:shortFileName];
    return file;
}

+ (BOOL)isFileExists:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *file = [self fullDocumentFileName:fileName];
    return [fileManager fileExistsAtPath:file];
}

+ (void)createFile:(NSString *)fileName overwrite:(BOOL)shouldOverwrite {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //create file directory, include multilayer directory
    NSRange lastTag = [fileName rangeOfString:@"/" options:NSBackwardsSearch];
    if (lastTag.location != NSNotFound && lastTag.location != 0) {
        NSString *shortDir = [fileName substringToIndex:lastTag.location];
        NSString *fullDir = [self fullDocumentFileName:shortDir];
        if (![fileManager fileExistsAtPath:fullDir]) {
            [fileManager createDirectoryAtPath:fullDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    NSString *file = [self fullDocumentFileName:fileName];
    
    //file not exists or want to overwrite it
    if (shouldOverwrite || ![fileManager fileExistsAtPath:file]) {
        [fileManager createFileAtPath:file contents:nil attributes:nil];
    }
}

+ (void)removeFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *file = [self fullDocumentFileName:fileName];
    [fileManager removeItemAtPath:file error:nil];
}

+ (void)writeFile:(NSString *)fileName contents:(NSData *)contents append:(BOOL)shouldAppend {
    if (![self isFileExists:fileName] || !shouldAppend) {
        [self createFile:fileName overwrite:YES];
    }
    NSString *fullName = [self fullDocumentFileName:fileName];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fullName];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:contents];
    [fileHandle closeFile];
}

@end
