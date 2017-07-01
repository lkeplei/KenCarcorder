//
//  KenRecorderVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRecorderVC.h"
#import "KenAlertView.h"
#import "KenMiniVideoVC.h"

@implementation KenRecorderVC
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"记录仪"];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *ssid = [KenCarcorder getCurrentSSID];
    if ([NSString isNotEmpty:ssid]) {
        if ([ssid containsString:@"IPCAM_AP_8"] || [ssid containsString:@"七彩云"]) {
            [self pushViewControllerString:@"KenDirectConnectVC" animated:NO];
        } 
    }
}

#pragma mark - event
- (void)nextStep {
    [self pushViewControllerString:@"KenExplain1VC" animated:YES];
}

#pragma mark - private method
- (void)initView {
    UIImageView *iCon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_iCon"]];
    iCon.center = CGPointMake(self.contentView.width / 2, self.contentView.height * 0.26);
    [self.contentView addSubview:iCon];
    
    UILabel *label = [UILabel labelWithTxt:@"您还没有设置记录仪" frame:(CGRect){0, iCon.maxY + 10, self.contentView.width, 30}
                                      font:[UIFont appFontSize16] color:[UIColor appGrayTextColor]];
    [self.contentView addSubview:label];
    
    UILabel *label1 = [UILabel labelWithTxt:@"保持记录仪处于开机状态并在您的附件，您\n可以通过 \"下一步\" 进行设置"
                                      frame:(CGRect){0, label.maxY + 10, self.contentView.width, 50}
                                       font:[UIFont appFontSize14] color:[UIColor appGrayTextColor]];
    label1.numberOfLines = 2;
    [label1 setLineSpacing:7];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label1];
    
    UIButton *nextBtn = [UIButton buttonWithImg:@"下一步" zoomIn:YES image:nil imagesec:nil target:self action:@selector(nextStep)];
    nextBtn.frame = (CGRect){60, self.contentView.height - 100, self.contentView.width - 120, 44};
    [nextBtn setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 4;
    nextBtn.layer.borderColor = [UIColor appMainColor].CGColor;
    nextBtn.layer.borderWidth = 0.5;
    [self.contentView addSubview:nextBtn];
}

@end
