//
//  KenDataModel.m
//
//  Created by Ken.Liu on 16/1/14.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "KenDataModel.h"

#pragma mark - file
@interface NSString (dataFile)

+ (NSString *)documentFolder;
+ (NSString *)cachesFolder;
- (NSString *)createSubFolder:(NSString *)subFolder;

@end

@implementation NSString (ArcFile)

+ (NSString *)documentFolder{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cachesFolder{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)createSubFolder:(NSString *)subFolder{
    NSString *subFolderPath=[NSString stringWithFormat:@"%@/%@",self,subFolder];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return subFolderPath;
}

@end

#pragma mark - data model
@implementation KenDataModel
#pragma mark - 内部方法
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super JsonModelInitWithCoder:decoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [self JsonModelEncodeWithCoder:encoder];
}

+ (NSDictionary *)modelDefaultValuesMapper {
    return [self setDefaultValueMap];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return [self setCustomPropertyMap];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return [self setContainerPropertyClassMap];
}

+ (NSArray *)modelPropertyBlacklist {
    return [self setPropertyBlacklist];
}

+ (NSArray *)modelPropertyWhitelist {
    return [self setPropertyWhitelist];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    return [self handleCustomTransformFromDictionary:dic];
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    return [self handleCustomTransformToDictionary:dic];
}

#pragma mark - 外部接口
+ (instancetype)initWithJsonString:(NSString *)jsonStr {
    return [self JsonModelWithJSON:jsonStr];
}

+ (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDict {
    return [self JsonModelWithDictionary:jsonDict];
}

+ (instancetype)initWithJsonData:(NSData *)jsonData {
    return [self JsonModelWithJSON:jsonData];
}

- (BOOL)updateWithJsonString:(NSString *)jsonStr {
    return [self JsonModelUpdateWithJSON:jsonStr];
}

- (BOOL)updateWithJsonDictionary:(NSDictionary *)jsonDict {
    return [self JsonModelUpdateWithDictionary:jsonDict];
}

- (BOOL)updateWithJsonData:(NSData *)jsonData {
    return [self JsonModelUpdateWithJSON:jsonData];
}

- (NSString *)transformToJson {
    return [self JsonModelToJSONString];
}

- (id)transformToObject {
    return [self JsonModelToJSONObject];
}

#pragma mark - 设置类方法
+ (NSArray *)setPropertyBlacklist {
    return nil;
}

+ (NSArray *)setPropertyWhitelist {
    return nil;
}

+ (NSDictionary *)setDefaultValueMap {
    return nil;
}

+ (NSDictionary *)setCustomPropertyMap {
    return nil;
}

+ (NSDictionary *)setContainerPropertyClassMap {
    return nil;
}

- (BOOL)handleCustomTransformFromDictionary:(NSDictionary *)jsonDict {
    return YES;
}

- (BOOL)handleCustomTransformToDictionary:(NSMutableDictionary *)jsonDict {
    return YES;
}

#pragma mark - 缓存对象
//归档
+ (BOOL)archiveObjectToCache:(id)obj toFile:(NSString *)path {
    return [NSKeyedArchiver archiveRootObject:obj toFile:path];
}
//删除
+ (BOOL)removeObjectFromCache:(NSString *)path {
    return [self archiveObjectToCache:nil toFile:path];
}
//解档
+ (id)unarchiveObjectFromCache:(NSString *)path {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (BOOL)setInstance {
    NSString *pathKey = [[NSString cachesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kendat",
                                                                                 [self.class getInstanceKey]]];
    return [self.class archiveObjectToCache:self toFile:pathKey];
}

+ (instancetype)getInstance {
    NSString *pathKey = [[NSString cachesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kendat",
                                                                                 [self getInstanceKey]]];
    return [self unarchiveObjectFromCache:pathKey];
}

+ (void)removeInstance {
    NSString *pathKey = [[NSString cachesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kendat",
                                                                                 [self getInstanceKey]]];
    [self removeObjectFromCache:pathKey];
}

+ (NSString *)getInstanceKey {
    return [NSString stringWithFormat:@"%@", [self className]];
}

/**
 *  根据key值，设置value，这个值如果有设置的映射就两者均可以设置
 */
- (void)setValue:(id)value forKey:(NSString *)key {
    NSDictionary *keyMap = [[self class] setCustomPropertyMap];
    __block NSString *realKey = nil;
    
    if ([[keyMap allValues] containsObject:key]) {
        [keyMap enumerateKeysAndObjectsUsingBlock:^(id keyValue, id objValue, BOOL *stop) {
            if ([objValue isEqual:key]) {
                realKey = keyValue;
                *stop = YES;
            }
        }];
    } else {
        realKey = key;
    }
    
    if (realKey) {
        [super setValue:value forKey:realKey];
    }
}

@end
