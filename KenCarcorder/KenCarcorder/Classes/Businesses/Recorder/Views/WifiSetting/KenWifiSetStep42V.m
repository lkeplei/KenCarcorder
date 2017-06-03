//
//  KenWifiSetStep42V.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep42V.h"
#import "Masonry.h"
#import "KenWifiSetStep4VC.h"

@interface KenWifiSetStep42V ()

@property (nonatomic, weak) KenWifiSetStep4VC *parentVC;

@end

@implementation KenWifiSetStep42V

- (instancetype)initWithParentVC:(KenWifiSetStep4VC *)parentVC frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _parentVC = parentVC;
        
        [self initView];
    }
    return self;
}

#pragma mark - private method
- (void)initView {
    UILabel *label1 = [UILabel labelWithTxt:@"请将手机靠近行车记录仪" frame:CGRectZero
                                       font:[UIFont appFontSize17] color:[UIColor appWhiteTextColor]];
    [self addSubview:label1];
    
    UIImageView *camera = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_4_camera"]];
    [self addSubview:camera];
    
    UIButton *button = [UIButton buttonWithImg:@"下一步" zoomIn:NO image:[UIImage imageNamed:@"wifi_1_btn"]
                                      imagesec:nil target:_parentVC action:@selector(nextStep)];
    button.titleLabel.font = [UIFont appFontSize15];
    [self addSubview:button];
    
    //autolayout
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kKenOffsetY(213));
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(self.mas_width);
    }];

    [camera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label1.mas_bottom).offset(kKenOffsetY(110));
        make.centerX.equalTo(self.mas_centerX);
    }];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(camera.mas_bottom).offset(kKenOffsetY(60));
        make.centerX.equalTo(self.mas_centerX);
    }];
}

@end
