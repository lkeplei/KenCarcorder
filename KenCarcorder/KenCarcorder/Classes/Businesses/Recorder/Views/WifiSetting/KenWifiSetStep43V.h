//
//  KenWifiSetStep43V.h
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KenWifiSetStep4VC;

@interface KenWifiSetStep43V : UIView

- (instancetype)initWithParentVC:(KenWifiSetStep4VC *)parentVC name:(NSString *)name pwd:(NSString *)pwd frame:(CGRect)frame;

- (void)onRecognizerStart;
- (void)onRecognizerEnd:(int)result data:(char *)data dataLen:(int)dataLen;

@end
