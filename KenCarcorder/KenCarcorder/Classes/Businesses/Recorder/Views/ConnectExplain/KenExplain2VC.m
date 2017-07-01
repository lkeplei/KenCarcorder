//
//  KenExplain2VC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/7/1.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenExplain2VC.h"

@interface KenExplain2VC ()

@end

@implementation KenExplain2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"记录仪"];
    
    [self initView];
}

#pragma mark - event
- (void)nextStep {
    [Async mainAfter:0.5 block:^{
        [self popToRootViewControllerAnimated:NO];
        [SysDelegate.rootVC changToHome];
    }];
    
    if ((UIDevice.iOSVersion >= 10.0)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=WIFI"] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}

#pragma mark - private method
- (void)initView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iCon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_bg2"]];
    iCon.size = CGSizeMake(kKenOffsetX(iCon.width * 2), kKenOffsetY(iCon.height * 2));
    [self.contentView addSubview:iCon];
    
    UILabel *label = [UILabel labelWithTxt:@"在设置中选择七彩云进行连接" frame:(CGRect){0, iCon.maxY + 30, self.contentView.width, 20}
                                      font:[UIFont appFontSize16] color:[UIColor appMainColor]];
    [self.contentView addSubview:label];
    
    UILabel *label1 = [UILabel labelWithTxt:@"(记录仪的默认密码：12345678)"
                                      frame:(CGRect){0, label.maxY + 10, self.contentView.width, 30}
                                       font:[UIFont appFontSize14] color:[UIColor colorWithHexString:@"#6BF2E5"]];
    [self.contentView addSubview:label1];
    
    UIButton *nextBtn = [UIButton buttonWithImg:@"我知道了" zoomIn:YES image:nil imagesec:nil target:self action:@selector(nextStep)];
    nextBtn.frame = (CGRect){60, label1.maxY + 20, self.contentView.width - 120, 44};
    [nextBtn setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 4;
    nextBtn.layer.borderColor = [UIColor appMainColor].CGColor;
    nextBtn.layer.borderWidth = 0.5;
    [self.contentView addSubview:nextBtn];
}
@end
