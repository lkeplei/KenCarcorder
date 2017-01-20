//
//  NSObject+JsonModel.m
//  JsonModel
//
//  Created by 徐鹏 on 15/11/5.
//  Copyright © 2015年 徐鹏. All rights reserved.
//

#import "NSObject+JsonModel.h"
#import "XPSuperClassInfo.h"
#import <libkern/OSAtomic.h>
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))

typedef NS_ENUM (NSUInteger, XPSEncodingNSType) {
    XPSEncodingTypeNSUnknown = 0,
    XPSEncodingTypeNSString,
    XPSEncodingTypeNSMutableString,
    XPSEncodingTypeNSValue,
    XPSEncodingTypeNSNumber,
    XPSEncodingTypeNSDecimalNumber,
    XPSEncodingTypeNSData,
    XPSEncodingTypeNSMutableData,
    XPSEncodingTypeNSDate,
    XPSEncodingTypeNSURL,
    XPSEncodingTypeNSArray,
    XPSEncodingTypeNSMutableArray,
    XPSEncodingTypeNSDictionary,
    XPSEncodingTypeNSMutableDictionary,
    XPSEncodingTypeNSSet,
    XPSEncodingTypeNSMutableSet,
};

static force_inline XPSEncodingNSType XPSClassGetNSType(Class cls) {
    if (!cls) return XPSEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return XPSEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return XPSEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return XPSEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return XPSEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return XPSEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return XPSEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return XPSEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return XPSEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return XPSEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return XPSEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return XPSEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return XPSEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return XPSEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return XPSEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return XPSEncodingTypeNSSet;
    return XPSEncodingTypeNSUnknown;
}

static force_inline BOOL XPSEncodingTypeIsCNumber(XPSEncodingType type) {
    switch (type & XPSEncodingTypeMask) {
        case XPSEncodingTypeBool:
        case XPSEncodingTypeInt8:
        case XPSEncodingTypeUInt8:
        case XPSEncodingTypeInt16:
        case XPSEncodingTypeUInt16:
        case XPSEncodingTypeInt32:
        case XPSEncodingTypeUInt32:
        case XPSEncodingTypeInt64:
        case XPSEncodingTypeUInt64:
        case XPSEncodingTypeFloat:
        case XPSEncodingTypeDouble:
        case XPSEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

static force_inline NSNumber *NSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"Y"  :     @(YES),
                @"y"  :     @(YES),
                @"N"  :     @(NO),
                @"n"  :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

static NSDate *NSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^NSDateParseBlock)(NSString *string);
    #define kParserNum 32
    static NSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    time_t t = 0;
                    struct tm tm = {0};
                    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%d %H:%M:%S", &tm);
                    tm.tm_isdst = -1;
                    t = mktime(&tm);
                    if (t >= 0) {
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
                        if (date) return date;
                    }
                    return [formatter2 dateFromString:string];
                }
            };
        }
        
        {
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            blocks[20] = ^(NSString *string) {
                time_t t = 0;
                struct tm tm = {0};
                strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
                tm.tm_isdst = -1;
                t = mktime(&tm);
                if (t >= 0) {
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
                    if (date) return date;
                }
                return [formatter dateFromString:string];
            };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    NSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
    #undef kParserNum
}


static force_inline Class NSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

static force_inline NSDateFormatter *ISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

