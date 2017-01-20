//
//  UIApplication+KenApplication.m
//  achr
//
//  Created by Ken.Liu on 16/9/27.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIApplication+KenApplication.h"
#import "Weakify.h"
#import "NSString+KenString.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation UIApplication (KenApplication)

+ (void)shakePhone {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)callPhone:(UIViewController *)controller phoneNumber:(NSString *)phone {
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
    UIWebView *callWebview = (UIWebView *)[controller.view viewWithTag:889988];
    if (!callWebview) {
        callWebview =[[UIWebView alloc] init];
        callWebview.tag = 889988;
        [callWebview setHidden:YES];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [controller.view addSubview:callWebview];
    } else {
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    }
}

+ (void)callQQ:(UIViewController *)controller qq:(NSString *)qq {
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", qq]];
    UIWebView *callWebview = (UIWebView *)[controller.view viewWithTag:889999];
    if (!callWebview) {
        callWebview =[[UIWebView alloc] init];
        callWebview.tag = 889999;
        [callWebview setHidden:YES];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [controller.view addSubview:callWebview];
    } else {
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    }
}

+ (NSString *)checkPicturePSWithData:(NSData *)data key:(NSArray *)key {
    if (key == nil || [key count] <= 0) {
        return nil;
    }
    
    NSString *resultKey = nil;
    
    NSInteger length = data.length;
    BOOL backwardsCheck = NO;
    if (length > 2048) {
        length = 1024;
        backwardsCheck = YES;
    }
    
    resultKey = [self checkData:data key:key start:0 end:length];
    if ([NSString isNotEmpty:resultKey]) {
        backwardsCheck = NO;
    }
    
    if (backwardsCheck) {
        resultKey = [self checkData:data key:key start:data.length - 1024 end:data.length];
    }
    
    return resultKey;
}

+ (NSString *)checkPicturePS:(NSString *)path key:(NSArray *)key {
    return [self checkPicturePSWithData:[[NSData alloc] initWithContentsOfMappedFile:path] key:key];
}

#pragma mark - private method
+ (NSString *)checkData:(NSData *)data key:(NSArray *)key start:(NSInteger)start end:(NSInteger)end{
    NSString *resultKey = nil;
    
    for (NSInteger i = 0; i < key.count; i++) {
        NSString *pskey = [key objectAtIndex:i];
        NSInteger length = pskey.length;
        NSInteger index = start;
        while (index + length <= end) {
            NSData *bb = [data subdataWithRange:NSMakeRange(index, 1)];
            char *cc = (char *)[bb bytes];
            NSString *str = [NSString stringWithUTF8String:cc];
            
            if (str.length >= 1) {
                if ([[str substringToIndex:1] isEqualToString:[pskey substringToIndex:1]]) {
                    NSData *bb = [data subdataWithRange:NSMakeRange(index, length)];
                    char *cc = (char *)[bb bytes];
                    NSString *str = [NSString stringWithUTF8String:cc];
                    
                    KenCategoryLog("找到一个 str = %@", str);
                    if ([NSString isNotEmpty:str] && [str.lowercaseString rangeOfString:pskey.lowercaseString].location != NSNotFound) {
                        KenCategoryLog("图片被PS过, pskey = %@ str = %@", pskey, str);
                        return pskey;
                    } else {
                        index += length;
                    }
                } else {
                    index++;
                }
            } else {
                index++;
            }
        }
    }
    
    return resultKey;
}

@end
