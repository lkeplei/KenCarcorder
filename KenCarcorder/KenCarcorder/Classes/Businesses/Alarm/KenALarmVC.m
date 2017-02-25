//
//  KenALarmVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenALarmVC.h"

@interface KenALarmVC ()

@end

@implementation KenALarmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"报警信息"];
    
    UILabel *label = [UILabel labelWithTxt:@"功能暂未开放，静请期待" frame:(CGRect){0,0,self.contentView.size}
                                      font:[UIFont appFontSize17] color:[UIColor appBlackTextColor]];
    [self.contentView addSubview:label];
}

@end