static force_inline id XPSValueForKeyPath(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths) {
    id value = nil;
    for (NSUInteger i = 0, max = keyPaths.count; i < max; i++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

@interface _JsonModelPropertyMeta : NSObject {
    @public
    NSString *_name;             ///< property's name
    XPSEncodingType _type;        ///< property's type
    XPSEncodingNSType _nsType;    ///< property's Foundation type
    BOOL _isCNumber;             ///< is c number type
    Class _cls;                  ///< property's class, or nil
    Class _genericCls;           ///< container's generic class, or nil if threr's no generic class
    SEL _getter;                 ///< getter, or nil if the instances cannot respond
    SEL _setter;                 ///< setter, or nil if the instances cannot respond
    
    NSString *_mappedToKey;      ///< the key mapped to
    NSArray *_mappedToKeyPath;   ///< the key path mapped to (nil if the name is not key path)
    _JsonModelPropertyMeta *_next; ///< next meta if there are multiple properties mapped to the same key.
}
@end

@implementation _JsonModelPropertyMeta

+ (instancetype)metaWithClassInfo:(XPSClassInfo *)classInfo propertyInfo:(XPSClassPropertyInfo *)propertyInfo generic:(Class)generic {
    _JsonModelPropertyMeta *meta = [self new];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_genericCls = generic;
    if ((meta->_type & XPSEncodingTypeMask) == XPSEncodingTypeObject) {
        meta->_nsType = XPSClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = XPSEncodingTypeIsCNumber(meta->_type);
    }
    meta->_cls = propertyInfo.cls;
    if (propertyInfo.getter) {
        SEL sel = NSSelectorFromString(propertyInfo.getter);
        if ([classInfo.cls instancesRespondToSelector:sel]) {
            meta->_getter = sel;
        }
    }
    if (propertyInfo.setter) {
        SEL sel = NSSelectorFromString(propertyInfo.setter);
        if ([classInfo.cls instancesRespondToSelector:sel]) {
            meta->_setter = sel;
        }
    }
    return meta;
}
@end


@interface _JsonModelMeta : NSObject {
    @public
    NSDictionary *_mapper;
    NSArray *_allPropertyMetas;
    NSArray *_keyPathPropertyMetas;
    NSUInteger _keyMappedCount;
    XPSEncodingNSType _nsType;
    
    BOOL _hasCustomTransformFromDictonary;
    BOOL _hasCustomTransformToDictionary;
}
@end

@implementation _JsonModelMeta

- (instancetype)initWithClass:(Class)cls {
    XPSClassInfo *classInfo = [XPSClassInfo classInfoWithClass:cls];
    if (!classInfo) return nil;
    self = [super init];

    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *properties = [(id<JsonModel>)cls modelPropertyBlacklist];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }

    NSSet *whitelist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *properties = [(id<JsonModel>)cls modelPropertyWhitelist];
        if (properties) {
            whitelist = [NSSet setWithArray:properties];
        }
    }

    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<JsonModel>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *tmp = genericMapper.mutableCopy;
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![key isKindOfClass:[NSString class]]) return;
                Class meta = object_getClass(obj);
                if (!meta) return;
                if (class_isMetaClass(meta)) {
                    tmp[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        tmp[key] = cls;
                    }
                }
            }];
            genericMapper = tmp;
        }
    }
    
    NSMutableDictionary *allPropertyMetas = [NSMutableDictionary new];
    XPSClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        for (XPSClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            if (whitelist && ![whitelist containsObject:propertyInfo.name]) continue;
            _JsonModelPropertyMeta *meta = [_JsonModelPropertyMeta metaWithClassInfo:classInfo
                                                                    propertyInfo:propertyInfo
                                                                         generic:genericMapper[propertyInfo.name]];
            if (!meta || !meta->_name) continue;
            if (!meta->_getter && !meta->_setter) continue;
            if (allPropertyMetas[meta->_name]) continue;
            allPropertyMetas[meta->_name] = meta;
        }
        curClassInfo = curClassInfo.superClassInfo;
    }
    if (allPropertyMetas.count) _allPropertyMetas = allPropertyMetas.allValues.copy;
    
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    NSMutableArray *keyPathPropertyMetas = [NSMutableArray new];
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id <JsonModel>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL *stop) {
            _JsonModelPropertyMeta *propertyMeta = allPropertyMetas[propertyName];
            if (propertyMeta) {
                NSArray *keyPath = [mappedToKey componentsSeparatedByString:@"."];
                propertyMeta->_mappedToKey = mappedToKey;
                if (keyPath.count > 1) {
                    propertyMeta->_mappedToKeyPath = keyPath;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                [allPropertyMetas removeObjectForKey:propertyName];
                if (mapper[mappedToKey]) {
                    ((_JsonModelPropertyMeta *)mapper[mappedToKey])->_next = propertyMeta;
                } else {
                    mapper[mappedToKey] = propertyMeta;
                }
            }
        }];
    }
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString *name, _JsonModelPropertyMeta *propertyMeta, BOOL *stop) {
        propertyMeta->_mappedToKey = name;
        if (mapper[name]) {
            ((_JsonModelPropertyMeta *)mapper[name])->_next = propertyMeta;
        } else {
            mapper[name] = propertyMeta;
        }
    }];
    
    if (mapper.count) _mapper = mapper;
    if(keyPathPropertyMetas) _keyPathPropertyMetas = keyPathPropertyMetas;
    _keyMappedCount = _allPropertyMetas.count;
    _nsType = XPSClassGetNSType(cls);
    _hasCustomTransformFromDictonary = ([cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)]);
    _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)]);
    
    return self;
}

