//
//  KenLoginVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenLoginVC.h"

@interface KenLoginVC ()

@end

@implementation KenLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loginRequest];
}

#pragma mark - event
- (void)loginRequest {
    [[KenServiceManager sharedServiceManager] accountloginWithName:@"13758184061" pwd:@"123456" verCode:@"" start:^{
        
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        
    }];
}

@end
