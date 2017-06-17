//
//  KenPlayItemVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayItemVC.h"
#import "KenPlayDeviceDM.h"

@interface KenPlayItemVC ()

@property (nonatomic, strong) KenPlayDeviceItemDM *deviceDM;

@end

@implementation KenPlayItemVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenPlayDeviceItemDM *)device {
    self = [super init];
    if (self) {
        _deviceDM = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:self.deviceDM.name];
}

@end