+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static OSSpinLock lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = OS_SPINLOCK_INIT;
    });
    OSSpinLockLock(&lock);
    _JsonModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    OSSpinLockUnlock(&lock);
    if (!meta) {
        meta = [[_JsonModelMeta alloc] initWithClass:cls];
        if (meta) {
            OSSpinLockLock(&lock);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            OSSpinLockUnlock(&lock);
        }
    }
    return meta;
}

@end

static force_inline NSNumber *ModelCreateNumberFromProperty(__unsafe_unretained id model,
                                                            __unsafe_unretained _JsonModelPropertyMeta *meta) {
    switch (meta->_type & XPSEncodingTypeMask) {
        case XPSEncodingTypeBool: {
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeInt8: {
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        } break;
        case XPSEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } break;
        case XPSEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } break;
        case XPSEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } break;
        default: return nil;
    }
}

static force_inline void ModelSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained NSNumber *num,
                                                  __unsafe_unretained _JsonModelPropertyMeta *meta) {
    switch (meta->_type & XPSEncodingTypeMask) {
        case XPSEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter, num.boolValue);
        } break;
        case XPSEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
        } break;
        case XPSEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
        } break;
        case XPSEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
        } break;
        case XPSEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
        } break;
        case XPSEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, meta->_setter, (int32_t)num.intValue);
        }
        case XPSEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint32_t)num.unsignedIntValue);
        } break;
        case XPSEncodingTypeInt64: {
            ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.longLongValue);
        }
        case XPSEncodingTypeUInt64: {
            ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
        } break;
        case XPSEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, meta->_setter, f);
        } break;
        case XPSEncodingTypeDouble: {
            double d = num.floatValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        } break;
        case XPSEncodingTypeLongDouble: {
            double d = num.floatValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, meta->_setter, (long double)d);
        } break;
        default: break;
    }
}

