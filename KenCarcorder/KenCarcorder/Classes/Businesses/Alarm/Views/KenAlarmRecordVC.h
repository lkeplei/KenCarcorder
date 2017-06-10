//
//  KenAlarmRecordVC.h
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@class KenAlarmItemDM;

@interface KenAlarmRecordVC : KenBaseVC

- (instancetype)initWithDevice:(KenDeviceDM *)device info:(KenAlarmItemDM *)info;

@end
