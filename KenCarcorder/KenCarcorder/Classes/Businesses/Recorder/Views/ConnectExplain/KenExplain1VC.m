//
//  KenExplain1VC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/7/1.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenExplain1VC.h"

@interface KenExplain1VC ()

@end

@implementation KenExplain1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"记录仪"];
    
    [self initView];
}

#pragma mark - event
- (void)nextStep {
    [self pushViewControllerString:@"KenExplain2VC" animated:YES];
}

#pragma mark - private method
- (void)initView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iCon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_bg1"]];
    iCon.size = CGSizeMake(kKenOffsetX(iCon.width * 2), kKenOffsetY(iCon.height * 2));
    [self.contentView addSubview:iCon];
    
    UILabel *label = [UILabel labelWithTxt:@"记录仪开机状态，并在您的附件" frame:(CGRect){0, iCon.maxY, self.contentView.width, 20}
                                      font:[UIFont appFontSize16] color:[UIColor appMainColor]];
    [self.contentView addSubview:label];
    
    UILabel *label1 = [UILabel labelWithTxt:@"(开机后请耐心等待，直到听到记录仪提示音)"
                                      frame:(CGRect){0, label.maxY + 10, self.contentView.width, 30}
                                       font:[UIFont appFontSize14] color:[UIColor colorWithHexString:@"#6BF2E5"]];
    [self.contentView addSubview:label1];
    
    UIButton *nextBtn = [UIButton buttonWithImg:@"下一步" zoomIn:YES image:nil imagesec:nil target:self action:@selector(nextStep)];
    nextBtn.frame = (CGRect){60, label1.maxY + 20, self.contentView.width - 120, 44};
    [nextBtn setTitleColor:[UIColor appMainColor] forState:UIControlStateNormal];
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 4;
    nextBtn.layer.borderColor = [UIColor appMainColor].CGColor;
    nextBtn.layer.borderWidth = 0.5;
    [self.contentView addSubview:nextBtn];
}
@end
