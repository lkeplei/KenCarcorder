//
//  NSObject+KenInvoker.m
//
//  Created by Ken.Liu on 16/5/3.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSObject+KenInvoker.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#endif

@interface InvokerPpointer : NSObject

@property (nonatomic) void *pointer;

@end

@implementation InvokerPpointer

@end

static NSLock              *_methodSignatureLock;
static NSMutableDictionary *_methodSignatureCache;

#pragma mark - invoker
@implementation NSObject (KenInvoker)

#pragma mark - public method
- (instancetype)invokeWithSelClassName:(NSString *)selName className:(NSString *)className error:(NSError *__autoreleasing *)error, ... {
    return [self invokeWithSelClass:NSSelectorFromString(selName) className:className error:error];
}

- (instancetype)invocateSelectorWithArgument:(NSString *)target selector:(NSString *)selector argsArr:(NSArray *)argsArr
                                       error:(NSError *__autoreleasing *)error {
    Class targetClass  = NSClassFromString(target);
    id targetInstance  = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    if ([targetClass respondsToSelector:@selector(shareInterface)]) {
        targetInstance = [targetClass performSelector:@selector(shareInterface)];
    } else {
        targetInstance  = [[targetClass alloc] init];
    }
#pragma clang diagnostic pop
    
    if (targetInstance) {
        return [self invocateSelectorWithArgumentError:targetInstance selector:NSSelectorFromString(selector) argsArr:argsArr error:nil];   
    } else {
        return nil;
    }
}

#pragma mark - private method
- (instancetype)invokeWithSelClass:(SEL)selector className:(NSString *)calssName error:(NSError *__autoreleasing *)error, ... {
    va_list argList;
    va_start(argList, error);
    
    Class targetClass  = NSClassFromString(calssName);
    id targetInstance  = [[targetClass alloc] init];
    NSArray* arguments = [self argumentsWithVaList:argList cls:targetClass selector:selector error:error];
    
    va_end(argList);
    
    if (!arguments) {
        return nil;
    }
    
    return [self invocateSelectorWithArgumentError:targetInstance selector:selector argsArr:arguments error:error];
}

/**
 *  获取SEL参数列表
 *
 *  @param argList  参数列表
 *  @param cls      class
 *  @param selector 接口
 *  @param error    错误
 *
 *  @return 参数列表
 */
- (NSArray *)argumentsWithArray:(NSArray *)argList cls:(Class)cls selector:(SEL)selector error:(NSError *__autoreleasing *)error {
    NSMethodSignature *methodSignature = [self methodSignature:cls selector:selector];
    NSString *selName = NSStringFromSelector(selector);
    
    if (!methodSignature) {
        [self generateError:[NSString stringWithFormat:@"unrecognized selector (%@)", selName] error:error];
        return nil;
    }
    
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc] init];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        id value = (i - 2) < argList.count ? argList[i - 2] : nil;
        if (value) {
            [argumentsBoxingArray addObject:value];
        } else {
            [argumentsBoxingArray addObject:[[NSNull alloc] init]];
        }
    }
    
    return [argumentsBoxingArray copy];
}

/**
 *  获取SEL参数列表
 *
 *  @param argList  参数列表
 *  @param cls      class
 *  @param selector 接口
 *  @param error    错误
 *
 *  @return 参数列表
 */