static void ModelSetValueForProperty(__unsafe_unretained id model,
                                     __unsafe_unretained id value,
                                     __unsafe_unretained _JsonModelPropertyMeta *meta) {
    if (meta->_isCNumber) {
        NSNumber *num = NSNumberCreateFromID(value);
        ModelSetNumberToProperty(model, num, meta);
        if (num) [num class];
    } else if (meta->_nsType) {
        if (value == (id)kCFNull) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case XPSEncodingTypeNSString:
                case XPSEncodingTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == XPSEncodingTypeNSString) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            if ([value isKindOfClass:[NSMutableString class]]) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSString *)value).mutableCopy);
                            }
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == XPSEncodingTypeNSString) ?
                                                                       ((NSNumber *)value).stringValue :
                                                                       ((NSNumber *)value).stringValue.mutableCopy);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, string);
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == XPSEncodingTypeNSString) ?
                                                                       ((NSURL *)value).absoluteString :
                                                                       ((NSURL *)value).absoluteString.mutableCopy);
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == XPSEncodingTypeNSString) ?
                                                                       ((NSAttributedString *)value).string :
                                                                       ((NSAttributedString *)value).string.mutableCopy);
                    }
                } break;
                    
                case XPSEncodingTypeNSValue:
                case XPSEncodingTypeNSNumber:
                case XPSEncodingTypeNSDecimalNumber: {
                    if (meta->_nsType == XPSEncodingTypeNSNumber) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, NSNumberCreateFromID(value));
                    } else if (meta->_nsType == XPSEncodingTypeNSDecimalNumber) {
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        } else if ([value isKindOfClass:[NSString class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil;
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        }
                    } else {
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        }
                    }
                } break;
                    
                case XPSEncodingTypeNSData:
                case XPSEncodingTypeNSMutableData: {
                    if ([value isKindOfClass:[NSData class]]) {
                        if (meta->_nsType == XPSEncodingTypeNSData) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            NSMutableData *data = [value isKindOfClass:[NSMutableData class]] ? value : ((NSData *)value).mutableCopy;
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                        }
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nsType == XPSEncodingTypeNSMutableData) {
                            data = ((NSData *)data).mutableCopy;
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                    }
                } break;
                    
                case XPSEncodingTypeNSDate: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, NSDateFromString(value));
                    }
                } break;
                    
                case XPSEncodingTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, nil);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, [[NSURL alloc] initWithString:str]);
                        }
                    }
                } break;
                    
                case XPSEncodingTypeNSArray:
                case XPSEncodingTypeNSMutableArray: {
                    if (meta->_genericCls) {
                        NSArray *valueArr = nil;
                        if ([value isKindOfClass:[NSArray class]]) valueArr = value;
                        else if ([value isKindOfClass:[NSSet class]]) valueArr = ((NSSet *)value).allObjects;
                        if (valueArr) {
                            NSMutableArray *objectArr = [NSMutableArray new];
                            for (id one in valueArr) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [objectArr addObject:one];
                                } else if ([one isKindOfClass:[NSDictionary class]]) {
                                    NSObject *newOne = [meta->_genericCls new];
                                    [newOne JsonModelUpdateWithDictionary:one];
                                    if (newOne) [objectArr addObject:newOne];
                                }
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, objectArr);
                        }
                    } else {
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nsType == XPSEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               [value isKindOfClass:[NSMutableArray class]] ?
                                                                               value :
                                                                               ((NSArray *)value).mutableCopy);
                            }
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            if (meta->_nsType == XPSEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).allObjects);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               [value isKindOfClass:[NSMutableArray class]] ?
                                                                               ((NSSet *)value).allObjects :
                                                                               ((NSSet *)value).allObjects.mutableCopy);
                            }
                        }
                    }
                } break;
                    
                case XPSEncodingTypeNSDictionary:
                case XPSEncodingTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta->_genericCls) {
                            NSMutableDictionary *dic = [NSMutableDictionary new];
                            [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, NSObject *oneValue, BOOL *stop) {
                                if ([oneValue isKindOfClass:[NSDictionary class]]) {
                                    NSObject *o = [meta->_genericCls new];
                                    [o JsonModelUpdateWithDictionary:(id)oneValue];
                                    if (o) dic[oneKey] = o;
                                }
                            }];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, dic);
                        } else {
                            if (meta->_nsType == XPSEncodingTypeNSDictionary) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               [value isKindOfClass:[NSMutableDictionary class]] ?
                                                                               value :
                                                                               ((NSDictionary *)value).mutableCopy);
                            }
                        }
                    }
                } break;
                    
                case XPSEncodingTypeNSSet:
                case XPSEncodingTypeNSMutableSet: {
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) valueSet = [NSMutableSet setWithArray:value];
                    else if ([value isKindOfClass:[NSSet class]]) valueSet = ((NSSet *)value);
                    
                    if (meta->_genericCls) {
                        NSMutableSet *set = [NSMutableSet new];
                        for (id one in valueSet) {
                            if ([one isKindOfClass:meta->_genericCls]) {
                                [set addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                NSObject *newOne = [meta->_genericCls new];
                                [newOne JsonModelUpdateWithDictionary:one];
                                if (newOne) [set addObject:newOne];
                            }
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, valueSet);
                    } else {
                        if (meta->_nsType == XPSEncodingTypeNSSet) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, valueSet);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           [valueSet isKindOfClass:[NSMutableSet class]] ?
                                                                           valueSet :
                                                                           ((NSSet *)valueSet).mutableCopy);
                        }
                    }
                } break;
                    
                default: break;
            }
        }
    } else {
        BOOL isNull = (value == (id)kCFNull);
        switch (meta->_type & XPSEncodingTypeMask) {
            case XPSEncodingTypeObject: {
                if (isNull) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
                }
                else if ([value isKindOfClass:meta->_cls]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                }
                else if ([value isKindOfClass:[NSDictionary class]]) {
                    NSObject *one = nil;
                    if (meta->_getter) {
                        one = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
                    }
                    if (one) {
                        [one JsonModelUpdateWithDictionary:value];
                    } else {
                        one = [meta->_cls new];
                        if (one) {
                            [one JsonModelUpdateWithDictionary:value];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)one);
                        }
                        else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                        }
                    }
                }
                else if ([value isKindOfClass:[NSArray class]]) {
                    NSObject *one = [meta->_cls new];
                    if (!one) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                    }
                }
                else if ([value isKindOfClass:[NSNumber class]]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                }
                else {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                }
            } break;
                
            case XPSEncodingTypeClass: {
                if (isNull) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)NULL);
                } else {
                    Class cls = ((NSObject *)value).class;
                    if (cls && class_isMetaClass(cls)) {
                        ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)value);
                    }
                }
            } break;
                
            case  XPSEncodingTypeSEL: {
                if (isNull) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)NULL);
                } else if ([value isKindOfClass:[NSString class]]) {
                    SEL sel = NSSelectorFromString(value);
                    if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)sel);
                }
            } break;
                
            case XPSEncodingTypeBlock: {
                if (isNull) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())NULL);
                } else if ([value isKindOfClass:NSBlockClass()]) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())value);
                }
            } break;
                
            case XPSEncodingTypeStruct:
            case XPSEncodingTypeUnion:
            case XPSEncodingTypeCArray: {
                if ([value isKindOfClass:[NSValue class]]) {
                    [model setValue:value forKey:meta->_name];
                }
            } break;
                
            case XPSEncodingTypePointer:
            case XPSEncodingTypeCString: {
                if (isNull) {
                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                } else if ([value isKindOfClass:[NSValue class]]) {
                    void *pointer = ((NSValue *)value).pointerValue;
                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)pointer);
                }
            } break;
                
            default: break;
        }
    }
}


