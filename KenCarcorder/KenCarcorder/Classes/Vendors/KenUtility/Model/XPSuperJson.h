//
//  XPSuperJson.h
//  XPSuperJson
//
//  Created by 徐鹏 on 15/11/25.
//  Copyright © 2015年 徐鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class XPSuperJson;

#pragma mark - XPSuperJsonItem
@interface XPSuperJsonItem : NSObject

@property (readonly) char charValue;
@property (readonly) unsigned char unsignedCharValue;
@property (readonly) short shortValue;
@property (readonly) unsigned short unsignedShortValue;
@property (readonly) int intValue;
@property (readonly) unsigned int unsignedIntValue;
@property (readonly) long longValue;
@property (readonly) unsigned long unsignedLongValue;
@property (readonly) long long longLongValue;
@property (readonly) unsigned long long unsignedLongLongValue;
@property (readonly) float floatValue;
@property (readonly) double doubleValue;
@property (readonly) BOOL boolValue;
@property (readonly) NSInteger integerValue NS_AVAILABLE(10_5, 2_0);
@property (readonly) NSUInteger unsignedIntegerValue NS_AVAILABLE(10_5, 2_0);
@property (readonly, copy, nonnull) NSString *stringValue;
@property (readonly, nonnull) NSArray *arrayValue;
@property (readonly, nonnull) NSDictionary *dictionaryValue;
@property (readonly, nonnull) NSDate *dateValue;
@property (readonly, nonnull) NSURL *urlValue;

#pragma mark - XPSuperJsonItem-实现下标访问
- (nonnull XPSuperJsonItem *)objectForKeyedSubscript:(nonnull NSString *)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(nullable XPSuperJsonItem *)obj forKeyedSubscript:(nonnull NSString *)key NS_AVAILABLE(10_8, 6_0);
- (nonnull XPSuperJsonItem *)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(nullable XPSuperJsonItem *)obj atIndexedSubscript:(NSUInteger)idx;

@end

#pragma mark - XPSuperJson
@interface XPSuperJson<KeyType : NSString *, ObjectType : XPSuperJsonItem *> : NSObject

#pragma mark - XPSuperJson-由Json初始化
+ (nonnull instancetype)superJsonWithDictionary:(nonnull NSDictionary *)dictionary;
+ (nonnull instancetype)superJsonWithString:(nonnull NSString *)string;
+ (nonnull instancetype)superJsonWithData:(nonnull NSData *)data;

- (nonnull NSString *)toJson;

#pragma mark - XPSuperJson-设置默认值映射字典，请在解析（访问属性）之前设置
- (void)setDefaultValueMap:(nonnull NSDictionary *)defaultValueMap;

#pragma mark - XPSuperJson-实现下标访问
- (nonnull XPSuperJsonItem *)objectForKeyedSubscript:(nonnull NSString *)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(nullable XPSuperJsonItem *)obj forKeyedSubscript:(nonnull NSString *)key NS_AVAILABLE(10_8, 6_0);

@end
NS_ASSUME_NONNULL_END

