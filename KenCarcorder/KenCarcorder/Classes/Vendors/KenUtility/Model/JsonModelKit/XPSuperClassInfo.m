//
//  XPSuperClassInfo.m
//  JsonModel
//
//  Created by 徐鹏 on 15/11/5.
//  Copyright © 2015年 徐鹏. All rights reserved.
//

#import "XPSuperClassInfo.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

XPSEncodingType XPSEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return XPSEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return XPSEncodingTypeUnknown;
    
    XPSEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= XPSEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= XPSEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= XPSEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= XPSEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= XPSEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= XPSEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= XPSEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return XPSEncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return XPSEncodingTypeVoid | qualifier;
        case 'B': return XPSEncodingTypeBool | qualifier;
        case 'c': return XPSEncodingTypeInt8 | qualifier;
        case 'C': return XPSEncodingTypeUInt8 | qualifier;
        case 's': return XPSEncodingTypeInt16 | qualifier;
        case 'S': return XPSEncodingTypeUInt16 | qualifier;
        case 'i': return XPSEncodingTypeInt32 | qualifier;
        case 'I': return XPSEncodingTypeUInt32 | qualifier;
        case 'l': return XPSEncodingTypeInt32 | qualifier;
        case 'L': return XPSEncodingTypeUInt32 | qualifier;
        case 'q': return XPSEncodingTypeInt64 | qualifier;
        case 'Q': return XPSEncodingTypeUInt64 | qualifier;
        case 'f': return XPSEncodingTypeFloat | qualifier;
        case 'd': return XPSEncodingTypeDouble | qualifier;
        case 'D': return XPSEncodingTypeLongDouble | qualifier;
        case '#': return XPSEncodingTypeClass | qualifier;
        case ':': return XPSEncodingTypeSEL | qualifier;
        case '*': return XPSEncodingTypeCString | qualifier;
        case '?': return XPSEncodingTypePointer | qualifier;
        case '[': return XPSEncodingTypeCArray | qualifier;
        case '(': return XPSEncodingTypeUnion | qualifier;
        case '{': return XPSEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return XPSEncodingTypeBlock | qualifier;
            else
                return XPSEncodingTypeObject | qualifier;
        } break;
        default: return XPSEncodingTypeUnknown | qualifier;
    }
}

@implementation XPSClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = XPSEncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation XPSClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    self = [super init];
    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            if (argumentType) {
                NSString *type = [NSString stringWithUTF8String:argumentType];
                [argumentTypes addObject:type ? type : @""];
                free(argumentType);
            } else {
                [argumentTypes addObject:@""];
            }
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end

@implementation XPSClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [self init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    XPSEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': {
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = XPSEncodingGetType(attrs[i].value);
                    if (type & XPSEncodingTypeObject) {
                        size_t len = strlen(attrs[i].value);
                        if (len > 3) {
                            char name[len - 2];
                            name[len - 3] = '\0';
                            memcpy(name, attrs[i].value + 2, len - 3);
                            _cls = objc_getClass(name);
                        }
                    }
                }
            } break;
            case 'V': {
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= XPSEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= XPSEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= XPSEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= XPSEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= XPSEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= XPSEncodingTypePropertyWeak;
            } break;
            case 'P': {
                type |= XPSEncodingTypePropertyGarbage;
            } break;
            case 'G': {
                type |= XPSEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'S': {
                type |= XPSEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            default:
                break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = _name;
        }
        if (!_setter) {
            _setter = [NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]];
        }
    }
    return self;
}

@end

@implementation XPSClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];

    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (instancetype)initWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self initWithClass:cls];
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            XPSClassMethodInfo *info = [[XPSClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            XPSClassPropertyInfo *info = [[XPSClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            XPSClassIvarInfo *info = [[XPSClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static OSSpinLock lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = OS_SPINLOCK_INIT;
    });
    OSSpinLockLock(&lock);
    XPSClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    OSSpinLockUnlock(&lock);
    if (!info) {
        info = [[XPSClassInfo alloc] initWithClass:cls];
        if (info) {
            OSSpinLockLock(&lock);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            OSSpinLockUnlock(&lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