typedef struct {
    void *modelMeta;
    void *model;
    void *dictionary;
} ModelSetContext;

static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    ModelSetContext *context = _context;
    __unsafe_unretained _JsonModelMeta *meta = (__bridge _JsonModelMeta *)(context->modelMeta);
    __unsafe_unretained _JsonModelPropertyMeta *propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)(context->model);
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    };
}

static void ModelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context) {
    ModelSetContext *context = _context;
    __unsafe_unretained NSDictionary *dictionary = (__bridge NSDictionary *)(context->dictionary);
    __unsafe_unretained _JsonModelPropertyMeta *propertyMeta = (__bridge _JsonModelPropertyMeta *)(_propertyMeta);
    if (!propertyMeta->_setter) return;
    id value = nil;
    if (propertyMeta->_mappedToKeyPath) {
        value = (XPSValueForKeyPath(dictionary, propertyMeta->_mappedToKeyPath));
    } else {
        value = [dictionary objectForKey:propertyMeta->_mappedToKey];
    }
    if (value) {
        __unsafe_unretained id model = (__bridge id)(context->model);
        ModelSetValueForProperty(model, value, propertyMeta);
    }
}

static id ModelToJSONObjectRecursive(NSObject *model) {
    if (!model || model == (id)kCFNull) return model;
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    if ([model isKindOfClass:[NSDictionary class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSString *stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!stringKey) return;
            id jsonObj = ModelToJSONObjectRecursive(obj);
            if (!jsonObj) jsonObj = (id)kCFNull;
            newDic[stringKey] = jsonObj;
        }];
        return newDic;
    }
    if ([model isKindOfClass:[NSSet class]]) {
        NSArray *array = ((NSSet *)model).allObjects;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in (NSArray *)model) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]]) return [ISODateFormatter() stringFromDate:(id)model];
    if ([model isKindOfClass:[NSData class]]) return nil;
    
    
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:[model class]];
    if (!modelMeta || modelMeta->_keyMappedCount == 0) return nil;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:64];
    __unsafe_unretained NSMutableDictionary *dic = result;
    [modelMeta->_mapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyMappedKey, _JsonModelPropertyMeta *propertyMeta, BOOL *stop) {
        if (!propertyMeta->_getter) return;
        
        id value = nil;
        if (propertyMeta->_isCNumber) {
            value = ModelCreateNumberFromProperty(model, propertyMeta);
        } else if (propertyMeta->_nsType) {
            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
            value = ModelToJSONObjectRecursive(v);
        } else {
            switch (propertyMeta->_type & XPSEncodingTypeMask) {
                case XPSEncodingTypeObject: {
                    id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = ModelToJSONObjectRecursive(v);
                    if (value == (id)kCFNull) value = nil;
                } break;
                case XPSEncodingTypeClass: {
                    Class v = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromClass(v) : nil;
                } break;
                case XPSEncodingTypeSEL: {
                    SEL v = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromSelector(v) : nil;
                } break;
                default: break;
            }
        }
        if (!value) return;
        
        if (propertyMeta->_mappedToKeyPath) {
            NSMutableDictionary *superDic = dic;
            NSMutableDictionary *subDic = nil;
            for (NSUInteger i = 0, max = propertyMeta->_mappedToKeyPath.count; i < max; i++) {
                NSString *key = propertyMeta->_mappedToKeyPath[i];
                if (i + 1 == max) {
                    if (!superDic[key]) superDic[key] = value;
                    break;
                }
                
                subDic = superDic[key];
                if (subDic) {
                    if ([subDic isKindOfClass:[NSDictionary class]]) {
                        if (![subDic isKindOfClass:[NSMutableDictionary class]]) {
                            subDic = subDic.mutableCopy;
                            superDic[key] = subDic;
                        }
                    } else {
                        break;
                    }
                } else {
                    subDic = [NSMutableDictionary new];
                    superDic[key] = subDic;
                }
                superDic = subDic;
                subDic = nil;
            }
        } else {
            if (!dic[propertyMeta->_mappedToKey]) {
                dic[propertyMeta->_mappedToKey] = value;
            }
        }
    }];
    
    if (modelMeta->_hasCustomTransformToDictionary) {
        BOOL suc = [((id<JsonModel>)model) modelCustomTransformToDictionary:dic];
        if (!suc) return nil;
    }
    return result;
}



