//
//  KenRecorderVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRecorderVC.h"
#import "Masonry.h"
#import "KenAlertView.h"
#import "KenMiniVideoVC.h"

@interface KenRecorderVC ()

@end

@implementation KenRecorderVC
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
    [self setNavTitle:@"记录仪"];
    
    [self pushViewControllerString:@"KenLoginVC" animated:NO];
    
    [self initView];
}

#pragma mark - private mthod
- (void)initView {
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    //远程连接
    UIImageView *item1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_item1"]];
    [self.contentView addSubview:item1];
    
    UILabel *label1 = [UILabel labelWithTxt:@"远程连接行车记录仪" frame:(CGRect){0,0,item1.size}
                                       font:[UIFont appFontSize17] color:[UIColor colorWithHexString:@"#F77278"]];
    [item1 addSubview:label1];
    
    [item1 clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenSelectVC" animated:YES];
    }];
    
    //直接连接
    UIImageView *item2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_item1"]];
    [self.contentView addSubview:item2];
    
    UILabel *label2 = [UILabel labelWithTxt:@"直接连接行车记录仪" frame:(CGRect){0,0,item2.size}
                                       font:[UIFont appFontSize17] color:[UIColor colorWithHexString:@"#22C486"]];
    [item2 addSubview:label2];
    
    @weakify(self)
    [item2 clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        NSString *ssid = [KenCarcorder getCurrentSSID];
        if ([NSString isNotEmpty:ssid]) {
            if ([ssid containsString:@"IPCAM_AP_8"] || [ssid containsString:@"七彩云"]) {
                KenMiniVideoVC *videoVC = [[KenMiniVideoVC alloc] init];
                [self pushViewController:videoVC animated:YES];
                [videoVC setDirectConnect];
            } else {
                //测试先放开
                KenMiniVideoVC *videoVC = [[KenMiniVideoVC alloc] init];
                [self pushViewController:videoVC animated:YES];
                [videoVC setDirectConnect];
                
                return ;
                
                [KenAlertView showAlertViewWithTitle:@"" contentView:nil message:@"连接之前需要先设置手机WIFI为行车记录仪网络"
                                        buttonTitles:@[@"取消", @"确定"]
                                  buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                                      if (index == 1) {
                                          NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                          if([[UIApplication sharedApplication] canOpenURL:url]) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }
                                      }
                                  }];
            }
        }
    }];
    
    //autolayout
    [item1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(164);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];

    [item2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(item1.mas_bottom).offset(28);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}

@end
