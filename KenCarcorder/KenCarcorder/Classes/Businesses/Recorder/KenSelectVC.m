//
//  KenSelectVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenSelectVC.h"
#import "Masonry.h"

@interface KenSelectVC ()

@end

@implementation KenSelectVC

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
    [self setLeftNavItemWithImg:[UIImage imageNamed:@"app_back"] selector:@selector(popViewController)];
    
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_bg"]];
    [self.contentView addSubview:bgV];
    
    UIImageView *topV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_top"]];
    [self.contentView addSubview:topV];
    
    //
    UIImageView *item1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_item1"]];
    [self.contentView addSubview:item1];
    
    UILabel *label1 = [UILabel labelWithTxt:@"设置行车记录仪的WiFi加入路由器或手机热点，可以远程访问"
                                      frame:(CGRect){85, 0, item1.width - 120, item1.height}
                                       font:[UIFont appFontSize14] color:[UIColor appBlackTextColor]];
    label1.numberOfLines = 0;
    label1.textAlignment = NSTextAlignmentLeft;
    [item1 addSubview:label1];
    
    [item1 clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenSelectVC" animated:YES];
    }];
    
    //
    UIImageView *item2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_item2"]];
    [self.contentView addSubview:item2];
    
    UILabel *label2 = [UILabel labelWithTxt:@"将行车记录仪加入我的APP，用于远程访问"
                                      frame:(CGRect){85, 0, item2.width - 120, item2.height}
                                       font:[UIFont appFontSize14] color:[UIColor appBlackTextColor]];
    label2.numberOfLines = 0;
    label2.textAlignment = NSTextAlignmentLeft;
    [item2 addSubview:label2];
    
    [item2 clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenSelectVC" animated:YES];
    }];
    
    //
    UIImageView *item3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_item3"]];
    [self.contentView addSubview:item3];
    
    UILabel *label3 = [UILabel labelWithTxt:@"购买七彩云行车记录仪" frame:(CGRect){85, 0, item3.width - 120, item3.height}
                                       font:[UIFont appFontSize14] color:[UIColor appBlackTextColor]];
    label3.textAlignment = NSTextAlignmentLeft;
    [item3 addSubview:label3];
    
    [item3 clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenSelectVC" animated:YES];
    }];
    
    //autolayout
    [item1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topV.mas_bottom).offset(34);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [item2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(item1.mas_bottom).offset(22);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [item3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(item2.mas_bottom).offset(22);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}

@end
