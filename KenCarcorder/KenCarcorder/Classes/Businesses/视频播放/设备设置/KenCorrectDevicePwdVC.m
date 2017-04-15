//
//  KenCorrectDevicePwdVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenCorrectDevicePwdVC.h"
#import "KenDeviceDM.h"

@interface KenCorrectDevicePwdVC ()

@property (nonatomic, strong) KenDeviceDM *deviceInfo;

@end

@implementation KenCorrectDevicePwdVC

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
    [self setNavTitle:@"更正密码"];
}

@end
