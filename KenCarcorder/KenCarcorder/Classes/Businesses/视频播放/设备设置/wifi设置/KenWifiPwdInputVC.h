//
//  KenWifiPwdInputVC.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@class KenDeviceDM, KenWifiNodeInfo;

@interface KenWifiPwdInputVC : KenBaseVC

- (instancetype)initWithDevice:(KenDeviceDM *)device wifiNode:(KenWifiNodeInfo *)wifiNode;
    
@end
