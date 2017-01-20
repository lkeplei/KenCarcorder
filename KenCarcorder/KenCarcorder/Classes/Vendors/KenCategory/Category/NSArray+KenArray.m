//
//  NSArray+KenArray.m
//  achr
//
//  Created by Ken.Liu on 16/6/30.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSArray+KenArray.h"
#import "NSObject+KenObject.h"

@implementation NSArray (KenArray)

- (NSString *)toJson {
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        jsonString = @"";
    }
    
    return jsonString;
}

+ (instancetype)fromJson:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&err];
    if(err) {
        //NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return array;
}

#pragma mark - safe
- (id)KenObjectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self logWarning:[@"objectAtIndex: array bounds ==>" stringByAppendingFormat:@"index[%ld] >= count[%ld]",(long)index ,
                          (long)[self count]]];
        return nil;
    }
    return [self KenObjectAtIndex:index];
}

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self swizzleMethod:@selector(KenObjectAtIndex:) tarClass:@"__NSArrayI" tarSel:@selector(objectAtIndex:)];
        }
    });
}

@end
