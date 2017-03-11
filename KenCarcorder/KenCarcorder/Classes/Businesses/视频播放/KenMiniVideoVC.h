//
//  KenMiniVideoVC.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@class KenDeviceDM;

@interface KenMiniVideoVC : KenBaseVC

@property (nonatomic, strong) KenDeviceDM *device;

//设置视频为直连模式
- (void)setDirectConnect;

@end