- (NSArray *)argumentsWithVaList:(va_list)argList cls:(Class)cls selector:(SEL)selector
                           error:(NSError *__autoreleasing *)error {
    
    NSMethodSignature *methodSignature = [self methodSignature:cls selector:selector];
    
    NSString *selName = NSStringFromSelector(selector);
    
    if (!methodSignature) {
        [self generateError:[NSString stringWithFormat:@"unrecognized selector (%@)", selName] error:error];
        return nil;
    }
    
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc] init];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define translate_argument_case(_typeString, _type) \
case _typeString: {                                 \
    _type value = va_arg(argList, _type);           \
    [argumentsBoxingArray addObject:@(value)];      \
}                                                   \
break;

                translate_argument_case('c', int)
                translate_argument_case('C', int)
                translate_argument_case('s', int)
                translate_argument_case('S', int)
                translate_argument_case('i', int)
                translate_argument_case('I', unsigned int)
                translate_argument_case('l', long)
                translate_argument_case('L', unsigned long)
                translate_argument_case('q', long long)
                translate_argument_case('Q', unsigned long long)
                translate_argument_case('f', double)
                translate_argument_case('d', double)
                translate_argument_case('B', int)
                
            case ':': {
                SEL value = va_arg(argList, SEL);
                NSString *selValueName = NSStringFromSelector(value);
                [argumentsBoxingArray addObject:selValueName];
            }
                break;
            case '{': {
                NSString *typeString = [self extractStructName:[NSString stringWithUTF8String:argumentType]];
                
#define translate_argument_struct(_type, _methodName)                   \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {        \
    _type val = va_arg(argList, _type);                                 \
    NSValue* value = [NSValue _methodName:val];                         \
    [argumentsBoxingArray addObject:value];                             \
    break;                                                              \
}
                translate_argument_struct(CGRect, valueWithCGRect)
                translate_argument_struct(CGPoint, valueWithCGPoint)
                translate_argument_struct(CGSize, valueWithCGSize)
                translate_argument_struct(NSRange, valueWithRange)
                translate_argument_struct(CGAffineTransform, valueWithCGAffineTransform)
                translate_argument_struct(UIEdgeInsets, valueWithUIEdgeInsets)
                translate_argument_struct(UIOffset, valueWithUIOffset)
                translate_argument_struct(CGVector, valueWithCGVector)
            }
                break;
            case '*':{
                [self generateError:@"unsupported char* argumenst" error:error];
                return nil;
            }
            case '^': {
                void *value = va_arg(argList, void**);
                InvokerPpointer *pointerObj = [[InvokerPpointer alloc] init];
                pointerObj.pointer = value;
                [argumentsBoxingArray addObject:pointerObj];
            }
                break;
            case '#': {
                Class value = va_arg(argList, Class);
                [argumentsBoxingArray addObject:(id)value];
                //xps_generateError(@"unsupported class argumenst",error);
                //return nil;
            }
                break;
            case '@':{
                id value = va_arg(argList, id);
                if (value) {
                    [argumentsBoxingArray addObject:value];
                } else {
                    [argumentsBoxingArray addObject:[[NSNull alloc] init]];
                }
            }
                break;
            default: {
                [self generateError:@"unsupported argumenst" error:error];
                return nil;
            }
        }
    }
    
    return [argumentsBoxingArray copy];
}

/**
 *  接口调用部分
 *
 *  @param target   接口类的实例
 *  @param selector 接口的SEL
 *  @param argsArr  接口参数
 *  @param error    错误
 *
 *  @return 返回selector对应的返回值
 */
