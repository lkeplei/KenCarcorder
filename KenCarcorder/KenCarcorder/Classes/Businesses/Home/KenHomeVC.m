//
//  KenHomeVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHomeVC.h"

@interface KenHomeVC ()

@end

@implementation KenHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"首页"];
    
    [self pushViewControllerString:@"KenLoginVC" animated:NO];
}

@end