@implementation NSObject (JsonModel)

+ (instancetype)JsonModelWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSObject *one = [self new];
    [one JsonModelUpdateWithJSON:json];
    return one;
}

+ (instancetype)JsonModelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    NSObject *one = [self new];
    [one JsonModelUpdateWithDictionary:dictionary];
    return one;
}

- (BOOL)JsonModelUpdateWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return NO;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return [self JsonModelUpdateWithDictionary:dic];
}

- (BOOL)JsonModelSetWithPropertyMetaArray:(NSDictionary *)dic
{
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta->_keyMappedCount == 0) return NO;
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)(modelMeta);
    context.model = (__bridge void *)(self);
    context.dictionary = (__bridge void *)(dic);
    
    if (modelMeta->_keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef)dic)) {
        CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction, &context);
        if (modelMeta->_keyPathPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
    } else {
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas,
                             CFRangeMake(0, modelMeta->_keyMappedCount),
                             ModelSetWithPropertyMetaArrayFunction,
                             &context);
    }
    
    if (modelMeta->_hasCustomTransformFromDictonary) {
        return [((id<JsonModel>)self) modelCustomTransformFromDictionary:dic];
    }
    
    return YES;
}

- (BOOL)JsonModelUpdateWithDictionary:(NSDictionary *)dic {
    if ([self.class respondsToSelector:@selector(modelDefaultValuesMapper)]) {
        NSDictionary *defaultValueMapper = [(id <JsonModel>)self.class modelDefaultValuesMapper];
        NSDictionary *mapDic = nil;
        if ([self.class respondsToSelector:@selector(modelCustomPropertyMapper)]) {
            mapDic = [(id <JsonModel>)self.class modelCustomPropertyMapper];
        }
        
        if ((!defaultValueMapper || defaultValueMapper == (id)kCFNull)) {
            if (!dic || dic == (id)kCFNull) return NO;
            if (![dic isKindOfClass:[NSDictionary class]]) return NO;
            
            return [self JsonModelSetWithPropertyMetaArray:dic];
        }
        else {
            if ((!dic || dic == (id)kCFNull) || ![dic isKindOfClass:[NSDictionary class]]) {
                if (mapDic) {
                    NSMutableDictionary *transDic = [NSMutableDictionary dictionary];
                    [defaultValueMapper enumerateKeysAndObjectsUsingBlock:^(NSString *defName, id defValue, BOOL *stop) {
                        if (mapDic[defName]) {
                            NSString *orgName = mapDic[defName];
                            id value = [transDic objectForKey:orgName];
                            if (!value || (value == (id)kCFNull)) {
                                [transDic setObject:defValue forKey:orgName];
                            }
                        }
                        else {
                            id value = [transDic objectForKey:defName];
                            if (!value || (value == (id)kCFNull)) {
                                [transDic setObject:defValue forKey:defName];
                            }
                        }
                    }];
                    return [self JsonModelSetWithPropertyMetaArray:transDic];
                }
                else {
                    return [self JsonModelSetWithPropertyMetaArray:defaultValueMapper];
                }
            }
            else {
                NSMutableDictionary *transDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [defaultValueMapper enumerateKeysAndObjectsUsingBlock:^(NSString *defName, id defValue, BOOL *stop) {
                    if (mapDic) {
                        if (mapDic[defName]) {
                            NSString *orgName = mapDic[defName];
                            id value = [transDic objectForKey:orgName];
                            if (!value || (value == (id)kCFNull)) {
                                [transDic setObject:defValue forKey:orgName];
                            }
                        }
                        else {
                            id value = [transDic objectForKey:defName];
                            if (!value || (value == (id)kCFNull)) {
                                [transDic setObject:defValue forKey:defName];
                            }
                        }
                    }
                    else {
                        id value = [transDic objectForKey:defName];
                        if (!value || (value == (id)kCFNull)) {
                            [transDic setObject:defValue forKey:defName];
                        }
                    }
                }];
                return [self JsonModelSetWithPropertyMetaArray:transDic];
            }
        }
    }
    else {
        if (!dic || dic == (id)kCFNull) return NO;
        if (![dic isKindOfClass:[NSDictionary class]]) return NO;
        
        return [self JsonModelSetWithPropertyMetaArray:dic];
    }
}