- (instancetype)invocateSelectorWithArgumentError:(id)target selector:(SEL)selector argsArr:(NSArray *)argsArr
                                            error:(NSError *__autoreleasing *)error {
    Class cls = [target class];
    NSMethodSignature *methodSignature = [self methodSignature:cls selector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    NSMutableArray *_markArray;
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id valObj = argsArr[i - 2];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
#define invocate_argument_case(_typeString, _type, _selector)    \
case _typeString: {                                         \
    if ([valObj isKindOfClass:[NSString class]] &&  \
        ([valObj isEqualToString:@"YES"] || [valObj isEqualToString:@"NO"] ||   \
         [valObj isEqualToString:@"yes"] || [valObj isEqualToString:@"no"])) {  \
        BOOL value = [valObj boolValue];                       \
        [invocation setArgument:&value atIndex:i];              \
    } else {    \
        _type value = [valObj _selector];                       \
        [invocation setArgument:&value atIndex:i];              \
    }   \
}                                                           \
break;
                invocate_argument_case('c', char, charValue)
                invocate_argument_case('C', unsigned char, unsignedCharValue)
                invocate_argument_case('s', short, shortValue)
                invocate_argument_case('S', unsigned short, unsignedShortValue)
                invocate_argument_case('i', int, intValue)
                invocate_argument_case('I', unsigned int, unsignedIntValue)
                invocate_argument_case('l', long, longValue)
                invocate_argument_case('L', unsigned long, unsignedLongValue)
                invocate_argument_case('q', long long, longLongValue)
//                invocate_argument_case('Q', unsigned long long, unsignedLongLongValue)
                invocate_argument_case('Q', long long, longLongValue)
                invocate_argument_case('f', float, floatValue)
                invocate_argument_case('d', double, doubleValue)
                invocate_argument_case('B', BOOL, boolValue)
            case ':':{
                NSString *selName = valObj;
                SEL selValue = NSSelectorFromString(selName);
                [invocation setArgument:&selValue atIndex:i];
            }
                break;
            case '{':{
                NSString *typeString = [self extractStructName:[NSString stringWithUTF8String:argumentType]];
                NSValue *val = (NSValue *)valObj;
#define invocate_argument_struct(_type, _methodName)                     \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
    _type value = [val _methodName];                                \
    [invocation setArgument:&value atIndex:i];                      \
    break;                                                          \
}
                invocate_argument_struct(CGRect, CGRectValue)
                invocate_argument_struct(CGPoint, CGPointValue)
                invocate_argument_struct(CGSize, CGSizeValue)
                invocate_argument_struct(NSRange, rangeValue)
                invocate_argument_struct(CGAffineTransform, CGAffineTransformValue)
                invocate_argument_struct(UIEdgeInsets, UIEdgeInsetsValue)
                invocate_argument_struct(UIOffset, UIOffsetValue)
                invocate_argument_struct(CGVector, CGVectorValue)
            }
                break;
            case '*':{
                NSCAssert(NO, @"argument boxing wrong,char* is not supported");
            }
                break;
            case '^':{
                InvokerPpointer *value = valObj;
                void *pointer = value.pointer;
                id obj = *((__unsafe_unretained id *)pointer);
                if (!obj) {
                    if (argumentType[1] == '@') {
                        if (!_markArray) {
                            _markArray = [[NSMutableArray alloc] init];
                        }
                        [_markArray addObject:valObj];
                    }
                }
                [invocation setArgument:&pointer atIndex:i];
            }
                break;
            case '#':{
                [invocation setArgument:&valObj atIndex:i];
            }
                break;
            default:{
                if ([valObj isKindOfClass:[NSNull class]]) {
                    [invocation setArgument:(__bridge void * _Nonnull)([NSNull null]) atIndex:i];
                } else {
                    [invocation setArgument:&valObj atIndex:i];
                }
            }
        }
    }
    
    [invocation invoke];
    
    if ([_markArray count] > 0) {
        for (InvokerPpointer *pointerObj in _markArray) {
            void *pointer = pointerObj.pointer;
            id obj = *((__unsafe_unretained id *)pointer);
            if (obj) {
                CFRetain((__bridge CFTypeRef)(obj));
            }
        }
    }
    
    const char *returnType = [methodSignature methodReturnType];
    NSString *selName = NSStringFromSelector(selector);
    if (strncmp(returnType, "v", 1) != 0 ) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            
            if (result == NULL) {
                return nil;
            }
            
            id returnValue;
            if ([selName isEqualToString:@"alloc"] || [selName isEqualToString:@"new"] || [selName isEqualToString:@"copy"] || [selName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            
            return returnValue;
        } else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
                    
#define invocate_return_case(_typeString, _type)   \
case _typeString: {                             \
    _type returnValue;                          \
    [invocation getReturnValue:&returnValue];   \
    return @(returnValue);                      \
}                                               \
break;
                    invocate_return_case('c', char)
                    invocate_return_case('C', unsigned char)
                    invocate_return_case('s', short)
                    invocate_return_case('S', unsigned short)
                    invocate_return_case('i', int)
                    invocate_return_case('I', unsigned int)
                    invocate_return_case('l', long)
                    invocate_return_case('L', unsigned long)
                    invocate_return_case('q', long long)
                    invocate_return_case('Q', unsigned long long)
                    invocate_return_case('f', float)
                    invocate_return_case('d', double)
                    invocate_return_case('B', BOOL)
                    
                case '{': {
                    NSString *typeString = [self extractStructName:[NSString stringWithUTF8String:returnType]];
#define invocate_return_struct(_type)                                                                 \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {                        \
    _type result;                                                                       \
    [invocation getReturnValue:&result];                                                \
    NSValue * returnValue = [NSValue valueWithBytes:&(result) objCType:@encode(_type)]; \
    return returnValue;                                                                 \
}
                    invocate_return_struct(CGRect)
                    invocate_return_struct(CGPoint)
                    invocate_return_struct(CGSize)
                    invocate_return_struct(NSRange)
                    invocate_return_struct(CGAffineTransform)
                    invocate_return_struct(UIEdgeInsets)
                    invocate_return_struct(UIOffset)
                    invocate_return_struct(CGVector)
                }
                    break;
                case '*':
                case '^':
                case '#': {
                    break;
                }
            }
            return nil;
        }
    }
    return nil;
};

- (void)generateError:(NSString *)errorInfo error:(NSError **)error {
    if (error) {
        *error = [NSError errorWithDomain:errorInfo ? errorInfo : @"message send reciver is nil" code:0 userInfo:nil];
    }
}

- (NSString *)extractStructName:(NSString *)typeEncodeString {
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    
    __block int firstVaildIndex = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        char c = (char)[typeEncodeString characterAtIndex:idx];
        if (c == '{' || c == '_') {
            firstVaildIndex++;
        } else {
            *stop = YES;
        }
    }];
    
    return [typeString substringFromIndex:(NSUInteger)firstVaildIndex];
}

- (NSMethodSignature *)methodSignature:(Class)cls selector:(SEL)selector {
    [_methodSignatureLock lock];
    
    if (!_methodSignatureCache) {
        _methodSignatureCache = [[NSMutableDictionary alloc]init];
    }
    
    if (!_methodSignatureCache[cls]) {
        _methodSignatureCache[(id<NSCopying>)cls] = [[NSMutableDictionary alloc] init];
    }
    
    NSString *selName = NSStringFromSelector(selector);
    NSMethodSignature *methodSignature = _methodSignatureCache[cls][selName];
    
    if (!methodSignature) {
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
        if (methodSignature) {
            _methodSignatureCache[cls][selName] = methodSignature;
        } else {
            methodSignature = [cls methodSignatureForSelector:selector];
            if (methodSignature) {
                _methodSignatureCache[cls][selName] = methodSignature;
            }
        }
    }
    
    [_methodSignatureLock unlock];
    
    return methodSignature;
}

@end
