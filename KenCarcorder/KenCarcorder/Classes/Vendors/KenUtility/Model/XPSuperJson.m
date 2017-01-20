//
//  XPSuperJson.m
//  XPSuperJson
//
//  Created by 徐鹏 on 15/11/25.
//  Copyright © 2015年 徐鹏. All rights reserved.
//

#import "XPSuperJson.h"

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

static force_inline XPSEncodingNSType XPSObjectGetNSType(__unsafe_unretained id value) {
    if (!value) return XPSEncodingTypeNSUnknown;
    if ([value isKindOfClass:[NSMutableString class]]) return XPSEncodingTypeNSMutableString;
    if ([value isKindOfClass:[NSString class]]) return XPSEncodingTypeNSString;
    if ([value isKindOfClass:[NSDecimalNumber class]]) return XPSEncodingTypeNSDecimalNumber;
    if ([value isKindOfClass:[NSNumber class]]) return XPSEncodingTypeNSNumber;
    if ([value isKindOfClass:[NSValue class]]) return XPSEncodingTypeNSValue;
    if ([value isKindOfClass:[NSMutableData class]]) return XPSEncodingTypeNSMutableData;
    if ([value isKindOfClass:[NSData class]]) return XPSEncodingTypeNSData;
    if ([value isKindOfClass:[NSDate class]]) return XPSEncodingTypeNSDate;
    if ([value isKindOfClass:[NSURL class]]) return XPSEncodingTypeNSURL;
    if ([value isKindOfClass:[NSMutableArray class]]) return XPSEncodingTypeNSMutableArray;
    if ([value isKindOfClass:[NSArray class]]) return XPSEncodingTypeNSArray;
    if ([value isKindOfClass:[NSMutableDictionary class]]) return XPSEncodingTypeNSMutableDictionary;
    if ([value isKindOfClass:[NSDictionary class]]) return XPSEncodingTypeNSDictionary;
    if ([value isKindOfClass:[NSMutableSet class]]) return XPSEncodingTypeNSMutableSet;
    if ([value isKindOfClass:[NSSet class]]) return XPSEncodingTypeNSSet;
    return XPSEncodingTypeNSUnknown;
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



@interface XPSuperJsonItem ()

@property (nonatomic) XPSuperJson *superJson;
@property (nonatomic) NSString *key;
@property (nonatomic) XPSEncodingNSType valueType;
@property (nonatomic) XPSEncodingNSType defaultValueType;
@property (nonatomic) id value;
@property (nonatomic) id defaultValue;
@property (nonatomic) NSNumber *numValue;
@property (nonatomic) NSNumber *defaultNumValue;

- (instancetype)initWithJsonValue:(id)value key:(NSString *)key superJson:(XPSuperJson *)superJson;

@end

@interface XPSuperJson ()

@property (nonatomic) NSMutableDictionary *jsonDict;
@property (nonatomic) NSMutableDictionary *defaultValueDict;

- (instancetype)initWithJsonDictionary:(NSDictionary *)dictionary;

@end

@implementation XPSuperJsonItem

- (instancetype)initWithJsonValue:(id)value key:(NSString *)key superJson:(XPSuperJson *)superJson
{
    self             = [super init];
    _superJson       = superJson;
    _key             = key;
    _value           = value;
    _defaultValue    = nil;
    _defaultNumValue = nil;
    _valueType       = XPSObjectGetNSType(_value);
    _numValue        = NSNumberCreateFromID(_value);
    
    if (_key && ![NSString isEmpty:_key]) {
        if ([_superJson.defaultValueDict objectForKey:_key]) {
            _defaultValue     = [_superJson.defaultValueDict objectForKey:_key];
            _defaultNumValue  = NSNumberCreateFromID(_defaultValue);
            _defaultValueType = XPSObjectGetNSType(_defaultValue);
        }
    }
    
    return self;
}

- (char)charValue
{
    if (_numValue) {
        return _numValue.charValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.charValue;
    }

    return ' ';
}

- (unsigned char)unsignedCharValue
{
    if (_numValue) {
        return _numValue.unsignedCharValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.unsignedCharValue;
    }

    return ' ';
}

- (short)shortValue
{
    if (_numValue) {
        return _numValue.shortValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.shortValue;
    }

    return 0;
}

- (unsigned short)unsignedShortValue
{
    if (_numValue) {
        return _numValue.unsignedShortValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.unsignedShortValue;
    }

    return 0;
}

- (int)intValue
{
    if (_numValue) {
        return _numValue.intValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.intValue;
    }

    return 0;
}

- (unsigned int)unsignedIntValue
{
    if (_numValue) {
        return _numValue.unsignedIntValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.unsignedIntValue;
    }

    return 0;
}

- (long)longValue
{
    if (_numValue) {
        return _numValue.longValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.longValue;
    }

    return 0;
}

- (unsigned long)unsignedLongValue
{
    if (_numValue) {
        return _numValue.unsignedLongValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.unsignedLongValue;
    }

    return 0;
}

- (long long)longLongValue
{
    if (_numValue) {
        return _numValue.longLongValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.longLongValue;
    }

    return 0;
}

- (unsigned long long)unsignedLongLongValue
{
    if (_numValue) {
        return _numValue.unsignedLongLongValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.unsignedLongLongValue;
    }

    return 0;
}

- (float)floatValue
{
    if (_numValue) {
        float f = _numValue.floatValue;
        if (isnan(f) || isinf(f)) f = 0;
        return f;
    }
    else if (_defaultNumValue) {
        float f = _defaultNumValue.floatValue;
        if (isnan(f) || isinf(f)) f = 0;
        return f;
    }

    return 0;
}

- (double)doubleValue
{
    if (_numValue) {
        double d = _numValue.doubleValue;
        if (isnan(d) || isinf(d)) d = 0;
        return d;
    }
    else if (_defaultNumValue) {
        double d = _defaultNumValue.doubleValue;
        if (isnan(d) || isinf(d)) d = 0;
        return d;
    }

    return 0;
}

- (BOOL)boolValue
{
    if (_numValue) {
        return _numValue.boolValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.boolValue;
    }

    return NO;
}

- (NSInteger)integerValue
{
    if (_numValue) {
        return _numValue.integerValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.integerValue;
    }

    return 0;
}

- (NSUInteger)unsignedIntegerValue
{
    if (_numValue) {
        return _numValue.unsignedIntegerValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.unsignedIntegerValue;
    }

    return 0;
}

- (NSString *)stringValue
{
    if ((_valueType == XPSEncodingTypeNSString) || (_valueType == XPSEncodingTypeNSMutableString)) {
        return _value;
    }

    if (_numValue) {
        return _numValue.stringValue;
    }
    else if (_defaultNumValue) {
        return _defaultNumValue.stringValue;
    }

    return @"";
}

- (NSArray *)arrayValue
{
    if ((_valueType == XPSEncodingTypeNSArray) || (_valueType == XPSEncodingTypeNSMutableArray)) {
        return _value;
    }
    
    if ((_defaultValueType == XPSEncodingTypeNSArray) || (_defaultValueType == XPSEncodingTypeNSMutableArray)) {
        return _defaultValue;
    }

    return @[];
}

- (NSDictionary *)dictionaryValue
{
    if ((_valueType == XPSEncodingTypeNSDictionary) || (_valueType == XPSEncodingTypeNSMutableDictionary)) {
        return _value;
    }
    
    if ((_defaultValueType == XPSEncodingTypeNSDictionary) || (_defaultValueType == XPSEncodingTypeNSMutableDictionary)) {
        return _defaultValue;
    }

    return @{};
}

- (NSDate *)dateValue
{
    NSDate *result = [NSDate dateWithTimeIntervalSince1970:0];
    if (_valueType == XPSEncodingTypeNSDate) {
        result = _value;
    }
    if ((_valueType == XPSEncodingTypeNSString) || (_valueType == XPSEncodingTypeNSMutableString)) {
        result = NSDateFromString((NSString *)_value);
    }
    if (_defaultValueType == XPSEncodingTypeNSDate) {
        result = _defaultValue;
    }
    if ((_defaultValueType == XPSEncodingTypeNSString) || (_defaultValueType == XPSEncodingTypeNSMutableString)) {
        result = NSDateFromString((NSString *)_defaultValue);
    }
    
    
    return result;
}

- (NSURL *)urlValue
{
    NSURL *result = [NSURL URLWithString:@""];
    if (_valueType == XPSEncodingTypeNSURL) {
        result = _value;
    }
    if ((_valueType == XPSEncodingTypeNSString) || (_valueType == XPSEncodingTypeNSMutableString)) {
        result = [(NSString *)_value toUrl];
    }
    if (_defaultValueType == XPSEncodingTypeNSURL) {
        result = _defaultValue;
    }
    if ((_defaultValueType == XPSEncodingTypeNSString) || (_defaultValueType == XPSEncodingTypeNSMutableString)) {
        result = [(NSString *)_defaultValue toUrl];
    }
    return result;
}

- (nonnull XPSuperJsonItem *)objectForKeyedSubscript:(NSString *)key NS_AVAILABLE(10_8, 6_0)
{
    if ((_valueType == XPSEncodingTypeNSDictionary) || (_valueType == XPSEncodingTypeNSMutableDictionary)) {
        if (_value) {
            NSDictionary *valueDictionary = _value;
            if ([valueDictionary objectForKey:key]) {
                return [[XPSuperJsonItem alloc] initWithJsonValue:valueDictionary[key] key:key superJson:self.superJson];
            }
        }
    }
    
    if ((_defaultValueType == XPSEncodingTypeNSDictionary) || (_defaultValueType == XPSEncodingTypeNSMutableDictionary)) {
        if (_value) {
            NSDictionary *valueDictionary = _defaultValue;
            if ([valueDictionary objectForKey:key]) {
                return [[XPSuperJsonItem alloc] initWithJsonValue:valueDictionary[key] key:key superJson:self.superJson];
            }
        }
    }

    return [[XPSuperJsonItem alloc] init];
}

- (void)setObject:(nullable XPSuperJsonItem *)obj forKeyedSubscript:(NSString *)key NS_AVAILABLE(10_8, 6_0)
{
}

- (nonnull XPSuperJsonItem *)objectAtIndexedSubscript:(NSUInteger)idx
{
    if ((_valueType == XPSEncodingTypeNSArray) || (_valueType == XPSEncodingTypeNSMutableArray)) {
        if (_value) {
            NSArray *valueArray = _value;
            if (idx < valueArray.count) {
                return [[XPSuperJsonItem alloc] initWithJsonValue:valueArray[idx] key:nil superJson:self.superJson];
            }
        }
    }
    
    if ((_defaultValueType == XPSEncodingTypeNSArray) || (_defaultValueType == XPSEncodingTypeNSMutableArray)) {
        if (_value) {
            NSArray *valueArray = _defaultValue;
            if (idx < valueArray.count) {
                return [[XPSuperJsonItem alloc] initWithJsonValue:valueArray[idx] key:nil superJson:self.superJson];
            }
        }
    }

    return [[XPSuperJsonItem alloc] init];
}

- (void)setObject:(nullable XPSuperJsonItem *)obj atIndexedSubscript:(NSUInteger)idx
{
}

@end

@implementation XPSuperJson

+ (nonnull instancetype)superJsonWithDictionary:(nonnull NSDictionary *)dictionary
{
    return [[XPSuperJson alloc] initWithJsonDictionary:dictionary];
}

+ (nonnull instancetype)superJsonWithString:(nonnull NSString *)string
{
    NSDictionary *dic = nil;
    NSData *jsonData = [string dataUsingEncoding : NSUTF8StringEncoding];
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    }
    if (dic) {
        return [[XPSuperJson alloc] initWithJsonDictionary:dic];
    }

    return [[XPSuperJson alloc] initWithJsonDictionary:@{}];
}

