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

@interface KenRecorderVC ()

@end

@implementation KenRecorderVC
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"记录仪"];
    
    [self initView];
}

#pragma mark - private mthod
- (void)initView {
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    //远程连接
    UIView *item1V = [[UIView alloc] initWithFrame:(CGRect){20, 115, self.contentView.width - 40, 60}];
    item1V.backgroundColor = [UIColor whiteColor];
    item1V.layer.masksToBounds = YES;
    item1V.layer.borderColor = [UIColor appBlueTextColor].CGColor;
    item1V.layer.borderWidth = 1.5;
    item1V.layer.cornerRadius = 30;
    [self.contentView addSubview:item1V];
    
    UIImageView *item1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_wifi"]];
    item1.center = CGPointMake(item1.width / 2 + 5, item1V.height / 2);
    [item1V addSubview:item1];
    
    UILabel *label1 = [UILabel labelWithTxt:@"远程连接行车记录仪" frame:(CGRect){item1.maxX + 25, 0, item1V.width - 60, item1V.height}
                                       font:[UIFont appFontSize17] color:[UIColor appBlueTextColor]];
    label1.textAlignment = NSTextAlignmentLeft;
    [item1V addSubview:label1];
    
    [item1V clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenSelectVC" animated:YES];
    }];
    
    //直接连接
    UIView *item2V = [[UIView alloc] initWithFrame:(CGRect){20, 195, self.contentView.width - 40, 60}];
    item2V.backgroundColor = [UIColor whiteColor];
    item2V.layer.masksToBounds = YES;
    item2V.layer.borderColor = [UIColor appOrangeTextColor].CGColor;
    item2V.layer.borderWidth = 1.5;
    item2V.layer.cornerRadius = 30;
    [self.contentView addSubview:item2V];
    
    UIImageView *item2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_link"]];
    item2.center = CGPointMake(item1.width / 2 + 5, item1V.height / 2);
    [item2V addSubview:item2];
    
    UILabel *label2 = [UILabel labelWithTxt:@"直接连接行车记录仪" frame:(CGRect){item2.maxX + 25, 0, item2V.width - 60, item2V.height}
                                       font:[UIFont appFontSize17] color:[UIColor appOrangeTextColor]];
    label2.textAlignment = NSTextAlignmentLeft;
    [item2V addSubview:label2];
    
    @weakify(self)
    [item2V clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        NSString *ssid = [KenCarcorder getCurrentSSID];
        if ([NSString isNotEmpty:ssid]) {
            if ([ssid containsString:@"IPCAM_AP_8"] || [ssid containsString:@"七彩云"]) {
                KenMiniVideoVC *videoVC = [[KenMiniVideoVC alloc] init];
                [self pushViewController:videoVC animated:YES];
                [videoVC setDirectConnect];
            } else {
                [KenAlertView showAlertViewWithTitle:@"" contentView:nil message:@"连接之前需要先设置手机WIFI为行车记录仪网络"
                                        buttonTitles:@[@"取消", @"确定"]
                                  buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                                      if (index == 1) {
                                          NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                          if([[UIApplication sharedApplication] canOpenURL:url]) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }
                                      }
                                  }];
            }
        }
    }];
}

@end