- (id)JsonModelToJSONObject {
    id jsonObject = ModelToJSONObjectRecursive(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) return jsonObject;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) return jsonObject;
    return nil;
}

- (NSData *)JsonModelToJSONData {
    id jsonObject = [self JsonModelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)JsonModelToJSONString {
    NSData *jsonData = [self JsonModelToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id)JsonModelCopy{
    if (self == (id)kCFNull) return self;
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self copy];
    
    NSObject *one = [self.class new];
    [modelMeta->_allPropertyMetas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
    }];
    for (_JsonModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            switch (propertyMeta->_type & XPSEncodingTypeMask) {
                case XPSEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeInt8:
                case XPSEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeInt16:
                case XPSEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeInt32:
                case XPSEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeInt64:
                case XPSEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XPSEncodingTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                default: break;
            }
        } else {
            switch (propertyMeta->_type & XPSEncodingTypeMask) {
                case XPSEncodingTypeObject:
                case XPSEncodingTypeClass:
                case XPSEncodingTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case XPSEncodingTypeSEL:
                case XPSEncodingTypePointer:
                case XPSEncodingTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case XPSEncodingTypeStruct:
                case XPSEncodingTypeUnion:
                case XPSEncodingTypeCArray: {
                    NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                    if (value) {
                        [self setValue:value forKey:propertyMeta->_name];
                    }
                } break;
                default: break;
            }
        }
    }
    return one;
}