+ (nonnull instancetype)superJsonWithData:(nonnull NSData *)data
{
    NSDictionary *dic = nil;
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary *)data;
        return [[XPSuperJson alloc] initWithJsonDictionary:dic];
    }
    
    dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    if (dic) {
        return [[XPSuperJson alloc] initWithJsonDictionary:dic];
    }

    return [[XPSuperJson alloc] initWithJsonDictionary:@{}];
}

- (instancetype)initWithJsonDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    _jsonDict         = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    _defaultValueDict = [NSMutableDictionary dictionary];
    return self;
}

- (void)setDefaultValueMap:(nonnull NSDictionary *)defaultValueMap
{
    [_defaultValueDict addEntriesFromDictionary:defaultValueMap];
}

- (nonnull NSString *)toJson
{
    return [_jsonDict toJson];
}

- (nonnull XPSuperJsonItem *)objectForKeyedSubscript:(NSString *)key NS_AVAILABLE(10_8, 6_0)
{
    if (_jsonDict) {
        if ([_jsonDict objectForKey:key]) {
            return [[XPSuperJsonItem alloc] initWithJsonValue:_jsonDict[key] key:key superJson:self];
        }
    }

    return [[XPSuperJsonItem alloc] init];
}

- (void)setObject:(nullable XPSuperJsonItem *)obj forKeyedSubscript:(NSString *)key NS_AVAILABLE(10_8, 6_0)
{
    if (_jsonDict) {
        [_jsonDict setObject:obj forKey:key];
    }
}

@end