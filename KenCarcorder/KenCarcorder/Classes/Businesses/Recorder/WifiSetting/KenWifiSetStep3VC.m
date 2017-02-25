//
//  KenWifiSetStep3VC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep3VC.h"
#import "Masonry.h"

@interface KenWifiSetStep3VC ()

@end

@implementation KenWifiSetStep3VC

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_1_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    UIImageView *top = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_1_top"]];
    [self.contentView addSubview:top];
    
    UILabel *label = [UILabel labelWithTxt:@"第三步 等待自动重启" frame:(CGRect){0,0,top.size}
                                      font:[UIFont appFontSize12] color:[UIColor appLightGrayTextColor]];
    [top addSubview:label];
    
    UILabel *label1 = [UILabel labelWithTxt:@"请查看行车记录仪是否" frame:CGRectZero
                                       font:[UIFont appFontSize17] color:[UIColor appWhiteTextColor]];
    [self.contentView addSubview:label1];
    
    UILabel *label2 = [UILabel labelWithTxt:@"蓝灯常亮" frame:CGRectZero
                                       font:[UIFont appFontSize22] color:[UIColor colorWithHexString:@"#005CAF"]];
    [self.contentView addSubview:label2];
    
    UIImageView *camera = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_3_camera"]];
    [self.contentView addSubview:camera];
    
    UILabel *label3 = [UILabel labelWithTxt:@"蓝灯" frame:CGRectZero
                                       font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
    [camera addSubview:label3];
    
    UILabel *label4 = [UILabel labelWithTxt:@"没有常亮？" frame:CGRectZero
                                       font:[UIFont appFontSize13] color:[UIColor appWhiteTextColor]];
    [self.contentView addSubview:label4];
    
    UIButton *button = [UIButton buttonWithImg:@"蓝灯已常亮" zoomIn:NO image:[UIImage imageNamed:@"wifi_1_btn"]
                                      imagesec:nil target:self action:@selector(confirmBtnClicked)];
    button.titleLabel.font = [UIFont appFontSize15];
    [self.contentView addSubview:button];
    
    //autolayout
    [top mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kKenOffsetY(50));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(top.mas_bottom).offset(kKenOffsetY(94));
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.equalTo(self.contentView.mas_width);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label1.mas_bottom).offset(kKenOffsetY(37));
        make.height.mas_equalTo(24);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.equalTo(self.contentView.mas_width);
    }];
    
    [camera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label2.mas_bottom).offset(kKenOffsetY(90));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
        make.top.equalTo(camera.mas_bottom).offset(kKenOffsetY(-164));
        make.centerX.equalTo(self.contentView.mas_right).offset(kKenOffsetX(-180));
    }];
    
    [label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(camera.mas_bottom).offset(kKenOffsetY(-70));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(20);
        make.width.equalTo(self.contentView.mas_width);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label4.mas_bottom).offset(kKenOffsetY(100));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}

#pragma mark -event
- (void)confirmBtnClicked {
    [self pushViewControllerString:@"KenWifiSetStep4VC" animated:YES];
}

@end