- (void)JsonModelEncodeWithCoder:(NSCoder *)aCoder {
    if (!aCoder) return;
    if (self == (id)kCFNull) {
        [((id<NSCoding>)self)encodeWithCoder:aCoder];
        return;
    }
    
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) {
        [((id<NSCoding>)self)encodeWithCoder:aCoder];
        return;
    }
    
    for (_JsonModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter) return;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = ModelCreateNumberFromProperty(self, propertyMeta);
            if (value) [aCoder encodeObject:value forKey:propertyMeta->_name];
        } else {
            switch (propertyMeta->_type & XPSEncodingTypeMask) {
                case XPSEncodingTypeObject: {
                    id value = ((id (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value && (propertyMeta->_nsType || [value respondsToSelector:@selector(encodeWithCoder:)])) {
                        [aCoder encodeObject:value forKey:propertyMeta->_name];
                    }
                } break;
                case XPSEncodingTypeSEL: {
                    SEL value = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value) {
                        NSString *str = NSStringFromSelector(value);
                        [aCoder encodeObject:str forKey:propertyMeta->_name];
                    }
                } break;
                case XPSEncodingTypeStruct:
                case XPSEncodingTypeUnion:
                case XPSEncodingTypeCArray: {
                    NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                    [aCoder encodeObject:value forKey:propertyMeta->_name];
                } break;
                    
                default:
                    break;
            }
        }
    }
}

- (id)JsonModelInitWithCoder:(NSCoder *)aDecoder {
    if (!aDecoder) return self;
    if (self == (id)kCFNull) return self;
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return self;
    
    for (_JsonModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            NSValue *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
            if (value) [self setValue:value forKey:propertyMeta->_name];
        } else {
            XPSEncodingType type = propertyMeta->_type & XPSEncodingTypeMask;
            switch (type) {
                case XPSEncodingTypeObject: {
                    id value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyMeta->_setter, value);
                } break;
                case XPSEncodingTypeSEL: {
                    NSString *str = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    if ([str isKindOfClass:[NSString class]]) {
                        SEL sel = NSSelectorFromString(str);
                        ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_setter, sel);
                    }
                } break;
                case XPSEncodingTypeStruct:
                case XPSEncodingTypeUnion:
                case XPSEncodingTypeCArray: {
                    NSValue *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    if (value) [self setValue:value forKey:propertyMeta->_name];
                } break;
                    
                default:
                    break;
            }
        }
    }
    return self;
}

- (NSUInteger)JsonModelHash {
    if (self == (id)kCFNull) return [self hash];
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self hash];
    
    NSUInteger value = 0;
    NSUInteger count = 0;
    for (_JsonModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter) continue;
        value ^= [[self valueForKey:NSStringFromSelector(propertyMeta->_getter)] hash];
        count++;
    }
    if (count == 0) value = (long)((__bridge void *)self);
    return value;
}

- (BOOL)JsonModelIsEqual:(id)model {
    if (self == model) return YES;
    if (![model isMemberOfClass:self.class]) return NO;
    _JsonModelMeta *modelMeta = [_JsonModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self isEqual:model];
    if ([self hash] != [model hash]) return NO;
    
    for (_JsonModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter) continue;
        id this = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id that = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if (this == that) continue;
        if (this == nil || that == nil) return NO;
        if ([this isEqual:that]) continue;
    }
    return YES;
}

@end



@implementation NSArray (JsonModel)

+ (NSArray *)JsonModelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *arr = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        arr = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![arr isKindOfClass:[NSArray class]]) arr = nil;
    }
    return [self JsonModelArrayWithClass:cls array:arr];
}

+ (NSArray *)JsonModelArrayWithClass:(Class)cls array:(NSArray *)arr {
    if (!cls || !arr) return nil;
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dic in arr) {
        if (![dic isKindOfClass:[NSDictionary class]]) continue;
        NSObject *obj = [cls JsonModelWithDictionary:dic];
        if (obj) [result addObject:obj];
    }
    return result;
}

@end


@implementation NSDictionary (JsonModel)

+ (NSDictionary *)JsonModelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return [self JsonModelDictionaryWithClass:cls dictionary:dic];
}

+ (NSDictionary *)JsonModelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic {
    if (!cls || !dic) return nil;
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in dic.allKeys) {
        if (![key isKindOfClass:[NSString class]]) continue;
        NSObject *obj = [cls JsonModelWithDictionary:dic[key]];
        if (obj) result[key] = obj;
    }
    return result;
}

@end
