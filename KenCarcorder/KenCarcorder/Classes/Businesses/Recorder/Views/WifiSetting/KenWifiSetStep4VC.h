//
//  KenWifiSetStep4VC.h
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@interface KenWifiSetStep4VC : KenBaseVC

//event
- (void)inputConfirm:(NSString *)name pwd:(NSString *)pwd;
- (void)nextStep;

@end