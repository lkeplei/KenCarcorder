//
//  KenDeviceWifiSetVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceWifiSetVC.h"
#import "KenDeviceDM.h"

@interface KenDeviceWifiSetVC ()

@property (nonatomic, strong) KenDeviceDM *deviceInfo;

@end

@implementation KenDeviceWifiSetVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"WIFI设置"];
}

@end
