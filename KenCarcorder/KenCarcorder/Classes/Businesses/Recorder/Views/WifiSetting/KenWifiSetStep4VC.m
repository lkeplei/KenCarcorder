//
//  KenWifiSetStep4VC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep4VC.h"
#import "Masonry.h"
#import "KenWifiSetStep41V.h"
#import "KenWifiSetStep42V.h"
#import "KenWifiSetStep43V.h"

@interface KenWifiSetStep4VC ()

@property (nonatomic, strong) KenWifiSetStep41V *step1View;
@property (nonatomic, strong) KenWifiSetStep42V *step2View;
@property (nonatomic, strong) KenWifiSetStep43V *step3View;

@property (nonatomic, strong) NSString *wifiName;
@property (nonatomic, strong) NSString *wifiPwd;

@end

@implementation KenWifiSetStep4VC

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
    
    UILabel *label = [UILabel labelWithTxt:@"第四步 连接无线网" frame:(CGRect){0,0,top.size}
                                      font:[UIFont appFontSize12] color:[UIColor appLightGrayTextColor]];
    [top addSubview:label];
    
    //autolayout
    [top mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kKenOffsetY(50));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.step1View];
}

#pragma mark - event
- (void)inputConfirm:(NSString *)name pwd:(NSString *)pwd {
    self.step1View.hidden = YES;
    [self.contentView addSubview:self.step2View];
    
    _wifiName = name;
    _wifiPwd = pwd;
}

- (void)nextStep {
    self.step2View.hidden = YES;
    [self.contentView addSubview:self.step3View];
}

#pragma mark - getter setter
- (KenWifiSetStep41V *)step1View {
    if (_step1View == nil) {
        _step1View = [[KenWifiSetStep41V alloc] initWithParentVC:self frame:(CGRect){0,0,self.contentView.size}];
    }
    return _step1View;
}

- (KenWifiSetStep42V *)step2View {
    if (_step2View == nil) {
        _step2View = [[KenWifiSetStep42V alloc] initWithParentVC:self frame:(CGRect){0,0,self.contentView.size}];
    }
    return _step2View;
}

- (KenWifiSetStep43V *)step3View {
    if (_step3View == nil) {
        _step3View = [[KenWifiSetStep43V alloc] initWithParentVC:self name:_wifiName pwd:_wifiPwd
                                                           frame:(CGRect){0,0,self.contentView.size}];
    }
    return _step3View;
}

@end
