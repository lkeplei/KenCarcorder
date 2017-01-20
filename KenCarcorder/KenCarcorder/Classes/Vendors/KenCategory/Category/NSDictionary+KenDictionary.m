//
//  NSDictionary+KenDictionary.m
//  KenCategory
//
//  Created by Ken.Liu on 2016/11/3.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "NSDictionary+KenDictionary.h"

@implementation NSDictionary (KenDictionary)

+ (instancetype)fromJson:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&err];
    if(err) {
        //NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dict;
}

- (NSString *)toJson {
    NSString *jsonString = nil;
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

@end
