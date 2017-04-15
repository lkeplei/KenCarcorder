//
//  KenDeviceChangePwdVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceChangePwdVC.h"
#import "KenDeviceDM.h"

@interface KenDeviceChangePwdVC ()

@property (nonatomic, strong) KenDeviceDM *deviceInfo;

@end

@implementation KenDeviceChangePwdVC

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
    [self setNavTitle:@"修改密码"];
}

@end
