//
//  KenAlarmRecordVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAlarmRecordVC.h"

@interface KenAlarmRecordVC ()

@property (nonatomic, copy) KenDeviceDM *deviceInfo;

@end

@implementation KenAlarmRecordVC
- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        _deviceInfo = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"报警回看"];
}

@end
